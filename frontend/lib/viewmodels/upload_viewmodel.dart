import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/prediction_result.dart';
import '../services/api_service.dart';

class UploadViewModel extends ChangeNotifier {
  File? selectedFile;
  bool isVideo = false;
  String? result;
  double? confidence;
  bool isLoading = false;
  LatLng? selectedLocation; // GPS'ten gelen konum (Google Maps)

  void setFile(File file, {required bool video}) {
    selectedFile = file;
    isVideo = video;
    notifyListeners();
  }

  void setLocation(LatLng location) {
    selectedLocation = location;
    notifyListeners();
  }

  Future<void> predict() async {
    if (selectedFile == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = isVideo
          ? await ApiService.uploadAndPredictVideo(selectedFile!)
          : await ApiService.uploadAndPredict(selectedFile!);

      result = response['class'] ?? 'Sonuç bulunamadı';
      confidence = response['confidence']?.toDouble() ?? 0.0;

      final downloadUrl = await _uploadFileToStorage();
      await _saveResultToFirestore(downloadUrl);
    } catch (e) {
      result = "Hata: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<String?> _uploadFileToStorage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || selectedFile == null) return null;

      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.path.split('/').last}";
      final ref = FirebaseStorage.instance
          .ref()
          .child('${isVideo ? 'videos' : 'images'}/$uid/$fileName');

      final uploadTask = await ref.putFile(selectedFile!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint(" Storage upload error: $e");
      return null;
    }
  }

  Future<void> _saveResultToFirestore(String? downloadUrl) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || result == null) return;

    final data = PredictionResult(
      uid: uid,
      resultClass: result!,
      fileType: isVideo ? 'video' : 'image',
      timestamp: DateTime.now(),
      confidence: confidence,
      fileUrl: downloadUrl,
      location: selectedLocation != null
          ? GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude)
          : null,
    );

    await FirebaseFirestore.instance.collection('predictions').add(data.toJson());
  }
}