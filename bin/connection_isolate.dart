library dart_fpmt.connection_isolate;

import 'dart:isolate';
import 'dart:io';
import 'connection_handler.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:isolate/isolate.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';

Logger _log = new Logger("dart_fpm.connection_isolate");

main(List<String> args, SendPort reply) async {
  var channel = new IsolateChannel.connectSend(reply);

  hierarchicalLoggingEnabled = true;
  Logger.root.onRecord.listen(new LogPrintHandler());

  ServerSocket serverSocket = await ServerSocket.bind(InternetAddress.LOOPBACK_IP_V4, 9090, shared: true);

  channel.stream.listen((event) {
    _log.info("Event received: $event");
  });

  await for (var socket in serverSocket) {
    new ConnectionHandler(socket).handle();
  }
}
