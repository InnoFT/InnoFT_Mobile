import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Screen"),
        automaticallyImplyLeading: false, // Отключаем кнопку "назад"
      ),
      body: Center(
        child: Text("This is the Profile Screen"),
      ),
    );
  }
}
