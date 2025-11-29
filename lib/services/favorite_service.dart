import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_fruit_ids';

  Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return {};
    final List<dynamic> list = json.decode(jsonString);
    return list.map((id) => id as int).toSet();
  }

  Future<void> saveFavorites(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(ids.toList());
    await prefs.setString(_key, jsonString);
  }

  Future<void> addFavorite(int id) async {
    final ids = await loadFavorites();
    ids.add(id);
    await saveFavorites(ids);
  }

  Future<void> removeFavorite(int id) async {
    final ids = await loadFavorites();
    ids.remove(id);
    await saveFavorites(ids);
  }
}
