import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';

class SignInSignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In / Sign Up"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showSignInDialog(context);
              },
              child: Text("Sign In"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showSignUpDialog(context);
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  // Диалог входа
  void _showSignInDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool rememberMe = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Sign In'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      Text("Remember me")
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (rememberMe) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('email', emailController.text);
                        await prefs.setString('password', passwordController.text);
                        await prefs.setBool('isLoggedIn', true); // Сохранение статуса
                      }

                      Navigator.pop(context); // Закрываем диалог
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
                    } catch (e) {
                      print('Error during sign in: $e');
                    }
                  },
                  child: Text('Enter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Диалог регистрации
  void _showSignUpDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    bool rememberMe = false;
    bool isDriver = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Sign Up'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      Text("Remember me")
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Passenger"),
                      Switch(
                        value: isDriver,
                        onChanged: (value) {
                          setState(() {
                            isDriver = value;
                          });
                        },
                      ),
                      Text("Driver"),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    String email = emailController.text;
                    String name = nameController.text;
                    String password = passwordController.text;
                    String confirmPassword = confirmPasswordController.text;

                    if (name.isEmpty) {
                      _showErrorDialog(context, 'Name cannot be empty.');
                    } else if (email.isEmpty) {
                      _showErrorDialog(context, 'Email cannot be empty.');
                    } else if (!_isEmailValid(email)) {
                      _showErrorDialog(context, 'Email must contain "@" and a domain (e.g. @gmail.com).');
                    } else if (!_isPasswordValid(password)) {
                      _showErrorDialog(context, 'Password must be at least 8 characters long, include a digit and a special character.');
                    } else if (password != confirmPassword) {
                      _showErrorDialog(context, 'Passwords do not match.');
                    } else {
                      try {
                        if (rememberMe) {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('email', email);
                          await prefs.setString('password', password);
                          await prefs.setBool('isDriver', isDriver);
                          await prefs.setBool('isLoggedIn', true);
                        }

                        Navigator.pop(context);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
                      } catch (e) {
                        print('Error during sign up: $e');
                      }
                    }
                  },
                  child: Text('Enter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Проверка email
  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Проверка пароля
  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    bool hasDigit = password.contains(RegExp(r'\d'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasDigit && hasSpecialChar;
  }

  // Показ окна ошибки
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
