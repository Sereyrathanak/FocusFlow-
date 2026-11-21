enum SessionStatus { running, paused, completed, stopped }

/// One Pomodoro focus session on a task (Focus Timer screen).
class FocusSession {
  final String id;
  final String taskId;
  final int plannedMinutes;
  int completedMinutes;
  final DateTime startedAt;
  DateTime? endedAt;
  SessionStatus status;

  FocusSession({
    required this.id,
    required this.taskId,
    required this.plannedMinutes,
    required this.startedAt,
    this.completedMinutes = 0,
    this.endedAt,
    this.status = SessionStatus.running,
  });

  bool get isActive {
    return status == SessionStatus.running || status == SessionStatus.paused;
  }

  void pause() {
    if (status == SessionStatus.running) {
      status = SessionStatus.paused;
    }
  }

  void resume() {
    if (status == SessionStatus.paused) {
      status = SessionStatus.running;
    }
  }

  void addFocusedMinutes(int minutes) {
    // only count time while running (rule 8)
    if (status != SessionStatus.running || minutes <= 0) {
      return;
    }
    completedMinutes = completedMinutes + minutes;
    if (completedMinutes > plannedMinutes) {
      completedMinutes = plannedMinutes;
    }
  }

  void complete(DateTime now) {
    status = SessionStatus.completed;
    endedAt = now;
  }

  void stop(DateTime now) {
    status = SessionStatus.stopped;
    endedAt = now;
  }
}
