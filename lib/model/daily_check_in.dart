/// Daily academic source checklist (Telegram, e-learning, tomorrow's classes).
class DailyCheckIn {
  final String id;
  final DateTime date;
  bool telegramChecked;
  bool elearningChecked;
  bool tomorrowScheduleChecked;

  DailyCheckIn({
    required this.id,
    required this.date,
    this.telegramChecked = false,
    this.elearningChecked = false,
    this.tomorrowScheduleChecked = false,
  });

  bool get isComplete {
    return telegramChecked && elearningChecked && tomorrowScheduleChecked;
  }

  int get checkedCount {
    int count = 0;
    if (telegramChecked) count++;
    if (elearningChecked) count++;
    if (tomorrowScheduleChecked) count++;
    return count;
  }

  bool isFor(DateTime day) {
    // same calendar date, ignore the hour/minute
    return date.year == day.year &&
        date.month == day.month &&
        date.day == day.day;
  }
}
