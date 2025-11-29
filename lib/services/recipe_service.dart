import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class RecipeService {
  static const _key = 'recipes';

  Future<List<Recipe>> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(recipes.map((r) => r.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<void> addRecipe(Recipe recipe) async {
    final recipes = await loadRecipes();
    recipes.add(recipe);
    await saveRecipes(recipes);
  }

  Future<void> deleteRecipe(String recipeId) async {
    final recipes = await loadRecipes();
    recipes.removeWhere((r) => r.id == recipeId);
    await saveRecipes(recipes);
  }
}
