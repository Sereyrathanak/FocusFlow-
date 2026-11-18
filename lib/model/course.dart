import 'class_schedule.dart';
import 'student_task.dart';

/// A course the student is taking (e.g. Mobile Development, English).
/// Composition: a Course owns its weekly ClassSchedules.
/// Aggregation: a Course groups StudentTasks (tasks stay visible if course is archived).
class Course {
  final String id;
  String name;
  String color;
  bool isArchived;
  final DateTime createdAt;
  final List<ClassSchedule> schedules;
  final List<StudentTask> tasks;

  Course({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.isArchived = false,
    List<ClassSchedule>? schedules,
    List<StudentTask>? tasks,
  })  : schedules = schedules ?? [],
        tasks = tasks ?? [];

  // rule 17: archived course can't get new tasks
  void archive() {
    isArchived = true;
  }

  void rename(String newName) {
    if (newName.trim().isEmpty) {
      throw ArgumentError('Course name cannot be empty');
    }
    name = newName.trim();
  }

  void addSchedule(ClassSchedule schedule) {
    schedules.add(schedule);
  }

  void addTask(StudentTask task) {
    tasks.add(task);
  }

  List<StudentTask> get pendingTasks {
    List<StudentTask> result = [];
    for (StudentTask task in tasks) {
      if (!task.isCompleted) {
        result.add(task);
      }
    }
    return result;
  }
}
