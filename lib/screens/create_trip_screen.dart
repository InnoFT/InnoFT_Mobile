import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../components/trip_provider.dart'; // Импортируем провайдер поездок

class CreateTripScreen extends ConsumerStatefulWidget {
  @override
  _CreateTripScreenState createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  // Контроллеры для полей ввода
  TextEditingController startPointController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController finishTimeController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController finishDateController = TextEditingController();
  TextEditingController availableSeatsController = TextEditingController();
  TextEditingController carController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  // Функция для выбора времени
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('HH:mm').format(
        DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
      );
      controller.text = formattedTime;
    }
  }

  // Функция для выбора даты
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      controller.text = formattedDate;
    }
  }

  // Функция для проверки заполненности всех полей, проверки на дату и цифры
  bool _validateFields() {
    if (startPointController.text.isEmpty ||
        destinationController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        finishTimeController.text.isEmpty ||
        startDateController.text.isEmpty ||
        finishDateController.text.isEmpty ||
        availableSeatsController.text.isEmpty ||
        carController.text.isEmpty ||
        priceController.text.isEmpty) {
      _showErrorDialog("All fields except comments must be filled.");
      return false;
    }
    
    if (!_isNumeric(availableSeatsController.text)) {
      _showErrorDialog("Available seats must be a numeric value.");
      return false;
    }
    
    if (!_isNumeric(priceController.text)) {
      _showErrorDialog("Price must be a numeric value.");
      return false;
    }

    DateTime startDateTime = DateTime.parse('${startDateController.text} ${startTimeController.text}');
    DateTime finishDateTime = DateTime.parse('${finishDateController.text} ${finishTimeController.text}');
    
    if (finishDateTime.isBefore(startDateTime)) {
      _showErrorDialog("Arrival date/time cannot be earlier than departure date/time.");
      return false;
    }

    return true;
  }

  // Проверка на числовые значения
  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  // Функция для проверки времени отправления
bool _isDepartureTimeValid() {
  DateTime now = DateTime.now();
  DateTime startDateTime = DateTime.parse('${startDateController.text} ${startTimeController.text}');
  
  if (startDateTime.isBefore(now)) {
    _showErrorDialog("Departure date/time cannot be earlier than the current date/time.");
    return false;
  }
  
  return true;
}

// Функция для создания поездки
void _createTrip() {
  if (_validateFields() && _isDepartureTimeValid()) {
    // Создаем поездку и добавляем в провайдер активных поездок
    final newTrip = {
      'from': startPointController.text,
      'to': destinationController.text,
      'departure': '${startDateController.text} ${startTimeController.text}',
      'arrival': '${finishDateController.text} ${finishTimeController.text}',
      'availableSeats': availableSeatsController.text,
      'totalSeats': availableSeatsController.text,
      'car': carController.text,
      'price': priceController.text,
      'comments': commentsController.text,
      'driver': 'your', // Отмечаем, что поездка принадлежит пользователю
    };

    ref.read(activeTripsProvider.notifier).addTrip(newTrip);
    Navigator.pushReplacementNamed(context, '/profile'); // Возвращаемся на экран профиля
  }
}


  // Показ ошибки
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Trip"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: startPointController,
              decoration: InputDecoration(labelText: "Start Point"),
            ),
            TextField(
              controller: destinationController,
              decoration: InputDecoration(labelText: "Destination"),
            ),
            TextField(
              controller: startDateController,
              readOnly: true,
              decoration: InputDecoration(labelText: "Start Date"),
              onTap: () => _selectDate(context, startDateController),
            ),
            TextField(
              controller: startTimeController,
              readOnly: true,
              decoration: InputDecoration(labelText: "Start Time"),
              onTap: () => _selectTime(context, startTimeController),
            ),
            TextField(
              controller: finishDateController,
              readOnly: true,
              decoration: InputDecoration(labelText: "Finish Date"),
              onTap: () => _selectDate(context, finishDateController),
            ),
            TextField(
              controller: finishTimeController,
              readOnly: true,
              decoration: InputDecoration(labelText: "Finish Time"),
              onTap: () => _selectTime(context, finishTimeController),
            ),
            TextField(
              controller: availableSeatsController,
              decoration: InputDecoration(labelText: "Available Seats"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: carController,
              decoration: InputDecoration(labelText: "Car"),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Price per Passenger"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: commentsController,
              decoration: InputDecoration(labelText: "Comments"),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createTrip,
              child: Text("Create Trip"),
            ),
          ],
        ),
      ),
    );
  }
}
