library dart_fpm.fcgi.name_value;

import 'package:dart_fpm/src/bytereader.dart';
import 'package:dart_fpm/src/bytewriter.dart';
import 'dart:convert';

class FcgiNameValuePair {

  final List<int> _name;
  final List<int> _value;
  final int contentLength;

  FcgiNameValuePair._(List<int> name, List<int> value) : _name = name,
        _value = value,
        contentLength = _getByteLength(name.length) + name.length +
        _getByteLength(value.length) + value.length;

  FcgiNameValuePair(String name, String value) :
        this._(UTF8.encode(name), UTF8.encode(value));

  String get name => UTF8.decode(_name);

  String get value => UTF8.decode(_value);

  static int _getByteLength (int length) => ByteWriter.isMultiByte(length) ? 4 : 1;

  factory FcgiNameValuePair.fromByteStream (ByteReader bytes) {
    int nameLength = bytes.nextVarByte;
    int valueLength = bytes.nextVarByte;
    return new FcgiNameValuePair._(bytes.nextBytes(nameLength), bytes.nextBytes(valueLength));
  }

  List<int> toByteStream () => new ByteWriter().addVarByte(name.length)
      .addVarByte(value.length).addBytes(_name).addBytes(_value).takeBytes();

}