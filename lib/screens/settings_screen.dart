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
              _showCurrentPasswordDialog(context); // Вызов диалога для ввода текущего пароля
            },
            child: Text('Change Password'),
          ),
        ],
      ),
    );
  }

  // Диалог для ввода текущего пароля
  void _showCurrentPasswordDialog(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Current Password'),
          content: TextField(
            controller: currentPasswordController,
            decoration: InputDecoration(labelText: 'Current Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрываем диалог
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Проверка пароля (заглушка для серверной проверки)
                if (_checkCurrentPassword(currentPasswordController.text)) {
                  Navigator.pop(context); // Закрываем диалог с текущим паролем
                  _showNewPasswordDialog(context); // Открываем диалог для нового пароля
                } else {
                  _showErrorDialog(context, 'Incorrect current password.');
                }
              },
              child: Text('Enter'),
            ),
          ],
        );
      },
    );
  }

  // Заглушка для проверки текущего пароля
  bool _checkCurrentPassword(String currentPassword) {
    // Здесь будет логика проверки пароля на сервере, пока возвращаем true для демонстрации
    return currentPassword == "123456"; // Заглушка: текущий пароль - "123456"
  }

  // Диалог для ввода нового пароля
  void _showNewPasswordDialog(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter New Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрываем диалог
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_validateNewPassword(context, newPasswordController.text, confirmPasswordController.text)) {
                  // Логика для изменения пароля (заглушка)
                  Navigator.pop(context); // Закрываем диалог
                }
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  // Проверка нового пароля
  bool _validateNewPassword(BuildContext context, String newPassword, String confirmPassword) {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog(context, 'New password fields cannot be empty.');
      return false;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog(context, 'Passwords do not match.');
      return false;
    }

    if (!_isPasswordValid(newPassword)) {
      _showErrorDialog(context, 'Password must be at least 8 characters long and include a digit and a special character.');
      return false;
    }

    return true;
  }

  // Проверка формата пароля
  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    bool hasDigit = password.contains(RegExp(r'\d'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasDigit && hasSpecialChar;
  }

  // Диалог ошибки
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
