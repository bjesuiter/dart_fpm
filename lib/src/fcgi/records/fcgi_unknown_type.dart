library dart_fpm.fcgi.records.unknown_type_body;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class FcgiUnknownTypeBody extends FcgiRecordBody {

  final int unknownType;

  FcgiUnknownTypeBody(this.unknownType);

  FcgiRecordType get type => FcgiRecordType.UNKNOWN_TYPE;

  @override
  List<int> toByteStream() => new ByteWriter().addByte(unknownType).addSpace(7)
      .takeBytes();

  @override
  String toString() {
    return 'FcgiUnknownTypeBody{unknownType: $unknownType}';
  }

}