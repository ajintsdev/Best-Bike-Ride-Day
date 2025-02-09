import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Import for reverse geocoding
import 'dart:math'; // Import for pi constant
import '../services/weather_service.dart'; // Import the weather service

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  List<dynamic>? _weatherData;
  bool _isLoading = false;
  String? _error;
  final TextEditingController _cityController = TextEditingController();

  // Function to get weather icons based on condition
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.cloudy_snowing;
      default:
        return Icons.help_outline;
    }
  }

  // Fetch weather data by city name
  Future<void> _fetchWeatherByCity() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _weatherService.fetchWeatherByCity(_cityController.text);
      if (data['list'] == null) {
        throw Exception('No weather data available');
      }
      setState(() {
        _weatherData = data['list'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch weather data. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Fetch weather data by current location
  Future<void> _fetchWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      // Fetch current location
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Reverse geocode coordinates to get the city name
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String? city = placemarks[0].locality; // Extract city name
      if (city != null) {
        setState(() {
          _cityController.text = city; // Populate the TextField with the city name
        });
      }

      // Fetch weather data using coordinates
      final data = await _weatherService.fetchWeatherByLocation(position.latitude, position.longitude);
      if (data['list'] == null) {
        throw Exception('No weather data available');
      }
      setState(() {
        _weatherData = data['list'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch location or weather data. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Best Bike Day'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Enter City Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchWeatherByLocation,
                  child: Icon(Icons.my_location),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWeatherByCity,
              child: Text('Get Weather'),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(child: Text('Error: $_error'))
            else if (_weatherData != null)
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      itemCount: _weatherData!.length ~/ 8, // Show one card per day (8 forecasts per day)
                      itemBuilder: (context, index) {
                        final weather = _weatherData![index * 8]; // Get the first forecast of the day
                        final date = DateTime.parse(weather['dt_txt']);
                        final formattedDate = DateFormat('EEE, MMM d').format(date);
                        final temp = weather['main']['temp'];
                        final condition = weather['weather'][0]['main'];
                        final rideQuality = _calculateRideQuality(temp, condition);

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.grey[850],
                          child: Container(
                            height: 150,
                            padding: EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(_getWeatherIcon(condition), size: 50, color: Colors.white),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(formattedDate, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                      SizedBox(height: 8),
                                      Text('$condition, $temp°C', style: TextStyle(fontSize: 16, color: Colors.white)),
                                      SizedBox(height: 8),
                                      Text(
                                        'Best Time to Ride: ${_getBestTime(_weatherData!, index)}',
                                        style: TextStyle(fontSize: 14, color: Colors.greenAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                ModernCircularProgressBar(rideQuality: rideQuality),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Center(child: Text('No weather data available')),
          ],
        ),
      ),
    );
  }

  // Calculate ride quality based on temperature and condition
  double _calculateRideQuality(double temp, String condition) {
    double tempQuality = _getTemperatureQuality(temp);
    double conditionQuality = _getConditionQuality(condition);
    return (tempQuality + conditionQuality) / 2; // Normalize to 0.0–1.0 range
  }

  double _getTemperatureQuality(double temp) {
    if (temp >= 15 && temp <= 25) {
      return 0.8; // Ideal temperature range
    } else if (temp > 25 && temp <= 30) {
      return 0.5; // Warm but acceptable
    } else {
      return 0.2; // Too cold or too hot
    }
  }

  double _getConditionQuality(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 0.8;
      case 'clouds':
        return 0.6;
      case 'rain':
        return 0.2;
      default:
        return 0.4;
    }
  }

  // Get best time to ride based on hourly forecasts
  String _getBestTime(List<dynamic> weatherData, int dayIndex) {
    final dayForecasts = weatherData.skip(dayIndex * 8).take(8); // Get all forecasts for the day
    final bestForecast = dayForecasts
        .where((forecast) => forecast['main']['temp'] > 15) // Filter comfortable temperatures
        .reduce((a, b) => a['main']['temp'] < b['main']['temp'] ? a : b); // Find the lowest temp

    if (bestForecast != null) {
      final time = DateFormat('h a').format(DateTime.parse(bestForecast['dt_txt']));
      final temp = bestForecast['main']['temp'];
      return '$time ($temp°C)';
    }
    return 'Not ideal today';
  }
}

// Custom Circular Progress Bar
class ModernCircularProgressBar extends StatelessWidget {
  final double rideQuality;

  const ModernCircularProgressBar({super.key, required this.rideQuality});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[850],
          ),
        ),
        CustomPaint(
          size: Size(80, 80),
          painter: ProgressPainter(rideQuality: rideQuality),
        ),
        Text(
          '${(rideQuality * 100).toInt()}%',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}

// Custom Painter for Solid Color Progress Arc
class ProgressPainter extends CustomPainter {
  final double rideQuality;

  ProgressPainter({required this.rideQuality});

  @override
  void paint(Canvas canvas, Size size) {
    final Color startColor = Color.lerp(Colors.green.shade300, Colors.red.shade300, 1 - rideQuality)!;

    final paint = Paint()
      ..color = startColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      -pi / 2,
      2 * pi * rideQuality,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}