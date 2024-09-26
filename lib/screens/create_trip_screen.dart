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
  // Mapbox controller
  late MapboxMapController mapController;

  // Coordinates for start and destination points
  LatLng? startPoint;
  LatLng? destinationPoint;

  // User location
  LatLng? userLocation;

  // Text controllers for trip details
  TextEditingController availableSeatsController = TextEditingController();
  TextEditingController carController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get user location on initialization
  }

  // Get current position of the user
  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
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
        mapController.clearSymbols();  // Clear markers
        mapController.clearLines();    // Clear the drawn route
        startPoint = coordinates;      // Set the new pickup point
        destinationPoint = null;       // Reset destination
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

    final String apiKey = 'pk.eyJ1IjoibGVsb25vdjIzIiwiYSI6ImNtMWlqc2YxbTBtb3EyanMyMDFyYXU2bGMifQ.tk-A8ed40Avnbu_-NXM69g';
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
  void _createTrip() {
    if (startPoint == null || destinationPoint == null) {
      _showErrorDialog("Please select both pickup and destination points.");
      return;
    }

    // You can handle trip creation logic here
    print("Trip created with the following data:");
    print("Pickup: $startPoint, Destination: $destinationPoint");
    print("Available Seats: ${availableSeatsController.text}");
    print("Car: ${carController.text}");
    print("Price per Passenger: ${priceController.text}");
    print("Comments: ${commentsController.text}");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Trip"),
        backgroundColor: Colors.teal,
      ),
      body: userLocation == null
          ? Center(child: CircularProgressIndicator()) // Show loader until user location is fetched
          : SingleChildScrollView( // Make the screen scrollable to avoid overflow
              child: Column(
                children: [
                  // Map for selecting pickup and destination
                  SizedBox(
                    height: 400,
                    child: MapboxMap(
                      accessToken: 'pk.eyJ1IjoibGVsb25vdjIzIiwiYSI6ImNtMWlqc2YxbTBtb3EyanMyMDFyYXU2bGMifQ.tk-A8ed40Avnbu_-NXM69g',
                      onMapCreated: (controller) => mapController = controller,
                      onMapClick: (point, coordinates) => _onMapTapped(coordinates),
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        // Display destination point
                        if (destinationPoint != null) ...[
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.flag, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                "Destination Point: ${destinationPoint!.latitude}, ${destinationPoint!.longitude}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 20),
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
                                  decoration: InputDecoration(
                                    labelText: "Available Seats",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: carController,
                                  decoration: InputDecoration(
                                    labelText: "Car",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: priceController,
                                  decoration: InputDecoration(
                                    labelText: "Price per Passenger",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: commentsController,
                                  decoration: InputDecoration(
                                    labelText: "Comments",
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: _createTrip,
                                    child: Text("Create Trip"),
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
