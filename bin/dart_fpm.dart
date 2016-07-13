library dart_fpm.bin;

import 'dart:io';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:dart_fpm/dart_fpm.dart';

/// maps request ids to detailed request information
Map<int, dynamic> requests;

Logger _libLogger = new Logger("dart_fpm");

main() async {
  hierarchicalLoggingEnabled = true;

  ServerSocket serverSocket = await ServerSocket.bind(InternetAddress.LOOPBACK_IP_V4, 9999);

  await for (var socket in serverSocket) {
    socket.write("Socket connected. Hello Dude!\n");

    socket
        .transform(new FcgiRecordTransformer())
        .listen(
        (FcgiRecord record) {
      //TODO: implement record handling
      _libLogger.info(record);
    }, onError: (data) {
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