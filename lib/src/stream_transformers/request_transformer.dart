library dart_fpm.fcgi_request_transformer;

import 'dart:async';
import '../fcgi/fcgi.dart';

class RequestTransformer implements StreamTransformer<FcgiRecord, dynamic> {

  @override
  Stream bind(Stream<FcgiRecord> stream) {
    // TODO: implement bind
  }
}