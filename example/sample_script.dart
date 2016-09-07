import 'dart:convert';
import 'dart:isolate';
import 'dart:io';

main(List<String> args, SendPort stdout) {
  var stdin = args[0];
  Map<String, String> params = JSON.decode(args[1]);

  stdout.send('''
  <html>
  <head>
  <title>Sample Script</title>
  <link href="bnware-generic-smooth.css" type="text/css" rel="stylesheet">
  </head>

  <body>
  <h1>This is a test Message from SampleScript</h1>
  </body>

  <table class="bnware-smooth">
  <tr>
  <th>Param</th>
  <th>Value</th>
  </tr>

  ${ params.keys.fold("", (content, key) =>
  "$content <tr><td>$key </td><td>${params[key]}</td></tr>")
  }
  </table>
  </html>
  ''');


  //Return exitCode different from 0 for testing
  return 2;
}
