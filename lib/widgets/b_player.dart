// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class BPlayer extends StatefulWidget {
  BPlayer({super.key, required this.controller});
  BetterPlayerController controller;

  @override
  State<BPlayer> createState() => _BPlayerState();
}

class _BPlayerState extends State<BPlayer> {
  @override
  Widget build(BuildContext context) {
    return Center(child: BetterPlayer(controller: widget.controller));
  }
}
