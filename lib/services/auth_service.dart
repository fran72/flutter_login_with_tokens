import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyDZM8ccszmbZlvCxD1-j1yQddrjXhtBhdk';
  // Sign up:   https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDZM8ccszmbZlvCxD1-j1yQddrjXhtBhdk

  final storage = const FlutterSecureStorage();

  Future<String?> createUser(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSeureToken': true,
    };

    final Uri url = Uri.https(_baseUrl, '/v1/accounts:signUp', {
      'key': _firebaseToken,
    });

    final res = await http.post(url, body: json.encode(authData));
    final Map<String, dynamic> decodedResp = json.decode(res.body);

    if (decodedResp.containsKey('idToken')) {
      await storage.write(key: 'idToken', value: decodedResp['idToken']);

      return null;
    } else {
      return decodedResp['error']['message'];
    }
  }

  Future<String?> loginUser(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSeureToken': true,
    };

    final Uri url = Uri.https(_baseUrl, '/v1/accounts:signInWithPassword', {
      'key': _firebaseToken,
    });

    final res = await http.post(url, body: json.encode(authData));
    final Map<String, dynamic> decodedResp = json.decode(res.body);

    debugPrint('$decodedResp');

    if (decodedResp.containsKey('idToken')) {
      await storage.write(key: 'token', value: decodedResp['idToken']);

      return null;
    } else {
      return decodedResp['error']['message'];
    }
  }

  Future logout() async {
    await storage.delete(key: 'token');
    return;
  }

  Future readToken() async {
    return await storage.read(key: 'token') ?? '';
  }
}
