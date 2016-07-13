library dart_fpm.fcgi.name_value;

import 'package:dart_fpm/src/bytereader.dart';
import 'package:dart_fpm/src/bytewriter.dart';
import 'dart:convert';

class FcgiNameValuePair {

  final List<int> _name;
  final List<int> _value;

  FcgiNameValuePair._(this._name, this._value);

  FcgiNameValuePair(String name, String value) :
        _name = UTF8.encode(name), _value = UTF8.encode(value);

  String get name => UTF8.decode(_name);

  String get value => UTF8.decode(_value);

  int get _nameLength => _name.length;

  int get _valueLength => _value.length;

  int get contentLength => _getByteLength(_nameLength) + _nameLength +
      _getByteLength(_valueLength) + _valueLength;

  static int _getByteLength (int length) => ByteWriter.isMultiByte(length) ? 4 : 1;

  factory FcgiNameValuePair.fromByteStream (ByteReader bytes) {
    return new FcgiNameValuePair._(bytes.nextBytes(bytes.nextVarByte),
        bytes.nextBytes(bytes.nextVarByte));
  }

  List<int> toByteStream () => new ByteWriter().addVarByte(_nameLength)
      .addVarByte(_valueLength).addBytes(_name).addBytes(_value).takeBytes();

}