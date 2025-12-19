import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendData() async {
  print('sendData() STARTED');
  final url = Uri.parse('http://127.0.0.1:8000/api/data/');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': 'Orion',
      'age': 25,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // ✅ Print everything
    print('Message: ${data['message']}');
    print('Name: ${data['name']}');
    print('Age: ${data['age']}');

  } else {
    print('Error: ${response.statusCode}');
    print(response.body);
  }
}
