class Fruit {
  final int id;
  final String name;
  final String family;
  final String order;
  final String genus;
  final Nutritions nutritions;

  Fruit({
    required this.id,
    required this.name,
    required this.family,
    required this.order,
    required this.genus,
    required this.nutritions,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      family: json['family'] ?? '',
      order: json['order'] ?? '',
      genus: json['genus'] ?? '',
      nutritions: Nutritions.fromJson(json['nutritions'] ?? {}),
    );
  }
}

class Nutritions {
  final double calories;
  final double fat;
  final double sugar;
  final double carbohydrates;
  final double protein;

  Nutritions({
    required this.calories,
    required this.fat,
    required this.sugar,
    required this.carbohydrates,
    required this.protein,
  });

  factory Nutritions.fromJson(Map<String, dynamic> json) {
    return Nutritions(
      calories: (json['calories'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      sugar: (json['sugar'] ?? 0).toDouble(),
      carbohydrates: (json['carbohydrates'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
    );
  }
}
