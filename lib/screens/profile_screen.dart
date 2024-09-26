import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inno_ft/screens/signin_signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../components/trip_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/create_trip_screen.dart';
import '../screens/find_trip_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _imageFile;
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  String? profileImageUrl;
  double userRating = 0.0;
  List<String> activeTrips = [];
  List<String> tripHistory = [];
  String? token;

  final String baseUrl = "http://localhost:8069";

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('Authorization');

    if (authToken == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignInSignUpScreen()),
      );
    } else {
      setState(() {
        token = authToken;
      });
      _loadUserData(authToken);
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUserData(String? authToken) async {
    if (authToken == null) {
      showErrorDialog(context, 'Error: No authentication token found.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['user'];
        setState(() {
          userName = data['Name'];
          userEmail = data['Email'];
          userPhone = data['Phone'];
          userRating = data['Raiting'] ?? 0.0;
          profileImageUrl = data['ProfilePic'] ?? "";
          activeTrips = ["None"];
          tripHistory = ["None"];
        });
      } else {
        showErrorDialog(
            context, 'Error loading profile: ${response.statusCode}');
      }
    } catch (e) {
      showErrorDialog(context, 'Error loading profile: $e');
    }
  }

  Future<void> _updateUserProfile(String name, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Authorization');

    if (token == null) {
      showErrorDialog(context, 'User is not authenticated');
      return;
    }

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/user/profile'),
      );
      request.headers['Authorization'] = token;
      request.fields['name'] = name;
      request.fields['city'] = phone;

      if (_imageFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('profile_pic', _imageFile!.path));
      }

      var response = await request.send();
      if (response.statusCode != 200) {
        showErrorDialog(
            context, 'Error updating profile: ${response.statusCode}');
      }
    } catch (e) {
      showErrorDialog(context, 'Error updating profile: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _updateUserProfile(userName, userPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTrips = ref
        .watch(activeTripsProvider); // Получаем активные поездки из провайдера
    final tripHistory = ref
        .watch(tripHistoryProvider); // Получаем историю поездок из провайдера

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile Screen'),
          bottom: const TabBar(
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

  void showEditDialog(BuildContext context, String field, String currentValue) {
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (field == 'name' && controller.text.isEmpty) {
                  showErrorDialog(context, 'Name cannot be empty.');
                  return;
                }
                if (field == 'email' && !isEmailValid(controller.text)) {
                  showErrorDialog(context, 'Invalid email format.');
                  return;
                }
                if (field == 'phone' && !isPhoneValid(controller.text)) {
                  showErrorDialog(context,
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
                _updateUserProfile(userName, userEmail);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context) {
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
                      : (profileImageUrl != "" && token != null
                              ? NetworkImage(
                                  "$baseUrl/user/profile/picture",
                                  headers: {
                                    'Authorization': token!,
                                  },
                                )
                              : const AssetImage(
                                  'assets/base_profile_picture.jpeg'))
                          as ImageProvider,
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Change Photo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildUserInfo('Name', userName, () {
            showEditDialog(context, 'name', userName);
          }),
          _buildUserInfo('Email', userEmail, () {
            showEditDialog(context, 'email', userEmail);
          }),
          _buildUserInfo('Phone', userPhone, () {
            showEditDialog(context, 'phone', userPhone);
          }),
          const SizedBox(height: 20),
          Text(
            'Rating: $userRating',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Active Trips:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (activeTrips.isEmpty)
            const Text('No active trips available.')
          else
            const Text('Some active trips available.'),
          const SizedBox(height: 20),
          const Text(
            'Trip History:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (tripHistory.isEmpty)
            const Text('No trip history available.')
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
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }

  // Виджет для активных поездок с возможностью завершить поездку
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

  // Диалог с деталями поездки и кнопкой Finish для ваших поездок
  void _showTripDetailsDialog(Map<String, String> trip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trip Details'),
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
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                ref.read(activeTripsProvider.notifier).removeTrip(trip);
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
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

  bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool isPhoneValid(String phone) {
    final RegExp phoneRegex = RegExp(r'^(\+7|8)\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  Widget _buildUserInfo(String label, String value, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Trip History'),
          content:
              const Text('Are you sure you want to clear your trip history?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(tripHistoryProvider.notifier).clearHistory();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
    List<Widget> _buildActiveTrips(List<String> trips) {
      if (trips.isEmpty) {
        return [const Text('No active trips available.')];
      }
      return trips.map((trip) => ListTile(title: Text(trip))).toList();
    }

    List<Widget> _buildTripHistory(List<String> trips) {
      if (trips.isEmpty) {
        return [const Text('No trip history available.')];
      }
      return trips.map((trip) => ListTile(title: Text(trip))).toList();
    }

    // Диалог подтверждения для очистки истории
    void _showClearHistoryDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Clear Trip History'),
            content:
                const Text('Are you sure you want to clear your trip history?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    tripHistory = [];
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          );
        },
      );
    }
  }
}
