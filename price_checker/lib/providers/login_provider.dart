import 'dart:convert'; // Add this import for json.decode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider() : super(AuthState());

  Future<void> login(String email, String password) async {
    final url =
        Uri.parse('https://money-saver-app-backend.onrender.com/auth/login');

    try {
      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        state = AuthState(
          id: responseData['userId'],
          token: responseData['token'],
          email: responseData['email'],
          name: responseData['name'],
          mobile: responseData['mobile'],
          imageUrl: responseData['imageUrl'],
        );

        // Call saveCredentials to store id and token in SharedPreferences
        await saveInfo(
          responseData['userId'],
          responseData['token'],
        );
        await saveUserData(responseData['email'], responseData['name'],
            responseData['mobile'], responseData['imageUrl']);
        await setLoggedInState(true);
      } else {
        print('Failed to log in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login: $e');
    }
  }

  Future<void> setLoggedInState(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('loggedIn', value);
  }

  Future<void> saveInfo(String? id, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', id ?? "");
    prefs.setString('token', token);
  }

  Future<Map<String, String?>> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString('userId');
    final String? name = prefs.getString('name');
    final String? email = prefs.getString('email');
    final String? mobile = prefs.getString('mobile');
    final String? imageUrl = prefs.getString('imageUrl');

    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'imageUrl': imageUrl,
    };
  }

  Future<void> saveUserData(
      String email, String name, String mobile, String imageUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
    prefs.setString('email', email);
    prefs.setString('mobile', mobile);
    prefs.setString('imageUrl', imageUrl);
  }
}

class AuthState {
  final String? id;
  final String? token;
  final String? email;
  final String? name;
  final String? mobile;
  final String? imageUrl;

  AuthState(
      {this.id, this.token, this.email, this.name, this.mobile, this.imageUrl});
}
