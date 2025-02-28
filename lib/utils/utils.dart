import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<String?> selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
  );

  if (picked != null) {
    // Format the date using intl package
    return DateFormat('dd/MM/yyyy').format(picked);
  }
  return null;
}
