import 'package:flutter/material.dart';
import '../models/fruit.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import 'fruit_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoriteService = FavoritesService();
  Set<int> favoriteIds = {};
  List<Fruit> favoriteFruits = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _loadFavoritesAndFruits();
  }

  Future<void> _loadFavoritesAndFruits() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      favoriteIds = await _favoriteService.loadFavorites();
      final result = await _apiService.getAllFruits();
      favoriteFruits = result.fruits.where((f) => favoriteIds.contains(f.id)).toList();
      setState(() {
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  void _removeFavorite(int fruitId) {
    setState(() {
      favoriteIds.remove(fruitId);
      favoriteFruits.removeWhere((f) => f.id == fruitId);
    });
    _favoriteService.removeFavorite(fruitId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
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
              onPressed: _loadFavoritesAndFruits,
              icon: const Icon(Icons.refresh),
              label: const Text('Перезагрузить'),
            ),
          ],
        ),
      )
          : favoriteFruits.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Вы пока ничего не добавили\nв избранное',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: favoriteFruits.length,
        itemBuilder: (context, index) {
          final fruit = favoriteFruits[index];
          return Card(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FruitDetailScreen(fruit: fruit),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fruit.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            fruit.family,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.local_fire_department,
                                  size: 16,
                                  color: Colors.orange[700]
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${fruit.nutritions.calories.toStringAsFixed(0)} ккал',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFavorite(fruit.id),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
