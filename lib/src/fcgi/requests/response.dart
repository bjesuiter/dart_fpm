library dart_fpm.fcgi.requests.response;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dart_fpm/src/fcgi/fcgi.dart';

typedef void DataFunction(Response, String);

typedef void DoneFunction(Response);

class Response implements StreamSink {
  //TODO: move isolate to response object
  //TODO: move control / data / error ports into response object from connection_handler

  final Request request;

  final ReceivePort _outPort = new ReceivePort();

  SendPort get stdout => _outPort.sendPort;

  final ReceivePort _errorPort = new ReceivePort();

  SendPort get stderr => _errorPort.sendPort;

  ProtocolStatus protocolStatus = ProtocolStatus.REQUEST_COMPLETE;

  int appStatus = 0;
  final List<String> _header = new List();
  bool _headerSent = false;
  final StreamController<String> _output = new StreamController();

  factory Response(Request request, Function onData, Function onError, Function onDone) {
    Response response = new Response._(request);
    response._createListener(onData, onError, onDone);
    return response;
  }

  Response._(this.request) {
    _outPort.listen((data) {
      add(data);
    });

    _errorPort.listen((error) {
      addError(error);
    });
  }

  @override
  Future get done => _output.done;

  FcgiRecord get endRequestRecord =>
      new FcgiRecord.generateResponse(requestId, new EndRequestBody(appStatus, protocolStatus));

  int get requestId => request.requestId;

  @override
  void add(event) {
    _output.add(event);
  }

  @override
  void addError(errorEvent, [StackTrace stackTrace]) {
    _output.addError(errorEvent, stackTrace);
  }

  @override
  Future addStream(Stream stream) => _output.addStream(stream);

  Future close() => _output.close();

  void header(dynamic entry) {
    _header.add(entry.toString());
  }

  void _createListener(DataFunction onData, DataFunction onError, DoneFunction onDone) {
    _output.stream.listen((data) {
      if (!_headerSent) {
        onData(this, "${_header.join("\r\n")}\r\n\r\n");
        _headerSent = true;
      }
      onData(this, data);
    }, onError: (error) {
      onError(this, error);
    }, onDone: () {
      onDone(this);
    }, cancelOnError: false);
  }
}
