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

  // TODO: constructor with id, name, color, createdAt; isArchived defaults to false
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

  // TODO: archive() -> set isArchived = true (rule 17: archived course can't get new tasks)
  void archive() => throw UnimplementedError();

  // TODO: rename(newName) -> update name, reject empty name
  void rename(String newName) => throw UnimplementedError();

  // TODO: addSchedule(schedule) -> add a ClassSchedule to this course
  void addSchedule(ClassSchedule schedule) => throw UnimplementedError();

  // TODO: addTask(task) -> add a StudentTask to this course
  void addTask(StudentTask task) => throw UnimplementedError();

  // TODO: pendingTasks getter -> tasks where status is not completed
  List<StudentTask> get pendingTasks => throw UnimplementedError();
}
