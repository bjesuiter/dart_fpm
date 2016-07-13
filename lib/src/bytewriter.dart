library dart_fpm.bytewriter;

import 'dart:io';

class ByteWriter {

  final BytesBuilder _builder;

  ByteWriter () : _builder = new BytesBuilder();

  ByteWriter addByte(int byte) {
    _builder.addByte(byte & 0xFF);
    return this;
  }

  ByteWriter addShort (int short) => addByte(short >> 8).addByte(short);

  ByteWriter addInt (int integer) => addShort(integer >> 16).addShort(integer);

  ByteWriter addVarByte (int value) => isMultiByte(value) ? addInt(value | (1 << 31)) : addByte(value);

  static bool isMultiByte(int value) => value >= 128;

  ByteWriter addSpace (int bytes) => addBytes(new List<int>.filled(bytes, 0));

  ByteWriter addBytes (List<int> bytes) {
    _builder.add(bytes);
    return this;
  }

  List<int> takeBytes() => _builder.takeBytes();

}