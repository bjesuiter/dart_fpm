library dart_fpm.fcgi.records.unknown_type_record;

import 'package:dart_fpm/src/fcgi/fcgi.dart';

class FcgiUnknownTypeRecord extends FcgiRecord {

  final int requestId;
  final int contentLength;
  final int paddingLength;

  FcgiUnknownTypeRecord(int requestId, FcgiRecordBody body,
      this.contentLength, this.paddingLength) :
        super.generateResponse(requestId, body),
        this.requestId = requestId;

}