import 'package:flutter/material.dart';

class ExpireScreen extends StatelessWidget {
  const ExpireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/BackgorundExprie.jpg'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
