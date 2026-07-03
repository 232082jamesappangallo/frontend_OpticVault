class ItemModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final int quantity;
  final String? location;
  final String? condition;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.quantity,
    this.location,
    this.condition,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Umum',
      quantity: json['quantity'] ?? 0,
      location: json['location'],
      condition: json['condition'],
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'quantity': quantity,
      'location': location,
      'condition': condition,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ItemModel copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    int? quantity,
    String? location,
    String? condition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
