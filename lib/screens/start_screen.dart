import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_app/widgets/timer_widget.dart';
import 'package:pomodoro_app/screens/goals_screen.dart';
import 'package:pomodoro_app/screens/stats_screen.dart';
import 'package:pomodoro_app/screens/login_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _backgroundColorTween;
  late ValueNotifier<bool> _timerEndedNotifier;
  final player = AudioPlayer();
  bool _isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _timerEndedNotifier = ValueNotifier<bool>(false);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _backgroundColorTween = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.white, end: Colors.green),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: Colors.white),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.white, end: Colors.green),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: Colors.white),
          weight: 1,
        ),
      ],
    ).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset(); // Zresetuj controller po zakończeniu animacji
      }
    });

    _timerEndedNotifier.addListener(() {
      if (_timerEndedNotifier.value) {
        startBackgroundColorAnimation();
      }
    });

  }

  void startBackgroundColorAnimation() {
    if (!_animationController.isAnimating) {
      _animationController.forward(from: 0.0);
    }
  }

  Future<void> _playSound() async {
    if (!_isMusicPlaying) {
      await player.setSource(AssetSource('nature.mp3'));
      player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('nature.mp3'),);
      _isMusicPlaying = true;
    } else {
      await player.pause();
      _isMusicPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro App 🍅', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            color: _backgroundColorTween.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TimerWidget(
                  timerEndedNotifier: _timerEndedNotifier,
                ),
                SizedBox(height: 16.0),

                // Play Music Button
                ElevatedButton(
                  onPressed: () {
                    _playSound(); // This will play or pause the music
                  },
                  child: Text("Music"),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle, color: Colors.blue),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.blue),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.blue),
            label: 'Account',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(color: Colors.blue),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalsScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
