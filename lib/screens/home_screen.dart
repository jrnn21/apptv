// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_field

import 'package:apptv02/models/link.dart';
import 'package:apptv02/providers/app_provider.dart';
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
  int focusItem = 1;
  double _seriesDownloadProgress = 0.0;
  double _moviesDownloadProgress = 0.0;
  double _tvDownloadProgress = 0.0;
  FocusNode node = FocusNode();
  late LinkApp linkApp;

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
  List<BoxShadow> shadow = const [
    BoxShadow(
      offset: Offset(1.0, 1.0),
      blurRadius: 3.0,
      color: Color.fromARGB(255, 134, 134, 134),
    ),
    BoxShadow(
      offset: Offset(1.0, 1.0),
      blurRadius: 8.0,
      color: Colors.black,
    ),
  ];
  List<Shadow> shadowText = const [
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
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    linkApp = context.read<AppProvider>().linkApp;
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

  void onKey(RawKeyEvent event) async {
    int i = 1;
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          i = (focusItem - 1).clamp(1, 3);
          setState(() {
            focusItem = i;
          });
          break;
        case LogicalKeyboardKey.arrowRight:
          i = (focusItem + 1).clamp(1, 3);
          setState(() {
            focusItem = i;
          });
          break;
        case LogicalKeyboardKey.enter:
          if (focusItem == 1) {
            if (_tvDownloadProgress == 100.0) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LiveScreen()));
            } else if (_tvDownloadProgress == 0.0) {
              Future<bool> isDone = context.read<TvProvider>().init(linkApp.tv);
              if (await isDone) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LiveScreen()));
              }
            }
          } else if (focusItem == 2) {
            if (_moviesDownloadProgress == 100.0) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MoviesScreen()));
            } else if (_moviesDownloadProgress == 0.0) {
              Future<bool> isDone =
                  context.read<MoviesProvider>().init(linkApp.movies);
              if (await isDone) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MoviesScreen()));
              }
            }
          } else if (focusItem == 3) {
            if (_seriesDownloadProgress == 100.0) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SeriesScreen()));
            } else if (_seriesDownloadProgress == 0.0) {
              Future<bool> isDone =
                  context.read<SeriesProvider>().init(linkApp.series);
              if (await isDone) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SeriesScreen()));
              }
            }
          }
          break;
        case LogicalKeyboardKey.select:
          if (focusItem == 1) {
            if (_tvDownloadProgress == 100.0) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LiveScreen()));
            } else if (_tvDownloadProgress == 0.0) {
              Future<bool> isDone = context.read<TvProvider>().init(linkApp.tv);
              if (await isDone) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LiveScreen()));
              }
            }
          } else if (focusItem == 2) {
            if (_moviesDownloadProgress == 100.0) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MoviesScreen()));
            } else if (_moviesDownloadProgress == 0.0) {
              Future<bool> isDone =
                  context.read<MoviesProvider>().init(linkApp.movies);
              if (await isDone) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MoviesScreen()));
              }
            }
          } else if (focusItem == 3) {
            if (_seriesDownloadProgress == 100.0) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SeriesScreen()));
            } else if (_seriesDownloadProgress == 0.0) {
              Future<bool> isDone =
                  context.read<SeriesProvider>().init(linkApp.series);
              if (await isDone) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SeriesScreen()));
              }
            }
          }
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double seriesDownloadProgress = context.watch<SeriesProvider>().download;
    double moviesDownloadProgress = context.watch<MoviesProvider>().download;
    double tvDownloadProgress = context.watch<TvProvider>().download;
    TimeExpire timeExpire = context.watch<ExpireProvider>().timer;
    setState(() {
      _seriesDownloadProgress = seriesDownloadProgress;
      _moviesDownloadProgress = moviesDownloadProgress;
      _tvDownloadProgress = tvDownloadProgress;
    });
    Duration? durationExpire = context.watch<ExpireProvider>().durationExpire;
    return RawKeyboardListener(
      focusNode: node,
      autofocus: true,
      onKey: onKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/BackgroundScreen.jpg'))),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 160,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.diagonal3Values(
                          focusItem == 1 ? 1.2 : 1,
                          focusItem == 1 ? 1.2 : 1,
                          1),
                      transformAlignment: Alignment.center,
                      child: Container(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              focusItem = 1;
                            });
                            if (tvDownloadProgress == 100.0) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const LiveScreen()));
                            } else if (tvDownloadProgress == 0.0) {
                              Future<bool> isDone =
                                  context.read<TvProvider>().init(linkApp.tv);
                              if (await isDone) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const LiveScreen()));
                              }
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            width: 180,
                            height: 225,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                              boxShadow: shadow,
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.1, 1],
                                colors: [
                                  Color(0xFF59B4FF),
                                  Color.fromARGB(255, 0, 26, 255),
                                ],
                              ),
                            ),
                            child: tvDownloadProgress == 100.0 ||
                                    tvDownloadProgress == 0.0
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // AnimatedContainer(
                                      //   height: 200,
                                      //   duration:
                                      //       const Duration(milliseconds: 200),
                                      //   transform: Matrix4.diagonal3Values(
                                      //       focusItem == 1 ? 1.2 : 1,
                                      //       focusItem == 1 ? 1.2 : 1,
                                      //       1),
                                      //   transformAlignment: Alignment.center,
                                      //   child: Column(
                                      //     children: [
                                      //       const SizedBox(height: 22),
                                      //       Image.asset(
                                      //         'images/TVicon2.png',
                                      //         width: 110,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // Image.asset(
                                      //   'images/Group4.png',
                                      //   width: 100,
                                      // )
                                      Icon(
                                        Icons.live_tv_rounded,
                                        color: Colors.white,
                                        size: 100,
                                        // shadows: shadowText,
                                      ),
                                      Text(
                                        'ប៉ុស្តិ៍ទូរទស្សន៍',
                                        // style: style,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10)
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
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.diagonal3Values(
                          focusItem == 2 ? 1.2 : 1,
                          focusItem == 2 ? 1.2 : 1,
                          1),
                      transformAlignment: Alignment.center,
                      child: Container(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              focusItem = 2;
                            });
                            if (moviesDownloadProgress == 100.0) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const MoviesScreen()));
                            } else if (moviesDownloadProgress == 0.0) {
                              Future<bool> isDone = context
                                  .read<MoviesProvider>()
                                  .init(linkApp.movies);
                              if (await isDone) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const MoviesScreen()));
                              }
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            width: 180,
                            height: 225,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                              boxShadow: shadow,
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.1, 1],
                                colors: [
                                  Color.fromARGB(255, 232, 118, 255),
                                  Color.fromARGB(255, 248, 0, 83),
                                ],
                              ),
                            ),
                            child: moviesDownloadProgress == 100.0 ||
                                    moviesDownloadProgress == 0.0
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // AnimatedContainer(
                                      //   height: 200,
                                      //   duration:
                                      //       const Duration(milliseconds: 200),
                                      //   transform: Matrix4.diagonal3Values(
                                      //       focusItem == 2 ? 1.2 : 1,
                                      //       focusItem == 2 ? 1.2 : 1,
                                      //       1),
                                      //   transformAlignment: Alignment.center,
                                      //   child: Center(
                                      //     child: Image.asset(
                                      //       'images/Movieicon2.png',
                                      //       width: 110,
                                      //     ),
                                      //   ),
                                      // ),
                                      //  Image.asset(
                                      //   'images/Group5.png',
                                      //   width: 100,
                                      // ),

                                      Icon(
                                        Icons.movie_creation,
                                        color: Colors.white,
                                        size: 100,
                                        // shadows: shadowText,
                                      ),
                                      Text(
                                        'រឿងហូលីវូត',
                                        // style: style,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10)
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
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.diagonal3Values(
                          focusItem == 3 ? 1.2 : 1,
                          focusItem == 3 ? 1.2 : 1,
                          1),
                      transformAlignment: Alignment.center,
                      child: Container(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              focusItem = 3;
                            });
                            if (seriesDownloadProgress == 100.0) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const SeriesScreen()));
                            } else if (seriesDownloadProgress == 0.0) {
                              Future<bool> isDone = context
                                  .read<SeriesProvider>()
                                  .init(linkApp.series);
                              if (await isDone) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const SeriesScreen()));
                              }
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            width: 180,
                            height: 225,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                              boxShadow: shadow,
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.1, 1],
                                colors: [
                                  Color.fromARGB(255, 172, 99, 255),
                                  Color.fromARGB(255, 75, 0, 160),
                                ],
                              ),
                            ),
                            child: seriesDownloadProgress == 100.0 ||
                                    seriesDownloadProgress == 0.0
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // AnimatedContainer(
                                      //   height: 200,
                                      //   duration:
                                      //       const Duration(milliseconds: 200),
                                      //   transform: Matrix4.diagonal3Values(
                                      //       focusItem == 3 ? 1.2 : 1,
                                      //       focusItem == 3 ? 1.2 : 1,
                                      //       1),
                                      //   transformAlignment: Alignment.center,
                                      //   child: Column(
                                      //     children: [
                                      //       const SizedBox(height: 47),
                                      //       Image.asset(
                                      //         'images/seriesicon3.png',
                                      //         width: 165,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      Icon(
                                        Icons.local_movies_rounded,
                                        color: Colors.white,
                                        size: 100,
                                        // shadows: shadowText,
                                      ),
                                      Text(
                                        'រឿងភាគ',
                                        // style: style,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10)
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
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Center(
                  child: Row(
                    children: [
                      Text('ផុតកំណត់ៈ '),
                      AnimatedFlipCounter(value: timeExpire.days),
                      Text(' ថ្ងៃ'),
                      const SizedBox(width: 10),
                      Text('${timeExpire.hours} ម៉ោង'),
                      const SizedBox(width: 10),
                      Text('${timeExpire.minutes} នាទី'),
                      const SizedBox(width: 10),
                      // Text('${timeExpire.seconds} វិនាទី', style: style),
                      AnimatedFlipCounter(value: timeExpire.seconds),
                      Text(' វិនាទី'),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   top: 20,
              //   left: 20,
              //   child: FlipClockPlus.reverseCountdown(
              //     duration: durationExpire,
              //     digitColor: Colors.white,
              //     backgroundColor: Colors.black,
              //     digitSize: 16.0,
              //     centerGapSpace: 0.0,
              //     width: 20,
              //     height: 25,
              //     flipDirection: FlipDirection.up,
              //     spacing: const EdgeInsets.symmetric(horizontal: 1),
              //     separator: const Text(':', style: TextStyle(fontSize: 20)),
              //     borderRadius: const BorderRadius.all(Radius.circular(3.0)),
              //     daysLabelStr: 'ថ្ងៃ',
              //     hoursLabelStr: 'ម៉ោង',
              //     minutesLabelStr: 'នាទី',
              //     secondsLabelStr: 'វិនាទី',
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
