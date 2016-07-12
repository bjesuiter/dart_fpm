library dart_fpm.fcgi.name_value;

import 'package:dart_fpm/src/bytereader.dart';
import 'package:dart_fpm/src/bytewriter.dart';

class FcgiNameValuePair {

  final List<int> name;
  final List<int> value;

  FcgiNameValuePair(this.name, this.value);

  int get nameLength => name.length;

  int get valueLength => value.length;

  int get contentLength => nameLength + valueLength;

  factory FcgiNameValuePair.fromByteStream (ByteReader bytes) {
    return new FcgiNameValuePair(bytes.nextBytes(bytes.nextVarByte),
        bytes.nextBytes(bytes.nextVarByte));
  }

  List<int> toByteStream () => new ByteWriter().addVarByte(nameLength)
      .addVarByte(valueLength).addBytes(name).addBytes(value).takeBytes();

}