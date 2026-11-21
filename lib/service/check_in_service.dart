import '../model/daily_check_in.dart';

enum CheckInItem { telegram, elearning, tomorrowSchedule }

/// UC-03 Complete Academic Check-In.
class CheckInService {
  DailyCheckIn? _current;

  DailyCheckIn todayCheckIn(DateTime now) {
    DailyCheckIn? current = _current;
    if (current != null && current.isFor(now)) {
      return current;
    }

    // rule 16: a new day starts with everything unchecked
    DailyCheckIn newCheckIn = DailyCheckIn(
      id: 'checkin-${now.year}-${now.month}-${now.day}',
      date: DateTime(now.year, now.month, now.day),
    );
    _current = newCheckIn;
    return newCheckIn;
  }

  void toggle(CheckInItem item, DateTime now) {
    DailyCheckIn checkIn = todayCheckIn(now);

    if (item == CheckInItem.telegram) {
      checkIn.telegramChecked = !checkIn.telegramChecked;
    } else if (item == CheckInItem.elearning) {
      checkIn.elearningChecked = !checkIn.elearningChecked;
    } else if (item == CheckInItem.tomorrowSchedule) {
      checkIn.tomorrowScheduleChecked = !checkIn.tomorrowScheduleChecked;
    }
  }
}
