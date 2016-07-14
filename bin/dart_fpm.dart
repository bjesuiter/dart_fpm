library dart_fpm.bin;

import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';
import 'package:dart_fpm/dart_fpm.dart';

/// maps request ids to detailed request information
Map<int, dynamic> requests;

Logger _libLogger = new Logger("dart_fpm");

//only for testing!!!
int counter = 0;

main() async {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  _libLogger.level = Level.ALL;

  Logger.root.onRecord.listen(new LogPrintHandler());

  ServerSocket serverSocket = await ServerSocket.bind(InternetAddress.LOOPBACK_IP_V4, 9999);


  await for (var socket in serverSocket) {
    socket
        .transform(new FcgiRecordTransformer())
        .listen((FcgiRecord record) {
      //TODO: implement record handling
      _libLogger.info(record.header.type.toString());

      FcgiRecord response;

      //only for testing
      counter++;
      if (counter < 4) return;

      //IMPORTANT: SEND CONTENT TYPE OF RETURN FIRST!!!
      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody(FcgiRecordType.STDOUT, new AsciiCodec().encode("Content-type: text/html\r\n\r\n")));

      socketAdd(socket, response);

      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody.fromString(FcgiRecordType.STDOUT, "Hello World!"));

      socketAdd(socket, response);

      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody.fromString(FcgiRecordType.STDOUT,
              '''
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

      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiEndRequestBody(1, FcgiProtocolStatus.REQUEST_COMPLETE));

      socketAdd(socket, response);

    }, onError: (data) {
      //TODO: check if stream is already closed (SocketException)
      if (data is SocketException) {
        //clean all available things for this requestID
        return;
      }

      if (data is FcgiRecord)
        socket.add(data.toByteStream());
    });
  }
}

socketAdd(Socket socket, FcgiRecord record) {
  _libLogger.info(record.header.type);

  socket.add(record.toByteStream());

  if (record.header.type == FcgiRecordType.END_REQUEST) {
    counter = 0;
  }
}