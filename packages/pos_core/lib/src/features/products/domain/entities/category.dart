import 'package:equatable/equatable.dart';

/// Product category entity.
///
/// Represents a category for organizing products in the catalog.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.imageUrl,
    this.iconName,
    this.color,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier
  final String id;

  /// Category name
  final String name;

  /// Category description
  final String? description;

  /// Parent category ID (for nested categories)
  final String? parentId;

  /// Category image URL
  final String? imageUrl;

  /// Icon name (for UI display)
  final String? iconName;

  /// Category color (hex code)
  final String? color;

  /// Is category active
  final bool isActive;

  /// Sort order for display
  final int sortOrder;

  /// When category was created
  final DateTime? createdAt;

  /// When category was last updated
  final DateTime? updatedAt;

  /// Check if this is a root category
  bool get isRoot => parentId == null;

  /// Copy with method for immutability
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? parentId,
    String? imageUrl,
    String? iconName,
    String? color,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        parentId,
        imageUrl,
        iconName,
        color,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
