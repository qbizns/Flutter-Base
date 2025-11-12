import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pos_core/pos_core.dart';
import 'package:printing/printing.dart';

/// Export Service
///
/// Handles exporting orders data to various formats (CSV, PDF)
class ExportService {
  /// Export orders to CSV format
  ///
  /// Returns the file path of the exported CSV
  static Future<String> exportOrdersToCsv(List<Order> orders) async {
    // Prepare CSV data
    final List<List<dynamic>> rows = [
      // Header row
      [
        'Order #',
        'Date',
        'Time',
        'Table',
        'Type',
        'Items',
        'Subtotal',
        'Tax',
        'Discount',
        'Total',
        'Payment Status',
        'Order Status',
      ],
    ];

    // Data rows
    for (final order in orders) {
      rows.add([
        order.orderNumber,
        DateFormat('yyyy-MM-dd').format(order.createdAt),
        DateFormat('HH:mm:ss').format(order.createdAt),
        'Table ${(order.id.hashCode % 20) + 1}',
        _getOrderTypeText(order.orderType),
        order.items.length,
        order.subtotal.toStringAsFixed(2),
        order.taxAmount.toStringAsFixed(2),
        order.discountAmount.toStringAsFixed(2),
        order.total.toStringAsFixed(2),
        _getPaymentStatusText(order.paymentStatus),
        _getOrderStatusText(order.status),
      ]);
    }

    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(rows);

    // Get downloads directory
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'orders_export_$timestamp.csv';
    final filePath = '${directory.path}/$fileName';

    // Write to file
    final file = File(filePath);
    await file.writeAsString(csvString);

    return filePath;
  }

  /// Export orders to PDF format
  ///
  /// Returns the file path of the exported PDF
  static Future<String> exportOrdersToPdf(List<Order> orders) async {
    final pdf = pw.Document();

    // Calculate summary statistics
    final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.total);
    final totalOrders = orders.length;
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    // Add page with orders table
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Orders Export Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on ${DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now())}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SmartPOS',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#714B67'),
                        ),
                      ),
                      pw.Text(
                        'Manager Dashboard',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Summary Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfSummaryCard(
                  'Total Orders',
                  totalOrders.toString(),
                  PdfColors.blue,
                ),
                _buildPdfSummaryCard(
                  'Total Revenue',
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  PdfColors.green,
                ),
                _buildPdfSummaryCard(
                  'Avg Order Value',
                  '\$${avgOrderValue.toStringAsFixed(2)}',
                  PdfColors.purple,
                ),
              ],
            ),

            pw.SizedBox(height: 32),

            // Orders Table
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F3F4F6'),
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 9,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
              },
              headers: [
                'Order #',
                'Date & Time',
                'Table',
                'Type',
                'Items',
                'Amount',
                'Payment',
                'Status',
              ],
              data: orders.map((order) {
                return [
                  '#${order.orderNumber}',
                  DateFormat('MMM d, yyyy\nh:mm a').format(order.createdAt),
                  'Table ${(order.id.hashCode % 20) + 1}',
                  _getOrderTypeText(order.orderType),
                  '${order.items.length}',
                  '\$${order.total.toStringAsFixed(2)}',
                  _getPaymentStatusText(order.paymentStatus),
                  _getOrderStatusText(order.status),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 24),

            // Footer note
            pw.Text(
              'This report contains ${orders.length} order(s).',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ];
        },
      ),
    );

    // Save PDF
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'orders_export_$timestamp.pdf';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Share PDF via system share dialog
  static Future<void> sharePdf(List<Order> orders) async {
    final pdf = pw.Document();

    // Calculate summary statistics
    final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.total);
    final totalOrders = orders.length;
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    // Add page with orders table
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Orders Export Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Generated on ${DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now())}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SmartPOS',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#714B67'),
                        ),
                      ),
                      pw.Text(
                        'Manager Dashboard',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Summary Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfSummaryCard(
                  'Total Orders',
                  totalOrders.toString(),
                  PdfColors.blue,
                ),
                _buildPdfSummaryCard(
                  'Total Revenue',
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  PdfColors.green,
                ),
                _buildPdfSummaryCard(
                  'Avg Order Value',
                  '\$${avgOrderValue.toStringAsFixed(2)}',
                  PdfColors.purple,
                ),
              ],
            ),

            pw.SizedBox(height: 32),

            // Orders Table
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F3F4F6'),
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 9,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
              },
              headers: [
                'Order #',
                'Date & Time',
                'Table',
                'Type',
                'Items',
                'Amount',
                'Payment',
                'Status',
              ],
              data: orders.map((order) {
                return [
                  '#${order.orderNumber}',
                  DateFormat('MMM d, yyyy\nh:mm a').format(order.createdAt),
                  'Table ${(order.id.hashCode % 20) + 1}',
                  _getOrderTypeText(order.orderType),
                  '${order.items.length}',
                  '\$${order.total.toStringAsFixed(2)}',
                  _getPaymentStatusText(order.paymentStatus),
                  _getOrderStatusText(order.status),
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    // Share PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'orders_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
    );
  }

  /// Helper widget for PDF summary cards
  static pw.Widget _buildPdfSummaryCard(
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for text conversion

  static String _getOrderTypeText(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine-In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
    }
  }

  static String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  static String _getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
