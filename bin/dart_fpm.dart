library dart_fpm.bin;

import 'dart:io';
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';
import 'package:dart_fpm/dart_fpm.dart';
import 'package:stream_channel/stream_channel.dart';

/// maps request ids to detailed request information
Map<int, dynamic> requests;

Logger _libLogger = new Logger("dart_fpm");

main() async {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  _libLogger.level = Level.ALL;

  Logger.root.onRecord.listen(new LogPrintHandler());

  ServerSocket serverSocket = await ServerSocket.bind(InternetAddress.LOOPBACK_IP_V4, 9090);

//  LoadBalancer loadBalancer = await LoadBalancer.create(4, IsolateRunner.spawn);


  await for (var socket in serverSocket) {
//    loadBalancer.run(handleConnection, socket);

    handleConnection(socket);

    var port = new ReceivePort();
    var isolate = await Isolate.spawnUri(new Uri.file("connection_isolate.dart"), [], port.sendPort);
    var channel = new IsolateChannel.connectReceive(port);

  }
}

socketAdd(Socket socket, FcgiRecord record) {
  _libLogger.info("<- $record");

  socket.add(record.toByteStream());
}

handleConnection(Socket socket) {
  bool keepAlive;

  socket
      .transform(new FcgiRecordTransformer())
      .listen((FcgiRecord record) {
    //TODO: implement record handling
    _libLogger.info("-> $record");

    if (record.header.type == RecordType.BEGIN_REQUEST) {
      BeginRequestBody body = record.body;
      keepAlive = body.keepAlive;
    }

    if (record.header.type == RecordType.STDIN && record.body.contentLength == 0) {
      FcgiRecord response;

      //IMPORTANT: SEND CONTENT TYPE OF RETURN FIRST!!!
      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody.fromString(RecordType.STDOUT,
              '''Content-Type: text/html; encoding=utf-8

<!DOCTYPE html>
  <html>
  <body>

  <h1>My First Heading</h1>

  <p>My first paragraph.</p>

  </body>
  </html>


                  '''
          ));

      socketAdd(socket, response);

      //IMPORTANT: TERMINATE STREAMS WITH EMPTY RECORD
      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody.empty(RecordType.STDOUT));

      socketAdd(socket, response);

      response = new FcgiRecord.generateResponse(record.header.requestId,
          new EndRequestBody(0, ProtocolStatus.REQUEST_COMPLETE));

      socketAdd(socket, response);
      if (!keepAlive) {
        socket.close();
      }
    }
  }, onError: (data) {
    //TODO: check if stream is already closed (SocketException)
    if (data is SocketException) {
      //clean all available things for this requestID
      return;
    }

    if (data is FcgiRecord) {
      int requestId = data.header.requestId;
      if (requestId != FCGI_NULL_REQUEST_ID) {
        socketAdd(socket, new FcgiRecord.generateResponse(requestId,
            new FcgiStreamBody.empty(RecordType.STDOUT)));
        socketAdd(socket, new FcgiRecord.generateResponse(requestId,
            new FcgiStreamBody.empty(RecordType.STDERR)));
      }
      socketAdd(socket, data);
    }
  });
}