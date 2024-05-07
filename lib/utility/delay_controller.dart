import 'dart:async';

class DelayController {
  late Timer _timer;
  bool _isRunning = false;

  void startDelay({required Duration duration, required Function func}) {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer(duration, () {
        _isRunning = false;
        func();
      });
    }
  }

  void stopDelay({required Function func}) {
    if (_isRunning) {
      _timer.cancel();
      _isRunning = false;
      func();
    }
  }
}
