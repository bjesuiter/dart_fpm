library dart_fpmt.connection_isolate;

import 'dart:isolate';
import 'dart:async';
import 'package:isolate/ports.dart';
import 'package:stream_channel/stream_channel.dart';

void main (List<String> args, SendPort reply) {
  var channel = new IsolateChannel.connectSend(reply);



}
