library dart_fpm.fcgi.requests.request;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'dart:async';

class Request {

  final int requestId;
  final RequestRole role;
  final bool keepAlive;
  final Map<String, String> _params = new Map();
  final StreamController<String> _stdinController = new StreamController();
  final StreamController<String> _dataController = new StreamController();

  Request._ (this.requestId, this.role, this.keepAlive);

  factory Request (FcgiRecord record) {
    if (record.header.type != RecordType.BEGIN_REQUEST) {
      throw new Exception("record must be a begin_request record");
    }
    BeginRequestBody body = record.body;
    return new Request._(record.header.requestId, body.role, body.keepAlive);
  }

  Stream<String> get stdin => _stdinController.stream;
  Stream<String> get data => _dataController.stream;
  Map<String, String> get params => new Map.unmodifiable(_params);

  void addParams (NameValuePairBody body) {
    _params.addAll(body.toMap());
  }

  void addData (FcgiStreamBody body) {
    switch (body.type) {
      case RecordType.STDIN:
        _stdinController.add(body.toString());
        break;
      case RecordType.DATA:
        _dataController.add(body.toString());
        break;
      default:
        throw new Exception("record must be a stdin or data record");
    }
  }

}