import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro_app/utils/data_storage.dart';
import 'package:quick_actions/quick_actions.dart';

class TimerWidget extends StatefulWidget {
  final ValueNotifier<bool> timerEndedNotifier;

  const TimerWidget({
    Key? key,
    required this.timerEndedNotifier,
  }) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();

  // Method to start the timer from outside
  void startTimer() {
    final _TimerWidgetState? state = _timerKey.currentState;
    state?.startTimer();
    //print("Trying");
  }
}

final GlobalKey<_TimerWidgetState> _timerKey = GlobalKey<_TimerWidgetState>();

class _TimerWidgetState extends State<TimerWidget> {
  late int _currentSeconds;
  late Timer _timer;
  late AudioPlayer player;
  bool _isTimerRunning = false;
  late int _timeInSeconds;
  late TextEditingController _sessionMinutesController;
  late TextEditingController _sessionSecondsController;
  late TextEditingController _breakMinutesController;
  late TextEditingController _breakSecondsController;
  bool _isWorkingPhase = true;
  int countToNotify = 0;
  int howOftenUpdateStatsInSec = 10;

  @override
  void initState() {
    super.initState();
    _currentSeconds = 25 * 60;
    player = AudioPlayer();
    _timeInSeconds = _currentSeconds;
    _sessionMinutesController = TextEditingController();
    _sessionMinutesController.text = '25';
    _sessionSecondsController = TextEditingController();
    _sessionSecondsController.text = '00';
    _breakMinutesController = TextEditingController();
    _breakMinutesController.text = '5';
    _breakSecondsController = TextEditingController();
    _breakSecondsController.text = '00';
    _isTimerRunning = false;
    _isWorkingPhase = true;
    //_startTimer(); dont start from default


  }

  void _setTimer(int minutes, int seconds) {
    setState(() {
      _currentSeconds = minutes * 60 + seconds;
      _timeInSeconds = _currentSeconds;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
          countToNotify++;
          if (countToNotify >= howOftenUpdateStatsInSec) {
            DataStorage.updateDailyTime(howOftenUpdateStatsInSec);
            countToNotify = 0;
          }
        } else {
          widget.timerEndedNotifier.value = false;
          _timer.cancel();
          _playSound();
          widget.timerEndedNotifier.value = true;
          _switchPhase();
        }
      });
    });
    _isTimerRunning = true;
  }

  Future<void> _playSound() async {
    await player.setSource(AssetSource('notification.wav'));
    await player.play(AssetSource('notification.wav'));
  }

  void startTimer() {
    _startTimer();
    setState(() {
      _isTimerRunning = true;
    });
  }

  void stopTimer() {
    _timer.cancel();
    widget.timerEndedNotifier.value = false;
    setState(() {
      _isTimerRunning = false;
    });
  }

  void restartTimer() {
    _timer.cancel();
    _isTimerRunning = false;

    int focusTimeMinutes = int.tryParse(_sessionMinutesController.text) ?? 0;
    int focusTimeSeconds = int.tryParse(_sessionSecondsController.text) ?? 0;

    int breakTimeMinutes = int.tryParse(_breakMinutesController.text) ?? 0;
    int breakTimeSeconds = int.tryParse(_breakSecondsController.text) ?? 0;


    if (_isWorkingPhase) {
      _setTimer(focusTimeMinutes, focusTimeSeconds);
    } else {
      _setTimer(breakTimeMinutes, breakTimeSeconds);
    }
    // _startTimer(); // I think it is better not to start automatically
  }

  void _switchPhase() {
    //print("I switch");
    _isWorkingPhase = !_isWorkingPhase;
    if (_isWorkingPhase) {
      int focusTimeMinutes = int.tryParse(_sessionMinutesController.text) ?? 0;
      int focusTimeSeconds = int.tryParse(_sessionSecondsController.text) ?? 0;
      _setTimer(focusTimeMinutes, focusTimeSeconds);
    } else {
      int breakTimeMinutes = int.tryParse(_breakMinutesController.text) ?? 0;
      int breakTimeSeconds = int.tryParse(_breakSecondsController.text) ?? 0;
      _setTimer(breakTimeMinutes, breakTimeSeconds);
    }
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    // There is an offset of 0.02% so that from the beginning user sees
    // what is this circle (showing just a point at the beginning could
    // be confusing
    double progressPercent = 0.02 + 1 - 0.98*(_currentSeconds / _timeInSeconds);
    if(progressPercent > 1){
      progressPercent = 1;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: CircularPercentIndicator(
            radius: 150,
            lineWidth: 8,
            percent: progressPercent,
            animation: true,
            progressColor: _isWorkingPhase ? Colors.blue : Colors.green,
            backgroundColor: Colors.black12,
            animateFromLastPercent: true,
            animationDuration: 500,
            widgetIndicator: Icon(
              Icons.circle,
              color: _isWorkingPhase ? Colors.blue : Colors.green,
            ),
            onAnimationEnd: () {
              //
            },
            center: Text(
              '${(_currentSeconds ~/ 60).toString().padLeft(2, '0')} : ${(_currentSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 50,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isTimerRunning)
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
                label: const Text(
                  'Start',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(7, 172, 0, 1.0),
                  shape: const StadiumBorder(),
                ),
                onPressed: startTimer,
              ),
            if (_isTimerRunning)
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.pause,
                  color: Colors.white,
                  size: 30,
                ),
                label: const Text(
                  'Pause',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(31, 145, 241, 1.0),
                  shape: const StadiumBorder(),
                ),
                onPressed: stopTimer,
              ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.restart_alt_outlined,
                color: Colors.white,
                size: 30,
              ),
              label: const Text(
                'Restart',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(31, 145, 241, 1.0),
                shape: const StadiumBorder(),
              ),
              onPressed: restartTimer,
            ),
          ],
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Focus Time: ', style: TextStyle(fontSize: 20)),
            SizedBox(
              width: 50, // Ustaw szerokość pola jak potrzebujesz
              child: TextField(
                controller: _sessionMinutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    int intValue = int.parse(value);
                    if (intValue < 0) {
                      _sessionMinutesController.text = '0';
                    }
                  }
                },
              ),
            ),
            Text(':', style: TextStyle(fontSize: 20)),
            SizedBox(
              width: 50,
              child: TextField(
                controller: _sessionSecondsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    int intValue = int.parse(value);
                    if (intValue < 0) {
                      _sessionSecondsController.text = '0';
                    } else if (intValue > 59) {
                      _sessionSecondsController.text = '59';
                    }
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Break Time: ', style: TextStyle(fontSize: 20)),
            SizedBox(
              width: 50,
              child: TextField(
                controller: _breakMinutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    int intValue = int.parse(value);
                    if (intValue < 0) {
                      _breakMinutesController.text = '0';
                    }
                  }
                },
              ),
            ),
            Text(':', style: TextStyle(fontSize: 20)),
            SizedBox(
              width: 50,
              child: TextField(
                controller: _breakSecondsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    int intValue = int.parse(value);
                    if (intValue < 0) {
                      _breakSecondsController.text = '0';
                    } else if (intValue > 59) {
                      _breakSecondsController.text = '59';
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
