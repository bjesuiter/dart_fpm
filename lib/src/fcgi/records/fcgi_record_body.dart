library dart_fpm.fcgi.records.body;

import 'package:dart_fpm/src/fcgi/fcgi_enum.dart';

abstract class FcgiRecordBody {

  static List<int> _EMPTY_STREAM = new List<int>.unmodifiable(new List(0));

  int get contentLength => 8;

  RecordType get type;

  List<int> toByteStream() => _EMPTY_STREAM;

  @override
  String toString() {
    return 'FcgiRecordBody{type: $type, contentLength: $contentLength}';
  }

}