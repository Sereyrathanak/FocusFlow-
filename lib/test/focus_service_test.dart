import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/model/course.dart';
import 'package:focusflow/model/focus_session.dart';
import 'package:focusflow/model/student_task.dart';
import 'package:focusflow/model/timer_settings.dart';
import 'package:focusflow/service/course_service.dart';
import 'package:focusflow/service/focus_service.dart';
import 'package:focusflow/service/task_service.dart';

// fixed "now" so the tests give the same result every day
DateTime now = DateTime(2026, 11, 18, 12, 0);

void main() {
  group('FocusService.startSession', () {
    // Normal: pending task -> running session with plannedMinutes = 25
    test('starts session on unfinished task', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 50,
      );

      FocusSession session = focusService.startSession(task.id, now);

      expect(session.status, SessionStatus.running);
      expect(session.plannedMinutes, 25);
      expect(focusService.activeSession, session);
      expect(task.sessions, [session]);
    });

    // Invalid: second session while one is active -> throws (rule 6)
    test('only one session at a time', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 50,
      );

      focusService.startSession(task.id, now);

      expect(() => focusService.startSession(task.id, now), throwsStateError);
    });

    // Invalid: completed task -> throws (rules 7, 9)
    test('cannot focus on completed task', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 50,
      );

      taskService.completeTask(task.id, now);

      expect(() => focusService.startSession(task.id, now), throwsStateError);
    });

    // Invalid: unknown taskId -> throws
    test('cannot focus on non-existing task', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());

      expect(() => focusService.startSession('wrong-id', now),
          throwsArgumentError);
    });
  });

  group('FocusService pause / stop / complete', () {
    // Special: tick while paused does not add minutes (rule 8)
    test('paused time is not counted', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 50,
      );
      FocusSession session = focusService.startSession(task.id, now);

      focusService.tick(5); // counted
      focusService.pauseSession();
      focusService.tick(10); // not counted, paused
      focusService.resumeSession();
      focusService.tick(3); // counted

      expect(session.completedMinutes, 8);
    });

    // Special: stop after 10 of 25 min -> completedMinutes 10, task still pending (14, 15)
    test('stop early keeps actual minutes', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 50,
      );
      FocusSession session = focusService.startSession(task.id, now);

      focusService.tick(10);
      focusService.stopSession(now);

      expect(session.completedMinutes, 10);
      expect(session.status, SessionStatus.stopped);
      expect(task.status, TaskStatus.pending);
      expect(focusService.activeSession, null);
    });

    // Normal: complete with markTaskDone -> task completed
    test('complete session can complete task', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 50,
      );
      FocusSession session = focusService.startSession(task.id, now);

      focusService.tick(25);
      focusService.completeSession(now, markTaskDone: true);

      expect(session.status, SessionStatus.completed);
      expect(task.status, TaskStatus.completed);
      expect(focusService.activeSession, null);
    });

    // Boundary: tick beyond plannedMinutes is capped
    test('focused minutes capped at planned', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 50,
      );
      FocusSession session = focusService.startSession(task.id, now);

      focusService.tick(40);

      expect(session.completedMinutes, 25);
    });
  });

  group('FocusService.startBreak', () {
    // Normal: 15 is allowed. Invalid: 20 is not allowed
    test('only 5, 10, 15, 30 minute breaks', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());

      expect(focusService.startBreak(15), 15);
      expect(() => focusService.startBreak(20), throwsArgumentError);
    });
  });
}
