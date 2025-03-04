import 'package:flutter/material.dart';
import 'package:invoice_generator/modules/theme/app_theme.dart';

class InvoiceTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isReadOnly;
  final TextStyle? textStyle;
  final Function(String)? onChanged;

  const InvoiceTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isReadOnly = false,
    this.textStyle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        onChanged: onChanged,
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
