import 'package:flutter/material.dart';

Widget qtyButton(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(10),
    ),
    child: IconButton(
      icon: Icon(icon, color: isAdd ? const Color(0xffFF7A00) : Colors.grey),
      onPressed: onTap,
    ),
  );
}