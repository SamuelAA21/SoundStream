import 'package:flutter/material.dart';

class ShellPage {
  const ShellPage({
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}
