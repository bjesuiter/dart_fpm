library dart_fpm.handle_connection;

import 'dart:io';
import 'package:dart_fpm/dart_fpm.dart';
import 'package:logging/logging.dart';

Logger _log = new Logger("dart_fpm.handle_connection");

handleConnection(Socket socket) {
  bool keepAlive;

  socket
      .transform(new FcgiRecordTransformer())
      .listen((FcgiRecord record) {
    //TODO: implement record handling
    _log.info("-> $record");

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

socketAdd(Socket socket, FcgiRecord record) {
  _log.info("<- $record");

  socket.add(record.toByteStream());
}