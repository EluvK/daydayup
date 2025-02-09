// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseGroup _$CourseGroupFromJson(Map<String, dynamic> json) => CourseGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    )..billIds =
        const ListStringConverter().fromJson(json['billIds'] as String);

Map<String, dynamic> _$CourseGroupToJson(CourseGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'billIds': const ListStringConverter().toJson(instance.billIds),
    };

CourseGroupBill _$CourseGroupBillFromJson(Map<String, dynamic> json) =>
    CourseGroupBill(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      description: json['description'] as String,
      time: DateTime.parse(json['time'] as String),
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$CourseGroupBillToJson(CourseGroupBill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'description': instance.description,
      'time': instance.time.toIso8601String(),
      'amount': instance.amount,
    };

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as String,
      name: json['name'] as String,
      groupId: json['groupId'] as String?,
      user: const UserConverter().fromJson(json['user'] as String),
      description: json['description'] as String,
      timeTable: const CourseTimeTableConverter()
          .fromJson(json['timeTable'] as String),
      pattern: const PatternConverter().fromJson(json['pattern'] as String),
      color: const ColorConverter().fromJson((json['color'] as num).toInt()),
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'groupId': instance.groupId,
      'user': const UserConverter().toJson(instance.user),
      'description': instance.description,
      'timeTable': const CourseTimeTableConverter().toJson(instance.timeTable),
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

CourseTimeTable _$CourseTimeTableFromJson(Map<String, dynamic> json) =>
    CourseTimeTable(
      startDate: DateTime.parse(json['startDate'] as String),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lessonStartTime: DateTime.parse(json['lessonStartTime'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$CourseTimeTableToJson(CourseTimeTable instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'daysOfWeek': instance.daysOfWeek,
      'lessonStartTime': instance.lessonStartTime.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
    };

Pattern _$PatternFromJson(Map<String, dynamic> json) => Pattern(
      type: $enumDecode(_$PatternTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$PatternToJson(Pattern instance) => <String, dynamic>{
      'type': _$PatternTypeEnumMap[instance.type]!,
      'value': instance.value,
    };

const _$PatternTypeEnumMap = {
  PatternType.eachSingleLesson: 100,
  PatternType.costClassTimeUnit: 200,
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
