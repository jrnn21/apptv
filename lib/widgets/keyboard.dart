// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final void Function(String) onKeyPressed;
  final int select;
  const CustomKeyboard(
      {super.key, required this.onKeyPressed, required this.select});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            KeyboardButton(
                text: '1',
                onPressed: () => onKeyPressed('1'),
                select: select,
                order: 1),
            KeyboardButton(
                text: '2',
                onPressed: () => onKeyPressed('2'),
                select: select,
                order: 2),
            KeyboardButton(
                text: '3',
                onPressed: () => onKeyPressed('3'),
                select: select,
                order: 3),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            KeyboardButton(
                text: '4',
                onPressed: () => onKeyPressed('4'),
                select: select,
                order: 4),
            KeyboardButton(
                text: '5',
                onPressed: () => onKeyPressed('5'),
                select: select,
                order: 5),
            KeyboardButton(
                text: '6',
                onPressed: () => onKeyPressed('6'),
                select: select,
                order: 6),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            KeyboardButton(
                text: '7',
                onPressed: () => onKeyPressed('7'),
                select: select,
                order: 7),
            KeyboardButton(
                text: '8',
                onPressed: () => onKeyPressed('8'),
                select: select,
                order: 8),
            KeyboardButton(
                text: '9',
                onPressed: () => onKeyPressed('9'),
                select: select,
                order: 9),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BackspaceButton(
                onPressed: () => onKeyPressed('backspace'),
                select: select,
                order: 10),
            KeyboardButton(
                text: '0',
                onPressed: () => onKeyPressed('0'),
                select: select,
                order: 11),
            KeyboardButton(
                text: 'OK',
                onPressed: () => onKeyPressed('login'),
                select: select,
                order: 12),
          ],
        ),
      ],
    );
  }
}

class KeyboardButton extends StatelessWidget {
  final String text;
  final int select;
  final int order;
  final void Function()? onPressed;

  const KeyboardButton({
    super.key,
    required this.text,
    required this.select,
    required this.order,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          // border: Border.all(color: Color.fromARGB(204, 0, 0, 0), width: 2),
          borderRadius: BorderRadius.circular(4),
          color: const Color.fromARGB(255, 39, 39, 39),
        ),
        child: Material(
          color: select == order ? Colors.white : Colors.transparent,
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            // highlightColor: Colors.white,
            // focusColor: Colors.white,
            borderRadius: BorderRadius.circular(4),
            onTap: onPressed,
            child: SizedBox(
              width: 50,
              height: 40,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: select == order ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BackspaceButton extends StatelessWidget {
  final void Function()? onPressed;
  final int select;
  final int order;

  const BackspaceButton({
    super.key,
    required this.onPressed,
    required this.select,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: const Color.fromARGB(255, 39, 39, 39),
        ),
        child: Material(
          color: select == order ? Colors.white : Colors.transparent,
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            highlightColor: Colors.blueAccent,
            focusColor: Colors.blueAccent,
            borderRadius: BorderRadius.circular(4),
            onTap: onPressed,
            child: SizedBox(
                width: 50,
                height: 40,
                child: Center(
                  child: Icon(
                    Icons.backspace_rounded,
                    color: select == order ? Colors.black : Colors.white,
                    size: 18,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
