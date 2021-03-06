library dart_fpmt.connection_isolate;

import 'dart:isolate';
import 'dart:io';
import 'dart:async';
import 'connection_handler.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:isolate/isolate.dart';
import 'package:dart_fpm/dart_fpm.dart';
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
    StreamController<FcgiRecord> managementRecords = new StreamController();

    managementRecords.stream.listen((record) {
      //TODO: handle management records
    });

    var connectionHandler = new ConnectionHandler(socket);

    socket
        .transform(new FcgiRecordTransformer())
        .transform(new FcgiRequestTransformer(managementRecords))
        .listen(connectionHandler.requestHandler, onError: connectionHandler.requestHandler_onError);
  }
}
