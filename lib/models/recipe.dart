class Recipe {
  final String id;
  final String name;
  final String description;
  final List<int> fruitIds; // id фруктов из избранного

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.fruitIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fruitIds': fruitIds,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      fruitIds: (json['fruitIds'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }
}
