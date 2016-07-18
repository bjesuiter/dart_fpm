library dart_fpm.fcgi.records.unknown_type_record;

import 'package:dart_fpm/src/fcgi/fcgi.dart';

class UnknownTypeRecord extends FcgiRecord {

  final int bodyLength;

  UnknownTypeRecord(FcgiRecordBody body,
      this.bodyLength) :
        super.generateResponse(FCGI_NULL_REQUEST_ID, body);

}