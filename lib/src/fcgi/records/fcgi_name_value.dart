library dart_fpm.fcgi.records.name_value_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytereader.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class FcgiNameValuePairBody extends FcgiRecordBody {

  final FcgiRecordType type;
  final List<FcgiNameValuePair> _entries;

  FcgiNameValuePairBody._(this.type, this._entries);

  int get contentLength => _entries.map((entry) => entry.contentLength).reduce((l1, l2) => l1 + l2);

  factory FcgiNameValuePairBody.fromByteStream (FcgiRecordHeader header, ByteReader bytes) {
    List<FcgiNameValuePair> entries = new List();
    int length = 0;
    while (length < header.contentLength) {
      entries.add(new FcgiNameValuePair.fromByteStream(bytes));
    }
    return new FcgiNameValuePairBody._(header.type, entries);
  }

  @override
  List<int> toByteStream() {
    ByteWriter bytes = new ByteWriter();
    _entries.forEach((entry) => bytes.addBytes(entry.toByteStream()));
    return bytes.takeBytes();
  }

  factory FcgiNameValuePairBody.fromMap (FcgiRecordType type, Map<String, String> map) {
    List<FcgiNameValuePair> entries = new List();
    map.forEach((key, value) {
      entries.add(new FcgiNameValuePair(key, value));
    });
    return new FcgiNameValuePairBody._(type, entries);
  }

  Map<String, String> toMap () {
    Map<String, String> map = new Map();
    _entries.forEach((entry) {
      map[entry.name] = entry.value;
    });
    return map;
  }

}