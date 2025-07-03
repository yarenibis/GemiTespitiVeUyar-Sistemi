import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; 

class AuthViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  bool isLoading = false;

  Future<void> register(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      user = await _authService.register(email, password); //  AuthService üzerinden çağırıyoruz

    } catch (e) {
      print('Register Error: $e');
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      user = await _authService.signIn(email, password); 

    } catch (e) {
      print('Login Error: $e');
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    user = null;
    notifyListeners();
  }
}
