import "dart:convert";

import "package:http/http.dart" as http;
import "package:weather_app/constants.dart";
import "package:weather_app/weather_model.dart";

class weatherApi {
  final String baseUrl = "http://api.weatherapi.com/v1/current.json";
  Future<ApiResponse> getCurrentWeather(String location) async {
    String apiUrl = "$baseUrl?key=$apiKey&q=$location";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("failed to load weather");
      }
    } catch (e) {
      throw Exception("failed to load weather");
    }
  }
}
