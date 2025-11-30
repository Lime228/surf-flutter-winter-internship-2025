import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/fruit.dart';
import '../services/recipe_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
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
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Произошла ошибка',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRecipes,
              icon: const Icon(Icons.refresh),
              label: const Text('Перезагрузить'),
            ),
          ],
        ),
      )
          : recipes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Создайте свой первый рецепт',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateRecipeScreen(),
                  ),
                );
                _loadRecipes();
              },
              icon: const Icon(Icons.add),
              label: const Text('Создать рецепт'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
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
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Удалить рецепт?'),
                              content: Text('Вы уверены, что хотите удалить "${recipe.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteRecipe(recipe.id);
                                  },
                                  child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (recipe.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      recipe.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.restaurant, size: 16, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Состав:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fruits.map((f) => f.name).join(', '),
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildNutritionChip(
                        Icons.local_fire_department,
                        '${nutrition['calories']!.toStringAsFixed(0)} ккал',
                        Colors.orange,
                      ),
                      _buildNutritionChip(
                        Icons.opacity,
                        '${nutrition['fat']!.toStringAsFixed(1)}г жиров',
                        Colors.amber,
                      ),
                      _buildNutritionChip(
                        Icons.cake,
                        '${nutrition['sugar']!.toStringAsFixed(1)}г сахара',
                        Colors.pink,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
