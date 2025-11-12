import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Product Form Dialog
///
/// Dialog for adding or editing products with full backend integration
class ProductFormDialog extends ConsumerStatefulWidget {
  const ProductFormDialog({
    this.product,
    super.key,
  });

  final Product? product;

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();

  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _trackInventory = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _skuController.text = widget.product!.sku ?? '';
      _barcodeController.text = widget.product!.barcode ?? '';
      _selectedCategoryId = widget.product!.category?.id;
      _isAvailable = widget.product!.isAvailable;
      _trackInventory = widget.product!.trackInventory;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.product != null;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider());

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(OdooSpacing.lg),
              decoration: BoxDecoration(
                color: OdooColors.gray50,
                border: Border(
                  bottom: BorderSide(
                    color: OdooColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add_circle_outline,
                    color: OdooColors.primary,
                    size: OdooIconSizes.lg,
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Text(
                    isEditing ? 'Edit Product' : 'Add New Product',
                    style: OdooTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: OdooColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OdooSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        'Product Name *',
                        style: OdooTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.sm),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter product name',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: OdooSpacing.lg),

                      // Description
                      Text(
                        'Description',
                        style: OdooTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.sm),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Enter product description',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: OdooSpacing.lg),

                      // Price and Category Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price *',
                                  style: OdooTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: OdooSpacing.sm),
                                TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    hintText: '0.00',
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Price is required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid price';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: OdooSpacing.lg),
                          Expanded(
                            child: categoriesAsync.when(
                              data: (categories) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category',
                                    style: OdooTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: OdooSpacing.sm),
                                  DropdownButtonFormField<String>(
                                    value: _selectedCategoryId,
                                    decoration: const InputDecoration(
                                      hintText: 'Select category',
                                      prefixIcon: Icon(Icons.category_outlined),
                                    ),
                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text('No category'),
                                      ),
                                      ...categories.map((category) {
                                        return DropdownMenuItem(
                                          value: category.id,
                                          child: Text(category.name),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const Text('Error loading categories'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: OdooSpacing.lg),

                      // SKU and Barcode Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SKU',
                                  style: OdooTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: OdooSpacing.sm),
                                TextFormField(
                                  controller: _skuController,
                                  decoration: const InputDecoration(
                                    hintText: 'Stock Keeping Unit',
                                    prefixIcon: Icon(Icons.qr_code),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: OdooSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Barcode',
                                  style: OdooTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: OdooSpacing.sm),
                                TextFormField(
                                  controller: _barcodeController,
                                  decoration: const InputDecoration(
                                    hintText: 'Product barcode',
                                    prefixIcon: Icon(Icons.barcode_reader),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: OdooSpacing.lg),

                      // Switches
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(OdooSpacing.md),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text(
                                  'Available for Sale',
                                  style: OdooTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Product can be sold',
                                  style: OdooTypography.bodySmall.copyWith(
                                    color: OdooColors.textSecondary,
                                  ),
                                ),
                                value: _isAvailable,
                                onChanged: (value) {
                                  setState(() {
                                    _isAvailable = value;
                                  });
                                },
                              ),
                              Divider(color: OdooColors.border),
                              SwitchListTile(
                                title: Text(
                                  'Track Inventory',
                                  style: OdooTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Monitor stock levels',
                                  style: OdooTypography.bodySmall.copyWith(
                                    color: OdooColors.textSecondary,
                                  ),
                                ),
                                value: _trackInventory,
                                onChanged: (value) {
                                  setState(() {
                                    _trackInventory = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(OdooSpacing.lg),
              decoration: BoxDecoration(
                color: OdooColors.gray50,
                border: Border(
                  top: BorderSide(
                    color: OdooColors.border,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _saveProduct,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(isEditing ? 'Update Product' : 'Add Product'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final price = double.parse(_priceController.text);

      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'price': price,
        'sku': _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        'category_id': _selectedCategoryId,
        'is_available': _isAvailable,
        'track_inventory': _trackInventory,
      };

      if (isEditing) {
        // Update existing product
        await apiClient.patch(
          '/products/${widget.product!.id}',
          data: productData,
        );
      } else {
        // Create new product
        await apiClient.post(
          '/products',
          data: productData,
        );
      }

      // Refresh products list
      ref.invalidate(productsProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Product updated successfully'
                  : 'Product created successfully',
            ),
            backgroundColor: OdooColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: ${e.toString()}'),
            backgroundColor: OdooColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
