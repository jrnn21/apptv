import 'dart:async';
import 'package:apptv02/main.dart';
import 'package:flutter/material.dart';

class TimeExpire {
  TimeExpire(
      {required this.days,
      required this.hours,
      required this.minutes,
      required this.seconds,
      required this.correntTime,
      required this.expireTime});
  int days;
  int hours;
  int minutes;
  int seconds;
  int correntTime;
  int expireTime;
}

class ExpireProvider extends ChangeNotifier {
  int _currentTime = DateTime.now().toUtc().millisecondsSinceEpoch;
  Timer? counterTimer;
  Duration _duration = const Duration();
  TimeExpire _timer = TimeExpire(
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
    correntTime: 0,
    expireTime: 0,
  );

  int get currentTime => _currentTime;
  TimeExpire get timer => _timer;
  Duration get durationExpire => _duration;

  void initExpireTime({required String time, required int totalDay}) async {
    int begin = DateTime.parse(time).millisecondsSinceEpoch;
    int durationInMilisecond = begin + 1000 * 60 * 60 * 24 * totalDay;
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(durationInMilisecond);
    DateTime now = DateTime.now().toUtc();
    Duration duration = now.difference(dateTime) * -1;
    _duration = duration;
    // notifyListeners();
    counterTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTime = _currentTime + 1000;
      now = DateTime.now().toUtc();
      duration = now.difference(dateTime) * -1;
      int days = duration.inDays;
      int hours = duration.inHours % 24;
      int minutes = duration.inMinutes % 60;
      int seconds = duration.inSeconds % 60;
      // print('Duration: $duration');
      // print('Days: $days, Hours: $hours, Minutes: $minutes, Seconds: $seconds');
      _timer = TimeExpire(
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        correntTime: _currentTime,
        expireTime: durationInMilisecond,
      );
      notifyListeners();
    });
  }

  void stopTimer() {
    counterTimer?.cancel();
  }

  void reStartApp(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MyApp(),
        ),
      );
    });
  }
}
