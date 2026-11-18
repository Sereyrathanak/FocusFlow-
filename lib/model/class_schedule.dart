/// One weekly class slot shown on the Weekly Schedule screen.
/// Times are stored as minutes since midnight (e.g. 8:30 -> 510).
class ClassSchedule {
  final String id;
  final String courseId;
  int dayOfWeek; 
  int startMinute;
  int endMinute;
  String? location;

  ClassSchedule({
    required this.id,
    required this.courseId,
    required this.dayOfWeek,
    required this.startMinute,
    required this.endMinute,
    this.location,
  });

  int get durationMinutes {
    return endMinute - startMinute;
  }

  bool get isValid {
    return endMinute > startMinute;
  }

  bool overlaps(ClassSchedule other) {
    if (dayOfWeek != other.dayOfWeek) {
      return false; // different days never overlap
    }
    
    // overlap = each class starts before the other one ends
    return startMinute < other.endMinute && other.startMinute < endMinute;
  }

  bool isOn(DateTime date) {
    return dayOfWeek == date.weekday;
  }
}
