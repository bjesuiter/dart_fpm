library dart_fpm.fcgi.records.unknown_type_record;

import 'package:dart_fpm/src/fcgi/fcgi.dart';

class FcgiUnknownTypeRecord extends FcgiRecord {

  final int bodyLength;

  FcgiUnknownTypeRecord(int requestId, FcgiRecordBody body,
      this.bodyLength) :
        super.generateResponse(requestId, body);

}