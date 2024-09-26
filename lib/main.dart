import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'package:inno_ft/screens/splash_screen.dart';
import 'components/theme_provider.dart'; // Импортируем провайдер темы
import 'screens/settings_screen.dart'; // Экран настроек
import 'screens/profile_screen.dart'; // Экран профиля
import 'screens/signin_signup_screen.dart'; // Экран входа/регистрации
import 'screens/create_trip_screen.dart'; // Экран создания поездки
import 'screens/find_trip_screen.dart'; // Экран поиска поездки

void main() {
  runApp(
    ProviderScope( // Оборачиваем все приложение в ProviderScope для работы с Riverpod
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeNotifierProvider); // Получаем текущую тему через Riverpod

    return MaterialApp(
      title: 'InnoFT',
      theme: ThemeData.light(), // Светлая тема
      darkTheme: ThemeData.dark(), // Темная тема
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light, // Переключение темной/светлой темы
      initialRoute: '/splash', // Начальный экран
      routes: {
        '/splash': (context) => SplashScreen(),
        '/signin_signup': (context) => SignInSignUpScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
        '/create_trip': (context) => CreateTripScreen(),
        '/find_trip': (context) => FindTripScreen(),
      },
    );
  }
}
