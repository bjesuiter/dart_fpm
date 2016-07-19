library dart_fpm.fcgi_record_transformer;

import 'dart:async';
import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytereader.dart';
import 'package:logging/logging.dart';

/// This transformer transforms a basic byte stream (Stream<List<int>>) into a stream of
/// Fast CGI Records
class FcgiRecordTransformer implements StreamTransformer<List<int>, FcgiRecord> {

  final StreamController _streamController = new StreamController();
  final Logger _log = new Logger("FcgiRecordTransformer");

  List<int> _buffer = new List();
  List<int> _activeRequests = new List();
  FcgiRecordHeader _header;

  ///this var holds bytes to skip, if an invalid record type appeared
  int _skipBytes = 0;

  @override
  Stream bind(Stream inStream) {
    inStream.listen((List<int> dataChunk) {
      _buffer.addAll(dataChunk);
      if (_skipBytes != 0 && _buffer.length < _skipBytes) {
        return;
      }
      var byteReader = new ByteReader(_buffer, offset: _skipBytes);
      //reset skip bytes
      _skipBytes = 0;
      _handleDataChunk(byteReader);
      _buffer = byteReader.remainingBytes;
    }, onError: _streamController.addError);

    return _streamController.stream;
  }

  void _handleDataChunk(ByteReader dataChunk) {
    recordLoop:
    while (true) {
      if (_header == null) {
        //when reading a new header
        if (!dataChunk.available(FCGI_HEADER_LEN))
          return;

        try {
          _header = new FcgiRecordHeader.fromByteStream(dataChunk);
        } on UnknownTypeRecord catch (record) {
          //unknown record type - skip that body and give to outStream as error!
          _streamController.addError(record);

          if (dataChunk.available(record.bodyLength)) {
            dataChunk.skip(record.bodyLength);
            continue;
          }

          //case if data to skip is not completely available
          _skipBytes = record.bodyLength;
          return;
        }
      }

      //when reading body of record
      if (!dataChunk.available(_header.bodyLength))
        return;


      if (_header.requestId != FCGI_NULL_REQUEST_ID &&
          !_activeRequests.contains(_header.requestId) &&
          _header.type != RecordType.BEGIN_REQUEST) {
        //requestId invalid
        dataChunk.skip(_header.bodyLength);
        _header = null;
        continue;
      }

      FcgiRecordBody body;

      switch (_header.type) {
        case RecordType.BEGIN_REQUEST:
          try {
            body = new BeginRequestBody.fromByteStream(dataChunk);
          } on EndRequestBody catch (error) {
            _streamController.addError(new FcgiRecord.generateResponse(_header.requestId, error));
            _header = null;
            continue recordLoop;
          }
          _activeRequests.add(_header.requestId);
          break;
        case RecordType.ABORT_REQUEST:
          body = new AbortRequestBody();
          break;
        case RecordType.GET_VALUES:
        case RecordType.PARAMS:
          body = new NameValuePairBody.fromByteStream(_header, dataChunk);
          break;
        case RecordType.STDIN:
        case RecordType.DATA:
          body = new FcgiStreamBody.fromByteStream(_header, dataChunk);
          break;
        default:
        // invalid type - ignore record / send to out stream
      }

      dataChunk.skip(_header.paddingLength);

      //build FcgiRequest
      _streamController.add(new FcgiRecord(_header, body));
      _header = null;
    }
  }

}

