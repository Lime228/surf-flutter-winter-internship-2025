import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/fruit.dart';
import '../services/recipe_service.dart';
import '../services/api_service.dart';
import 'create_recipe_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  final ApiService _apiService = ApiService();

  List<Recipe> recipes = [];
  List<Fruit> allFruits = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final loadedRecipes = await _recipeService.loadRecipes();
      final result = await _apiService.getAllFruits();
      setState(() {
        recipes = loadedRecipes;
        allFruits = result.fruits;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<void> _deleteRecipe(String recipeId) async {
    await _recipeService.deleteRecipe(recipeId);
    await _loadRecipes();
  }

  List<Fruit> _getFruitsForRecipe(Recipe recipe) {
    return allFruits.where((f) => recipe.fruitIds.contains(f.id)).toList();
  }

  Map<String, double> _calculateNutrition(List<Fruit> fruits) {
    double totalCalories = 0;
    double totalFat = 0;
    double totalSugar = 0;
    double totalCarbs = 0;
    double totalProtein = 0;

    for (var fruit in fruits) {
      totalCalories += fruit.nutritions.calories;
      totalFat += fruit.nutritions.fat;
      totalSugar += fruit.nutritions.sugar;
      totalCarbs += fruit.nutritions.carbohydrates;
      totalProtein += fruit.nutritions.protein;
    }

    return {
      'calories': totalCalories,
      'fat': totalFat,
      'sugar': totalSugar,
      'carbs': totalCarbs,
      'protein': totalProtein,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепты'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateRecipeScreen(),
                ),
              );
              _loadRecipes();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Произошла ошибка'),
            ElevatedButton(
              onPressed: _loadRecipes,
              child: const Text('Перезагрузить'),
            ),
          ],
        ),
      )
          : recipes.isEmpty
          ? const Center(child: Text('Создайте свой первый рецепт'))
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final fruits = _getFruitsForRecipe(recipe);
          final nutrition = _calculateNutrition(fruits);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRecipe(recipe.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(recipe.description),
                  const SizedBox(height: 8),
                  Text(
                    'Состав: ${fruits.map((f) => f.name).join(', ')}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Калории: ${nutrition['calories']!.toStringAsFixed(0)} • '
                        'Жир: ${nutrition['fat']!.toStringAsFixed(1)}г • '
                        'Сахар: ${nutrition['sugar']!.toStringAsFixed(1)}г',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}
