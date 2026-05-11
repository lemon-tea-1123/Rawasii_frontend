// A reusable widget you can wrap around anything

import 'package:flutter/material.dart';

// A reusable widget you can wrap around anything
class ParentSized extends StatelessWidget {
  final Widget Function(double width, double height) builder;

  const ParentSized({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(
        constraints.maxWidth,
        constraints.maxHeight,
      ),
    );
  }
}