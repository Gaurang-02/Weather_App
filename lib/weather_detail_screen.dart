import 'package:flutter/material.dart';
import 'package:weather_app/weather_model.dart';

class WeatherDetailScreen extends StatefulWidget {
  final ApiResponse? initialResponse;
  final Future<ApiResponse?> Function() onRefresh;

  WeatherDetailScreen({
    required this.initialResponse,
    required this.onRefresh,
  });

  @override
  _WeatherDetailScreenState createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late ApiResponse? response;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    response = widget.initialResponse;
  }

  Future<void> _refreshWeather() async {
    setState(() {
      isLoading = true;
    });

    try {
      final newResponse = await widget.onRefresh();
      setState(() {
        response = newResponse;
      });
    } catch (error) {
      // Handle error appropriately here showing snackBar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh weather data. Please try again.'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth >= 600;

    double locationIconSize = isTablet ? 70 : 50;
    double locationTextSize = isTablet ? 40 : 30;
    double countryTextSize = isTablet ? 20 : 15;
    double tempTextSize = isTablet ? 80 : 60;
    double conditionTextSize = isTablet ? 20 : 15;
    double padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.location_on,
                    size: locationIconSize,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response!.location?.name ?? "Unknown location",
                        style: TextStyle(
                          fontSize: locationTextSize,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        response!.location?.country ?? "",
                        style: TextStyle(
                          fontSize: countryTextSize,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              if (response!.current?.condition?.icon != null)
                Center(
                  child: SizedBox(
                    child: Image.network(
                      "https:${response!.current!.condition!.icon}"
                          .replaceAll("64x64", "128x128"),
                      scale: isTablet ? 0.5 : 0.7,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  (response!.current?.tempC.toString() ?? " ") + " °c",
                  style: TextStyle(
                      fontSize: tempTextSize, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  (response!.current?.condition?.text.toString() ?? " "),
                  style: TextStyle(
                      fontSize: conditionTextSize, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Card(
                elevation: 4,
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _dataAndTileWidget("Humidity",
                              "${response!.current?.humidity.toString() ?? " "} %"),
                          _dataAndTileWidget("Wind Speed",
                              "${response!.current?.windKph.toString() ?? " "} km/h"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _dataAndTileWidget("UV",
                              "${response!.current?.uv.toString() ?? ""} "),
                          _dataAndTileWidget("Precipitation",
                              "${response!.current?.precipMm.toString() ?? " "} mm"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _dataAndTileWidget("Local Time",
                              "${response!.location?.localtime?.split(" ").last ?? " "} "),
                          _dataAndTileWidget("Local Date",
                              "${response!.location?.localtime?.split(" ").first ?? " "} "),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _refreshWeather,
        child: isLoading ? CircularProgressIndicator() : Icon(Icons.refresh),
        shape: CircleBorder(),
        backgroundColor: Colors.white24,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _dataAndTileWidget(String title, String data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            data,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
