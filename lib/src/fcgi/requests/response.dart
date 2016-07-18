library dart_fpm.fcgi.requests.response;

import 'package:dart_fpm/src/fcgi/fcgi.dart';
import 'dart:async';

class Response {

  final int requestId;
  ProtocolStatus protocolStatus = ProtocolStatus.REQUEST_COMPLETE;
  int appStatus = 0;
  final Map<String, String> header = new Map();
  final StreamController<String> _output = new StreamController();

  Response._(this.requestId);

  factory Response (int requestId, Function onData, Function onError,
      Function onDone) {
    Response response = new Response._(requestId);
    response._output.stream.listen(onData, onError: onError, onDone: onDone,
        cancelOnError: false);
    return response;
  }

  StreamSink<String> get output  => _output;

  void close () {
    _output.close();
  }

}