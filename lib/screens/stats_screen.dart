import 'package:flutter/material.dart';
import 'package:pomodoro_app/utils/data_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:quick_actions/quick_actions.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _currentWeekIndex = 0;

  @override
  Widget build(BuildContext context) {

    final QuickActions quickActions = QuickActions();
    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_timer',
        localizedTitle: 'Start time',
        icon: 'ic_home',
      ),
    ]);

    // final sessionProvider = Provider.of<SessionProvider>(context);

    //_saveDummyData(); // I've run this once and don't run now, to be sure that this is saved

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Time spent on pomodoro sessions in a week', style: TextStyle(fontSize: 17,),),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    _changeWeek(-1); // Move to the previous week
                  },
                ),
                Text(
                  _getWeekRange(),
                  style: TextStyle(fontSize: 17,),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    _changeWeek(1); // Move to the next week
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 350,
              child: FutureBuilder<List<double>>(
                future: _getWeeklyData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  else {
                    return BarChart(
                      getData(snapshot.data!),
                      );
                    // );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDummyData() async {
    DateTime currentDate = DateTime.now();

    // Truncate the time portion to ensure an accurate comparison
    DateTime truncatedCurrentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    await DataStorage.saveDailyTime(truncatedCurrentDate, const Duration(minutes: 30));

    // Save data for the previous day
    DateTime previousDate = currentDate.subtract(const Duration(days: 1));
    DateTime truncatedPreviousDate = DateTime(previousDate.year, previousDate.month, previousDate.day);
    await DataStorage.saveDailyTime(truncatedPreviousDate, const Duration(minutes: 20));

    // Save data for the day before previous day (two days ago)
    DateTime twoDaysAgoDate = currentDate.subtract(const Duration(days: 2));
    DateTime truncatedTwoDaysAgoDate = DateTime(twoDaysAgoDate.year, twoDaysAgoDate.month, twoDaysAgoDate.day);
    await DataStorage.saveDailyTime(truncatedTwoDaysAgoDate, const Duration(minutes: 15));
    // Add more dummy data as needed
  }


  Future<List<double>> _getWeeklyData() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - DateTime.monday) + Duration(days: _currentWeekIndex * 7));

    List<double> data = [];

    for (int i = 0; i < 7; i++) {
      DateTime date = startOfWeek.add(Duration(days: i));
      DateTime truncatedDate = DateTime(date.year, date.month, date.day);

      Duration timeSpent = await DataStorage.getDailyTime(truncatedDate);

      data.add(timeSpent.inSeconds.toDouble());
    }

    return data;
  }


  void _changeWeek(int offset) {
    _currentWeekIndex += offset;

    // Trigger a rebuild by calling setState
    setState(() {});
  }

  String _getWeekRange() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - DateTime.monday) + Duration(days: _currentWeekIndex * 7));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    String formattedStartDate = DateFormat('dd.MM.yyyy').format(startOfWeek);
    String formattedEndDate = DateFormat('dd.MM.yyyy').format(endOfWeek);

    return '$formattedStartDate - $formattedEndDate';
  }


  List<BarChartGroupData> _getBarGroups(List<double> data) {
    return List.generate(
      data.length,
          (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data.isEmpty ? 0 : data.reduce(max),
              color: Colors.blueAccent,
            ),
          ],
        );
      },
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('M', style: style);
        break;
      case 1:
        text = const Text('T', style: style);
        break;
      case 2:
        text = const Text('W', style: style);
        break;
      case 3:
        text = const Text('T', style: style);
        break;
      case 4:
        text = const Text('F', style: style);
        break;
      case 5:
        text = const Text('S', style: style);
        break;
      case 6:
        text = const Text('S', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  BarChartGroupData makeGroupData(
      int x,
      double y, {
        Color? barColor,
        double width = 22,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: Color.fromRGBO(245, 225, 225, 1.0),
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  BarChartData getData(List<double> weeklyData) {
    // Find the maximum value in the data
    double maxData = weeklyData.isNotEmpty ? weeklyData.reduce(max) : 1.0;

    return BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueAccent,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String time = formatTime(weeklyData[group.x.toInt()].toInt());
            return BarTooltipItem(
              time,
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(weeklyData.length, (i) {
        double normalizedValue = weeklyData[i] / maxData * 20;
        return makeGroupData(
          i,
          normalizedValue,
          barColor: Colors.blueAccent,
        );
      }),
      gridData: const FlGridData(show: false),
    );
  }
}
