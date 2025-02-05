import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) => color.value;
}

@JsonSerializable()
class Course {
  final String id;
  final String name;
  final User user;
  final String description;
  final Pattern pattern;

  @ColorConverter()
  final Color color;

  Course({
    required this.id,
    required this.name,
    required this.user,
    required this.description,
    required this.pattern,
    required this.color,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

@JsonSerializable()
class Lesson {
  final String courseId;
  final String id;
  final String name;
  final User user;
  final DateTime startTime;
  final DateTime endTime;

  Lesson({
    required this.courseId,
    required this.id,
    required this.name,
    required this.user,
    required this.startTime,
    required this.endTime,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

@JsonSerializable()
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

  factory Pattern.fromJson(Map<String, dynamic> json) => _$PatternFromJson(json);
  Map<String, dynamic> toJson() => _$PatternToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  final String name;
  @ColorConverter()
  final Color color;

  User({
    required this.id,
    required this.name,
    required this.color,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
