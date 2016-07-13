library dart_fpm.fcgiRecordTransformer;

import 'dart:async';
import 'dart:io';
import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytereader.dart';
import 'package:logging/logging.dart';

/// This transformer transforms a basic byte stream (Stream<List<int>>) into a stream of
/// Fast CGI Records
class FcgiRecordTransformer implements StreamTransformer<List<int>, FcgiRecord> {

  StreamController streamController = new StreamController();
  Logger _log = new Logger("FcgiRecordTransformer");

  List<int> buffer = new List();
  List<int> activeRequests = new List();
  FcgiRecordHeader header;

  ///this var holds bytes to skip, if an invalid record type appeared
  int skipBytes = 0;

  @override
  Stream bind(Stream inStream) {
    inStream.listen((List<int> dataChunk) {
      buffer.addAll(dataChunk);
      if (skipBytes != 0 && buffer.length < skipBytes) {
        return;
      }
      var byteReader = new ByteReader(buffer, offset: skipBytes);
      //reset skip bytes
      skipBytes = 0;
      handleDataChunk(byteReader);
      buffer = byteReader.remainingBytes;
    });

    return streamController.stream;
  }

  void handleDataChunk(ByteReader dataChunk) {
    recordLoop:
    do {
      if (header == null) {
        //when reading a new header
        if (!dataChunk.available(FCGI_HEADER_LEN))
          return;

        try {
          header = new FcgiRecordHeader.fromByteStream(dataChunk);
        } on FcgiUnknownTypeRecord catch (record) {
          //unknown record type - skip that body and give to outStream as error!
          streamController.addError(record);

          if (dataChunk.available(record.bodyLength)) {
            dataChunk.skip(record.bodyLength);
            continue;
          }

          //case if data to skip is not completely available
          skipBytes = record.bodyLength;
          return;
        }
      }

      //when reading body of record
      if (!dataChunk.available(header.bodyLength))
        return;


      if (!activeRequests.contains(header.requestId) && header.type != FcgiRecordType.BEGIN_REQUEST) {
        //requestId invalid
        dataChunk.skip(header.bodyLength);
        header = null;
        continue;
      }

      FcgiRecordBody body;

      switch (header.type) {
        case FcgiRecordType.BEGIN_REQUEST:
          try {
            body = new FcgiBeginRequestBody.fromByteStream(dataChunk);
          } on FcgiEndRequestBody catch (error) {
            streamController.addError(new FcgiRecord.generateResponse(header.requestId, error));
            header = null;
            continue recordLoop;
          }
          activeRequests.add(header.requestId);
          break;
        case FcgiRecordType.ABORT_REQUEST:
          body = null;
          break;
        case FcgiRecordType.GET_VALUES:
        case FcgiRecordType.PARAMS:
          body = new FcgiNameValuePairBody.fromByteStream(header, dataChunk);
          break;
        case FcgiRecordType.STDIN:
        case FcgiRecordType.DATA:
        //TODO: add later
          break;
        default:
        // invalid type - ignore record / send to out stream
      }

      //build FcgiRequest
      streamController.add(new FcgiRecord(header, body));
    } while (dataChunk.availableBytes > 0);
  }

}

