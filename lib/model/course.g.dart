// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as String,
      name: json['name'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      description: json['description'] as String,
      pattern: Pattern.fromJson(json['pattern'] as Map<String, dynamic>),
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'user': instance.user,
      'description': instance.description,
      'pattern': instance.pattern,
      'color': const ColorConverter().toJson(instance.color),
    };

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
      courseId: json['courseId'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'courseId': instance.courseId,
      'id': instance.id,
      'name': instance.name,
      'user': instance.user,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
    };

Pattern _$PatternFromJson(Map<String, dynamic> json) => Pattern(
      startDate: DateTime.parse(json['startDate'] as String),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      courseLength: (json['courseLength'] as num).toInt(),
    );

Map<String, dynamic> _$PatternToJson(Pattern instance) => <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'daysOfWeek': instance.daysOfWeek,
      'duration': instance.duration.inMicroseconds,
      'courseLength': instance.courseLength,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': const ColorConverter().toJson(instance.color),
    };
