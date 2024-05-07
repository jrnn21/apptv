// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final void Function(String) onKeyPressed;
  const CustomKeyboard({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(96, 0, 0, 0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              KeyboardButton(text: '1', onPressed: () => onKeyPressed('1')),
              KeyboardButton(text: '2', onPressed: () => onKeyPressed('2')),
              KeyboardButton(text: '3', onPressed: () => onKeyPressed('3')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              KeyboardButton(text: '4', onPressed: () => onKeyPressed('4')),
              KeyboardButton(text: '5', onPressed: () => onKeyPressed('5')),
              KeyboardButton(text: '6', onPressed: () => onKeyPressed('6')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              KeyboardButton(text: '7', onPressed: () => onKeyPressed('7')),
              KeyboardButton(text: '8', onPressed: () => onKeyPressed('8')),
              KeyboardButton(text: '9', onPressed: () => onKeyPressed('9')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BackspaceButton(onPressed: () => onKeyPressed('backspace')),
              KeyboardButton(text: '0', onPressed: () => onKeyPressed('0')),
              KeyboardButton(
                  text: 'OK', onPressed: () => onKeyPressed('login')),
            ],
          ),
        ],
      ),
    );
  }
}

class KeyboardButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const KeyboardButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromARGB(197, 0, 0, 0),
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            highlightColor: Colors.blueAccent,
            focusColor: Colors.blueAccent,
            borderRadius: BorderRadius.circular(5),
            onTap: onPressed,
            child: SizedBox(
                width: 50,
                height: 40,
                child: Center(
                    child: Text(
                  text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ))),
          ),
        ),
      ),
    );
  }
}

class BackspaceButton extends StatelessWidget {
  final void Function()? onPressed;

  const BackspaceButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromARGB(197, 0, 0, 0),
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            highlightColor: Colors.blueAccent,
            focusColor: Colors.blueAccent,
            borderRadius: BorderRadius.circular(5),
            onTap: onPressed,
            child: const SizedBox(
                width: 50,
                height: 40,
                child: Center(
                  child: Icon(
                    Icons.backspace_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
