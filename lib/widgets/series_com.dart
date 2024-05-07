// ignore_for_file: must_be_immutable

import 'package:apptv02/utility/class.dart';
import 'package:apptv02/utility/counter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SeriesCom extends StatefulWidget {
  SeriesCom(
      {super.key,
      required this.ontap,
      required this.onselect,
      required this.allMoviesEp,
      required this.e,
      required this.i,
      required this.selectMovie});
  Function() ontap;
  Function() onselect;
  List<M3USeriesItem> allMoviesEp;
  M3USeriesItem e;
  int i;
  int selectMovie;

  @override
  State<SeriesCom> createState() => _SeriesComState();
}

class _SeriesComState extends State<SeriesCom> {
  VisibilityDetectorController vController = VisibilityDetectorController();
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool se = widget.i == widget.selectMovie;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.diagonal3Values(se ? 1.15 : 1.0, se ? 1.15 : 1.0, 1.0),
      transformAlignment: Alignment.center,
      child: Material(
        color:
            widget.i == widget.selectMovie ? Colors.pink : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: widget.ontap,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: Colors.white12, borderRadius: BorderRadius.circular(8)),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7.0),
                  child: Container(color: Colors.black87),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(7.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.e.logo.trim(),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                widget.e.ep.trim().length != 1
                    ? Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 68, 68, 68)
                                    .withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 14,
                            child: Center(
                              child: Text(
                                counterSeriesByEp(
                                        list: widget.allMoviesEp,
                                        value: widget.e.title)
                                    .trim(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
