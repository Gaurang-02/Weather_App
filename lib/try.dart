import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/api.dart';
import 'package:weather_app/weather_model.dart';
import 'weather_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inProgress = false;
  String? errorMessage;
  TextEditingController _controller = TextEditingController();
  List<String> lastSearchCities = [];

  @override
  void initState() {
    super.initState();
    _loadLastSearchCities();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadLastSearchCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastSearchCities = prefs.getStringList('lastSearchCities') ?? [];
    });
  }

  Future<void> _saveLastSearchCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (lastSearchCities.contains(city)) {
      lastSearchCities.remove(city);
    }
    lastSearchCities.insert(0, city);
    if (lastSearchCities.length > 2) {
      lastSearchCities = lastSearchCities.sublist(0, 2);
    }
    prefs.setStringList('lastSearchCities', lastSearchCities);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

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
                      onTap: () {
                        setState(() {}); // To refresh the UI
                      },
                    ),
                    SizedBox(height: 10),
                    if (lastSearchCities.isNotEmpty)
                      Column(
                        children: lastSearchCities
                            .map((city) => ListTile(
                                  title: Text(city),
                                  trailing: Icon(Icons.history),
                                  onTap: () {
                                    _controller.text = city;
                                    _getWeatherData(city);
                                  },
                                ))
                            .toList(),
                      ),
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

      // Save the last searched city
      await _saveLastSearchCity(location);

      // Navigate to WeatherDetailScreen if data is available
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeatherDetailScreen(
            initialResponse: response,
            onRefresh: () => weatherApi().getCurrentWeather(location),
          ),
        ),
      ).then((_) {
        // Refresh the state when returning to the home screen
        _loadLastSearchCities();
        setState(() {});
      });
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
