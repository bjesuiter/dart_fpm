library dart_fpm.fcgi.records.unknown_type_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class UnknownTypeBody extends FcgiRecordBody {

  final int unknownType;

  UnknownTypeBody(this.unknownType);

  RecordType get type => RecordType.UNKNOWN_TYPE;

  @override
  List<int> toByteStream() => new ByteWriter().addByte(unknownType).addSpace(7)
      .takeBytes();

  @override
  String toString() {
    return 'FcgiUnknownTypeBody{unknownType: $unknownType}';
  }

}