library dart_fpm.fcgi.requests.response;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'dart:async';

typedef void DataFunction(Response, String);

typedef void DoneFunction(Response);

class Response {

  final int requestId;
  ProtocolStatus protocolStatus = ProtocolStatus.REQUEST_COMPLETE;
  int appStatus = 0;
  final List<String> _header = new List();
  bool _headerSent = false;
  final StreamController<String> _output = new StreamController();

  Response._(this.requestId);

  factory Response (int requestId, Function onData, Function onError,
      Function onDone) {
    Response response = new Response._(requestId);
    response._createListener(onData, onError, onDone);
    return response;
  }

  void _createListener(DataFunction onData, DataFunction onError,
      DoneFunction onDone) {
    _output.stream.listen((data) {
      if (!_headerSent) {
        onData(this, "${_header.join("\r\n")}\r\n\r\n");
        _headerSent;
      }
      onData(this, data);
    }, onError: (error) {
      onError(this, error);
    }, onDone: () {
      onDone(this);
    },
        cancelOnError: false);
  }

  StreamSink<String> get output => _output;

  void close() {
    _output.close();
  }

  void header(dynamic entry) {
    _header.add(entry.toString());
  }

  FcgiRecord get endRequestRecord =>
      new FcgiRecord.generateResponse(
          requestId, new EndRequestBody(appStatus, protocolStatus));


}