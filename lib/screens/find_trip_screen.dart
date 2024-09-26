import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Импортируем Riverpod
import '../components/trip_provider.dart'; // Импортируем провайдер для активных поездок

class FindTripScreen extends ConsumerStatefulWidget {
  @override
  _FindTripScreenState createState() => _FindTripScreenState();
}

class _FindTripScreenState extends ConsumerState<FindTripScreen> {
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();

  List<Map<String, String>> availableTrips = [];

  // Метод для отправки данных на сервер (пока заглушка)
  void _findTrips() {
    String from = fromController.text;
    String to = toController.text;

    if (from.isEmpty || to.isEmpty) {
      _showErrorDialog('Please fill in both fields.');
      return;
    }

    // Заглушка для получения списка поездок с сервера
    setState(() {
      availableTrips = [
        {
          'from': from,
          'to': to,
          'departure': '10:00 AM',
          'arrival': '12:00 PM',
          'availableSeats': '3',
          'totalSeats': '4',
          'driverName': 'John Doe',
          'driverPhone': '+71234567890',
        },
        {
          'from': from,
          'to': to,
          'departure': '1:00 PM',
          'arrival': '3:00 PM',
          'availableSeats': '2',
          'totalSeats': '4',
          'driverName': 'Jane Smith',
          'driverPhone': '+79876543210',
        },
      ];
    });
  }

  // Метод для показа диалога с ошибкой
  void _showErrorDialog(String message) {
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

  // Метод для показа диалога с деталями поездки
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
              Text('Driver: ${trip['driverName']}'),
              Text('Driver Phone: ${trip['driverPhone']}'),
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
                _bookTrip(trip); // Бронируем поездку
                Navigator.pop(context); // Закрываем диалог
              },
              child: Text('Book'),
            ),
          ],
        );
      },
    );
  }

  // Метод для бронирования поездки
  void _bookTrip(Map<String, String> trip) {
    ref.read(activeTripsProvider.notifier).addTrip(trip); // Добавляем поездку в провайдер активных поездок
    print('Booking trip from ${trip['from']} to ${trip['to']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find a Trip'),
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
                    decoration: InputDecoration(labelText: 'From'),
                  ),
                ),
                Icon(Icons.arrow_forward, size: 24),
                Expanded(
                  child: TextField(
                    controller: toController,
                    decoration: InputDecoration(labelText: 'To'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _findTrips, // Поиск поездок
                child: Text('Find'),
              ),
            ),
            SizedBox(height: 20),

            if (availableTrips.isNotEmpty) ...[
              Text(
                'Available Trips:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: availableTrips.length,
                  itemBuilder: (context, index) {
                    final trip = availableTrips[index];
                    return ListTile(
                      title: Text('From ${trip['from']} to ${trip['to']}'),
                      subtitle: Text('Departure: ${trip['departure']}'),
                      onTap: () => _showTripDetailsDialog(trip), // Открываем диалог с деталями
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
