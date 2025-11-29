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
        backgroundColor: Colors.green,
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
              onPressed: _loadFavoritesAndFruits,
              child: const Text('Перезагрузить'),
            ),
          ],
        ),
      )
          : favoriteFruits.isEmpty
          ? const Center(child: Text('Вы пока ничего не добавили в избранное'))
          : ListView.builder(
        itemCount: favoriteFruits.length,
        itemBuilder: (context, index) {
          final fruit = favoriteFruits[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(fruit.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFavorite(fruit.id),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FruitDetailScreen(fruit: fruit),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }


}
