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

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
//
// /// Custom Request class that prints the upload progress
// class ProgressMultipartRequest extends http.MultipartRequest {
//   ProgressMultipartRequest(String method, Uri url) : super(method, url);
//
//   @override
//   http.ByteStream finalize() {
//     final stream = super.finalize();
//     final total = contentLength;
//     int bytesSent = 0;
//     int lastPercent = -1;
//
//     // Intercept the stream to count bytes as they leave the device
//     return http.ByteStream(stream.map((chunk) {
//       bytesSent += chunk.length;
//       if (total > 0) {
//         int currentPercent = ((bytesSent / total) * 100).floor();
//
//         if (currentPercent > lastPercent) {
//           lastPercent = currentPercent;
//           print("Upload Progress: $currentPercent%");
//
//           // --- THE FIX: Notify when upload is done but response is pending ---
//           if (currentPercent >= 100) {
//             print("✅ Upload complete. Waiting for server to process data...");
//           }
//         }
//       }
//       return chunk;
//     }));
//   }
// }
//
// Future<void> pickAndUploadFile() async {
//   // 1. Pick File
//   final result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['edf'],
//     withData: true,
//   );
//
//   if (result == null) {
//     if (kDebugMode) print('User cancelled');
//     return;
//   }
//
//   final file = result.files.single;
//   final bytes = file.bytes;
//   final filename = file.name;
//
//   print("Starting upload...");
//
//   final uri = Uri.parse('http://127.0.0.1:8000/api/data/predict/');
//
//   // 2. Use the Custom Request
//   final request = ProgressMultipartRequest('POST', uri)
//     ..files.add(http.MultipartFile.fromBytes(
//       'file',
//       bytes!,
//       filename: filename,
//       contentType: MediaType('application', 'octet-stream'),
//     ));
//
//   request.headers['Accept'] = 'application/json';
//
//   // 3. Send (Progress prints happen here)
//   final streamed = await request.send();
//
//   // 4. Get Response
//   final resp = await http.Response.fromStream(streamed);
//
//   if (kDebugMode) {
//     print('Response Received!');
//     print('Status: ${resp.statusCode}');
//     print('Body: ${resp.body}');
//   }
// }