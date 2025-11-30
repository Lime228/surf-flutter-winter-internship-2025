import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/fruit.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

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
        const SnackBar(
          content: Text('Введите название рецепта'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedFruitIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы один фрукт'),
          backgroundColor: Colors.red,
        ),
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Рецепт "$name" создан'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание рецепта'),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: const Text(
              'Готово',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteFruits.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Добавьте фрукты в избранное,\nчтобы создать рецепт',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Перейти к фруктам'),
              ),
            ],
          ),
        ),
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
                hintText: 'Например, "Энергетический завтрак"',
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание рецепта',
                hintText: 'Добавьте описание (необязательно)',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Icon(Icons.checklist, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Выберите фрукты',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Выбрано: ${selectedFruitIds.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            ...favoriteFruits.map((fruit) {
              final isSelected = selectedFruitIds.contains(fruit.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected ? AppTheme.lightGreen.withOpacity(0.3) : null,
                child: CheckboxListTile(
                  title: Text(
                    fruit.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${fruit.family} • ${fruit.nutritions.calories.toStringAsFixed(0)} ккал',
                  ),
                  value: isSelected,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedFruitIds.add(fruit.id);
                      } else {
                        selectedFruitIds.remove(fruit.id);
                      }
                    });
                  },
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить рецепт'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
