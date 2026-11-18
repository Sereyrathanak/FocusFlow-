import '../model/course.dart';
import '../model/student_task.dart';
import 'course_service.dart';

/// UC-04 Manage Tasks, UC-05 View Workload, UC-09 Search and Filter.
/// Multi-entity: uses CourseService to check the task's Course.
class TaskService {
  final CourseService courseService;
  final List<StudentTask> _tasks = [];
  int _nextId = 1;

  TaskService(this.courseService);

  StudentTask createTask({
    required String courseId,
    required String title,
    required DateTime deadline,
    required int estimatedMinutes,
    String? notes,
  }) {
    Course? course = courseService.findById(courseId);
    // rule 2
    if (course == null) {
      throw ArgumentError('Course not found');
    }
    // rule 17
    if (course.isArchived) {
      throw StateError('Cannot add task to an archived course');
    }
    checkTask(title, estimatedMinutes);

    StudentTask task = StudentTask(
      id: 'task-$_nextId',
      courseId: courseId,
      title: title.trim(),
      deadline: deadline,
      estimatedMinutes: estimatedMinutes,
      createdAt: DateTime.now(),
      notes: notes,
    );
    _nextId++;
    _tasks.add(task);
    course.addTask(task);
    return task;
  }

  void editTask(String id,
      {String? title, DateTime? deadline, int? estimatedMinutes, String? notes}) {
    StudentTask? task = findById(id);
    if (task == null) {
      throw ArgumentError('Task not found');
    }

    // check first, so a wrong edit changes nothing
    checkTask(title ?? task.title, estimatedMinutes ?? task.estimatedMinutes);

    if (title != null) {
      task.title = title.trim();
    }
    if (deadline != null) {
      task.deadline = deadline;
    }
    if (estimatedMinutes != null) {
      task.estimatedMinutes = estimatedMinutes;
    }
    if (notes != null) {
      task.notes = notes;
    }
  }

  void completeTask(String id, DateTime now) {
    StudentTask? task = findById(id);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    task.markCompleted(now);
  }

  void reopenTask(String id) {
    StudentTask? task = findById(id);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    if (!task.isCompleted) {
      throw StateError('Task is not completed');
    }
    task.reopen();
  }

  void deleteTask(String id, {required bool confirmed}) {
    // rule 10
    if (!confirmed) {
      throw StateError('Delete must be confirmed');
    }
    StudentTask? task = findById(id);
    if (task == null) {
      throw ArgumentError('Task not found');
    }
    _tasks.remove(task);

    Course? course = courseService.findById(task.courseId);
    if (course != null) {
      course.tasks.remove(task);
    }
  }

  StudentTask? findById(String id) {
    for (StudentTask task in _tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  // every task, also completed ones and ones from archived courses (rule 18)
  List<StudentTask> allTasks() {
    return List.from(_tasks);
  }

  List<StudentTask> overdueTasks(DateTime now) {
    List<StudentTask> result = [];
    for (StudentTask task in _tasks) {
      if (task.isOverdue(now)) {
        result.add(task);
      }
    }
    return result;
  }

  List<StudentTask> dueTodayTasks(DateTime now) {
    List<StudentTask> result = [];
    for (StudentTask task in _tasks) {
      if (!task.isCompleted && task.isDueToday(now) && !task.isOverdue(now)) {
        result.add(task);
      }
    }
    return result;
  }

  List<StudentTask> upcomingTasks(DateTime now) {
    DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    List<StudentTask> result = [];
    for (StudentTask task in _tasks) {
      if (!task.isCompleted && !task.deadline.isBefore(tomorrow)) {
        result.add(task);
      }
    }
    return result;
  }

  List<StudentTask> completedTasks() {
    List<StudentTask> result = [];
    for (StudentTask task in _tasks) {
      if (task.isCompleted) {
        result.add(task);
      }
    }
    return result;
  }

  List<StudentTask> search(String keyword) {
    String key = keyword.trim().toLowerCase();
    List<StudentTask> result = [];
    for (StudentTask task in _tasks) {
      String notes = task.notes ?? '';
      if (task.title.toLowerCase().contains(key) ||
          notes.toLowerCase().contains(key)) {
        result.add(task);
      }
    }
    return result;
  }

  List<StudentTask> filter({String? courseId, TaskStatus? status}) {
    List<StudentTask> result = [];
    for (StudentTask task in _tasks) {
      // a filter that is null is skipped
      if (courseId != null && task.courseId != courseId) {
        continue;
      }
      if (status != null && task.status != status) {
        continue;
      }
      result.add(task);
    }
    return result;
  }

  void checkTask(String title, int estimatedMinutes) {
    // rule 1
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    // rule 3
    if (estimatedMinutes <= 0) {
      throw ArgumentError('Estimated minutes must be more than 0');
    }
  }
}
