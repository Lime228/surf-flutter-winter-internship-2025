import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/fruit.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../screens/fruit_detail_screen.dart';
import '../screens/filter_sheet.dart';

class FruitListScreen extends StatefulWidget {
  const FruitListScreen({super.key});

  @override
  State<FruitListScreen> createState() => _FruitListScreenState();
}

class _FruitListScreenState extends State<FruitListScreen> {
  final ApiService _apiService = ApiService();

  final FavoritesService _favoriteService = FavoritesService();
  Set<int> favoriteIds = {};

  List<Fruit> allFruits = [];
  List<Fruit> filteredFruits = [];
  bool isLoading = true;
  bool isError = false;
  final TextEditingController _searchController = TextEditingController();

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isOnline = true;

  String dataSource = 'Загрузка...';

  double? minCalories;
  double? maxCalories;
  double? maxSugar;
  double? maxFat;

  /// 0 - A-Z, 1 - Z-A, 2 - calories asc, 3 - calories desc
  int sortType = 0;

  @override
  void initState() {
    super.initState();
    _loadFruits();
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            isOnline = result != ConnectivityResult.none;
          });
        });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoriteService.loadFavorites();
    setState(() {
      favoriteIds = ids;
    });
  }

  void _toggleFavorite(int fruitId) async {
    if (favoriteIds.contains(fruitId)) {
      await _favoriteService.removeFavorite(fruitId);
      setState(() {
        favoriteIds.remove(fruitId);
      });
    } else {
      await _favoriteService.addFavorite(fruitId);
      setState(() {
        favoriteIds.add(fruitId);
      });
    }
  }

  Future<void> _loadFruits() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final result = await _apiService.getAllFruits();
      setState(() {
        allFruits = result.fruits;
        filteredFruits = _filterAndSortFruits(allFruits);
        dataSource = result.source;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      filteredFruits = _filterAndSortFruits(allFruits);
    });
  }

  List<Fruit> _filterAndSortFruits(List<Fruit> fruits) {
    String query = _searchController.text.toLowerCase();
    List<Fruit> filtered = fruits.where((fruit) {
      final matchesQuery = fruit.name.toLowerCase().contains(query) ||
          fruit.family.toLowerCase().contains(query);

      final caloriesOk = (minCalories == null ||
          fruit.nutritions.calories >= minCalories!) &&
          (maxCalories == null || fruit.nutritions.calories <= maxCalories!);
      final sugarOk = maxSugar == null || fruit.nutritions.sugar <= maxSugar!;
      final fatOk = maxFat == null || fruit.nutritions.fat <= maxFat!;

      return matchesQuery && caloriesOk && sugarOk && fatOk;
    }).toList();
    return _sortFruits(filtered);
  }

  List<Fruit> _sortFruits(List<Fruit> fruits) {
    switch (sortType) {
      case 0:
        return fruits..sort((a, b) => a.name.compareTo(b.name));
      case 1:
        return fruits..sort((a, b) => b.name.compareTo(a.name));
      case 2:
        return fruits..sort((a, b) => a.nutritions.calories.compareTo(b.nutritions.calories));
      case 3:
        return fruits..sort((a, b) => b.nutritions.calories.compareTo(a.nutritions.calories));
      default:
        return fruits;
    }
  }

  void _changeSort(int newSortType) {
    setState(() {
      sortType = newSortType;
      filteredFruits = _sortFruits(filteredFruits);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фрукты'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FilterSheet(
                  minCalories: minCalories,
                  maxCalories: maxCalories,
                  maxSugar: maxSugar,
                  maxFat: maxFat,
                  sortType: sortType,
                ),
              );
              if (result != null) {
                setState(() {
                  minCalories = result['minCalories'];
                  maxCalories = result['maxCalories'];
                  maxSugar = result['maxSugar'];
                  maxFat = result['maxFat'];
                  sortType = result['sortType'] ?? 0;
                  filteredFruits = _filterAndSortFruits(allFruits);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadFruits();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по названию или семейству...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isError
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Произошла ошибка'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFruits,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
                : filteredFruits.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty ? 'Нет данных' : 'Ничего не найдено',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredFruits.length,
              itemBuilder: (context, index) {
                final fruit = filteredFruits[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(fruit.name[0].toUpperCase()),
                    ),
                    title: Text(fruit.name),
                    subtitle: Text('${fruit.family} • ${fruit.nutritions.calories.toStringAsFixed(0)} ккал'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            favoriteIds.contains(fruit.id) ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => _toggleFavorite(fruit.id),
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
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
          ),
          if (!isOnline)
            Container(
              width: double.infinity,
              color: Colors.red.shade700,
              padding: const EdgeInsets.all(6),
              child: const Text(
                'Нет соединения с сетью',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            width: double.infinity,
            color: Colors.grey.shade300,
            padding: const EdgeInsets.all(6),
            child: Text(
              dataSource,
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

}
