import 'package:equatable/equatable.dart';

/// Modifier option (e.g., "Extra Cheese", "No Onions")
class Modifier extends Equatable {
  const Modifier({
    required this.id,
    required this.name,
    required this.price,
    this.sku,
    this.isDefault = false,
    this.isActive = true,
    this.sortOrder = 0,
  });

  /// Unique identifier
  final String id;

  /// Modifier name
  final String name;

  /// Additional price for this modifier
  final double price;

  /// Stock Keeping Unit
  final String? sku;

  /// Is this the default selection
  final bool isDefault;

  /// Is modifier active
  final bool isActive;

  /// Sort order for display
  final int sortOrder;

  /// Is this a free modifier
  bool get isFree => price == 0;

  /// Copy with method for immutability
  Modifier copyWith({
    String? id,
    String? name,
    double? price,
    String? sku,
    bool? isDefault,
    bool? isActive,
    int? sortOrder,
  }) {
    return Modifier(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        sku,
        isDefault,
        isActive,
        sortOrder,
      ];
}

/// Group of modifiers (e.g., "Size", "Toppings", "Extras")
class ModifierGroup extends Equatable {
  const ModifierGroup({
    required this.id,
    required this.name,
    required this.modifiers,
    this.selectionType = ModifierSelectionType.single,
    this.isRequired = false,
    this.minSelection = 0,
    this.maxSelection,
    this.sortOrder = 0,
  });

  /// Unique identifier
  final String id;

  /// Group name (e.g., "Size", "Toppings")
  final String name;

  /// Available modifiers in this group
  final List<Modifier> modifiers;

  /// How many modifiers can be selected
  final ModifierSelectionType selectionType;

  /// Is selection required
  final bool isRequired;

  /// Minimum number of selections required
  final int minSelection;

  /// Maximum number of selections allowed
  final int? maxSelection;

  /// Sort order for display
  final int sortOrder;

  /// Get active modifiers only
  List<Modifier> get activeModifiers =>
      modifiers.where((m) => m.isActive).toList();

  /// Get default modifiers
  List<Modifier> get defaultModifiers =>
      modifiers.where((m) => m.isDefault).toList();

  /// Validate if selection meets requirements
  bool isValidSelection(List<String> selectedModifierIds) {
    final count = selectedModifierIds.length;

    // Check minimum requirement
    if (isRequired && count < minSelection) {
      return false;
    }

    // Check maximum limit
    if (maxSelection != null && count > maxSelection!) {
      return false;
    }

    // Check selection type
    if (selectionType == ModifierSelectionType.single && count > 1) {
      return false;
    }

    return true;
  }

  /// Copy with method for immutability
  ModifierGroup copyWith({
    String? id,
    String? name,
    List<Modifier>? modifiers,
    ModifierSelectionType? selectionType,
    bool? isRequired,
    int? minSelection,
    int? maxSelection,
    int? sortOrder,
  }) {
    return ModifierGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      modifiers: modifiers ?? this.modifiers,
      selectionType: selectionType ?? this.selectionType,
      isRequired: isRequired ?? this.isRequired,
      minSelection: minSelection ?? this.minSelection,
      maxSelection: maxSelection ?? this.maxSelection,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        modifiers,
        selectionType,
        isRequired,
        minSelection,
        maxSelection,
        sortOrder,
      ];
}

/// Modifier selection type
enum ModifierSelectionType {
  /// Only one modifier can be selected (radio buttons)
  single,

  /// Multiple modifiers can be selected (checkboxes)
  multiple,
}
