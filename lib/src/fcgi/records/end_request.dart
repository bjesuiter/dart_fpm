library dart_fpm.fcgi.records.end_request_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class EndRequestBody extends FcgiRecordBody {

  final int appStatus;
  final ProtocolStatus protocolStatus;

  EndRequestBody(this.appStatus, this.protocolStatus);

  RecordType get type => RecordType.END_REQUEST;

  @override
  List<int> toByteStream() => new ByteWriter().addInt(appStatus)
      .addByte(protocolStatus.value).addSpace(3).takeBytes();

  @override
  String toString() {
    return 'FcgiEndRequestBody{appStatus: $appStatus, protocolStatus: $protocolStatus}';
  }

}