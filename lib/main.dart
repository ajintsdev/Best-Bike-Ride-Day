import 'package:flutter/material.dart';
import 'screens/weather_screen.dart';

void main() {
  runApp(BikeRideHelperApp());
}

class BikeRideHelperApp extends StatelessWidget {
  const BikeRideHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bike Ride Helper',
      theme: ThemeData.dark(), // Enable dark theme
      home: WeatherScreen(),
    );
  }
}