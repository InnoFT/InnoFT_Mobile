import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inno_ft/components/theme_provider.dart';

class ThemeToggleSwitch extends ConsumerStatefulWidget {
  @override
  _ThemeToggleSwitchState createState() => _ThemeToggleSwitchState();
}

class _ThemeToggleSwitchState extends ConsumerState<ThemeToggleSwitch> {
  bool _isExpanded = false; // Track whether the theme toggle is expanded

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider); // Watch for theme changes

    return Stack(
      children: [
        // Sliding theme switch container
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          left: _isExpanded ? 0 : -180, // Slide offscreen when collapsed
          top: MediaQuery.of(context).size.height / 2 - 50, // Center vertically
          child: Container(
            width: 200, // Fixed width for the container
            padding: EdgeInsets.all(8.0), // Add padding for better appearance
            decoration: BoxDecoration(
              color: isDarkTheme ? Colors.blue.shade900 : Colors.blue.shade200, // Background color
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black12, // Add a shadow for better visibility
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arrow to indicate toggle action positioned on the right side of the panel
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Align arrow to the right
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded; // Toggle the expansion
                        });
                      },
                      child: Icon(
                        _isExpanded
                            ? Icons.arrow_back_ios
                            : Icons.arrow_forward_ios, // Arrow icon
                        size: 16,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                // "Dark theme" label
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Dark theme',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black, // Text color based on theme
                      fontSize: 16,
                    ),
                  ),
                ),
                // Switch to toggle theme (Doesn't collapse the panel on interaction)
                Switch(
                  value: isDarkTheme,
                  onChanged: (value) {
                    ref.read(themeNotifierProvider.notifier).toggleTheme(); // Toggle theme
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.blueAccent, // Customize switch color in dark mode
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
