library dart_fpm.fcgi.records.stream_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytereader.dart';
import 'dart:convert';

class FcgiStreamBody extends FcgiRecordBody {

  final FcgiRecordType type;
  final List<int> bytes;
  final int contentLength;

  FcgiStreamBody(this.type, List<int> bytes) : this.bytes = new List.from(bytes),
        contentLength = bytes.length;

  FcgiStreamBody.fromString(FcgiRecordType type, String content,
      {Codec<String, List<int>> codec : UTF8}) :
      this(type, codec.encode(content));

  FcgiStreamBody.fromByteStream (FcgiRecordHeader header, ByteReader bytes) :
    this(header.type, bytes.nextBytes(header.contentLength));

  @override
  List<int> toByteStream() => new List.from(bytes);

  @override
  String toString({Codec<String, List<int>> codec : UTF8}) {
    return codec.decode(bytes);
  }


}