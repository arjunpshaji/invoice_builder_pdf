import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_generator/modules/home/widgets/invoice_text_field.dart';
import 'package:invoice_generator/modules/theme/app_theme.dart';
import 'package:pdf/pdf.dart' show PdfColors;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceGenerator extends ConsumerWidget {
  InvoiceGenerator({super.key});

  final TextEditingController headerController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController gstRateController = TextEditingController();
  final TextEditingController gstAmountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final ValueNotifier<bool> isGSTNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<List<Map<String, dynamic>>> invoiceItemsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  /// Generate PDF
  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(headerController.text, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Address: ${addressController.text}", style: const pw.TextStyle(fontSize: 16)),
              pw.Text("Email: ${emailController.text}", style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Description')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Unit')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Price/unit')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total')),
                    ],
                  ),
                  ...invoiceItemsNotifier.value.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['description'].text)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['unit'].text)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['price'].text)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['total'])),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
              if (isGSTNotifier.value) pw.Text("GST Rate: ${gstRateController.text}%", style: const pw.TextStyle(fontSize: 16)),
              if (isGSTNotifier.value) pw.Text("GST Amount: ${gstAmountController.text}", style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text("Total Amount: ${totalAmountController.text}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// **Print or Save PDF**
  void printInvoice() async {
    final pdfBytes = await generatePdf();
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  // Add new field
  void addNewItem() {
    invoiceItemsNotifier.value = [
      ...invoiceItemsNotifier.value,
      {
        'description': TextEditingController(),
        'unit': TextEditingController(),
        'price': TextEditingController(),
        'total': '0.00',
      }
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate grand total
    void calculateGrandTotal() {
      double grandTotal = invoiceItemsNotifier.value.fold(0.0, (sum, item) {
        return sum + (double.tryParse(item['total']) ?? 0.0);
      });

      if (isGSTNotifier.value) {
        double gstRate = double.tryParse(gstRateController.text) ?? 0.0;
        double gstAmount = grandTotal * (gstRate / 100);
        gstAmountController.text = gstAmount.toStringAsFixed(2);
        grandTotal += gstAmount;
      } else {
        gstAmountController.text = "0.00";
      }

      totalAmountController.text = grandTotal.toStringAsFixed(2);
    }

    // Calculate total
    void calculateTotal(int index) {
      double unit = double.tryParse(invoiceItemsNotifier.value[index]['unit'].text) ?? 0.0;
      double price = double.tryParse(invoiceItemsNotifier.value[index]['price'].text) ?? 0.0;
      final updatedItems = [...invoiceItemsNotifier.value];
      updatedItems[index]['total'] = (unit * price).toStringAsFixed(2);
      invoiceItemsNotifier.value = updatedItems;
      calculateGrandTotal();
    }

    // Remove field
    void removeItem(int index) {
      invoiceItemsNotifier.value = List.from(invoiceItemsNotifier.value)..removeAt(index);
      calculateGrandTotal();
    }

    return Scaffold(
      backgroundColor: appColor(context).green,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width > 900 ? 160 : 10,
                80,
                MediaQuery.of(context).size.width > 900 ? 160 : 10,
                160,
              ),
              padding: const EdgeInsets.all(80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: appColor(context).background,
                border: Border.all(
                  width: 1,
                  color: appColor(context).text!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InvoiceTextField(
                      label: "Header Title",
                      controller: headerController,
                      textStyle: TextStyle(fontSize: 32, color: appColor(context).text, fontWeight: FontWeight.w700)),
                  InvoiceTextField(
                    label: "Address",
                    controller: addressController,
                    textStyle: TextStyle(fontSize: 20, color: appColor(context).text),
                  ),
                  InvoiceTextField(
                    label: "Email",
                    controller: emailController,
                    textStyle: TextStyle(fontSize: 20, color: appColor(context).text),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: invoiceItemsNotifier,
                    builder: (context, value, child) => Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: appColor(context).primaryText?.withValues(alpha: .25)),
                          children: [
                            TableCell(
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: AutoSizeText(
                                      'Description',
                                      minFontSize: 16,
                                      maxFontSize: 18,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: appColor(context).text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ))),
                            TableCell(
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: AutoSizeText(
                                      'Unit (hrs/sqft)',
                                      minFontSize: 16,
                                      maxFontSize: 18,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: appColor(context).text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ))),
                            TableCell(
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: AutoSizeText(
                                      'Price/unit',
                                      minFontSize: 16,
                                      maxFontSize: 18,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: appColor(context).text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ))),
                            TableCell(
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: AutoSizeText(
                                      'Total',
                                      minFontSize: 16,
                                      maxFontSize: 18,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: appColor(context).text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ))),
                          ],
                        ),
                        ...invoiceItemsNotifier.value.asMap().entries.map((entry) {
                          return TableRow(
                            children: InvoiceItemRow(
                              itemData: entry.value,
                              onValueChanged: () => calculateTotal(entry.key),
                            ).buildRow(context, invoiceItemsNotifier),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      IconButton(
                        color: appColor(context).green,
                        onHover: (value) {},
                        onPressed: addNewItem,
                        icon: Icon(
                          Icons.add_circle,
                          color: appColor(context).green,
                        ),
                        tooltip: "Add Field",
                      ),
                      IconButton(
                        color: appColor(context).green,
                        onHover: (value) {},
                        onPressed: () {
                          removeItem(invoiceItemsNotifier.value.length - 1);
                        },
                        icon: Icon(
                          Icons.remove_circle_rounded,
                          color: appColor(context).green,
                        ),
                        tooltip: "Remove Field",
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder(
                    valueListenable: isGSTNotifier,
                    builder: (context, value, child) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isGSTNotifier.value,
                              onChanged: (value) {
                                isGSTNotifier.value = value!;
                                calculateGrandTotal();
                              },
                            ),
                            Text(
                              "Include GST",
                              style: TextStyle(fontSize: 18, color: appColor(context).text),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isGSTNotifier.value)
                          InvoiceTextField(
                            label: "GST Rate (%)",
                            controller: gstRateController,
                            textStyle: TextStyle(fontSize: 16, color: appColor(context).text),
                            onChanged: (value) => calculateGrandTotal(),
                          ),
                        const SizedBox(height: 8),
                        if (isGSTNotifier.value)
                          InvoiceTextField(
                            label: "GST Amount",
                            controller: gstAmountController,
                            isReadOnly: true,
                            textStyle: TextStyle(fontSize: 18, color: appColor(context).text),
                          ),
                        const SizedBox(height: 8),
                        InvoiceTextField(
                          label: "Total Amount",
                          controller: totalAmountController,
                          isReadOnly: true,
                          textStyle: TextStyle(fontSize: 20, color: appColor(context).text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  IconButton(
                    onPressed: printInvoice,
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: appColor(context).errorText,
                        ),
                        Text(
                          'Export as PDF',
                          style: TextStyle(fontSize: 18, color: appColor(context).text, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    tooltip: "Export as PDF",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Invoice Item Row
class InvoiceItemRow {
  final Map<String, dynamic> itemData;
  final VoidCallback onValueChanged;

  InvoiceItemRow({required this.itemData, required this.onValueChanged});

  List<Widget> buildRow(BuildContext context, ValueNotifier<List<Map<String, dynamic>>> invoiceItemsNotifier) {
    return [
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: itemData['description'],
            decoration: const InputDecoration(border: InputBorder.none),
            style: TextStyle(fontSize: 18, color: appColor(context).text),
          ),
        ),
      ),
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: itemData['unit'],
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => onValueChanged(),
            decoration: const InputDecoration(border: InputBorder.none),
            style: TextStyle(fontSize: 18, color: appColor(context).text),
          ),
        ),
      ),
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: itemData['price'],
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => onValueChanged(),
            decoration: const InputDecoration(border: InputBorder.none),
            style: TextStyle(fontSize: 18, color: appColor(context).text),
          ),
        ),
      ),
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Tooltip(
            message: itemData['total'],
            child: AutoSizeText(
              itemData['total'],
              minFontSize: 16,
              maxFontSize: 18,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: appColor(context).text,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
