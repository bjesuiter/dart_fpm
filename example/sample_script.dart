
import 'dart:async';
import 'dart:isolate';

main (args, SendPort stdout) {

  stdout.send("This is a test Message from SampleScript");

  //Return exitCode different from 0 for testing
  return 2;
}
