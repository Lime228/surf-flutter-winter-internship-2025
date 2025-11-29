import 'package:flutter/material.dart';

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

  final Map<String, Map<String, dynamic>> _presets = {
    'Завтрак': {
      'minCalories': 40.0,
      'maxCalories': 80.0,
      'minCarbs': 10.0,
      'maxSugar': 12.0,
      'maxFat': 0.5,
    },
    'Тренировка': {
      'minCalories': 50.0,
      'maxCalories': 100.0,
      'minCarbs': 12.0,
      'maxFat': 0.3,
    },
    'Сытость': {
      'minCalories': 50.0,
      'maxCalories': 90.0,
      'minCarbs': 10.0,
      'maxCarbs': 15.0,
      'maxSugar': 10.0,
      'minProtein': 0.5,
    },
    'Перекус': {
      'maxCalories': 50.0,
      'maxSugar': 7.0,
      'maxFat': 0.4,
    },
    'Диета': {
      'maxCalories': 40.0,
      'maxSugar': 6.0,
      'maxFat': 0.3,
    },
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
      _minCaloriesController.text = preset['minCalories']?.toString() ?? '';
      _maxCaloriesController.text = preset['maxCalories']?.toString() ?? '';
      _maxSugarController.text = preset['maxSugar']?.toString() ?? '';
      _maxFatController.text = preset['maxFat']?.toString() ?? '';
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
              AppBar(
                title: const Text('Фильтры'),
                backgroundColor: Colors.green,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Сортировка',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('A-Z'),
                          selected: _selectedSortType == 0,
                          onSelected: (selected) {
                            setState(() => _selectedSortType = 0);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Z-A'),
                          selected: _selectedSortType == 1,
                          onSelected: (selected) {
                            setState(() => _selectedSortType = 1);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Калории ↑'),
                          selected: _selectedSortType == 2,
                          onSelected: (selected) {
                            setState(() => _selectedSortType = 2);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Калории ↓'),
                          selected: _selectedSortType == 3,
                          onSelected: (selected) {
                            setState(() => _selectedSortType = 3);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Заготовленные фильтры',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _presets.keys.map((presetName) {
                        return ChoiceChip(
                          label: Text(presetName),
                          selected: _selectedPreset == presetName,
                          onSelected: (selected) {
                            if (selected) {
                              _applyPreset(presetName);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ручные фильтры',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Сбросить'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _minCaloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Минимум калорий',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxCaloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Максимум калорий',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxSugarController,
                      decoration: const InputDecoration(
                        labelText: 'Максимум сахара (г)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxFatController,
                      decoration: const InputDecoration(
                        labelText: 'Максимум жиров (г)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Применить',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
