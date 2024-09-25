import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Импортируем Riverpod
import '../components/theme_provider.dart'; // Импортируем провайдер темы

class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeNotifierProvider); // Получаем текущее состояние темы

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Тумблер для переключения темы
          ListTile(
            title: Text('Dark Theme'),
            trailing: Switch(
              value: isDarkTheme,
              onChanged: (value) {
                ref.read(themeNotifierProvider.notifier).toggleTheme(); // Переключаем тему
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Логика для изменения пароля
            },
            child: Text('Change Password'),
          ),
        ],
      ),
    );
  }
}
