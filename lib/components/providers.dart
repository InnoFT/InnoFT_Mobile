import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для профиля
final profileProvider = StateProvider<String>((ref) {
  return "User Name"; // Изначально имя пользователя
});

// Провайдер для управления поездками (список поездок)
final tripProvider = StateProvider<List<String>>((ref) {
  return ["Trip 1", "Trip 2"]; // Изначально список поездок
});
