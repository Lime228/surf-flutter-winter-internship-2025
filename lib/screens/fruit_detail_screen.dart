import 'package:flutter/material.dart';
import '../models/fruit.dart';

class FruitDetailScreen extends StatelessWidget {
  final Fruit fruit;

  const FruitDetailScreen({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fruit.name),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Семейство: ${fruit.family}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Порядок: ${fruit.order}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Род: ${fruit.genus}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            const Text('Питательная ценность (на 100 г):', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildNutritionRow('Калории', '${fruit.nutritions.calories} ккал'),
            _buildNutritionRow('Жир', '${fruit.nutritions.fat} г'),
            _buildNutritionRow('Сахар', '${fruit.nutritions.sugar} г'),
            _buildNutritionRow('Углеводы', '${fruit.nutritions.carbohydrates} г'),
            _buildNutritionRow('Белки', '${fruit.nutritions.protein} г'),
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
