// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as String,
      name: json['name'] as String,
      user: const UserConverter().fromJson(json['user'] as String),
      description: json['description'] as String,
      pattern: const PatternConverter().fromJson(json['pattern'] as String),
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'user': const UserConverter().toJson(instance.user),
      'description': instance.description,
      'pattern': const PatternConverter().toJson(instance.pattern),
      'color': const ColorConverter().toJson(instance.color),
    };

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
      courseId: json['courseId'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      user: const UserConverter().fromJson(json['user'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: $enumDecode(_$LessonStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'courseId': instance.courseId,
      'id': instance.id,
      'name': instance.name,
      'user': const UserConverter().toJson(instance.user),
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'status': _$LessonStatusEnumMap[instance.status]!,
    };

const _$LessonStatusEnumMap = {
  LessonStatus.notStarted: 100,
  LessonStatus.finished: 200,
  LessonStatus.skipped: 301,
  LessonStatus.notAttended: 302,
};

Pattern _$PatternFromJson(Map<String, dynamic> json) => Pattern(
      startDate: DateTime.parse(json['startDate'] as String),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lessonStartTime: DateTime.parse(json['lessonStartTime'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      courseLength: (json['courseLength'] as num).toInt(),
    );

Map<String, dynamic> _$PatternToJson(Pattern instance) => <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'daysOfWeek': instance.daysOfWeek,
      'lessonStartTime': instance.lessonStartTime.toIso8601String(),
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
