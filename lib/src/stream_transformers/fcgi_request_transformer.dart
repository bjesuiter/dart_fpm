library dart_fpm.fcgi_request_transformer;

import 'dart:async';
import '../fcgi/fcgi.dart';

class FcgiRequestTransformer implements StreamTransformer<FcgiRecord, Request> {

  final StreamController<Request> _streamController = new StreamController();
  final StreamSink<FcgiRecord> managementRecords;

  final Map<int, Request> _requests = new Map();

  /// stream sink to handle management records
  FcgiRequestTransformer(this.managementRecords);

  @override
  Stream<Request> bind(Stream<FcgiRecord> stream) {
    stream.listen((record) {
      _handleRecord(record);
    }, onError: _streamController.addError);
    return _streamController.stream;
  }

  void _handleRecord (FcgiRecord record) {
    if (record.header.requestId == FCGI_NULL_REQUEST_ID) {
      managementRecords.add(record);
      return;
    }
    if (!_requests.containsKey(record.header.requestId) && record.header.type != RecordType.BEGIN_REQUEST) {
      _streamController.addError(new RangeError.index(record.header.requestId, _requests.keys));
      return;
    }
    if (record.header.type == RecordType.STDIN && record.body.contentLength == 0) {
      _streamController.add(_requests.remove(record.header.requestId));
      return;
    }
    switch (record.header.type) {
      case RecordType.BEGIN_REQUEST:
        _requests[record.header.requestId] = new Request(record);
        break;
      case RecordType.PARAMS:
        _requests[record.header.requestId].addParams(record.body);
        break;
      case RecordType.STDIN:
      case RecordType.DATA:
        _requests[record.header.requestId].addData(record.body);
        break;
      default:
        _streamController.addError(new RangeError("invalid record type"));
    }
  }
}