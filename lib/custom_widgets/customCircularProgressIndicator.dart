import 'package:flutter/material.dart';

class Customcircularprogressindicator extends StatelessWidget {
  const Customcircularprogressindicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
}
