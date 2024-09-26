import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static const String baseUrl = "http://localhost:8069";
  static const String authTokenKey = "Authorization";

  Future<String?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(authTokenKey, token);

      return token;
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      throw Exception(errorMessage);
    }
  }

  Future<void> register(String name, String email, String phone, String password, String role) async {
    final url = Uri.parse('$baseUrl/register');
    
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
        "role": role,
      }),
    );
    
    if (response.statusCode != 200) {
      final errorMessage = jsonDecode(response.body)['error'];
      throw Exception(errorMessage);
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(authTokenKey);
    
    if (token != null) {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token
        },
      );
      
      if (response.statusCode == 200) {
        await prefs.remove(authTokenKey);
      } else {
        final errorMessage = jsonDecode(response.body)['error'];
        throw Exception(errorMessage);
      }
    } else {
      throw Exception("No active session found");
    }
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(authTokenKey);
    return token != null;
  }

  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(authTokenKey);
  }

  Future<void> fetchDataWithToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(authTokenKey);

    if (token != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/protected-route'),
        headers: {
          "Authorization": token,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Data fetched: $data");
      } else {
        final errorMessage = jsonDecode(response.body)['error'];
        throw Exception("Error fetching data: $errorMessage");
      }
    } else {
      throw Exception("No active session found");
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }
}
