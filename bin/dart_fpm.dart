library dart_fpm.bin;

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';
import 'package:dart_fpm/dart_fpm.dart';

/// maps request ids to detailed request information
Map<int, dynamic> requests;

Logger _libLogger = new Logger("dart_fpm");

main() async {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.ALL;
  _libLogger.level = Level.ALL;

  Logger.root.onRecord.listen(new LogPrintHandler());

  ServerSocket serverSocket = await ServerSocket.bind(InternetAddress.LOOPBACK_IP_V4, 9999);

  //only for testing!!!
  int counter = 0;

  await for (var socket in serverSocket) {
    socket
        .transform(new FcgiRecordTransformer())
        .listen((FcgiRecord record) {
      //TODO: implement record handling
      _libLogger.info(record.header.type.toString());

      FcgiRecord response;

      //only for testing
      counter++;
//      if (counter < 4) return;

      //IMPORTANT: SEND CONTENT TYPE OF RETURN FIRST!!!
      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody(FcgiRecordType.STDOUT, new AsciiCodec().encode("Content-type: text/html\r\n\r\n")));

      socket.add(response.toByteStream());

      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody(FcgiRecordType.STDOUT, new AsciiCodec().encode("Hello World!")));

      socket.add(response.toByteStream());

//        response = new FcgiRecord.generateResponse(record.header.requestId,
//            new FcgiStreamBody(FcgiRecordType.DATA, new AsciiCodec().encode(
//                '''
//                <!DOCTYPE html>
//<html>
//<body>
//
//<h1>My First Heading</h1>
//
//<p>My first paragraph.</p>
//
//</body>
//</html>
//
//
//                '''
//            )));
//
//        socket.add(response.toByteStream());

      socket.flush().then((data) {
        response = new FcgiRecord.generateResponse(record.header.requestId,
            new FcgiEndRequestBody(0, FcgiProtocolStatus.REQUEST_COMPLETE));

        socket.add(response.toByteStream());

        counter = 0;
      });
    }, onError: (data) {
      //TODO: check if stream is already closed (SocketException)
      if (data is SocketException) {
        //clean all available things for this requestID
        return;
      }

      if (data is FcgiRecord)
        socket.add(data.toByteStream());
    });

//    socket.listen((data) {
//      contentBuilder.add(data);
//      counter++;
//      if (counter > 0) {
//        var buffer = new Uint8List.fromList(contentBuilder.takeBytes());
//        socket.write("${buffer.take(8)}\n");
//        counter = 0;
//      }
//    });
  }
}