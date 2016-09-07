import 'dart:convert';
import 'dart:isolate';
import 'dart:io';

main(List<String> args, SendPort stdout) {
  //Output content through stdout
  stdout.send("This is a test Message from SampleScript <br>");

  var stdin = args[0];
  Map<String, String> params = JSON.decode(args[1]);

  params.forEach((k, v) => stdout.send("Key=$k Value=$v <br>"));

  //Return exitCode different from 0 for testing
  return 2;
}
