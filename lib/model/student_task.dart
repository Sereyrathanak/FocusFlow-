import 'focus_session.dart';

enum TaskStatus { pending, completed }

/// One piece of academic work captured by the student (Quick Task Form).
/// Composition: a StudentTask owns its FocusSession history.
class StudentTask {
  final String id;
  final String courseId;
  String title;
  String? notes;
  DateTime deadline;
  int estimatedMinutes;
  TaskStatus status;
  final DateTime createdAt;
  DateTime? completedAt;
  final List<FocusSession> sessions;

  StudentTask({
    required this.id,
    required this.courseId,
    required this.title,
    required this.deadline,
    required this.estimatedMinutes,
    required this.createdAt,
    this.notes,
    this.status = TaskStatus.pending,
    this.completedAt,
    List<FocusSession>? sessions,
  }) : sessions = sessions ?? [];

    bool get isCompleted {
    return status == TaskStatus.completed;
  }

  bool isOverdue(DateTime now) {
    return !isCompleted && deadline.isBefore(now);
  }

  bool isDueToday(DateTime now) {
    return deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day;
  }

  bool fitsIn(int availableMinutes) {
    return estimatedMinutes <= availableMinutes; 
  }

  void markCompleted(DateTime now) {
    status = TaskStatus.completed;
    completedAt = now;
  }

  void reopen() {
    status = TaskStatus.pending;
    completedAt = null;
  }

  void addSession(FocusSession session) {
    sessions.add(session);
  }

  int get totalFocusedMinutes {
    int total = 0;
    for (FocusSession session in sessions) {
      total = total + session.completedMinutes;
    }
    return total;
  }

  DateTime? get lastSessionAt {
    DateTime? newest; 
    for (FocusSession session in sessions) {
      if (newest == null || session.startedAt.isAfter(newest)) {
        newest = session.startedAt;
      }
    }
    return newest; 
  }
}
