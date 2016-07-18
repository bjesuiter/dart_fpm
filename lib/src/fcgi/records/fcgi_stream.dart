library dart_fpm.fcgi.records.stream_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytereader.dart';
import 'dart:convert';

class FcgiStreamBody extends FcgiRecordBody {

  final RecordType type;
  final List<int> bytes;
  final int contentLength;

  FcgiStreamBody._(this.type, this.bytes, this.contentLength);

  FcgiStreamBody(RecordType type, List<int> bytes) :
        this._(type, new List.from(bytes), bytes.length);

  FcgiStreamBody.empty(RecordType type) :
        this._(type, null, 0);

  FcgiStreamBody.fromString(RecordType type, String content,
      {Codec<String, List<int>> codec : UTF8}) :
      this(type, codec.encode(content));

  FcgiStreamBody.fromByteStream (FcgiRecordHeader header, ByteReader bytes) :
    this(header.type, bytes.nextBytes(header.contentLength));

  @override
  List<int> toByteStream() => bytes == null ? super.toByteStream() : new List.from(bytes);

  @override
  String toString({Codec<String, List<int>> codec : UTF8}) {
    return codec.decode(bytes ?? super.toByteStream());
  }


}