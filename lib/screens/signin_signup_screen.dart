import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inno_ft/services/auth_service.dart';
import 'profile_screen.dart';

class SignInSignUpScreen extends StatelessWidget {
  final AuthController _authController = AuthController();

  SignInSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "InnoFellowTravelers",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700.withOpacity(0.9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    _showSignInDialog(context);
                  },
                  child: const Text("Sign In", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900.withOpacity(0.9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    _showSignUpDialog(context);
                  },
                  child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool rememberMe = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.blue.shade50.withOpacity(0.9),
              title: Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: Colors.blue.shade700,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      Text(
                        "Remember me",
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await _authController.login(
                        emailController.text,
                        passwordController.text,
                      );

                      if (rememberMe) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('rememberMe', true);
                        await prefs.setString('email', emailController.text);
                        await prefs.setString(
                            'password', passwordController.text);
                      }

                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    } catch (err) {
                      _showErrorDialog(context, "Error logging in: $err");
                    }
                  },
                  child: const Text('Enter', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Sign-up Dialog
  void _showSignUpDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    bool rememberMe = false;
    bool isDriver = false;
    String role = "Fellow Traveller";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.blue.shade50.withOpacity(0.9),
              title: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: Colors.blue.shade700,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      Text(
                        "Remember me",
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Passenger",
                        style: TextStyle(
                            color: Colors.blue.shade900, fontSize: 16),
                      ),
                      Switch(
                        activeColor: Colors.blue.shade700,
                        value: isDriver,
                        onChanged: (value) {
                          setState(() {
                            isDriver = value;
                            role = isDriver ? "Driver" : "Fellow Traveller";
                          });
                        },
                      ),
                      Text(
                        "Driver",
                        style: TextStyle(
                            color: Colors.blue.shade900, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    String email = emailController.text;
                    String name = nameController.text;
                    String phone = phoneController.text;
                    String password = passwordController.text;
                    String confirmPassword = confirmPasswordController.text;

                    if (isDriver) {
                      role = "Driver";
                    }

                    if (name.isEmpty) {
                      _showErrorDialog(context, 'Name cannot be empty.');
                    } else if (email.isEmpty) {
                      _showErrorDialog(context, 'Email cannot be empty.');
                    } else if (!_isEmailValid(email)) {
                      _showErrorDialog(context,
                          'Email must contain "@" and a domain (e.g. @gmail.com).');
                    } else if (phone.isEmpty) {
                      _showErrorDialog(
                          context, 'Phone number cannot be empty.');
                    } else if (!_isPhoneValid(phone)) {
                      _showErrorDialog(context,
                          'Phone number must start with +7 or 8 and contain 11 digits.');
                    } else if (!_isPasswordValid(password)) {
                      _showErrorDialog(context,
                          'Password must be at least 8 characters long, include a digit and a special character.');
                    } else if (password != confirmPassword) {
                      _showErrorDialog(context, 'Passwords do not match.');
                    } else {
                      try {
                        await _authController.register(
                          name,
                          email,
                          phone,
                          password,
                          role,
                        );

                        if (rememberMe) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('email', email);
                          await prefs.setString('phone', phone);
                          await prefs.setString('password', password);
                          await prefs.setBool('isDriver', isDriver);
                          await prefs.setBool('rememberMe', true);
                        }

                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      } catch (e) {
                        _showErrorDialog(context, 'Error during sign up: $e');
                      }

                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    }
                  },
                  child: const Text('Enter', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Phone validation
  bool _isPhoneValid(String phone) {
    final RegExp phoneRegex = RegExp(r'^(\+7|8)\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  // Email validation
  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    bool hasDigit = password.contains(RegExp(r'\d'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasDigit && hasSpecialChar;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.blue.shade50.withOpacity(0.9),
          title: Center(
            child: Text(
              'Error',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        );
      },
    );
  }
}
