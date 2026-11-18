import '../model/course.dart';

/// UC-01 Manage Courses. In-memory list for now (later: local DB).
class CourseService {
  final List<Course> _courses = [];
  int _nextId = 1;

  Course createCourse(String name, String color) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Course name cannot be empty');
    }
    if (isNameTaken(name, '')) {
      throw ArgumentError('Course name already exists');
    }

    Course course = Course(
      id: 'course-$_nextId',
      name: name.trim(),
      color: color,
      createdAt: DateTime.now(),
    );
    _nextId++;
    _courses.add(course);
    return course;
  }

  void editCourse(String id, {String? name, String? color}) {
    Course? course = findById(id);
    if (course == null) {
      throw ArgumentError('Course not found');
    }

    if (name != null) {
      if (isNameTaken(name, id)) {
        throw ArgumentError('Course name already exists');
      }
      course.rename(name);
    }
    if (color != null) {
      course.color = color;
    }
  }

  void archiveCourse(String id) {
    Course? course = findById(id);
    if (course == null) {
      throw ArgumentError('Course not found');
    }
    // rule 17: no new tasks, rule 18: old tasks stay visible
    course.archive();
  }

  Course? findById(String id) {
    for (Course course in _courses) {
      if (course.id == id) {
        return course;
      }
    }
    return null;
  }

  List<Course> activeCourses() {
    List<Course> result = [];
    for (Course course in _courses) {
      if (!course.isArchived) {
        result.add(course);
      }
    }
    return result;
  }

  List<Course> allCourses() {
    return List.from(_courses);
  }

  // skipId lets editCourse keep the same name
  bool isNameTaken(String name, String skipId) {
    for (Course course in _courses) {
      if (course.id != skipId &&
          course.name.toLowerCase() == name.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}
