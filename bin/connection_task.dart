library dart_fpm.ConnectionTask;

import 'package:worker/worker.dart';
import 'dart:io';
import 'package:dart_fpm/dart_fpm.dart';
import 'package:logging/logging.dart';

class ConnectionTask implements Task {

  final Socket socket;
  final Logger _log = new Logger("dart_fpm.connection_task");

  ConnectionTask(this.socket);

  //only for testing!!!
  int counter = 0;

  @override
  execute() {
    socket
        .transform(new FcgiRecordTransformer())
        .listen((FcgiRecord record) {
      //TODO: implement record handling
      _log.info(record.header.type.toString());

      FcgiRecord response;

      //only for testing
      counter++;
      if (counter < 4) return;

      //IMPORTANT: SEND CONTENT TYPE OF RETURN FIRST!!!
      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody.fromString(RecordType.STDOUT, "Content-type: text/html\r\n\r\n"));

      socketAdd(socket, response);

      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody.fromString(RecordType.STDOUT, "Hello World!"));

      socketAdd(socket, response);

      response = new FcgiRecord.generateResponse(record.header.requestId,
          new FcgiStreamBody.fromString(RecordType.STDOUT,
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
          new EndRequestBody(1, ProtocolStatus.REQUEST_COMPLETE));

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

  socketAdd(Socket socket, FcgiRecord record) {
    _log.info(record.header.type);

    socket.add(record.toByteStream());

    if (record.header.type == RecordType.END_REQUEST) {
      counter = 0;
    }
  }
}