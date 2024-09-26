import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  _CreateTripScreenState createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  // Mapbox controller
  late MapboxMapController mapController;

  // Coordinates for start and destination points
  LatLng? startPoint;
  LatLng? destinationPoint;

  // User location
  LatLng? userLocation;

  // Text controllers for trip details
  TextEditingController availableSeatsController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get user location on initialization
  }

  // Get current position of the user
  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      const double defaultLatitude = 55.75229643707189;
      const double defaultLongitude = 48.74462643352501;
      setState(() {
        userLocation = const LatLng(defaultLatitude, defaultLongitude);
      });
    }
  }

  // Callback when map is tapped to set points and add markers
  void _onMapTapped(LatLng coordinates) {
    setState(() {
      if (startPoint == null) {
        // Set pickup point
        startPoint = coordinates;
        mapController.addSymbol(SymbolOptions(
          geometry: startPoint!,
          iconImage: "car-15", // Pickup point icon
          iconSize: 2.5, // Make the marker bigger
        ));
      } else if (destinationPoint == null) {
        // Set destination point
        destinationPoint = coordinates;
        mapController.addSymbol(SymbolOptions(
          geometry: destinationPoint!,
          iconImage: "castle-15", // Destination point icon
          iconSize: 2.5, // Make the marker bigger
        ));
        // Once both points are set, fetch and draw the route
        _getRouteAndDrawPolyline();
      } else {
        // Reset the map: clear markers and route
        mapController.clearSymbols(); // Clear markers
        mapController.clearLines(); // Clear the drawn route
        startPoint = coordinates; // Set the new pickup point
        destinationPoint = null; // Reset destination
        mapController.addSymbol(SymbolOptions(
          geometry: startPoint!,
          iconImage: "car-15",
          iconSize: 2.5,
        ));
      }
    });
  }

  // Fetch route from Mapbox Directions API and draw polyline
  Future<void> _getRouteAndDrawPolyline() async {
    if (startPoint == null || destinationPoint == null) return;

    const String apiKey =
        'pk.eyJ1IjoibGVsb25vdjIzIiwiYSI6ImNtMWlqc2YxbTBtb3EyanMyMDFyYXU2bGMifQ.tk-A8ed40Avnbu_-NXM69g';
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${startPoint!.longitude},${startPoint!.latitude};${destinationPoint!.longitude},${destinationPoint!.latitude}?geometries=geojson&access_token=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'] as List;
      List<LatLng> polylineCoordinates = route
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList(); // Reversing to LatLng format

      mapController.addLine(LineOptions(
        geometry: polylineCoordinates,
        lineColor: "#ff0000", // Red color for the line
        lineWidth: 5.0,
      ));
    } else {
      print('Error fetching route: ${response.statusCode}');
    }
  }

  // Function to create the trip using input data
  Future<void> _createTrip() async {
    if (startPoint == null || destinationPoint == null) {
      _showErrorDialog("Please select both pickup and destination points.");
      return;
    }
    // You can handle trip creation logic here
    final url = Uri.parse('http://localhost:8069/tips/create');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "total_seats": availableSeatsController.value,
          "price_per_seat": priceController.value,
          "start_latitude": startPoint!.latitude,
          "start_longitude": startPoint!.longitude,
          "end_latitude": destinationPoint!.latitude,
          "end_longitude": destinationPoint!.longitude,
        }),
      );

      if (response.statusCode != 200) {
        _showErrorDialog('Error creating trip: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error creating trip: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Trip"),
        backgroundColor: Colors.teal,
      ),
      body: userLocation == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader until user location is fetched
          : SingleChildScrollView(
              // Make the screen scrollable to avoid overflow
              child: Column(
                children: [
                  // Map for selecting pickup and destination
                  SizedBox(
                    height: 400,
                    child: MapboxMap(
                      accessToken:
                          'pk.eyJ1IjoibGVsb25vdjIzIiwiYSI6ImNtMWlqc2YxbTBtb3EyanMyMDFyYXU2bGMifQ.tk-A8ed40Avnbu_-NXM69g',
                      onMapCreated: (controller) => mapController = controller,
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
                              const Icon(Icons.location_on,
                                  color: Colors.green),
                              const SizedBox(width: 10),
                              Text(
                                "Pickup Point: ${startPoint!.latitude}, ${startPoint!.longitude}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        // Display destination point
                        if (destinationPoint != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.flag, color: Colors.red),
                              const SizedBox(width: 10),
                              Text(
                                "Destination Point: ${destinationPoint!.latitude}, ${destinationPoint!.longitude}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        // Form for trip details
                        Card(
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
                                  decoration: const InputDecoration(
                                    labelText: "Available Seats",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: priceController,
                                  decoration: const InputDecoration(
                                    labelText: "Price per Passenger",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: commentsController,
                                  decoration: const InputDecoration(
                                    labelText: "Comments",
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: _createTrip,
                                    child: const Text("Create Trip"),
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
    );
  }
}
