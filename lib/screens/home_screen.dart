// ignore_for_file: use_build_context_synchronously

import 'package:apptv02/providers/expire_provider.dart';
import 'package:apptv02/providers/movies_provider.dart';
import 'package:apptv02/providers/series_provider.dart';
import 'package:apptv02/providers/tv_provider.dart';
import 'package:apptv02/screens/live_screen.dart';
import 'package:apptv02/screens/movies_screen.dart';
import 'package:apptv02/screens/series_screen.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int? focusItem;
  TextStyle style = const TextStyle(
    color: Colors.white,
    // fontWeight: FontWeight.bold,
    fontSize: 16,
    fontFamilyFallback: ['koulen'],
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
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      context.read<ExpireProvider>().stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      // App is back in the foreground
    } else if (state == AppLifecycleState.inactive) {
      // App is inactive
    }
  }

  @override
  Widget build(BuildContext context) {
    double seriesDownloadProgress = context.watch<SeriesProvider>().download;
    double moviesDownloadProgress = context.watch<MoviesProvider>().download;
    double tvDownloadProgress = context.watch<TvProvider>().download;
    TimeExpire timeExpire = context.watch<ExpireProvider>().timer;
    Duration? durationExpire = context.watch<ExpireProvider>().durationExpire;
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
              image:
                  DecorationImage(image: AssetImage('images/Background.jpg'))),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 130,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        autofocus: true,
                        focusColor: const Color.fromARGB(90, 255, 0, 0),
                        highlightColor: const Color.fromARGB(90, 255, 0, 0),
                        onFocusChange: (value) {
                          if (value) {
                            setState(() {
                              focusItem = 1;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          if (tvDownloadProgress == 100.0) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const LiveScreen()));
                          } else if (tvDownloadProgress == 0.0) {
                            Future<bool> isDone =
                                context.read<TvProvider>().init();
                            if (await isDone) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const LiveScreen()));
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 200,
                          // height: 250,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: tvDownloadProgress == 100.0 ||
                                  tvDownloadProgress == 0.0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      height: 200,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      transform: Matrix4.diagonal3Values(
                                          focusItem == 1 ? 1.2 : 1,
                                          focusItem == 1 ? 1.2 : 1,
                                          1),
                                      transformAlignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 22),
                                          Image.asset(
                                            'images/TVicon2.png',
                                            width: 110,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Image.asset(
                                      'images/Group4.png',
                                      width: 100,
                                    )
                                    // Text(
                                    //   'ផ្សាយផ្ទាល់',
                                    //   style: style,
                                    // )
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                        child: SpinKitWaveSpinner(
                                          color: Colors.white,
                                          waveColor: Colors.blueAccent,
                                          size: 80.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    AnimatedFlipCounter(
                                      value: tvDownloadProgress,
                                      fractionDigits: 1,
                                      suffix: "%",
                                      duration: const Duration(seconds: 1),
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        focusColor: const Color.fromARGB(90, 255, 0, 0),
                        highlightColor: const Color.fromARGB(90, 255, 0, 0),
                        onFocusChange: (value) {
                          if (value) {
                            setState(() {
                              focusItem = 2;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          if (moviesDownloadProgress == 100.0) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const MoviesScreen()));
                          } else if (moviesDownloadProgress == 0.0) {
                            Future<bool> isDone =
                                context.read<MoviesProvider>().init();
                            if (await isDone) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const MoviesScreen()));
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 200,
                          // height: 250,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: moviesDownloadProgress == 100.0 ||
                                  moviesDownloadProgress == 0.0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      height: 200,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      transform: Matrix4.diagonal3Values(
                                          focusItem == 2 ? 1.2 : 1,
                                          focusItem == 2 ? 1.2 : 1,
                                          1),
                                      transformAlignment: Alignment.center,
                                      child: Center(
                                        child: Image.asset(
                                          'images/Movieicon2.png',
                                          width: 110,
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      'images/Group5.png',
                                      width: 100,
                                    )
                                    // Text('រឿងហូលីវូត', style: style)
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                        child: SpinKitWaveSpinner(
                                          color: Colors.white,
                                          waveColor: Colors.blueAccent,
                                          size: 80.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    AnimatedFlipCounter(
                                      value: moviesDownloadProgress,
                                      fractionDigits: 1,
                                      suffix: "%",
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        focusColor: const Color.fromARGB(90, 255, 0, 0),
                        highlightColor: const Color.fromARGB(90, 255, 0, 0),
                        onFocusChange: (value) {
                          if (value) {
                            setState(() {
                              focusItem = 3;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          if (seriesDownloadProgress == 100.0) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const SeriesScreen()));
                          } else if (seriesDownloadProgress == 0.0) {
                            Future<bool> isDone =
                                context.read<SeriesProvider>().init();
                            if (await isDone) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const SeriesScreen()));
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 200,
                          // height: 250,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: seriesDownloadProgress == 100.0 ||
                                  seriesDownloadProgress == 0.0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      height: 200,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      transform: Matrix4.diagonal3Values(
                                          focusItem == 3 ? 1.2 : 1,
                                          focusItem == 3 ? 1.2 : 1,
                                          1),
                                      transformAlignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 47),
                                          Image.asset(
                                            'images/seriesicon3.png',
                                            width: 165,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Text(
                                    //   'រឿងភាគ',
                                    //   style: style,
                                    // )
                                    Image.asset(
                                      'images/Group6.png',
                                      width: 80,
                                    )
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                        child: SpinKitWaveSpinner(
                                          color: Colors.white,
                                          waveColor: Colors.blueAccent,
                                          size: 80.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    AnimatedFlipCounter(
                                      value: seriesDownloadProgress,
                                      fractionDigits: 2, // decimal precision
                                      suffix: "%",
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Positioned(
              //   top: 5,
              //   left: 10,
              //   child: Center(
              //     child: Row(
              //       children: [
              //         Text('ផុតកំណត់ៈ ', style: style),
              //         AnimatedFlipCounter(
              //             value: timeExpire.days, textStyle: style),
              //         Text(' ថ្ងៃ', style: style),
              //         const SizedBox(width: 10),
              //         Text('${timeExpire.hours} ម៉ោង', style: style),
              //         const SizedBox(width: 10),
              //         Text('${timeExpire.minutes} នាទី', style: style),
              //         const SizedBox(width: 10),
              //         Text('${timeExpire.seconds} វិនាទី', style: style),
              //       ],
              //     ),
              //   ),
              // ),
              Positioned(
                  top: 5,
                  left: 10,
                  child: FlipClockPlus.reverseCountdown(
                    duration: durationExpire,
                    digitColor: Colors.white,
                    backgroundColor: Colors.black,
                    digitSize: 16.0,
                    centerGapSpace: 0.0,
                    width: 20,
                    height: 25,
                    flipDirection: FlipDirection.up,
                    spacing: const EdgeInsets.symmetric(horizontal: 1),
                    separator: const Text(':', style: TextStyle(fontSize: 20)),
                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                    daysLabelStr: 'ថ្ងៃ',
                    hoursLabelStr: 'ម៉ោង',
                    minutesLabelStr: 'នាទី',
                    secondsLabelStr: 'វិនាទី',
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
