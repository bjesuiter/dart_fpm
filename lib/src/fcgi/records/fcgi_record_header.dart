library dart_fpm.fcgi_record_header;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/fcgi/fcgi_const.dart';
import 'package:dart_fpm/src/bytereader.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class FcgiRecordHeader {

  final int version;
  final RecordType type;
  final int requestId;
  final int contentLength;
  final int paddingLength;

  FcgiRecordHeader._(this.version, this.type, this.requestId, this.contentLength, this.paddingLength);

  factory FcgiRecordHeader.fromByteStream (ByteReader bytes) {
    int version = bytes.nextByte;
    int typeValue = bytes.nextByte;
    int requestId = bytes.nextShort;
    int contentLength = bytes.nextShort;
    int paddingLength = bytes.nextByte;
    bytes.skip(1);
    try {
      return new FcgiRecordHeader._(version,
          new RecordType.fromValue(typeValue), requestId, contentLength,
          paddingLength);
    } on UnknownTypeBody catch (body) {
      throw new UnknownTypeRecord(body, contentLength + paddingLength);
    }
  }

  FcgiRecordHeader.generateResponse (int requestId, FcgiRecordBody body) :
    this._(FCGI_VERSION_1, body.type, requestId, body.contentLength,
          (8 - (body.contentLength % 8)) % 8);

  int get bodyLength => contentLength + paddingLength;

  List<int> toByteStream () => new ByteWriter().addByte(version)
      .addByte(type.value).addShort(requestId).addShort(contentLength)
      .addByte(paddingLength).addSpace(1).takeBytes();

  @override
  String toString() {
    return 'FcgiRecordHeader{version: $version, type: $type, requestId: $requestId, contentLength: $contentLength, paddingLength: $paddingLength}';
  }

}