library dart_fpmt.connection_isolate;

import 'dart:isolate';
import 'dart:io';
import 'handle_connection.dart';
import 'package:stream_channel/stream_channel.dart';

void main (List<String> args, SendPort reply) {
  var channel = new IsolateChannel.connectSend(reply);

  channel.stream.listen( (event) {
    if (event is Socket) {
      handleConnection(event);
    }
  });

}
