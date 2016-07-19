library dart_fpm.connection_handler;

import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:dart_fpm/dart_fpm.dart';
import 'package:logging/logging.dart';

Logger _log = new Logger("dart_fpm.handle_connection");

class ConnectionHandler {
  Socket socket;

  ConnectionHandler(this.socket);

  requestHandler(Request request) {
    var onData = (response, data) {
      socketAdd(new FcgiRecord.generateResponse(
          response.requestId, new FcgiStreamBody.fromString(RecordType.STDOUT, data.toString())));
    };

    var onError = (response, error) {
      socketAdd(new FcgiRecord.generateResponse(
          response.requestId, new FcgiStreamBody.fromString(RecordType.STDERR, error.toString())));
    };

    var onDone = (Response response) {
      socketAdd(new FcgiRecord.generateResponse(response.requestId, new FcgiStreamBody.empty(RecordType.STDOUT)));
      socketAdd(new FcgiRecord.generateResponse(response.requestId, new FcgiStreamBody.empty(RecordType.STDERR)));
      socketAdd(response.endRequestRecord);
      if (!request.keepAlive) {
        socket.close();
      }
    };

    Response response = new Response(request.requestId, onData, onError, onDone);

    //IMPORTANT: SEND CONTENT TYPE OF RETURN FIRST!!!
    response.header("Content-Type: text/plain; encoding=utf-8");
    response.output.add(request.params.toString());

    var scriptPath = request.params["SCRIPT_FILENAME"];

    if (scriptPath.isEmpty) response.output.addError("ScriptPath should not be empty!");

    var file = new File(scriptPath);
    if (!file.existsSync())
      response.output.addError(new FileSystemException("Script not available", scriptPath));

    var commandPort = new ReceivePort()
      ..listen((data) {

      });

    var exitPort = new ReceivePort()
      ..listen((data) {
        return data;
      });

    var errorPort = new ReceivePort()
      ..listen((error) {
        throw error;
      });

    var isolateFuture = Isolate.spawnUri(
        file.uri, [], commandPort.sendPort, onExit: exitPort.sendPort, onError: errorPort.sendPort);

    response.close();
  }

  requestHandler_onError(data) {
    //TODO: check if stream is already closed (SocketException)
    if (data is SocketException) {
      //clean all available things for this requestID
      return;
    }

    if (data is FcgiRecord) {
      int requestId = data.header.requestId;
      if (requestId != FCGI_NULL_REQUEST_ID) {
        socketAdd(new FcgiRecord.generateResponse(requestId, new FcgiStreamBody.empty(RecordType.STDOUT)));
        socketAdd(new FcgiRecord.generateResponse(requestId, new FcgiStreamBody.empty(RecordType.STDERR)));
      }
      socketAdd(data);
    }
  }

  socketAdd(FcgiRecord record) {
    _log.info("<- $record");

    socket.add(record.toByteStream());
  }
}
