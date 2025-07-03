import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionResult {
  final String uid;
  final String resultClass;
  final String fileType;
  final DateTime timestamp;
  final double? confidence;
  final String? fileUrl;
  final GeoPoint? location; // 📍 Yeni alan

  PredictionResult({
    required this.uid,
    required this.resultClass,
    required this.fileType,
    required this.timestamp,
    this.confidence,
    this.fileUrl,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'resultClass': resultClass,
      'fileType': fileType,
      'timestamp': timestamp,
      'confidence': confidence,
      'fileUrl': fileUrl,
      'location': location != null
          ? {'latitude': location!.latitude, 'longitude': location!.longitude}
          : null,
    };
  }
}


