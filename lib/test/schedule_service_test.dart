import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/model/class_schedule.dart';
import 'package:focusflow/model/course.dart';
import 'package:focusflow/service/course_service.dart';
import 'package:focusflow/service/schedule_service.dart';

// times are minutes since midnight: 8:00 = 8 * 60 = 480
void main() {
  group('ScheduleService.addSchedule', () {
    // Normal: Monday 8:00-9:30 -> saved, shows in weeklySchedule[1]
    test('adds valid class', () {
      CourseService courseService = CourseService();
      ScheduleService scheduleService = ScheduleService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      ClassSchedule schedule = scheduleService.addSchedule(
        courseId: course.id,
        dayOfWeek: 1,
        startMinute: 8 * 60,
        endMinute: 9 * 60 + 30,
      );

      expect(scheduleService.weeklySchedule()[1], [schedule]);
      expect(course.schedules.contains(schedule), true);
    });

    // Invalid: end before start -> throws (rule 4)
    test('rejects end before start', () {
      CourseService courseService = CourseService();
      ScheduleService scheduleService = ScheduleService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      expect(
        () => scheduleService.addSchedule(
          courseId: course.id,
          dayOfWeek: 1,
          startMinute: 10 * 60,
          endMinute: 9 * 60,
        ),
        throwsArgumentError,
      );
    });

    // Boundary: end == start -> throws
    test('rejects zero-length class', () {
      CourseService courseService = CourseService();
      ScheduleService scheduleService = ScheduleService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      expect(
        () => scheduleService.addSchedule(
          courseId: course.id,
          dayOfWeek: 1,
          startMinute: 9 * 60,
          endMinute: 9 * 60,
        ),
        throwsArgumentError,
      );
    });

    // Special: 8:00-10:00 and 9:00-11:00 same day -> findOverlaps returns 1 (rule 5)
    test('detects overlapping classes', () {
      CourseService courseService = CourseService();
      ScheduleService scheduleService = ScheduleService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      ClassSchedule first = scheduleService.addSchedule(
        courseId: course.id,
        dayOfWeek: 1,
        startMinute: 8 * 60,
        endMinute: 10 * 60,
      );
      ClassSchedule second = scheduleService.addSchedule(
        courseId: course.id,
        dayOfWeek: 1,
        startMinute: 9 * 60,
        endMinute: 11 * 60,
      );

      expect(scheduleService.findOverlaps(first), [second]);
    });

    // Boundary: 8:00-9:00 and 9:00-10:00 -> touching, not overlapping
    test('back-to-back classes do not overlap', () {
      CourseService courseService = CourseService();
      ScheduleService scheduleService = ScheduleService(courseService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      ClassSchedule first = scheduleService.addSchedule(
        courseId: course.id,
        dayOfWeek: 1,
        startMinute: 8 * 60,
        endMinute: 9 * 60,
      );
      scheduleService.addSchedule(
        courseId: course.id,
        dayOfWeek: 1,
        startMinute: 9 * 60,
        endMinute: 10 * 60,
      );

      expect(scheduleService.findOverlaps(first).length, 0);
    });
  });
}
