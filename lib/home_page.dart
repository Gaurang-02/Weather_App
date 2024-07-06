import 'package:flutter/material.dart';
import 'package:weather_app/api.dart';
import 'package:weather_app/weather_model.dart';

import 'weather_detail_screen.dart'; // Import the new screen

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inProgress = false;
  String? errorMessage;
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet =
        screenWidth > 600; // Adjust this threshold for your tablet design

    double searchBarWidth = isTablet ? screenWidth * 0.6 : screenWidth * 0.9;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Weather App")),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: searchBarWidth,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search city here',
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _getWeatherData(_controller.text);
                      },
                      child: Text("Search"),
                    ),
                    SizedBox(height: 10),
                    if (inProgress)
                      CircularProgressIndicator()
                    else if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getWeatherData(String location) async {
    setState(() {
      inProgress = true;
      errorMessage = null;
    });

    try {
      ApiResponse? response = await weatherApi().getCurrentWeather(location);
      if (response == null) {
        throw Exception("No data received");
      }

      // Navigate to WeatherDetailScreen if data is available
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>WeatherDetailScreen(
            initialResponse: response,
            onRefresh: () => weatherApi().getCurrentWeather(location),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = "Invalid city name or data not available";
      });
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
