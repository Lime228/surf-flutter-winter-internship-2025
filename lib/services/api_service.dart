import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fruit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiResult {
  final List<Fruit> fruits;
  final String source; // 'Данные из сети' или 'Данные из кэша'

  ApiResult(this.fruits, this.source);
}

class ApiService {
  static const String baseUrl = 'https://www.fruityvice.com/api/fruit';

  Future<ApiResult> getAllFruits() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse('$baseUrl/all'));
      if (response.statusCode == 200) {
        await prefs.setString('cached_fruits', response.body);
        final List<dynamic> data = json.decode(response.body);
        final fruits = data.map((json) => Fruit.fromJson(json)).toList();
        return ApiResult(fruits, 'Данные из сети');
      } else {
        throw Exception('Ошибка загрузки: ${response.statusCode}');
      }
    } catch (e) {
      final cachedData = prefs.getString('cached_fruits');
      if (cachedData != null) {
        final List<dynamic> data = json.decode(cachedData);
        final fruits = data.map((json) => Fruit.fromJson(json)).toList();
        return ApiResult(fruits, 'Данные из кэша');
      } else {
        throw Exception('Ошибка сети и нет кэша: $e');
      }
    }
  }
}
