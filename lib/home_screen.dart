import 'package:flutter/material.dart';
import 'screens/fruit_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruit App'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Фрукты'),
            Tab(text: 'Избранное'),
            Tab(text: 'Рецепты'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FruitListScreen(),
          FavoritesScreen(),
          RecipesScreen(),
        ],
      ),
    );
  }
}
