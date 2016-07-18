library dart_fpm.fcgi.records.begin_request_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/fcgi/fcgi_const.dart';
import 'package:dart_fpm/src/bytereader.dart';

class BeginRequestBody extends FcgiRecordBody {

  final RequestRole role;
  final int flags;

  BeginRequestBody._(this.role, this.flags);

  bool get keepAlive => flags & FCGI_KEEP_CONN != 0;

  factory BeginRequestBody.fromByteStream (ByteReader bytes) {
    int roleValue = bytes.nextShort;
    int flags = bytes.nextByte;
    bytes.skip(5);
    return new BeginRequestBody._(new RequestRole.fromValue(roleValue),
        flags);
  }

  @override
  RecordType get type => RecordType.BEGIN_REQUEST;

  @override
  String toString() {
    return 'FcgiBeginRequestBody{role: $role, keepAlive: $keepAlive}';
  }
}