library dart_fpm.fcgi.records.end_request_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class FcgiEndRequestBody extends FcgiRecordBody {

  final int appStatus;
  final FcgiProtocolStatus protocolStatus;

  FcgiEndRequestBody(this.appStatus, this.protocolStatus);

  FcgiRecordType get type => FcgiRecordType.END_REQUEST;

  @override
  List<int> toByteStream() => new ByteWriter().addInt(appStatus)
      .addByte(protocolStatus.value).addSpace(3).takeBytes();

  @override
  String toString() {
    return 'FcgiEndRequestBody{appStatus: $appStatus, protocolStatus: $protocolStatus}';
  }

}