import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/providers.dart'; // Подключаем провайдеры
class FindTripScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripProvider); // Подключаем провайдер поездок

    return Scaffold(
      appBar: AppBar(
        title: Text("Find a Trip Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Available Trips to Join:"),
            for (final trip in trips) Text(trip), // Отображаем все доступные поездки
          ],
        ),
      ),
    );
  }
}
