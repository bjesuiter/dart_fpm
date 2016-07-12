library dart_fpm.fcgi_enum;

import 'package:enums/enums.dart';
import 'package:dart_fpm/src/fcgi/records/records.dart';

/// Values for type component of FCGI_Header
class FcgiRecordType extends Enum {

  static const FcgiRecordType BEGIN_REQUEST = const FcgiRecordType._(1);
  static const FcgiRecordType ABORT_REQUEST = const FcgiRecordType._(2);
  static const FcgiRecordType END_REQUEST = const FcgiRecordType._(3);
  static const FcgiRecordType PARAMS = const FcgiRecordType._(4);
  static const FcgiRecordType STDIN = const FcgiRecordType._(5);
  static const FcgiRecordType STDOUT = const FcgiRecordType._(6);
  static const FcgiRecordType STDERR = const FcgiRecordType._(7);
  static const FcgiRecordType DATA = const FcgiRecordType._(8);
  static const FcgiRecordType GET_VALUES = const FcgiRecordType._(9);
  static const FcgiRecordType GET_VALUES_RESULT = const FcgiRecordType._(10);
  static const FcgiRecordType UNKNOWN_TYPE = const FcgiRecordType._(11);
  static const FcgiRecordType MAXTYPE = UNKNOWN_TYPE;

  final int value;

  const FcgiRecordType._(this.value);

  static List<FcgiRecordType> get values => Enum.values(FcgiRecordType);

  factory FcgiRecordType.fromValue (int value) {
    if (value == 0 || value > MAXTYPE.value) {
      throw new FcgiUnknownTypeBody(value);
    }
    return values[value - 1];
  }

}

/// Values for role component of FCGI_BeginRequestBody
class FcgiRequestRole extends Enum {

  static const FcgiRequestRole RESPONDER = const FcgiRequestRole._(1);
  static const FcgiRequestRole AUTHORIZER = const FcgiRequestRole._(2);
  static const FcgiRequestRole FILTER = const FcgiRequestRole._(3);

  final int value;

  const FcgiRequestRole._(this.value);

  static List<FcgiRequestRole> get values => Enum.values(FcgiRequestRole);

  factory FcgiRequestRole.fromValue (int value) {
    if (value == 0 || value > FILTER.value) {
      throw new FcgiEndRequestBody(1, FcgiProtocolStatus.UNKNOWN_ROLE);
    }
    return values[value - 1];
  }

}

/// Values for protocolStatus component of FCGI_EndRequestBody
class FcgiProtocolStatus extends Enum {

  static const FcgiProtocolStatus REQUEST_COMPLETE = const FcgiProtocolStatus._(0);
  static const FcgiProtocolStatus CANT_MPX_CONN = const FcgiProtocolStatus._(1);
  static const FcgiProtocolStatus OVERLOADED = const FcgiProtocolStatus._(2);
  static const FcgiProtocolStatus UNKNOWN_ROLE = const FcgiProtocolStatus._(3);

  final int value;

  const FcgiProtocolStatus._(this.value);

  static List<FcgiProtocolStatus> get values => Enum.values(FcgiProtocolStatus);

}