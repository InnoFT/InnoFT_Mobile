import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Проверка статуса входа при запуске
  }

  // Функция для проверки наличия данных входа
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Задержка на 2 секунды для показа лого
    await Future.delayed(Duration(seconds: 2));

    if (isLoggedIn) {
      // Если пользователь уже залогинен, перенаправляем на экран профиля
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      // Если данных нет, перенаправляем на экран авторизации/регистрации
      Navigator.pushReplacementNamed(context, '/signin_signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Лого приложения
            Icon(Icons.directions_car, size: 100),
            SizedBox(height: 20),
            Text(
              "Welcome to BlaBlaClone",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
