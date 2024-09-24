import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/providers.dart'; // Подключаем провайдеры
class CreateTripScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripProvider); // Подключаем провайдер поездок

    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Trip Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Available Trips:"),
            for (final trip in trips) Text(trip), // Отображаем все поездки
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newTrip = "Trip ${trips.length + 1}";
                ref.read(tripProvider.notifier).state = [...trips, newTrip]; // Добавляем новую поездку
              },
              child: Text("Create New Trip"),
            ),
          ],
        ),
      ),
    );
  }
}
