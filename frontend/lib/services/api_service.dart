import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://192.168.128.210:8000"; // Android emulator için
  // static const String baseUrl = "http://localhost:8000"; // Web veya iOS için

  static Future<Map<String, dynamic>> uploadAndPredict(File file) async {
    final uri = Uri.parse("$baseUrl/predict");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    return json.decode(respStr);
  }

  static Future<Map<String, dynamic>> uploadAndPredictVideo(File file) async {
    final uri = Uri.parse("$baseUrl/predict");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    return json.decode(respStr);
  }
}

