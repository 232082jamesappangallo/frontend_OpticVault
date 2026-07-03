class CategoryModel {
  final String name;

  CategoryModel({
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['category'] ?? json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': name,
    };
  }

  CategoryModel copyWith({
    String? name,
  }) {
    return CategoryModel(
      name: name ?? this.name,
    );
  }
}

