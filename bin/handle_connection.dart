library dart_fpm.handle_connection;

import 'dart:io';
import 'dart:async';
import 'package:dart_fpm/dart_fpm.dart';
import 'package:logging/logging.dart';

Logger _log = new Logger("dart_fpm.handle_connection");

handleConnection(Socket socket) {

  StreamController<FcgiRecord> managementRecords = new StreamController();
  managementRecords.stream.listen((record) {
    //TODO: handle management records
  });

  socket
      .transform(new FcgiRecordTransformer())
      .transform(new FcgiRequestTransformer(managementRecords))
      .listen((Request request) {
      Response response = new Response(request.requestId, (response, data) {
        socketAdd(socket, new FcgiRecord.generateResponse(response.requestId,
            new FcgiStreamBody.fromString(RecordType.STDOUT, data.toString())));
      }, (response, error) {
        socketAdd(socket, new FcgiRecord.generateResponse(response.requestId,
            new FcgiStreamBody.fromString(RecordType.STDERR, error.toString())));
      }, (response) {
        socketAdd(socket, new FcgiRecord.generateResponse(response.requestId,
            new FcgiStreamBody.empty(RecordType.STDOUT)));
        socketAdd(socket, new FcgiRecord.generateResponse(response.requestId,
            new FcgiStreamBody.empty(RecordType.STDERR)));
        socketAdd(socket, new FcgiRecord.generateResponse(response.requestId,
            new EndRequestBody(response.appStatus, response.protocolStatus)));
        if (!request.keepAlive) {
          socket.close();
        }
      });

    //IMPORTANT: SEND CONTENT TYPE OF RETURN FIRST!!!
//    response.header("Content-Type: text/html; encoding=utf-8");
    response.output.add('''
<!DOCTYPE html>
<html>
<head>
<title>Test</title>
</head>
<body>
<h1>My First Heading</h1>
<p>My first paragraph.</p>
</body>
</html>
''');
      response.close();
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