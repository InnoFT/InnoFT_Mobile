import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateTripScreen extends ConsumerStatefulWidget {
  @override
  _CreateTripScreenState createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  late MapboxMapController mapController;

  LatLng? startPoint;
  LatLng? destinationPoint;
  LatLng? userLocation;

  TextEditingController availableSeatsController = TextEditingController();
  TextEditingController carController =
      TextEditingController(text: "Reno Logan");
  TextEditingController priceController = TextEditingController();
  TextEditingController commentsController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapTapped(LatLng coordinates) {
    setState(() {
      if (startPoint == null) {
        // Set pickup point
        startPoint = coordinates;
        mapController.addSymbol(SymbolOptions(
          geometry: startPoint!,
          iconImage: "car-15",
          iconSize: 2.5,
        ));
      } else if (destinationPoint == null) {
        // Set destination point
        destinationPoint = coordinates;
        mapController.addSymbol(SymbolOptions(
          geometry: destinationPoint!,
          iconImage: "castle-15",
          iconSize: 2.5,
        ));
        _getRouteAndDrawPolyline();
      } else {
        mapController.clearSymbols();
        mapController.clearLines();
        startPoint = coordinates;
        destinationPoint = null;
        mapController.addSymbol(SymbolOptions(
          geometry: startPoint!,
          iconImage: "car-15",
          iconSize: 2.5,
        ));
      }
    });
  }

  Future<void> _getRouteAndDrawPolyline() async {
    if (startPoint == null || destinationPoint == null) return;

    final String apiKey =
        'pk.eyJ1IjoibGVsb25vdjIzIiwiYSI6ImNtMWlqc2YxbTBtb3EyanMyMDFyYXU2bGMifQ.tk-A8ed40Avnbu_-NXM69g';
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${startPoint!.longitude},${startPoint!.latitude};${destinationPoint!.longitude},${destinationPoint!.latitude}?geometries=geojson&access_token=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'] as List;
      List<LatLng> polylineCoordinates =
          route.map((coord) => LatLng(coord[1], coord[0])).toList();

      mapController.addLine(LineOptions(
        geometry: polylineCoordinates,
        lineColor: "#0000FF",
        lineWidth: 5.0,
      ));
    } else {
      print('Error fetching route: ${response.statusCode}');
    }
  }

  void _createTrip() {
    if (startPoint == null || destinationPoint == null) {
      _showErrorDialog("Please select both pickup and destination points.");
      return;
    }
  }

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

  Future<void> _selectStartTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue.shade700,
            timePickerTheme: TimePickerThemeData(
              dialHandColor: Colors.blue.shade700,
              dialBackgroundColor: Colors.blue.shade100,
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade700, width: 2),
              ),
            ),
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onSurface: Colors.black,
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        startTimeController.text = selectedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.blue.shade900.withOpacity(0.8),
            ),
          ),
          userLocation == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 400,
                        child: MapboxMap(
                          accessToken:
                              'pk.eyJ1IjoibGVsb25vdjIzIiwiYSI6ImNtMWlqc2YxbTBtb3EyanMyMDFyYXU2bGMifQ.tk-A8ed40Avnbu_-NXM69g',
                          onMapCreated: (controller) =>
                              mapController = controller,
                          onMapClick: (point, coordinates) =>
                              _onMapTapped(coordinates),
                          initialCameraPosition: CameraPosition(
                            target: userLocation!,
                            zoom: 14.0,
                          ),
                          myLocationEnabled: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display pickup point
                            if (startPoint != null) ...[
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.green),
                                  SizedBox(width: 10),
                                  Text(
                                    "Pickup Point: ${startPoint!.latitude}, ${startPoint!.longitude}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (destinationPoint != null) ...[
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.flag, color: Colors.red),
                                  SizedBox(width: 10),
                                  Text(
                                    "Destination Point: ${destinationPoint!.latitude}, ${destinationPoint!.longitude}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            SizedBox(height: 20),

                            Card(
                              color: Colors.blue.shade50.withOpacity(0.9),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: availableSeatsController,
                                      decoration: InputDecoration(
                                        labelText: "Available Seats",
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade900,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: carController,
                                      decoration: InputDecoration(
                                        labelText: "Car",
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade900,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: priceController,
                                      decoration: InputDecoration(
                                        labelText: "Price per Passenger",
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade900,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: startTimeController,
                                      decoration: InputDecoration(
                                        labelText: "Start Time",
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade900,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                      onTap: () => _selectStartTime(context),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: commentsController,
                                      decoration: InputDecoration(
                                        labelText: "Comments",
                                        labelStyle: TextStyle(
                                          color: Colors.blue.shade900,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                    ),
                                    SizedBox(height: 20),
                                    Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade700
                                              .withOpacity(0.9),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        onPressed: _createTrip,
                                        child: Text("Create Trip",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
