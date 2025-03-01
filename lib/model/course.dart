import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'course.g.dart';

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) {
    final alpha = (color.a * 255).toInt();
    final red = (color.r * 255).toInt();
    final green = (color.g * 255).toInt();
    final blue = (color.b * 255).toInt();
    // Combine the components into a single int using bit shifting
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }
}

class UserConverter implements JsonConverter<User, String> {
  const UserConverter();

  @override
  User fromJson(String json) => User.fromJson(jsonDecode(json));

  @override
  String toJson(User user) => jsonEncode(user.toJson());
}

class CourseTimeTableConverter implements JsonConverter<CourseTimeTable, String> {
  const CourseTimeTableConverter();

  @override
  CourseTimeTable fromJson(String json) => CourseTimeTable.fromJson(jsonDecode(json));

  @override
  String toJson(CourseTimeTable timeTable) => jsonEncode(timeTable.toJson());
}

class PatternConverter implements JsonConverter<Pattern, String> {
  const PatternConverter();

  @override
  Pattern fromJson(String json) => Pattern.fromJson(jsonDecode(json));

  @override
  String toJson(Pattern pattern) => jsonEncode(pattern.toJson());
}

class ListStringConverter implements JsonConverter<List<String>, String> {
  const ListStringConverter();

  @override
  List<String> fromJson(String json) => jsonDecode(json).cast<String>();

  @override
  String toJson(List<String> list) => jsonEncode(list);
}

@JsonSerializable()
class CourseGroup {
  final String id;
  String name;
  String description;
  double restAmount;
  @ListStringConverter()
  List<String> billIds = [];

  CourseGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.restAmount,
  });

  CourseGroup clone() {
    return CourseGroup(
      id: id,
      name: name,
      description: description,
      restAmount: restAmount,
    );
  }

  factory CourseGroup.fromJson(Map<String, dynamic> json) => _$CourseGroupFromJson(json);
  Map<String, dynamic> toJson() => _$CourseGroupToJson(this);
}

@JsonSerializable()
class CourseGroupBill {
  final String id;
  final String groupId;
  String description;
  DateTime time;
  double amount;

  CourseGroupBill({
    required this.id,
    required this.groupId,
    required this.description,
    required this.time,
    required this.amount,
  });

  CourseGroupBill clone() {
    return CourseGroupBill(
      id: id,
      groupId: groupId,
      description: description,
      time: time,
      amount: amount,
    );
  }

  factory CourseGroupBill.fromJson(Map<String, dynamic> json) => _$CourseGroupBillFromJson(json);
  Map<String, dynamic> toJson() => _$CourseGroupBillToJson(this);
}

@JsonSerializable()
class Course {
  final String id;
  String name;
  String? groupId;

  @UserConverter()
  User user;
  String description;

  @CourseTimeTableConverter()
  CourseTimeTable timeTable;

  @PatternConverter()
  Pattern pattern;

  @ColorConverter()
  Color color;

  Course({
    required this.id,
    required this.name,
    this.groupId,
    required this.user,
    required this.description,
    required this.timeTable,
    required this.pattern,
    required this.color,
  });

  Course clone() {
    return Course(
      id: id,
      name: name,
      groupId: groupId,
      user: user.clone(),
      description: description,
      timeTable: timeTable.clone(),
      pattern: pattern.clone(),
      color: color,
    );
  }

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

@JsonSerializable()
class Lesson {
  final String courseId;
  final String id;
  String name;
  @UserConverter()
  User user;
  DateTime startTime;
  DateTime endTime;
  LessonStatus status;

  Lesson({
    required this.courseId,
    required this.id,
    required this.name,
    required this.user,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  Lesson clone() {
    return Lesson(
      courseId: courseId,
      id: id,
      name: name,
      user: user.clone(),
      startTime: startTime,
      endTime: endTime,
      status: status,
    );
  }

  Lesson copyWith({
    String? courseId,
    String? id,
    String? name,
    User? user,
    DateTime? startTime,
    DateTime? endTime,
    LessonStatus? status,
  }) {
    return Lesson(
      courseId: courseId ?? this.courseId,
      id: id ?? this.id,
      name: name ?? this.name,
      user: user ?? this.user,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

@JsonSerializable()
class CourseTimeTable {
  DateTime startDate;
  WeekType weekType;
  List<String> daysOfWeek;
  DateTime lessonStartTime;
  Duration duration;

  CourseTimeTable({
    required this.startDate,
    required this.weekType,
    required this.daysOfWeek,
    required this.lessonStartTime,
    required this.duration,
  });

  CourseTimeTable clone() {
    return CourseTimeTable(
      startDate: startDate,
      weekType: weekType,
      daysOfWeek: List<String>.from(daysOfWeek),
      lessonStartTime: lessonStartTime,
      duration: duration,
    );
  }

  factory CourseTimeTable.fromJson(Map<String, dynamic> json) => _$CourseTimeTableFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTimeTableToJson(this);
}

@JsonSerializable()
class Pattern {
  PatternType type;
  double value;

  Pattern({
    required this.type,
    required this.value,
  });

  Pattern clone() {
    return Pattern(
      type: type,
      value: value,
    );
  }

  factory Pattern.fromJson(Map<String, dynamic> json) => _$PatternFromJson(json);
  Map<String, dynamic> toJson() => _$PatternToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  String name;
  @ColorConverter()
  Color color;

  User({
    required this.id,
    required this.name,
    required this.color,
  });

  User clone() {
    return User(
      id: id,
      name: name,
      color: color,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonEnum()
enum LessonStatus {
  @JsonValue(100)
  notStarted, // Lesson is in the future
  @JsonValue(200)
  finished, // Lesson is in the past and has been attended
  @JsonValue(301)
  canceled, // Lesson is in the past and has not been attended
  @JsonValue(302)
  notAttended, // Lesson is in the past and has not been attended
}

@JsonEnum()
enum PatternType {
  @JsonValue(100)
  eachSingleLesson,
  @JsonValue(200)
  costClassTimeUnit,
}

@JsonEnum()
enum WeekType {
  @JsonValue(7)
  weekly,
  @JsonValue(14)
  biWeekly,
}

extension LessonStatusExtension on LessonStatus {
  String get name {
    switch (this) {
      case LessonStatus.notStarted:
        return '未开始';
      case LessonStatus.finished:
        return '完成';
      case LessonStatus.canceled:
        return '取消';
      case LessonStatus.notAttended:
        return '缺课';
    }
  }

  Color get color {
    switch (this) {
      case LessonStatus.notStarted:
        return Colors.grey;
      case LessonStatus.finished:
        return Colors.green;
      case LessonStatus.canceled:
        return Colors.blue;
      case LessonStatus.notAttended:
        return Colors.red;
    }
  }
}
