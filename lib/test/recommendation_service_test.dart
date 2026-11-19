import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/model/course.dart';
import 'package:focusflow/model/student_task.dart';
import 'package:focusflow/service/course_service.dart';
import 'package:focusflow/service/recommendation_service.dart';
import 'package:focusflow/service/task_service.dart';

// fixed "now" so the tests give the same result every day
DateTime now = DateTime(2026, 11, 18, 12, 0);

void main() {
  group('RecommendationService.recommend', () {
    // Normal: overdue task chosen before upcoming task (rule 12)
    test('prioritizes overdue task', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      RecommendationService service = RecommendationService(taskService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      taskService.createTask(
        courseId: course.id,
        title: 'Upcoming',
        deadline: DateTime(2026, 11, 19),
        estimatedMinutes: 25,
      );
      StudentTask overdue = taskService.createTask(
        courseId: course.id,
        title: 'Overdue',
        deadline: DateTime(2026, 11, 17),
        estimatedMinutes: 25,
      );

      expect(service.recommend(30, now), overdue);
    });

    // Normal: closest deadline chosen among pending tasks
    test('prefers closest deadline', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      RecommendationService service = RecommendationService(taskService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      taskService.createTask(
        courseId: course.id,
        title: 'Later',
        deadline: DateTime(2026, 11, 21),
        estimatedMinutes: 25,
      );
      StudentTask sooner = taskService.createTask(
        courseId: course.id,
        title: 'Sooner',
        deadline: DateTime(2026, 11, 19),
        estimatedMinutes: 25,
      );

      expect(service.recommend(30, now), sooner);
    });

    // Normal: 30 min available -> 25 min task preferred over 60 min task (rule 13)
    test('prefers task that fits available time', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      RecommendationService service = RecommendationService(taskService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      taskService.createTask(
        courseId: course.id,
        title: 'Long',
        deadline: DateTime(2026, 11, 19),
        estimatedMinutes: 60,
      );
      StudentTask short = taskService.createTask(
        courseId: course.id,
        title: 'Short',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 25,
      );

      expect(service.recommend(30, now), short);
    });

    // Invalid: completed tasks never recommended (rule 11)
    test('excludes completed tasks', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      RecommendationService service = RecommendationService(taskService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      StudentTask done = taskService.createTask(
        courseId: course.id,
        title: 'Done',
        deadline: DateTime(2026, 11, 17),
        estimatedMinutes: 25,
      );
      StudentTask pending = taskService.createTask(
        courseId: course.id,
        title: 'Pending',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 25,
      );
      taskService.completeTask(done.id, now);

      expect(service.recommend(30, now), pending);
      expect(service.rankTasks(30, now).contains(done), false);
    });

    // Special: rejected task id is skipped, next best returned
    test('skips rejected task', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      RecommendationService service = RecommendationService(taskService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      StudentTask best = taskService.createTask(
        courseId: course.id,
        title: 'Best',
        deadline: DateTime(2026, 11, 19),
        estimatedMinutes: 25,
      );
      StudentTask next = taskService.createTask(
        courseId: course.id,
        title: 'Next',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 25,
      );

      expect(service.recommend(30, now, excludeIds: {best.id}), next);
    });

    // Special: no pending tasks -> null (empty state)
    test('returns null when nothing to do', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      RecommendationService service = RecommendationService(taskService);

      expect(service.recommend(30, now), null);
    });

    // Boundary: task duration exactly equals available minutes -> fits
    test('task equal to available time fits', () {
      CourseService courseService = CourseService();
      TaskService taskService = TaskService(courseService);
      RecommendationService service = RecommendationService(taskService);
      Course course = courseService.createCourse('Mobile Dev', 'blue');

      taskService.createTask(
        courseId: course.id,
        title: 'Too long',
        deadline: DateTime(2026, 11, 19),
        estimatedMinutes: 31,
      );
      StudentTask exact = taskService.createTask(
        courseId: course.id,
        title: 'Exact',
        deadline: DateTime(2026, 11, 20),
        estimatedMinutes: 30,
      );

      expect(service.recommend(30, now), exact);
      expect(service.explain(exact, 30, now), 'Due in 2 days, fits 30 min');
    });
  });
}
