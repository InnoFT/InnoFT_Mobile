import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../components/trip_provider.dart';

class FindTripScreen extends ConsumerStatefulWidget {
  const FindTripScreen({super.key});

  @override
  _FindTripScreenState createState() => _FindTripScreenState();
}

class _FindTripScreenState extends ConsumerState<FindTripScreen> {
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();

  List<Map<String, dynamic>> availableTrips = [];

  Future<void> _findTrips() async {
    String from = fromController.text;
    String to = toController.text;

    if (from.isEmpty || to.isEmpty) {
      _showErrorDialog('Please fill in both fields.');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('Authorization');

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8069/trips/available?start_city=$from&end_city=$to'), headers: {"Content-Type": "application/json", "Authorization": authToken!},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          availableTrips = List<Map<String, dynamic>>.from(data['trips']);
        });
      } else {
        _showErrorDialog('Failed to fetch trips.');
      }
    } catch (e) {
      _showErrorDialog('Error occurred: $e');
    }
  }

  // Error dialog
  void _showErrorDialog(String message) {
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

  void _showTripDetailsDialog(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trip Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('From: ${trip['startLocation']['city']}'),
              Text('To: ${trip['endLocation']['city']}'),
              Text('Departure: ${trip['departureTime']}'),
              Text('Seats: ${trip['availableSeats']}/${trip['totalSeats']}'),
              Text('Driver: ${trip['driver']['name']}'),
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
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('Book'),
            ),
          ],
        );
      },
    );
  }

  // Book trip method
  void _bookTrip(Map<String, String> trip) {
    ref.read(activeTripsProvider.notifier).addTrip(trip);
    print('Booking trip from ${trip['startLocation']} to ${trip['endLocation']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fromController,
                    decoration: const InputDecoration(labelText: 'From'),
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 24),
                Expanded(
                  child: TextField(
                    controller: toController,
                    decoration: const InputDecoration(labelText: 'To'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _findTrips, // Fetch trips from API
                child: const Text('Find'),
              ),
            ),
            const SizedBox(height: 20),
            if (availableTrips.isNotEmpty) ...[
              const Text(
                'Available Trips:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: availableTrips.length,
                  itemBuilder: (context, index) {
                    final trip = availableTrips[index];
                    return ListTile(
                      title: Text('From ${trip['startLocation']['city']} to ${trip['endLocation']['city']}'),
                      subtitle: Text('Departure: ${trip['departureTime']}'),
                      onTap: () => _showTripDetailsDialog(trip), // Show trip details
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
