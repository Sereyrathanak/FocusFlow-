import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/model/course.dart';
import 'package:focusflow/model/daily_check_in.dart';
import 'package:focusflow/model/student_task.dart';
import 'package:focusflow/model/timer_settings.dart';
import 'package:focusflow/service/check_in_service.dart';
import 'package:focusflow/service/course_service.dart';
import 'package:focusflow/service/focus_service.dart';
import 'package:focusflow/service/progress_service.dart';
import 'package:focusflow/service/task_service.dart';

// fixed "now" so the tests give the same result every day
DateTime now = DateTime(2026, 11, 18, 12, 0);

void main() {
  group('ProgressService', () {
    // Normal: two sessions today (25 + 10) -> focusMinutesOn(today) == 35
    test('sums focus minutes for a day', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      FocusService focusService = FocusService(taskService, TimerSettings());
      ProgressService progressService = ProgressService(taskService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');
      StudentTask task = taskService.createTask(
        courseId: course.id,
        title: 'Lab 1',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 60,
      );

      // first session: 25 minutes, completed
      focusService.startSession(task.id, now);
      focusService.tick(25);
      focusService.completeSession(now);

      // second session: 10 minutes, stopped early
      focusService.startSession(task.id, DateTime(2026, 11, 18, 14, 0));
      focusService.tick(10);
      focusService.stopSession(DateTime(2026, 11, 18, 14, 10));

      expect(progressService.focusMinutesOn(now), 35);
      expect(progressService.focusMinutesByCourse()[course.id], 35);
    });

    // Special: day without sessions -> 0, no error
    test('day without sessions returns zero', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      ProgressService progressService = ProgressService(taskService);

      expect(progressService.focusMinutesOn(now), 0);
    });

    // Boundary: no tasks -> completionPercentage == 0 (no divide by zero)
    test('completion percentage with no tasks', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      ProgressService progressService = ProgressService(taskService);

      expect(progressService.completionPercentage(), 0);
    });
  });

  group('CheckInService', () {
    // Normal: toggle telegram -> telegramChecked true for today
    test('toggles an item', () {
      CheckInService checkInService = CheckInService();

      checkInService.toggle(CheckInItem.telegram, now);

      DailyCheckIn checkIn = checkInService.todayCheckIn(now);
      expect(checkIn.telegramChecked, true);
      expect(checkIn.checkedCount, 1);
    });

    // Special: next day -> new check-in, all unchecked (rule 16)
    test('resets on a new day', () {
      CheckInService checkInService = CheckInService();
      checkInService.toggle(CheckInItem.telegram, now);

      DateTime tomorrow = DateTime(2026, 11, 19, 8, 0);
      DailyCheckIn checkIn = checkInService.todayCheckIn(tomorrow);

      expect(checkIn.checkedCount, 0);
      expect(checkIn.isFor(tomorrow), true);
    });
  });
}
