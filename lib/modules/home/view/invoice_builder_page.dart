import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_generator/modules/theme/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceBuilderPage extends StatefulWidget {
  const InvoiceBuilderPage({super.key});

  @override
  _InvoiceBuilderPageState createState() => _InvoiceBuilderPageState();
}

class _InvoiceBuilderPageState extends State<InvoiceBuilderPage> {
  final TextEditingController headerController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController gstRateController = TextEditingController();
  final TextEditingController gstAmountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();

  List<Map<String, dynamic>> invoiceItems = [];
  bool isGST = false;

  void addNewItem() {
    setState(() {
      invoiceItems.add({
        'description': TextEditingController(),
        'hours': TextEditingController(),
        'price': TextEditingController(),
        'total': '0.00',
      });
    });
  }

  void calculateTotal(int index) {
    double hours = double.tryParse(invoiceItems[index]['hours'].text) ?? 0.0;
    double price = double.tryParse(invoiceItems[index]['price'].text) ?? 0.0;
    setState(() {
      invoiceItems[index]['total'] = (hours * price).toStringAsFixed(2);
      calculateGrandTotal();
    });
  }

  void calculateGrandTotal() {
    double grandTotal = invoiceItems.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['total']) ?? 0.0);
    });

    if (isGST) {
      double gstRate = double.tryParse(gstRateController.text) ?? 0.0;
      double gstAmount = grandTotal * (gstRate / 100);
      gstAmountController.text = gstAmount.toStringAsFixed(2);
      grandTotal += gstAmount;
    } else {
      gstAmountController.text = "0.00";
    }

    totalAmountController.text = grandTotal.toStringAsFixed(2);
  }

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
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('No. of hrs')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Price/hr')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total')),
                    ],
                  ),
                  ...invoiceItems.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['description'].text)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['hours'].text)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['price'].text)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item['total'])),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
              if (isGST) pw.Text("GST Rate: ${gstRateController.text}%", style: const pw.TextStyle(fontSize: 16)),
              if (isGST) pw.Text("GST Amount: ${gstAmountController.text}", style: const pw.TextStyle(fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor(context).green,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(160, 80, 160, 160),
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

                  /// Invoice Table
                  Table(
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
                                  child: Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: appColor(context).text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ))),
                          TableCell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    'No. of hrs',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: appColor(context).text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ))),
                          TableCell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    'Price/hr',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: appColor(context).text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ))),
                          TableCell(
                              child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: appColor(context).text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ))),
                        ],
                      ),
                      ...invoiceItems.asMap().entries.map((entry) {
                        return TableRow(
                          children: InvoiceItemRow(
                            itemData: entry.value,
                            onValueChanged: () => calculateTotal(entry.key),
                          ).buildRow(context),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),
                  IconButton(
                    color: appColor(context).green,
                    onHover: (value) {},
                    onPressed: addNewItem,
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.add_box_rounded,
                          color: appColor(context).green,
                        ),
                        Text(
                          'Add Field',
                          style: TextStyle(fontSize: 18, color: appColor(context).text),
                        )
                      ],
                    ),
                    tooltip: "Add Field",
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isGST,
                            onChanged: (value) {
                              setState(() {
                                isGST = value!;
                                calculateGrandTotal(); // Recalculate total when GST is toggled
                              });
                            },
                          ),
                          Text(
                            "Include GST",
                            style: TextStyle(fontSize: 16, color: appColor(context).text),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isGST)
                        InvoiceTextField(
                          label: "GST Rate (%)",
                          controller: gstRateController,
                          textStyle: TextStyle(fontSize: 16, color: appColor(context).text),
                        ),
                      const SizedBox(height: 8),
                      if (isGST)
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
                          style: TextStyle(fontSize: 18, color: appColor(context).text),
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

/// **Reusable Input Field**
class InvoiceTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isReadOnly;
  final TextStyle? textStyle;

  const InvoiceTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isReadOnly = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: appColor(context).text!),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appColor(context).text!),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appColor(context).text!),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appColor(context).text!),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appColor(context).text!),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
        ),
        style: textStyle,
      ),
    );
  }
}

class InvoiceItemRow {
  final Map<String, dynamic> itemData;
  final VoidCallback onValueChanged;

  InvoiceItemRow({required this.itemData, required this.onValueChanged});

  List<Widget> buildRow(BuildContext context) {
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
            controller: itemData['hours'],
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
          child: Text(itemData['total'],
              style: TextStyle(
                fontSize: 18,
                color: appColor(context).text,
              )),
        ),
      ),
    ];
  }
}
