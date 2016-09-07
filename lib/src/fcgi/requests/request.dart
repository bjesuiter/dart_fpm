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
  String _stdin;
  String _data;

  Request._ (this.requestId, this.role, this.keepAlive);

  factory Request (FcgiRecord record) {
    if (record.header.type != RecordType.BEGIN_REQUEST) {
      throw new Exception("record must be a begin_request record");
    }
    BeginRequestBody body = record.body;
    return new Request._(record.header.requestId, body.role, body.keepAlive);
  }

  String get stdin => _stdin;

  String get data => _data;

  Map<String, String> get params => new Map.unmodifiable(_params);

  void addParams(NameValuePairBody body) {
    _params.addAll(body.toMap());
  }

  void addData(FcgiStreamBody body) {
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

  /// Marks this request object as completed
  Future complete() async {
    Future<String> stdin = _stdinController.stream.join();
    Future<String> data = _dataController.stream.join();
    _stdinController.close();
    _dataController.close();
    _stdin = await stdin;
    _data = await data;
  }

}