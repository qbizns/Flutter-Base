/// Modifier/Add-on
///
/// Represents customization options for menu items
/// (e.g., Extra Cheese, No Onions, Spicy Level)
class Modifier {
  final String id;
  final String name;
  final String? description;
  final double price; // Additional cost (0 for no charge)
  final ModifierType type;
  final List<String>? options; // For choice modifiers
  final int? minSelection; // Minimum selections required
  final int? maxSelection; // Maximum selections allowed

  const Modifier({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.type,
    this.options,
    this.minSelection,
    this.maxSelection,
  });
}

/// Modifier Type
enum ModifierType {
  addon('Add-on'),           // Extra cheese, bacon, etc.
  removal('Removal'),        // No onions, no pickles, etc.
  choice('Choice'),          // Size, spice level, etc.
  quantity('Quantity');      // Number of items

  final String label;

  const ModifierType(this.label);
}
