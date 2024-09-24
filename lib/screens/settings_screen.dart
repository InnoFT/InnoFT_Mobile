import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Заглушка для текущего пароля
  final String currentPasswordInDb = "password123"; // Это заглушка

  // Метод для проверки существующего пароля
  bool _checkCurrentPassword(String enteredPassword) {
    return enteredPassword == currentPasswordInDb;
  }

  // Метод для проверки нового пароля
  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    bool hasDigit = password.contains(RegExp(r'\d'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasDigit && hasSpecialChar;
  }

  // Метод для открытия диалога для ввода текущего пароля
  void _showCurrentPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Current Password'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Current Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Проверяем текущий пароль
                if (_checkCurrentPassword(passwordController.text)) {
                  Navigator.pop(context); // Закрываем текущий диалог
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

  // Метод для открытия диалога для ввода нового пароля
  void _showNewPasswordDialog(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter New Password'),
          content: TextField(
            controller: newPasswordController,
            decoration: InputDecoration(labelText: 'New Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Проверяем новый пароль
                if (_isPasswordValid(newPasswordController.text)) {
                  Navigator.pop(context);
                  _showSuccessDialog(context, 'Password changed successfully.');
                } else {
                  _showErrorDialog(context,
                      'Password must be at least 8 characters long, include a digit and a special character.');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Метод для показа ошибки
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

  // Метод для показа успешного сообщения
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showCurrentPasswordDialog(context);
          },
          child: Text('Change Password'),
        ),
      ),
    );
  }
}
