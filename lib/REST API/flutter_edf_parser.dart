import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<void> pickAndUploadFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['edf'],
    withData: true, // <-- get bytes directly
  );

  if (result == null) {
    print('User cancelled');
    return;
  }

  final file = result.files.single;
  final bytes = file.bytes; // Uint8List
  final filename = file.name;

  final uri = Uri.parse('http://127.0.0.1:8000/api/data/predict/');


  final request = http.MultipartRequest('POST', uri)
    ..files.add(http.MultipartFile.fromBytes(
      'file',
      bytes!,
      filename: filename,
      contentType: MediaType('application', 'octet-stream'), // EDF is binary
    ));

  // Add any headers if needed
  request.headers['Accept'] = 'application/json';

  final streamed = await request.send();
  final resp = await http.Response.fromStream(streamed);

  print('Status: ${resp.statusCode}');
  print('Body: ${resp.body}');
}
