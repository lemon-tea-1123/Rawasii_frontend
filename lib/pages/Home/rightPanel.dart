import 'package:flutter/material.dart';
import 'package:rawasii/globals.dart';
import 'package:rawasii/pages/Home/parentSize.dart';

class RightPanel extends StatefulWidget {
  const RightPanel({super.key});

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  @override
  Widget build(BuildContext context) {
    return ParentSized(
      builder: (double width, double height) {
        return Container(
          color: bgColor,

          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: width * 0.04),
                  Align(
                    alignment: AlignmentGeometry.topLeft,
                    child: Text(
                      'Followings :',
                      style: TextStyle(
                        color: darkColor,
                        fontFamily: 'Tajawal-Bold',
                        fontSize: width * 0.08,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
