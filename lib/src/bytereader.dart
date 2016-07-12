library dart_fpm.byte_reader;

import 'dart:typed_data';

class ByteReader {

  final Uint8List _data;
  int _offset;

  ByteReader (List<int>data, {offset : 0}) :
        _data = new Uint8List.fromList(data),
        _offset = offset;

  int get nextByte => _data.elementAt(_offset++);

  int get nextShort => (nextByte << 8) | nextByte;

  int get nextInt => (nextShort << 16) | nextShort;

  int get nextVarByte => ((_data.elementAt(_offset) >> 7) == 0) ? nextByte : nextInt;

  bool available (int bytes) => (_data.lengthInBytes - _offset) >= bytes;

  void skip (int count) {
    _offset += count;
  }

  List<int> nextBytes (int count) {
    List<int> bytes = _data.sublist(_offset, _offset + count);
    _offset += count;
    return bytes;
  }

}