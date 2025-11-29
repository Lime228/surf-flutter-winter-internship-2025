import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/fruit.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final RecipeService _recipeService = RecipeService();
  final FavoritesService _favoriteService = FavoritesService();
  final ApiService _apiService = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Fruit> favoriteFruits = [];
  Set<int> selectedFruitIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    try {
      final favoriteIds = await _favoriteService.loadFavorites();
      final result = await _apiService.getAllFruits();
      setState(() {
        favoriteFruits = result.fruits.where((f) => favoriteIds.contains(f.id)).toList();
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveRecipe() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Название рецепта обязательно')),
      );
      return;
    }

    if (selectedFruitIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один фрукт')),
      );
      return;
    }

    final recipe = Recipe(
      id: const Uuid().v4(),
      name: name,
      description: _descriptionController.text.trim(),
      fruitIds: selectedFruitIds.toList(),
    );

    await _recipeService.addRecipe(recipe);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание рецепта'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteFruits.isEmpty
          ? const Center(
        child: Text('Добавьте фрукты в избранное, чтобы создать рецепт'),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название рецепта *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание рецепта',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Выберите фрукты из избранного:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...favoriteFruits.map((fruit) {
              final isSelected = selectedFruitIds.contains(fruit.id);
              return CheckboxListTile(
                title: Text(fruit.name),
                subtitle: Text('${fruit.family} • ${fruit.nutritions.calories.toStringAsFixed(0)} ккал'),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedFruitIds.add(fruit.id);
                    } else {
                      selectedFruitIds.remove(fruit.id);
                    }
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Сохранить',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
