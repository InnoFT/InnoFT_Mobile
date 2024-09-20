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
                    // Заглушка для проверки данных с удалённой БД
                    if (rememberMe) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('email', emailController.text);
                      await prefs.setString('password', passwordController.text);
                      await prefs.setBool('isLoggedIn', true); // Сохранение статуса
                    }
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
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

  // Диалог регистрации с переключателем "Пассажир или Водитель"
  void _showSignUpDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    bool rememberMe = false;
    bool isDriver = false; // Переменная для переключателя

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
                    // Заглушка для сохранения данных в удалённую БД и локальное хранилище
                    if (rememberMe) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('email', emailController.text);
                      await prefs.setString('password', passwordController.text);
                      await prefs.setBool('isDriver', isDriver); // Сохранение роли
                      await prefs.setBool('isLoggedIn', true); // Сохранение статуса
                    }
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
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
}
