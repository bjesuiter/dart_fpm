library dart_fpm.fcgi.name_value;

import 'package:dart_fpm/src/bytereader.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class FcgiNameValuePair {

  final List<int> name;
  final List<int> value;
  final int contentLength;

  FcgiNameValuePair(List<int> name, List<int> value) : this.name = name,
        this.value = value,
        contentLength = _getByteLength(name.length) + name.length +
        _getByteLength(value.length) + value.length;

  static int _getByteLength (int length) => ByteWriter.isMultiByte(length) ? 4 : 1;

  factory FcgiNameValuePair.fromByteStream (ByteReader bytes) {
    int nameLength = bytes.nextVarByte;
    int valueLength = bytes.nextVarByte;
    return new FcgiNameValuePair(bytes.nextBytes(nameLength), bytes.nextBytes(valueLength));
  }

  List<int> toByteStream () => new ByteWriter().addVarByte(name.length)
      .addVarByte(value.length).addBytes(name).addBytes(value).takeBytes();

}