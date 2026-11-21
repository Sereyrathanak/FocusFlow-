import '../model/focus_session.dart';
import '../model/student_task.dart';
import 'task_service.dart';

/// UC-10 View Progress (Progress Summary screen).
/// Multi-entity: reads Tasks, their FocusSessions and Courses.
class ProgressService {
  final TaskService taskService;

  ProgressService(this.taskService);

  int tasksCompletedOn(DateTime day) {
    int count = 0;
    for (StudentTask task in taskService.completedTasks()) {
      DateTime? completedAt = task.completedAt;
      if (completedAt != null && isSameDay(completedAt, day)) {
        count++;
      }
    }
    return count;
  }

  int tasksCompletedThisWeek(DateTime now) {
    // weekday: Monday = 1, so go back (weekday - 1) days
    DateTime monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    int count = 0;
    for (StudentTask task in taskService.completedTasks()) {
      DateTime? completedAt = task.completedAt;
      if (completedAt != null && !completedAt.isBefore(monday)) {
        count++;
      }
    }
    return count;
  }

  int focusMinutesOn(DateTime day) {
    int total = 0;
    for (StudentTask task in taskService.allTasks()) {
      for (FocusSession session in task.sessions) {
        if (isSameDay(session.startedAt, day)) {
          total = total + session.completedMinutes;
        }
      }
    }
    return total;
  }

  int totalFocusMinutes() {
    int total = 0;
    for (StudentTask task in taskService.allTasks()) {
      total = total + task.totalFocusedMinutes;
    }
    return total;
  }

  Map<String, int> focusMinutesByCourse() {
    Map<String, int> result = {};
    for (StudentTask task in taskService.allTasks()) {
      int oldTotal = result[task.courseId] ?? 0;
      result[task.courseId] = oldTotal + task.totalFocusedMinutes;
    }
    return result;
  }

  double completionPercentage() {
    int allCount = taskService.allTasks().length;
    if (allCount == 0) {
      return 0; // no tasks, avoid divide by zero
    }
    int doneCount = taskService.completedTasks().length;
    return doneCount / allCount * 100;
  }

  int overdueCount(DateTime now) {
    return taskService.overdueTasks(now).length;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
