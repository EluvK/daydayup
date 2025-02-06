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

class PatternConverter implements JsonConverter<Pattern, String> {
  const PatternConverter();

  @override
  Pattern fromJson(String json) => Pattern.fromJson(jsonDecode(json));

  @override
  String toJson(Pattern pattern) => jsonEncode(pattern.toJson());
}

@JsonSerializable()
class Course {
  final String id;
  String name;

  @UserConverter()
  User user;
  String description;

  @PatternConverter()
  Pattern pattern;

  @ColorConverter()
  Color color;

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

@JsonEnum()
enum LessonStatus {
  @JsonValue(100)
  notStarted, // Lesson is in the future
  @JsonValue(200)
  finished, // Lesson is in the past and has been attended
  @JsonValue(301)
  skipped, // Lesson is in the past and has not been attended
  @JsonValue(302)
  notAttended, // Lesson is in the past and has not been attended
}
