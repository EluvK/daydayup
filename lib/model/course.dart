class Course {
  final String id;
  final String name;
  final String userId;
  final String userName;
  final String description;
  final Pattern pattern;

  Course({
    required this.id,
    required this.name,
    required this.userId,
    required this.userName,
    required this.description,
    required this.pattern,
  });
}

// each individual lesson of the course
class Lesson {
  final String courseId;
  final String id;
  final String name;
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;

  Lesson({
    required this.courseId,
    required this.id,
    required this.name,
    required this.userId,
    required this.userName,
    required this.startTime,
    required this.endTime,
  });
}

// describe the pattern of the course
class Pattern {
  final DateTime startDate;
  final List<String> daysOfWeek;
  final Duration duration;
  final int courseLength;

  Pattern({
    required this.startDate,
    required this.daysOfWeek,
    required this.duration,
    required this.courseLength,
  });
}

class User {
  final String id;
  final String name;

  User({
    required this.id,
    required this.name,
  });
}
