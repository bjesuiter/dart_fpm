library dart_fpm.fcgi.records.record;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class FcgiRecord {

  final FcgiRecordHeader header;
  final FcgiRecordBody body;

  FcgiRecord._(this.header, this.body);

  factory FcgiRecord.generateResponse (int requestId, FcgiRecordBody body) {
    return new FcgiRecord._(new FcgiRecordHeader.generateResponse(requestId, body), body);
  }

  List<int> toByteStream () => new ByteWriter().addBytes(header.toByteStream())
      .addBytes(body.toByteStream()).addSpace(header.paddingLength).takeBytes();

}