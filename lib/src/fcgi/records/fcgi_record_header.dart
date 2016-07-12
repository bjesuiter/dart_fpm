library dart_fpm.fcgi_record_header;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/fcgi/fcgi_const.dart';
import 'package:dart_fpm/src/bytereader.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class FcgiRecordHeader {

  final int version;
  final FcgiRecordType type;
  final int requestId;
  final int contentLength;
  final int paddingLength;

  FcgiRecordHeader._(this.version, this.type, this.requestId, this.contentLength, this.paddingLength);

  factory FcgiRecordHeader.fromByteStream (ByteReader bytes) {
    var header = new FcgiRecordHeader._(bytes.nextByte,
        new FcgiRecordType.fromValue(bytes.nextByte), bytes.nextShort,
        bytes.nextShort, bytes.nextByte);
    bytes.skip(1);
    return header;
  }

  factory FcgiRecordHeader.generateResponse (int requestId, FcgiRecordBody body) {
    return new FcgiRecordHeader._(FCGI_VERSION_1, body.type, requestId, body.contentLength, (8 - (body.contentLength % 8)) % 8);
  }

  List<int> toByteStream () => new ByteWriter().addByte(version)
      .addByte(type.value).addShort(requestId).addShort(contentLength)
      .addByte(paddingLength).addSpace(1).takeBytes();

}