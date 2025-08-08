import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class GoongService {
  static const String _apiKey = 'gIiV4j1KXqCxBbeOsCz26wx9F7VaHUCw9FmJU03t';

  static Future<List<String>> loadLocations() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/dia_danh_viet_nam.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final locations = jsonList.map((item) => item['location'] as String).toList();

      for (var location in locations) {
        debugPrint('📍 $location');
      }
      return locations;
    } catch (e) {
      debugPrint('Error loading locations: $e');
      return [];
    }
  }


  static Future<List<String>> fetchAddressSuggestions(String input) async {
    final url = Uri.parse(
      'https://rsapi.goong.io/Place/AutoComplete?input=$input&api_key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final predictions = data['predictions'] as List;
      debugPrint(url.toString());
      return predictions.map((p) => p['description'] as String).toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }
}
