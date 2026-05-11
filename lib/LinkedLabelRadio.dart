import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';

class LinkedLabelRadio extends StatelessWidget {
  const LinkedLabelRadio({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.padding = const EdgeInsets.all(8.0),
  });

  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value), // Allows tapping the text to select
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: (String? newValue) {
                onChanged(newValue);
              },
              activeColor: Color.fromARGB(
                255,
                60,
                15,
                1,
              ), // Styling the radio color
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal-Bold',
                fontSize: 18,
                fontWeight: value == groupValue
                    ? FontWeight.w800
                    : FontWeight.normal,
                color: value == groupValue
                    ? Color.fromARGB(255, 60, 15, 1)
                    : darkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
