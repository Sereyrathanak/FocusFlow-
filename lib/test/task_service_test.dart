import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/model/course.dart';
import 'package:focusflow/model/student_task.dart';
import 'package:focusflow/service/course_service.dart';
import 'package:focusflow/service/task_service.dart';

// fixed "now" so the tests give the same result every day
DateTime now = DateTime(2026, 11, 18, 12, 0);

void main() {
  group('TaskService.createTask', () {
    // Normal: valid title, active course, 30 min -> task saved, appears in list
    test('creates task with valid input', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 30,
      );

      expect(taskService.findById(task.id), task);
      expect(course.tasks.contains(task), true);
      expect(task.status, TaskStatus.pending);
    });

    // Invalid: empty or whitespace title -> throws (rule 1)
    test('rejects empty title', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      expect(
        () => taskService.createTask(
          courseId: course.id,
          title: '   ',
          deadline: DateTime(2026, 11, 20),
          estimatedMinutes: 30,
        ),
        throwsArgumentError,
      );
    });

    // Invalid: courseId that does not exist -> throws (rule 2)
    test('rejects non-existing course', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);

      expect(
        () => taskService.createTask(
          courseId: 'wrong-id',
          title: 'Lab 1',
          deadline: DateTime(2026, 11, 20),
          estimatedMinutes: 30,
        ),
        throwsArgumentError,
      );
    });

    // Invalid: archived course -> throws (rule 17)
    test('rejects archived course', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      courseService.archiveCourse(course.id);

      expect(
        () => taskService.createTask(
          courseId: course.id,
          title: 'Lab 1',
          deadline: DateTime(2026, 11, 20),
          estimatedMinutes: 30,
        ),
        throwsStateError,
      );
    });

    // Boundary: estimatedMinutes = 0 -> throws, = 1 -> ok (rule 3)
    test('duration boundary 0 vs 1 minute', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      expect(
        () => taskService.createTask(
          courseId: course.id,
          title: 'Lab 1',
          deadline: DateTime(2026, 11, 20),
          estimatedMinutes: 0,
        ),
        throwsArgumentError,
      );

      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 1,
      );
      expect(task.estimatedMinutes, 1);
    });
  });

  group('TaskService workload', () {
    // Normal: overdue / due today / upcoming are separated correctly
    test('classifies tasks by deadline', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      StudentTask overdue = taskService.createTask(
        courseId: course.id,
        title: 'Yesterday',
        deadline: DateTime(2026, 11, 17),
        estimatedMinutes: 30,
      );
      StudentTask today = taskService.createTask(
        courseId: course.id,
        title: 'Tonight',
        deadline: DateTime(2026, 11, 18, 18, 0),
        estimatedMinutes: 30,
      );
      StudentTask upcoming = taskService.createTask(
        courseId: course.id,
        title: 'Next week',
        deadline: DateTime(2026, 11, 25),
        estimatedMinutes: 30,
      );

      expect(taskService.overdueTasks(now), [overdue]);
      expect(taskService.dueTodayTasks(now), [today]);
      expect(taskService.upcomingTasks(now), [upcoming]);
    });

    // Special: completed tasks not counted as overdue
    test('completed task is not overdue', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Yesterday',
        deadline: DateTime(2026, 11, 17),
        estimatedMinutes: 30,
      );

      taskService.completeTask(task.id, now);

      expect(taskService.overdueTasks(now).length, 0);
      expect(taskService.completedTasks(), [task]);
    });
  });

  group('TaskService complete / reopen / delete', () {
    // Normal: complete then reopen -> pending, completedAt null
    test('reopen completed task', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 30,
      );

      taskService.completeTask(task.id, now);
      taskService.reopenTask(task.id);

      expect(task.status, TaskStatus.pending);
      expect(task.completedAt, null);
    });

    // Invalid: delete without confirmation -> throws (rule 10)
    test('delete requires confirmation', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 30,
      );

      expect(() => taskService.deleteTask(task.id, confirmed: false),
          throwsStateError);
      expect(taskService.findById(task.id), task); // still there

      taskService.deleteTask(task.id, confirmed: true);
      expect(taskService.findById(task.id), null);
      expect(course.tasks.length, 0);
    });

    // Special: archived course's tasks still visible (rule 18)
    test('tasks stay visible after course archived', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 30,
      );

      courseService.archiveCourse(course.id);

      expect(taskService.allTasks(), [task]);
      expect(taskService.filter(courseId: course.id), [task]);
    });
  });
}
