import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/providers.dart'; // Импортируем провайдеры
import '../screens/settings_screen.dart';
import '../screens/create_trip_screen.dart';
import '../screens/find_trip_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _imageFile;
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  double userRating = 0.0;
  List<String> activeTrips = [];
  List<String> tripHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Загружаем данные пользователя при входе
  }

  // Метод для загрузки данных пользователя
  Future<void> _loadUserData() async {
    setState(() {
      userName = "John Doe"; // Заглушка для имени
      userEmail = "john.doe@example.com"; // Заглушка для email
      userPhone = "+71234567890"; // Заглушка для телефона
      userRating = 4.7; // Заглушка для рейтинга
      activeTrips = ["Trip 1", "Trip 2"]; // Заглушка для активных поездок
      tripHistory = ["Trip 3 (Completed)", "Trip 4 (Completed)"]; // Заглушка для истории поездок
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Screen'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Settings', icon: Icon(Icons.settings)),
              Tab(text: 'Profile', icon: Icon(Icons.person)),
              Tab(text: 'Create Trip', icon: Icon(Icons.add_circle)),
              Tab(text: 'Find Trip', icon: Icon(Icons.search)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SettingsScreen(),
            _buildProfileContent(context),
            CreateTripScreen(),
            FindTripScreen(),
          ],
        ),
      ),
    );
  }

  // Основное содержимое профиля
  Widget _buildProfileContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Фото пользователя
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : AssetImage('assets/user_photo.png') as ImageProvider,
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Change Photo'),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Имя пользователя, email и номер телефона
          _buildUserInfo('Name', userName, () {
            _showEditDialog(context, 'name', userName);
          }),
          _buildUserInfo('Email', userEmail, () {
            _showEditDialog(context, 'email', userEmail);
          }),
          _buildUserInfo('Phone', userPhone, () {
            _showEditDialog(context, 'phone', userPhone);
          }),

          SizedBox(height: 20),

          // Рейтинг пользователя
          Text(
            'Rating: $userRating',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Активные поездки
          Text(
            'Active Trips:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ..._buildActiveTrips(activeTrips),

          SizedBox(height: 20),

          // История поездок с кнопкой "очистить"
          Text(
            'Trip History:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ..._buildTripHistory(tripHistory),
          ElevatedButton(
            onPressed: _showClearHistoryDialog,
            child: Text('Clear History'),
          ),
        ],
      ),
    );
  }

  // Виджет для отображения информации пользователя
  Widget _buildUserInfo(String label, String value, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: $value',
            style: TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  // Построение списка активных поездок
  List<Widget> _buildActiveTrips(List<String> trips) {
    if (trips.isEmpty) {
      return [Text('No active trips available.')];
    }
    return trips.map((trip) => ListTile(title: Text(trip))).toList();
  }

  // Построение истории поездок
  List<Widget> _buildTripHistory(List<String> trips) {
    if (trips.isEmpty) {
      return [Text('No trip history available.')];
    }
    return trips.map((trip) => ListTile(title: Text(trip))).toList();
  }

  // Диалог для изменения информации с проверкой на ошибки
  void _showEditDialog(BuildContext context, String field, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Enter new $field'),
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
                // Валидация для имени
                if (field == 'name' && controller.text.isEmpty) {
                  _showErrorDialog(context, 'Name cannot be empty.');
                  return;
                }
                // Валидация для email
                if (field == 'email' && !_isEmailValid(controller.text)) {
                  _showErrorDialog(context, 'Invalid email format.');
                  return;
                }
                // Валидация для телефона
                if (field == 'phone' && !_isPhoneValid(controller.text)) {
                  _showErrorDialog(context, 'Phone number must start with +7 or 8 and contain 11 digits.');
                  return;
                }

                // Сохраняем изменения
                if (field == 'name') {
                  setState(() {
                    userName = controller.text;
                  });
                }
                if (field == 'email') {
                  setState(() {
                    userEmail = controller.text;
                  });
                }
                if (field == 'phone') {
                  setState(() {
                    userPhone = controller.text;
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Диалог подтверждения для очистки истории
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear Trip History'),
          content: Text('Are you sure you want to clear your trip history?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tripHistory = [];
                });
                Navigator.pop(context);
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  // Проверка email на правильность
  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Проверка телефона на правильность (только цифры и знак "+" в начале)
  bool _isPhoneValid(String phone) {
    final RegExp phoneRegex = RegExp(r'^(\+7|8)\d{10}$');
    return phoneRegex.hasMatch(phone);
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
