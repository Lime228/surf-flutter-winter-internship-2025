import 'dart:async';

import 'package:flutter/material.dart';
import 'screens/filter_sheet.dart';
import 'services/api_service.dart';
import 'models/fruit.dart';
import 'screens/fruit_detail_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


void main() {
  runApp(const FruitApp());
}

class FruitApp extends StatelessWidget {
  const FruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const FruitListScreen(),
    );
  }
}

class FruitListScreen extends StatefulWidget {
  const FruitListScreen({super.key});

  @override
  State<FruitListScreen> createState() => _FruitListScreenState();
}

class _FruitListScreenState extends State<FruitListScreen> {
  final ApiService _apiService = ApiService();
  List<Fruit> allFruits = [];
  List<Fruit> filteredFruits = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  double? minCalories;
  double? maxCalories;
  double? maxSugar;
  double? maxFat;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isOnline = true;



  // Сортировка: 0 - по имени A-Z, 1 - по имени Z-A, 2 - по калориям
  int sortType = 0;

  @override
  void initState() {
    super.initState();
    _loadFruits();
    _searchController.addListener(_onSearchChanged);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
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


  Future<void> _loadFruits() async {
    try {
      final fruitList = await _apiService.getAllFruits();
      setState(() {
        allFruits = fruitList;
        filteredFruits = _sortFruits(fruitList);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
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

      final caloriesOk = (minCalories == null || fruit.nutritions.calories >= minCalories!) &&
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
        title: const Text('Fruit App'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, double?>>(
                context: context,
                isScrollControlled: true,
                builder: (context) => FilterSheet(
                  minCalories: minCalories,
                  maxCalories: maxCalories,
                  maxSugar: maxSugar,
                  maxFat: maxFat,
                ),
              );
              if (result != null) {
                setState(() {
                  minCalories = result['minCalories'];
                  maxCalories = result['maxCalories'];
                  maxSugar = result['maxSugar'];
                  maxFat = result['maxFat'];
                  filteredFruits = _filterAndSortFruits(allFruits);
                });
              }
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.sort),
            onSelected: _changeSort,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('A-Z')),
              const PopupMenuItem(value: 1, child: Text('Z-A')),
              const PopupMenuItem(value: 2, child: Text('По калориям (возрастание)')),
              const PopupMenuItem(value: 3, child: Text('По калориям (убывание)')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
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
                    trailing: const Icon(Icons.arrow_forward_ios),
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
              color: Colors.red.shade700,
              height: 24,
              alignment: Alignment.center,
              child: const Text(
                'Нет соединения с сетью',
                style: TextStyle(color: Colors.white),
              ),
            ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadFruits,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
