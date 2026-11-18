/// Pomodoro preferences from the Settings screen.
class TimerSettings {
  int focusMinutes;
  int shortBreakMinutes;
  int longBreakMinutes;
  int sessionsBeforeLongBreak;

// set default timer 
  TimerSettings({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
  });


  bool get isValid {
    return focusMinutes > 0 &&
        shortBreakMinutes > 0 &&
        longBreakMinutes > 0 &&
        sessionsBeforeLongBreak > 0;
  }

  int breakMinutesAfter(int sessionCount) {
    // every 4th sessiongets a long break
    if (sessionCount > 0 && sessionCount % sessionsBeforeLongBreak == 0) {
      return longBreakMinutes;
    }
    return shortBreakMinutes;
  }
}
