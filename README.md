# Best Bike Ride App 

A Flutter application that helps cyclists determine the best days and times for their rides based on weather conditions. The app provides a 7-day weather forecast with an intuitive quality score system to help users plan their cycling activities effectively.

## Features 🌟

- **5-Day Weather Forecast**: Comprehensive weather data for the next 5 days
- **Quality Score System**: Visual progress bar indicating ride conditions (0-100%)
- **Best Time Recommendations**: Suggests optimal riding times for each day
- **Location Services**: 
  - Manual city search
  - Automatic current location detection
- **Weather Indicators**:
  - Temperature
  - Weather conditions (Clear, Cloudy, Rain, etc.)
  - Time-specific forecasts

## Quality Score Calculation 📊

The app uses a sophisticated algorithm to calculate ride quality based on:

- **Temperature Range**:
  - 15-25°C: Optimal (80%)
  - 25-30°C: Moderate (50%)
  - Other: Less favorable (20%)
- **Weather Conditions**:
  - Clear: Excellent (80%)
  - Cloudy: Good (60%)
  - Rain: Poor (20%)
  - Other: Fair (40%)

The final score is an average of temperature and weather condition ratings, displayed as a circular progress indicator.

## Dependencies 📦

- **Flutter SDK**: ^3.6.2
- **intl**: ^0.18.0 - For date formatting
- **geolocator**: ^9.0.2 - For location services
- **geocoding**: ^2.0.5 - For reverse geocoding
- **http**: ^1.3.0 - For API requests
- **cupertino_icons**: ^1.0.8

## Project Structure 📁

bike_ride_app/
├── lib/
│ ├── main.dart # App entry point
│ ├── screens/
│ │ └── weather_screen.dart # Main weather display screen
│ └── services/
│ └── weather_service.dart # Weather API service
├── android/ # Android-specific files
├── ios/ # iOS-specific files
├── web/ # Web platform files
├── windows/ # Windows platform files
├── linux/ # Linux platform files
├── macos/ # macOS platform files
├── test/ # Test files
├── pubspec.yaml # Project dependencies
└── README.md # Project documentation

### Key Components:

- **lib/main.dart**: Entry point of the application, sets up the theme and initial screen
- **lib/screens/weather_screen.dart**: Main screen containing:
  - City search functionality
  - Location detection
  - Weather display cards
  - Quality score indicators
  - Best time recommendations
- **lib/services/weather_service.dart**: Handles:
  - OpenWeatherMap API integration
  - Weather data fetching
  - Location-based queries

## Getting Started 🚀

1. **Prerequisites**:
   - Flutter SDK
   - Android Studio / VS Code
   - OpenWeatherMap API key

2. **Installation**:
   ```bash
   git clone https://github.com/ajintsdev/Best-Bike-Ride-Day.git
   cd bike_ride_app
   flutter pub get
   ```

3. **API Configuration**:
   - Add your OpenWeatherMap API key in `lib/services/weather_service.dart`

4. **Run the app**:
   ```bash
   flutter run
   ```

## Permissions Required 🔒

- Location access (for automatic location detection)
- Internet access (for weather data fetching)

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Screenshots 📱

[Add screenshots of your app here]

## Support 💪

If you like this project, please give it a ⭐️ on GitHub!

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
