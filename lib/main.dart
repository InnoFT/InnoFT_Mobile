import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Подключаем Riverpod
import 'screens/signin_signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/create_trip_screen.dart';
import 'screens/find_trip_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp())); // Оборачиваем приложение в ProviderScope
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlaBlaClone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/signin_signup',
      routes: {
        '/signin_signup': (context) => SignInSignUpScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/create_trip': (context) => CreateTripScreen(),
        '/find_trip': (context) => FindTripScreen(),
      },
    );
  }
}
