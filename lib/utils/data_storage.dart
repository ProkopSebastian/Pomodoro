import 'package:shared_preferences/shared_preferences.dart'; // użyte do zapisywania lokalnego

class DataStorage {
  static Future<void> saveDailyTime(DateTime date, Duration timeSpent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Format the date to use only the date portion
    String dateString = "${date.year}-${date.month}-${date.day}";

    //print('Saving data - Date: $dateString, Time Spent (minutes): ${timeSpent.inMinutes}');

    prefs.setInt(dateString, timeSpent.inSeconds);
  }

  static Future<void> updateDailyTime(int secondsToAdd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime date = DateTime.now();

    // Format the date to use only the date portion
    String dateString = "${date.year}-${date.month}-${date.day}";

    // Get the data for today:
    Duration timeToday = await getDailyTime(DateTime.now());
    int timeTodayInSeconds = timeToday.inSeconds;
    timeTodayInSeconds += secondsToAdd;

    //print('Updating time spent for today: now it has been ${timeTodayInSeconds} seconds');

    prefs.setInt(dateString, timeTodayInSeconds);
  }


  static Future<Duration> getDailyTime(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Format the date to use only the date portion
    String dateString = "${date.year}-${date.month}-${date.day}";

    //print('Retrieving data - Date: $dateString');

    int storedSeconds = prefs.getInt(dateString) ?? 0;

    //print('Retrieved Time Spent (seconds): $storedSeconds');

    return Duration(seconds: storedSeconds);
  }


}