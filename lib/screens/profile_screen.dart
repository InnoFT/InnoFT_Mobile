import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/theme_toggle_switch.dart';
import '../components/trip_provider.dart'; // Импортируем провайдер для активных поездок и истории поездок
import '../screens/create_trip_screen.dart';
import '../screens/find_trip_screen.dart';// Import the ThemeToggleSwitch

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

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on initialization
  }

  Future<void> _loadUserData() async {
    setState(() {
      userName = "John Doe";
      userEmail = "john.doe@example.com";
      userPhone = "+71234567890";
      userRating = 4.7;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTrips = ref.watch(activeTripsProvider);
    final tripHistory = ref.watch(tripHistoryProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Screen'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Profile', icon: Icon(Icons.person)),
              Tab(text: 'Create Trip', icon: Icon(Icons.add_circle)),
              Tab(text: 'Find Trip', icon: Icon(Icons.search)),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildProfileContent(context, activeTrips, tripHistory),
                CreateTripScreen(),
                FindTripScreen(),
              ],
            ),
            ThemeToggleSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, List<Map<String, String>> activeTrips, List<String> tripHistory) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : AssetImage('/user_photo.png') as ImageProvider,
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Change Photo'),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
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
          Text(
            'Rating: $userRating',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Active Trips:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (activeTrips.isEmpty)
            Text('No active trips available.')
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: activeTrips.length,
              itemBuilder: (context, index) {
                final trip = activeTrips[index];
                return _buildTripItem(trip);
              },
            ),
          SizedBox(height: 20),
          Text(
            'Trip History:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (tripHistory.isEmpty)
            Text('No trip history available.')
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: tripHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tripHistory[index]),
                );
              },
            ),
          ElevatedButton(
            onPressed: _showClearHistoryDialog,
            child: Text('Clear History'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripItem(Map<String, String> trip) {
    return ListTile(
      title: Text('From ${trip['from']} to ${trip['to']}'),
      subtitle: Text('Departure: ${trip['departure']}'),
      trailing: trip['driver'] == 'your'
          ? Text('(your)', style: TextStyle(color: Colors.blue))
          : null,
      onTap: () => _showTripDetailsDialog(trip),
    );
  }

  Widget _buildUserInfo(String label, String value, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label: $value', style: TextStyle(fontSize: 16)),
          IconButton(icon: Icon(Icons.edit), onPressed: onPressed),
        ],
      ),
    );
  }


  // Диалог с деталями поездки и кнопкой Finish для ваших поездок
  void _showTripDetailsDialog(Map<String, String> trip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Trip Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('From: ${trip['from']}'),
              Text('To: ${trip['to']}'),
              Text('Departure: ${trip['departure']}'),
              Text('Arrival: ${trip['arrival']}'),
              Text('Seats: ${trip['availableSeats']}/${trip['totalSeats']}'),
              Text('Driver: ${trip['driver']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрываем диалог без действий
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(activeTripsProvider.notifier)
                    .removeTrip(trip); // Удаляем поездку из активных
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            if (trip['driver'] == 'your') ...[
              TextButton(
                onPressed: () {
                  ref
                      .read(activeTripsProvider.notifier)
                      .removeTrip(trip); // Удаляем из активных
                  ref.read(tripHistoryProvider.notifier).addTripToHistory(
                      '${trip['from']} to ${trip['to']}'); // Добавляем в историю
                  Navigator.pop(context);
                },
                child: Text('Finish'),
              ),
            ],
          ],
        );
      },
    );
  }

  // Диалог для очистки истории
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
                Navigator.pop(context); // Закрываем диалог без действий
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(tripHistoryProvider.notifier)
                    .clearHistory(); // Очищаем историю поездок через провайдер
                Navigator.pop(context); // Закрываем диалог
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  // Диалог для изменения информации
  void _showEditDialog(
      BuildContext context, String field, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

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
                  _showErrorDialog(context,
                      'Phone number must start with +7 or 8 and contain 11 digits.');
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

  // Проверка email на правильность
  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Проверка телефона на правильность
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
}
