import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '89bf36a211eed46cb0aa46e32448131d'; // Replace with your OpenWeatherMap API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  // Fetch weather data by city name
  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Fetch weather data by coordinates (latitude and longitude)
  Future<Map<String, dynamic>> fetchWeatherByLocation(double lat, double lon) async {
    final response = await http.get(Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}