import 'package:flutter/material.dart';
import '../models/fruit.dart';
import '../services/favorite_service.dart';

class FruitDetailScreen extends StatefulWidget {
  final Fruit fruit;

  const FruitDetailScreen({super.key, required this.fruit});

  @override
  State<FruitDetailScreen> createState() => _FruitDetailScreenState();
}

class _FruitDetailScreenState extends State<FruitDetailScreen> {
  final FavoritesService _favoriteService = FavoritesService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final ids = await _favoriteService.loadFavorites();
    setState(() {
      isFavorite = ids.contains(widget.fruit.id);
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await _favoriteService.removeFavorite(widget.fruit.id);
    } else {
      await _favoriteService.addFavorite(widget.fruit.id);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fruit.name),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Семейство: ${widget.fruit.family}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Порядок: ${widget.fruit.order}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Род: ${widget.fruit.genus}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            const Text('Питательная ценность (на 100 г):', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildNutritionRow('Калории', '${widget.fruit.nutritions.calories} ккал'),
            _buildNutritionRow('Жир', '${widget.fruit.nutritions.fat} г'),
            _buildNutritionRow('Сахар', '${widget.fruit.nutritions.sugar} г'),
            _buildNutritionRow('Углеводы', '${widget.fruit.nutritions.carbohydrates} г'),
            _buildNutritionRow('Белки', '${widget.fruit.nutritions.protein} г'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
