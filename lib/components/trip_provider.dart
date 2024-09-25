import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeTripsProvider = StateNotifierProvider<ActiveTripsNotifier, List<Map<String, String>>>((ref) {
  return ActiveTripsNotifier();
});

class ActiveTripsNotifier extends StateNotifier<List<Map<String, String>>> {
  ActiveTripsNotifier() : super([]);

  // Добавление поездки в активные поездки
  void addTrip(Map<String, String> trip) {
    state = [...state, trip];
  }

  // Удаление поездки
  void removeTrip(Map<String, String> trip) {
    state = state.where((t) => t != trip).toList();
  }

  // Очистка всех поездок
  void clearTrips() {
    state = [];
  }
}

final tripHistoryProvider = StateNotifierProvider<TripHistoryNotifier, List<String>>((ref) {
  return TripHistoryNotifier();
});

class TripHistoryNotifier extends StateNotifier<List<String>> {
  TripHistoryNotifier() : super([]);

  // Добавление поездки в историю поездок
  void addTripToHistory(String trip) {
    state = [...state, trip];
  }

  // Очистка истории поездок
  void clearHistory() {
    state = [];
  }
}

