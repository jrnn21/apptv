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
  TextStyle style = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
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
    // TimeExpire timeExpire = context.watch<ExpireProvider>().timer;
    Duration? durationExpire = context.watch<ExpireProvider>().durationExpire;
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
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
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        focusColor: Colors.white,
                        autofocus: true,
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (tvDownloadProgress == 100.0) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const LiveScreen()));
                          } else if (tvDownloadProgress == 0.0) {
                            context.read<TvProvider>().init();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 200,
                          height: 250,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromARGB(255, 42, 230, 220),
                                Color.fromARGB(255, 8, 49, 230),
                              ],
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 69, 70, 70)
                                    .withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          child: tvDownloadProgress == 100.0 ||
                                  tvDownloadProgress == 0.0
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.live_tv_rounded,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'ផ្សាយផ្ទាល់',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      value: tvDownloadProgress,
                                      fractionDigits: 1, // decimal precision
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
                        focusColor: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (moviesDownloadProgress == 100.0) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const MoviesScreen()));
                          } else if (moviesDownloadProgress == 0.0) {
                            context.read<MoviesProvider>().init();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 200,
                          height: 250,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              // stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Color.fromARGB(255, 243, 164, 250),
                                Color.fromARGB(255, 173, 7, 165),
                              ],
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 69, 70, 70)
                                    .withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(
                                    1, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: moviesDownloadProgress == 100.0 ||
                                  moviesDownloadProgress == 0.0
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.movie,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'រឿងហូលីវូត',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      value: moviesDownloadProgress,
                                      fractionDigits: 1, // decimal precision
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
                        focusColor: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (seriesDownloadProgress == 100.0) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const SeriesScreen()));
                          } else if (seriesDownloadProgress == 0.0) {
                            context.read<SeriesProvider>().init();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 200,
                          height: 250,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              // stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Color.fromARGB(255, 163, 234, 247),
                                Color.fromARGB(255, 19, 49, 180),
                              ],
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 69, 70, 70)
                                    .withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(
                                    1, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: seriesDownloadProgress == 100.0 ||
                                  seriesDownloadProgress == 0.0
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_movies,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'រឿងភាគ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                  bottom: 5,
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
