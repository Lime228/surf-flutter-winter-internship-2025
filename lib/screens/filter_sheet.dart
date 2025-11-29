import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final double? minCalories;
  final double? maxCalories;
  final double? maxSugar;
  final double? maxFat;

  const FilterSheet({
    super.key,
    this.minCalories,
    this.maxCalories,
    this.maxSugar,
    this.maxFat,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TextEditingController minCaloriesController;
  late TextEditingController maxCaloriesController;
  late TextEditingController maxSugarController;
  late TextEditingController maxFatController;

  @override
  void initState() {
    super.initState();
    minCaloriesController = TextEditingController(text: widget.minCalories?.toString() ?? '');
    maxCaloriesController = TextEditingController(text: widget.maxCalories?.toString() ?? '');
    maxSugarController = TextEditingController(text: widget.maxSugar?.toString() ?? '');
    maxFatController = TextEditingController(text: widget.maxFat?.toString() ?? '');
  }

  @override
  void dispose() {
    minCaloriesController.dispose();
    maxCaloriesController.dispose();
    maxSugarController.dispose();
    maxFatController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Navigator.of(context).pop({
      'minCalories': double.tryParse(minCaloriesController.text),
      'maxCalories': double.tryParse(maxCaloriesController.text),
      'maxSugar': double.tryParse(maxSugarController.text),
      'maxFat': double.tryParse(maxFatController.text),
    });
  }

  void _clearFilters() {
    minCaloriesController.clear();
    maxCaloriesController.clear();
    maxSugarController.clear();
    maxFatController.clear();
    setState(() {}); // Обновить UI
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Фильтры по питательным веществам',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField('Мин. калории', minCaloriesController),
                _buildTextField('Макс. калории', maxCaloriesController),
                _buildTextField('Макс. сахар', maxSugarController),
                _buildTextField('Макс. жир', maxFatController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Применить'),
                ),
                TextButton(
                  onPressed: () {
                    _clearFilters();
                    Navigator.of(context).pop({
                      'minCalories': null,
                      'maxCalories': null,
                      'maxSugar': null,
                      'maxFat': null,
                    });
                  },
                  child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
