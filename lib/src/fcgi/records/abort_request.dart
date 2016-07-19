library dart_fpm.fcgi.records.abort_request_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';

class AbortRequestBody extends FcgiRecordBody {

  final int contentLength = 0;

  @override
  RecordType get type => RecordType.ABORT_REQUEST;

  @override
  String toString() {
    return 'AbortRequestBody{}';
  }

}