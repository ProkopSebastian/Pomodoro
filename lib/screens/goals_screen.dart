import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_app/utils/data_storage.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

Future<int> getTimeToday() async {
  Duration todaysProgressDuration = await DataStorage.getDailyTime(DateTime.now());
  int todayProgress = todaysProgressDuration.inSeconds;
  return todayProgress;
}

class _GoalsScreenState extends State<GoalsScreen> {
  int daysInARow = 5;
  int goalDuration = 30;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildGoalWidget(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _showChangeGoalDialog(context);
              },
              child: Text('Change Goal', style: TextStyle(color: Colors.blueAccent),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalWidget() {
    return FutureBuilder<int>(
      future: getTimeToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int todayProgress = snapshot.data ?? 0;
          todayProgress = (todayProgress /60).round();
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Daily Study Goal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Days in a Row: $daysInARow'),
                const SizedBox(height: 10),
                goalDuration > 0
                    ? Column(
                  children: [
                    LinearProgressIndicator(
                      value: todayProgress / goalDuration,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Today\'s Progress: $todayProgress mins'),
                        Text('Goal: $goalDuration mins'),
                      ],
                    ),
                  ],
                )
                    : Text('If you really want to set your goal to 0:00 then it is already achieved :)'),
              ],
            ),
          );
        }
      },
    );
  }



  // Function to show the change goal dialog
  Future<void> _showChangeGoalDialog(BuildContext context) async {
    Duration? newGoalDuration = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return _buildCupertinoTimePicker();
      },
    );

    if (newGoalDuration != null && newGoalDuration.inMinutes > 0) {
      setState(() {
        goalDuration = newGoalDuration.inMinutes;
      });
    }
  }

  Widget _buildCupertinoTimePicker() {
    return Container(
      height: 200,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        initialDateTime: DateTime(DateTime.now().year, 1, 1, 0, goalDuration),
        onDateTimeChanged: (DateTime newDateTime) {
          Duration newDuration = newDateTime.difference(DateTime(DateTime.now().year, 1, 1));
          setState(() {
            goalDuration = newDuration.inMinutes;
          });
        },
      ),
    );
  }
}
