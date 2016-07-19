library dart_fpm.connection_handler;

import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:dart_fpm/dart_fpm.dart';
import 'package:logging/logging.dart';

Logger _log = new Logger("dart_fpm.handle_connection");

class ConnectionHandler {

  static List<Socket> sockets;
  Map<int, Isolate> isolates;

  Socket socket;

  ConnectionHandler(this.socket) {
    if (!sockets.contains(socket)) {
      sockets.add(socket);
    }
  }

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

    Response response = new Response(request, onData, onError, onDone);

    //IMPORTANT: SEND CONTENT TYPE OF RETURN FIRST!!!
    response.header("Content-Type: text/plain; encoding=utf-8");
    response.add(request.params.toString());

    var scriptPath = request.params["SCRIPT_FILENAME"];

    if (scriptPath.isEmpty) response.addError("ScriptPath should not be empty!");

    var file = new File(scriptPath);
    if (!file.existsSync())
      response.addError(new FileSystemException("Script not available", scriptPath));

    var commandPort = new ReceivePort()
      ..listen((data) {

      });

    var exitPort = new ReceivePort()
      ..listen((data) {
        return data;
      });

    var isolateFuture = Isolate.spawnUri(
        file.uri, [], commandPort.sendPort, onExit: exitPort.sendPort, onError: response.stderr);

    isolateFuture.then((isolate) {
      isolates[request.requestId] = isolate;
    });

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
        if (data.header.type == RecordType.ABORT_REQUEST) {
          //isolate abbrechen
          // end request senden
          return;
        }

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
