library dart_fpm.fcgi_enum;

import 'package:enums/enums.dart';
import 'package:dart_fpm/src/fcgi/records/records.dart';

/// Values for type component of FCGI_Header
class RecordType extends Enum {

  static const RecordType BEGIN_REQUEST = const RecordType._(1);
  static const RecordType ABORT_REQUEST = const RecordType._(2);
  static const RecordType END_REQUEST = const RecordType._(3);
  static const RecordType PARAMS = const RecordType._(4);
  static const RecordType STDIN = const RecordType._(5);
  static const RecordType STDOUT = const RecordType._(6);
  static const RecordType STDERR = const RecordType._(7);
  static const RecordType DATA = const RecordType._(8);
  static const RecordType GET_VALUES = const RecordType._(9);
  static const RecordType GET_VALUES_RESULT = const RecordType._(10);
  static const RecordType UNKNOWN_TYPE = const RecordType._(11);
  static const RecordType MAXTYPE = UNKNOWN_TYPE;

  final int value;

  const RecordType._(this.value);

  static List<RecordType> get values => Enum.values(RecordType);

  factory RecordType.fromValue (int value) {
    if (value == 0 || value > MAXTYPE.value) {
      throw new UnknownTypeBody(value);
    }
    return values[value - 1];
  }

}

/// Values for role component of FCGI_BeginRequestBody
class RequestRole extends Enum {

  static const RequestRole RESPONDER = const RequestRole._(1);
  static const RequestRole AUTHORIZER = const RequestRole._(2);
  static const RequestRole FILTER = const RequestRole._(3);

  final int value;

  const RequestRole._(this.value);

  static List<RequestRole> get values => Enum.values(RequestRole);

  factory RequestRole.fromValue (int value) {
    if (value == 0 || value > FILTER.value) {
      throw new EndRequestBody(1, ProtocolStatus.UNKNOWN_ROLE);
    }
    return values[value - 1];
  }

}

/// Values for protocolStatus component of FCGI_EndRequestBody
class ProtocolStatus extends Enum {

  static const ProtocolStatus REQUEST_COMPLETE = const ProtocolStatus._(0);
  static const ProtocolStatus CANT_MPX_CONN = const ProtocolStatus._(1);
  static const ProtocolStatus OVERLOADED = const ProtocolStatus._(2);
  static const ProtocolStatus UNKNOWN_ROLE = const ProtocolStatus._(3);

  final int value;

  const ProtocolStatus._(this.value);

  static List<ProtocolStatus> get values => Enum.values(ProtocolStatus);

}