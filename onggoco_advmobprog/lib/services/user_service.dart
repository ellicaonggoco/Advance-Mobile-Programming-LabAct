import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../constants.dart';
import '../models/user.dart';

ValueNotifier<UserService> userService = ValueNotifier(UserService());

class UserService {
  Map<String, dynamic> data = {};
  final fb.FirebaseAuth firebaseAuth = fb.FirebaseAuth.instance;

  fb.User? get currentUser => firebaseAuth.currentUser;

  Stream<fb.User?> get authStateChanges => firebaseAuth.authStateChanges();

  // --------------------------------------------------------------
  // ENHANCEMENT 1 & 2: Firebase Authentication Methods (PDF Page 17)
  // --------------------------------------------------------------
  Future<fb.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await setLoginType('firebase');

    // Save basic Firebase user info to SharedPreferences for offline/persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', credential.user?.email ?? email);
    await prefs.setString(
        'username', credential.user?.displayName ?? email.split('@').first);
    await prefs.setString(
        'firstName', credential.user?.displayName ?? 'Firebase');
    await prefs.setString('lastName', 'User');
    await prefs.setString('token', credential.user?.uid ?? '');

    return credential;
  }

  Future<fb.UserCredential> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
    }
    return credential;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> updateUsername({required String username}) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(username);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('firstName', username);
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    fb.AuthCredential credential = fb.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
    await logout();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    fb.AuthCredential credential = fb.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  // --------------------------------------------------------------
  // Login Type Helper: 'dummyjson' vs 'firebase' (Enhancement 2 & 3)
  // --------------------------------------------------------------
  Future<String> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loginType') ??
        (currentUser != null ? 'firebase' : 'dummyjson');
  }

  Future<void> setLoginType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginType', type);
  }

  // --------------------------------------------------------------
  // DummyJSON Authentication Methods (Lab Activity 4 baseline)
  // --------------------------------------------------------------
  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      await saveUserData(data);
      await setLoginType('dummyjson');
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  /// Save User data to SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);

    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);

    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  /// Retrieve user data from SharedPreferences
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = await getLoginType();

    if (loginType == 'firebase' && currentUser != null) {
      return {
        'id': 0,
        'username': currentUser?.displayName ??
            prefs.getString('username') ??
            currentUser?.email?.split('@').first ??
            'Firebase User',
        'email': currentUser?.email ?? prefs.getString('email') ?? '',
        'firstName': currentUser?.displayName ??
            prefs.getString('firstName') ??
            'Firebase',
        'lastName': prefs.getString('lastName') ?? 'User',
        'gender': 'N/A',
        'image': currentUser?.photoURL ?? '',
        'accessToken': currentUser?.uid ?? '',
        'refreshToken': '',
        'token': currentUser?.uid ?? '',
        'loginType': 'firebase',
      };
    }

    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
      'loginType': loginType,
    };
  }

  /// Retrieve User model from SharedPreferences
  Future<User> getUser() async {
    final userData = await getUserData();
    return User.fromJson(userData);
  }

  /// Check if user is Logged In
  Future<bool> isLoggedIn() async {
    if (currentUser != null) return true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  /// Logout and Clear User Data (Enhancement 1 & 3)
  Future<void> logout() async {
    try {
      if (currentUser != null) {
        await signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }
}
