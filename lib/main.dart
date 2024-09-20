import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // подключение экрана приветствия
import 'screens/profile_screen.dart'; // подключение экрана профиля
import 'screens/signin_signup_screen.dart'; // подключение экрана входа/регистрации

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InnoFT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Настраиваем маршруты
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),            // Приветственный экран
        '/signin_signup': (context) => SignInSignUpScreen(), // Экран авторизации/регистрации
        '/profile': (context) => ProfileScreen(),    // Экран профиля после входа/регистрации
      },
    );
  }
}
