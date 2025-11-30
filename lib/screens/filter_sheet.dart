import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilterSheet extends StatefulWidget {
  final double? minCalories;
  final double? maxCalories;
  final double? maxSugar;
  final double? maxFat;
  final int sortType;

  const FilterSheet({
    super.key,
    this.minCalories,
    this.maxCalories,
    this.maxSugar,
    this.maxFat,
    this.sortType = 0,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TextEditingController _minCaloriesController;
  late TextEditingController _maxCaloriesController;
  late TextEditingController _maxSugarController;
  late TextEditingController _maxFatController;
  late int _selectedSortType;
  String? _selectedPreset;

  final Map<String, PresetData> _presets = {
    'Завтрак': PresetData(
      minCalories: 40.0,
      maxCalories: 80.0,
      maxSugar: 12.0,
      maxFat: 0.5,
      icon: Icons.wb_sunny,
      color: Colors.orange,
    ),
    'Тренировка': PresetData(
      minCalories: 50.0,
      maxCalories: 100.0,
      maxFat: 0.3,
      icon: Icons.fitness_center,
      color: Colors.blue,
    ),
    'Сытость': PresetData(
      minCalories: 50.0,
      maxCalories: 90.0,
      maxSugar: 10.0,
      icon: Icons.restaurant,
      color: Colors.green,
    ),
    'Перекус': PresetData(
      maxCalories: 50.0,
      maxSugar: 7.0,
      maxFat: 0.4,
      icon: Icons.cookie,
      color: Colors.brown,
    ),
    'Диета': PresetData(
      maxCalories: 40.0,
      maxSugar: 6.0,
      maxFat: 0.3,
      icon: Icons.eco,
      color: Colors.teal,
    ),
  };

  @override
  void initState() {
    super.initState();
    _minCaloriesController = TextEditingController(text: widget.minCalories?.toString() ?? '');
    _maxCaloriesController = TextEditingController(text: widget.maxCalories?.toString() ?? '');
    _maxSugarController = TextEditingController(text: widget.maxSugar?.toString() ?? '');
    _maxFatController = TextEditingController(text: widget.maxFat?.toString() ?? '');
    _selectedSortType = widget.sortType;
  }

  @override
  void dispose() {
    _minCaloriesController.dispose();
    _maxCaloriesController.dispose();
    _maxSugarController.dispose();
    _maxFatController.dispose();
    super.dispose();
  }

  void _applyPreset(String presetName) {
    final preset = _presets[presetName]!;
    setState(() {
      _selectedPreset = presetName;
      _minCaloriesController.text = preset.minCalories?.toString() ?? '';
      _maxCaloriesController.text = preset.maxCalories?.toString() ?? '';
      _maxSugarController.text = preset.maxSugar?.toString() ?? '';
      _maxFatController.text = preset.maxFat?.toString() ?? '';
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedPreset = null;
      _minCaloriesController.clear();
      _maxCaloriesController.clear();
      _maxSugarController.clear();
      _maxFatController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // AppBar
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text(
                                'Сбросить',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const Text(
                              'Фильтры',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop({
                                  'minCalories': _minCaloriesController.text.isNotEmpty
                                      ? double.tryParse(_minCaloriesController.text)
                                      : null,
                                  'maxCalories': _maxCaloriesController.text.isNotEmpty
                                      ? double.tryParse(_maxCaloriesController.text)
                                      : null,
                                  'maxSugar': _maxSugarController.text.isNotEmpty
                                      ? double.tryParse(_maxSugarController.text)
                                      : null,
                                  'maxFat': _maxFatController.text.isNotEmpty
                                      ? double.tryParse(_maxFatController.text)
                                      : null,
                                  'sortType': _selectedSortType,
                                });
                              },
                              child: const Text(
                                'Готово',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Содержимое
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Сортировка
                    const Row(
                      children: [
                        Icon(Icons.sort, color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'Сортировка',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortChip('A-Z', 0),
                        _buildSortChip('Z-A', 1),
                        _buildSortChip('Калории ↑', 2),
                        _buildSortChip('Калории ↓', 3),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Заготовленные фильтры
                    const Row(
                      children: [
                        Icon(Icons.dashboard_customize, color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'Быстрые фильтры',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.8,
                      children: _presets.entries.map((entry) {
                        final presetName = entry.key;
                        final preset = entry.value;
                        final isSelected = _selectedPreset == presetName;
                        return InkWell(
                          onTap: () => _applyPreset(presetName),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? preset.color.withOpacity(0.15)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? preset.color
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  preset.icon,
                                  color: preset.color,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  presetName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Ручные фильтры
                    const Row(
                      children: [
                        Icon(Icons.tune, color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'Настроить вручную',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _minCaloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Минимум калорий',
                        suffixText: 'ккал',
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxCaloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Максимум калорий',
                        suffixText: 'ккал',
                        prefixIcon: Icon(Icons.trending_down),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxSugarController,
                      decoration: const InputDecoration(
                        labelText: 'Максимум сахара',
                        suffixText: 'г',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxFatController,
                      decoration: const InputDecoration(
                        labelText: 'Максимум жиров',
                        suffixText: 'г',
                        prefixIcon: Icon(Icons.opacity),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortChip(String label, int value) {
    final isSelected = _selectedSortType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedSortType = value);
        }
      },
      selectedColor: AppTheme.lightGreen,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? AppTheme.primaryGreen : Colors.black87,
      ),
    );
  }
}


class PresetData {
  final double? minCalories;
  final double? maxCalories;
  final double? maxSugar;
  final double? maxFat;
  final IconData icon;
  final Color color;

  PresetData({
    this.minCalories,
    this.maxCalories,
    this.maxSugar,
    this.maxFat,
    required this.icon,
    required this.color,
  });
}
