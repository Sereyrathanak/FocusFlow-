import '../model/class_schedule.dart';
import '../model/course.dart';
import 'course_service.dart';

/// UC-02 Manage Class Schedule (Weekly Schedule screen).
class ScheduleService {
  final CourseService courseService;
  final List<ClassSchedule> _schedules = [];
  int _nextId = 1;

  ScheduleService(this.courseService);

  ClassSchedule addSchedule({
    required String courseId,
    required int dayOfWeek,
    required int startMinute,
    required int endMinute,
    String? location,
  }) {
    Course? course = courseService.findById(courseId);
    if (course == null) {
      throw ArgumentError('Course not found');
    }
    checkTimes(dayOfWeek, startMinute, endMinute);

    ClassSchedule schedule = ClassSchedule(
      id: 'schedule-$_nextId',
      courseId: courseId,
      dayOfWeek: dayOfWeek,
      startMinute: startMinute,
      endMinute: endMinute,
      location: location,
    );
    _nextId++;
    _schedules.add(schedule);
    course.addSchedule(schedule);
    return schedule;
  }

  void editSchedule(String id,
      {int? dayOfWeek, int? startMinute, int? endMinute, String? location}) {
    ClassSchedule? schedule = findById(id);
    if (schedule == null) {
      throw ArgumentError('Schedule not found');
    }

    // use the old value when a new one is not given
    int newDay = dayOfWeek ?? schedule.dayOfWeek;
    int newStart = startMinute ?? schedule.startMinute;
    int newEnd = endMinute ?? schedule.endMinute;

    // check first, so a wrong edit changes nothing
    checkTimes(newDay, newStart, newEnd);

    schedule.dayOfWeek = newDay;
    schedule.startMinute = newStart;
    schedule.endMinute = newEnd;
    if (location != null) {
      schedule.location = location;
    }
  }

  void removeSchedule(String id) {
    ClassSchedule? schedule = findById(id);
    if (schedule == null) {
      throw ArgumentError('Schedule not found');
    }
    _schedules.remove(schedule);

    Course? course = courseService.findById(schedule.courseId);
    if (course != null) {
      course.schedules.remove(schedule);
    }
  }

  ClassSchedule? findById(String id) {
    for (ClassSchedule schedule in _schedules) {
      if (schedule.id == id) {
        return schedule;
      }
    }
    return null;
  }

  // rule 5: overlap is only a warning, not an error
  List<ClassSchedule> findOverlaps(ClassSchedule schedule) {
    List<ClassSchedule> result = [];
    for (ClassSchedule other in _schedules) {
      if (other.id != schedule.id && schedule.overlaps(other)) {
        result.add(other);
      }
    }
    return result;
  }

  List<ClassSchedule> todayClasses(DateTime now) {
    return classesOn(now.weekday);
  }

  Map<int, List<ClassSchedule>> weeklySchedule() {
    Map<int, List<ClassSchedule>> week = {};
    // 1 = Monday ... 7 = Sunday
    for (int day = 1; day <= 7; day++) {
      week[day] = classesOn(day);
    }
    return week;
  }

  List<ClassSchedule> classesOn(int dayOfWeek) {
    List<ClassSchedule> result = [];
    for (ClassSchedule schedule in _schedules) {
      if (schedule.dayOfWeek == dayOfWeek) {
        result.add(schedule);
      }
    }
    // earliest class first
    result.sort((a, b) => a.startMinute.compareTo(b.startMinute));
    return result;
  }

  void checkTimes(int dayOfWeek, int startMinute, int endMinute) {
    if (dayOfWeek < 1 || dayOfWeek > 7) {
      throw ArgumentError('Day must be 1 (Monday) to 7 (Sunday)');
    }
    if (startMinute < 0 || endMinute > 24 * 60) {
      throw ArgumentError('Time must be inside one day');
    }
    // rule 4
    if (endMinute <= startMinute) {
      throw ArgumentError('End time must be after start time');
    }
  }
}
