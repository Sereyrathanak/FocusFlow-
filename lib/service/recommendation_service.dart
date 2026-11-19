import '../model/student_task.dart';
import 'task_service.dart';

/// UC-06 Get Task Recommendation: "What should I work on with the time I have?"
/// Simple rules, not AI.
class RecommendationService {
  final TaskService taskService;

  RecommendationService(this.taskService);

  StudentTask? recommend(int availableMinutes, DateTime now,
      {Set<String> excludeIds = const {}}) {
    for (StudentTask task in rankTasks(availableMinutes, now)) {
      // skip tasks the student rejected
      if (!excludeIds.contains(task.id)) {
        return task;
      }
    }
    return null; // nothing to do
  }

  List<StudentTask> rankTasks(int availableMinutes, DateTime now) {
    // rule 11: never recommend completed tasks
    List<StudentTask> candidates = [];
    for (StudentTask task in taskService.allTasks()) {
      if (!task.isCompleted) {
        candidates.add(task);
      }
    }

    candidates.sort((a, b) => compareTasks(a, b, availableMinutes, now));
    return candidates;
  }

  /// Negative = a comes first, positive = b comes first.
  /// Order: overdue > fits the time > closest deadline > least recent session.
  /// "Fits" is checked before deadline, or a deadline a few minutes earlier
  /// would always win over the time the student really has.
  int compareTasks(StudentTask a, StudentTask b, int availableMinutes,
      DateTime now) {
    // 1. overdue first (rule 12)
    if (a.isOverdue(now) && !b.isOverdue(now)) return -1;
    if (!a.isOverdue(now) && b.isOverdue(now)) return 1;

    // 2. task that fits the available time first (rule 13)
    if (a.fitsIn(availableMinutes) && !b.fitsIn(availableMinutes)) return -1;
    if (!a.fitsIn(availableMinutes) && b.fitsIn(availableMinutes)) return 1;

    // 3. closest deadline first
    if (a.deadline.isBefore(b.deadline)) return -1;
    if (b.deadline.isBefore(a.deadline)) return 1;

    // 4. task never focused, or focused longest ago, first
    DateTime? aLast = a.lastSessionAt;
    DateTime? bLast = b.lastSessionAt;
    if (aLast == null && bLast == null) return 0;
    if (aLast == null) return -1;
    if (bLast == null) return 1;
    return aLast.compareTo(bLast);
  }

  String explain(StudentTask task, int availableMinutes, DateTime now) {
    String when;
    if (task.isOverdue(now)) {
      when = 'Overdue';
    } else if (task.isDueToday(now)) {
      when = 'Due today';
    } else {
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime dueDay =
          DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      int days = dueDay.difference(today).inDays;
      if (days == 1) {
        when = 'Due tomorrow';
      } else {
        when = 'Due in $days days';
      }
    }

    String fit;
    if (task.fitsIn(availableMinutes)) {
      fit = 'fits $availableMinutes min';
    } else {
      fit = 'needs ${task.estimatedMinutes} min';
    }

    return '$when, $fit';
  }
}
