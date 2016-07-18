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



