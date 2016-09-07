
import 'dart:async';
import 'dart:isolate';
import 'dart:io';

main (args, SendPort stdout) {

  //Output content through stdout
  stdout.send("This is a test Message from SampleScript <br>");

  //Access Parameters through environment variables
  Map<String, String> env = Platform.environment;
  env.forEach((k, v) => stdout.send("Key=$k Value=$v <br>"));

  //Return exitCode different from 0 for testing
  return 2;
}
