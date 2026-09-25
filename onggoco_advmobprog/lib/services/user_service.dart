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

  // --- ENHANCEMENT 1 ---
  // eto yung pang-login sa firebase gamit email at password
  Future<fb.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    // rekta tawag sa firebase auth
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // tag natin na firebase para alam sa profile screen mamaya
    await setLoginType('firebase');

    // save agad sa prefs para kahit ma-exit yung app naka-login pa rin
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

  // gawa ng bagong account sa firebase, rekta pasok to sa cloud console
  Future<fb.UserCredential> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // lagyan na rin ng display name kung nilagay ni user
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
    }
    return credential;
  }

  // sign out lang sa firebase
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  // palit username/display name tapos save din agad sa prefs para updated lagi
  Future<void> updateUsername({required String username}) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(username);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('firstName', username);
    }
  }

  // delete account: hingin muna password paps para sure na siya talaga may ari bago burahin
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    fb.AuthCredential credential = fb.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    // re-auth muna para safe
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
    await logout(); // bura na rin sa phone
  }

  // palit password: kailangan re-auth gamit old pass bago palitan ng bago
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    fb.AuthCredential credential = fb.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    // check muna old password
    await currentUser!.reauthenticateWithCredential(credential);
    // sabay kabit nung bago
    await currentUser!.updatePassword(newPassword);
  }

  // check lang natin kung firebase ba o dummyjson yung naka-login
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

  // logout: signout sa firebase sabay wipeout lahat ng nakatambak sa shared prefs
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
