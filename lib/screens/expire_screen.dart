import 'package:apptv02/models/user.dart';
import 'package:apptv02/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpireScreen extends StatefulWidget {
  const ExpireScreen({super.key});

  @override
  State<ExpireScreen> createState() => _ExpireScreenState();
}

class _ExpireScreenState extends State<ExpireScreen> {
  TextStyle style = const TextStyle(
    color: Colors.white,
    fontFamilyFallback: ['radley'],
    letterSpacing: 3,
    fontSize: 16,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 8.0,
        color: Colors.black,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/BackgorundExprie.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            // width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                'លេខទូរស័ព្ទរបស់អ្នក: ${user.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  // fontFamilyFallback: ['radley'],
                  fontSize: 16,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 8.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
