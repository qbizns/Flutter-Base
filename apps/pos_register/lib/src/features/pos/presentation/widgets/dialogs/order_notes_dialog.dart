import 'package:flutter/material.dart';

/// Order notes dialog for POS
class OrderNotesDialog extends StatefulWidget {
  const OrderNotesDialog({
    super.key,
    this.initialNotes,
  });

  final String? initialNotes;

  @override
  State<OrderNotesDialog> createState() => _OrderNotesDialogState();

  static Future<String?> show(
    BuildContext context, {
    String? initialNotes,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => OrderNotesDialog(initialNotes: initialNotes),
    );
  }
}

class _OrderNotesDialogState extends State<OrderNotesDialog> {
  late final TextEditingController _notesController;
  final List<String> _templates = [
    'No onions',
    'Extra spicy',
    'Well done',
    'No ice',
    'Extra sauce',
    'On the side',
    'Light on salt',
    'Allergy: nuts',
    'Allergy: dairy',
    'Allergy: gluten',
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addTemplate(String template) {
    final currentText = _notesController.text;
    if (currentText.isEmpty) {
      _notesController.text = template;
    } else {
      _notesController.text = '$currentText, $template';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.note_alt, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Order Notes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notes input
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add special instructions or notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _notesController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _notesController.clear());
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Templates section
            const Text(
              'Quick Templates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Templates chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _templates.map((template) {
                return ActionChip(
                  label: Text(template),
                  onPressed: () {
                    setState(() => _addTemplate(template));
                  },
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: const TextStyle(fontSize: 13),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_notesController.text.trim());
                  },
                  child: const Text('Save Notes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
