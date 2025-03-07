import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/day_of_week_picker.dart';
import 'package:daydayup/utils/utils.dart';
import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';
import 'package:uuid/uuid.dart';

typedef CourseLessonMap = Map<Course, List<Lesson>>;

enum CalculateError {
  notEnoughAmount,
}

typedef CalResult<CourseLessonMap> = Result<Map<Course, List<Lesson>>, CalculateError>;

/// 根据传入的当前课程信息，重新推导所有 lesson
///
/// 场景1：修改课程信息后，重新计算课程安排，此时 (mut course, null)
///
/// 场景2：调整某一节课、新建课程后，重新计算课程安排，此时 (course, mut lesson)
CalResult<CourseLessonMap> reCalculateLessonsForTimeUnit(Course course, Lesson? editLesson) {
  var coursesController = Get.find<CoursesController>();
  final courseGroupCourses = coursesController.getCourseGroupCourses(course.groupId!);
  final List<Course> editCourses = courseGroupCourses.map((e) => e.clone()).toList();

  if (editCourses.firstWhereOrNull((element) => element.id == course.id) == null) {
    editCourses.add(course.clone());
  } else {
    editCourses[editCourses.indexWhere((element) => element.id == course.id)] = course.clone();
  }
  final CourseGroup courseGroup = coursesController.getCourseGroup(course.groupId!);

  var currentCourseLessons = <Course, List<Lesson>>{};
  // update course information in editCourses
  for (var i = 0; i < editCourses.length; i++) {
    final courseId = editCourses[i].id;
    currentCourseLessons[editCourses[i]] = coursesController.getCourseLessons(courseId).map((e) => e.clone()).toList();
  }

  if (editLesson != null) {
    // update lesson information in currentCourseLessons
    for (var courseGroupCourse in editCourses) {
      if (currentCourseLessons[courseGroupCourse]!.indexWhere((element) => element.id == editLesson.id) != -1) {
        currentCourseLessons[courseGroupCourse]![currentCourseLessons[courseGroupCourse]!
            .indexWhere((element) => element.id == editLesson.id)] = editLesson.clone();
      }
    }
  }

  var nowTime = DateTime.now();
  // sort all entry in currentCourseLessons
  for (var courseGroupCourse in editCourses) {
    currentCourseLessons[courseGroupCourse]!.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // return result <Course, (notBilled, billed)>
  Map<Course, (List<Lesson>, List<Lesson>)> resultCourseLessons = {};
  // Map<Course, int> courseCompletedCount = {};
  for (var courseGroupCourse in editCourses) {
    resultCourseLessons[courseGroupCourse] = ([], []);
    // courseCompletedCount[courseGroupCourse] = 0;
  }

  double generateCourseTimeUnitCost = 0;

  // the past shall not be modified by this function
  for (var eachCourse in editCourses) {
    for (var lesson in currentCourseLessons[eachCourse]!) {
      if (lesson.status != LessonStatus.notStarted ||
          lesson.endTime.isBefore(nowTime) ||
          lesson.id == editLesson?.id ||
          lesson.endTime != lesson.originalEndTime) {
        print("add lesson ${lesson.name}, status ${lesson.status}, endTime: ${lesson.endTime}");
        if (lesson.status == LessonStatus.archived || lesson.status == LessonStatus.canceled) {
          resultCourseLessons[eachCourse]!.$1.add(lesson);
        } else {
          print('add billed lesson ${lesson.name}');
          resultCourseLessons[eachCourse]!.$2.add(lesson);
          generateCourseTimeUnitCost += eachCourse.pattern.value;
        }
      }
    }
  }

  print('========== current unit : $generateCourseTimeUnitCost, ${courseGroup.totalAmount} ==========');
  if (generateCourseTimeUnitCost > courseGroup.totalAmount) {
    print('generateCourseTimeUnitCost > courseGroup.restAmount');
    return Failure(CalculateError.notEnoughAmount);
  }

  bool generateMore = true;
  DateTime courseDate = nowTime.toUtc();
  for (var eachCourse in editCourses) {
    courseDate = eachCourse.timeTable.startDate.isBefore(courseDate) ? eachCourse.timeTable.startDate : courseDate;
  }
  courseDate = courseDate.toLocal();
  print('reCal start from: $courseDate');
  while (generateMore) {
    print('try generate for day: $courseDate');
    print('current unit : $generateCourseTimeUnitCost, ${courseGroup.totalAmount - generateCourseTimeUnitCost}');
    if (courseGroup.totalAmount <= generateCourseTimeUnitCost) {
      break;
    }
    generateMore = false;
    for (var eachCourse in editCourses) {
      // print('courseGroupCourse: ${courseGroupCourse.name}, cost: ${courseGroupCourse.pattern.value}');
      if (courseGroup.totalAmount - generateCourseTimeUnitCost < eachCourse.pattern.value ||
          eachCourse.timeTable.daysOfWeek.isEmpty) {
        print('cant generate ${eachCourse.name} rest amount: ${courseGroup.totalAmount - generateCourseTimeUnitCost}');
        continue;
      }
      generateMore = true;
      print('each Course: ${eachCourse.name}, startDate: ${eachCourse.timeTable.startDate} | ${matchCourseTimeType(
        eachCourse.timeTable.startDate,
        courseDate,
        eachCourse.timeTable.weekType,
        eachCourse.timeTable.daysOfWeek,
      )} | ${!keepOnlyDay(eachCourse.timeTable.startDate).isAfter(keepOnlyDay(courseDate))}');
      if (matchCourseTimeType(
            eachCourse.timeTable.startDate,
            courseDate,
            eachCourse.timeTable.weekType,
            eachCourse.timeTable.daysOfWeek,
          ) &&
          !keepOnlyDay(eachCourse.timeTable.startDate).isAfter(keepOnlyDay(courseDate))) {
        var startTime = eachCourse.timeTable.lessonStartTime
            .toLocal()
            .copyWith(year: courseDate.year, month: courseDate.month, day: courseDate.day)
            .toUtc();
        var endTime = startTime.add(eachCourse.timeTable.duration);
        print("endTime: $endTime");
        if (resultCourseLessons[eachCourse]!.$2.isNotEmpty &&
            resultCourseLessons[eachCourse]!.$2.last.endTime.isAfter(endTime)) {
          // skip duplicate generate course
          continue;
        }
        Lesson? ifExistLesson = (resultCourseLessons[eachCourse]!.$1 + resultCourseLessons[eachCourse]!.$2)
            .firstWhereOrNull((element) => element.originalEndTime == endTime);
        if (ifExistLesson != null) {
          print(
              'skip exist lesson ${ifExistLesson.name} at endTime $endTime originalEndTime: ${ifExistLesson.originalEndTime}');
        } else {
          final bool isArchived = endTime.isBefore(nowTime);
          final name = "${eachCourse.name} @ ${isArchived ? '存档' : resultCourseLessons[eachCourse]!.$2.length + 1}";
          final status = isArchived ? LessonStatus.archived : LessonStatus.notStarted;
          final genLesson = Lesson(
            id: currentCourseLessons[eachCourse]!.firstWhereOrNull((element) => element.startTime == startTime)?.id ??
                const Uuid().v4(),
            name: name,
            user: eachCourse.user,
            courseId: eachCourse.id,
            startTime: startTime,
            endTime: endTime,
            originalEndTime: endTime,
            status: status,
          );
          print("generate course $name end at $endTime status: $status");
          if (isArchived) {
            resultCourseLessons[eachCourse]!.$1.add(genLesson);
          } else {
            resultCourseLessons[eachCourse]!.$2.add(genLesson);
            generateCourseTimeUnitCost += eachCourse.pattern.value;
          }
        }
      }
    }
    courseDate = courseDate.add(const Duration(days: 1));
  }
  print('genresult: ${resultCourseLessons.length}');
  for (var eachCourse in editCourses) {
    print(
        'genresult: ${eachCourse.name} ${resultCourseLessons[eachCourse]!.$1.length} ${resultCourseLessons[eachCourse]!.$2.length}');
  }
  return Success(resultCourseLessons.map((key, value) => MapEntry(key, value.$1 + value.$2)));
}

/// 根据传入的当前 lessons，和 course 重新推导所有 lesson
///
/// 场景1：修改课程信息后，重新计算课程安排，此时 (mut course, null)
///
/// 场景2：调整某一节课、新建课程后，重新计算课程安排，此时 (course, mut editlesson)
CalResult<CourseLessonMap> reCalculateLessonsForEachSingle(final Course course, Lesson? editLesson) {
  var notBilledLessons = <Lesson>[];
  var billedLessons = <Lesson>[];
  var nowTime = DateTime.now();

  final coursesController = Get.find<CoursesController>();
  late final List<Lesson> currentLessons = coursesController.getCourseLessons(course.id);
  final List<Lesson> currentLessonsCopy = currentLessons.map((e) => e.clone()).toList();
  if (editLesson != null) {
    if (currentLessonsCopy.indexWhere((element) => element.id == editLesson.id) != -1) {
      currentLessonsCopy[currentLessonsCopy.indexWhere((element) => element.id == editLesson.id)] = editLesson;
    } else {
      currentLessonsCopy.add(editLesson);
    }
  }
  currentLessonsCopy.sort((a, b) => a.startTime.compareTo(b.startTime));

  // currentLessons.sort((a, b) => a.startTime.compareTo(b.startTime));
  for (var lesson in currentLessonsCopy) {
    // the past && the user-defined status shall not be modified by this function
    if (lesson.status != LessonStatus.notStarted ||
        lesson.endTime.isBefore(nowTime) ||
        lesson.id == editLesson?.id ||
        lesson.endTime != lesson.originalEndTime) {
      if (lesson.status == LessonStatus.archived || lesson.status == LessonStatus.canceled) {
        notBilledLessons.add(lesson);
      } else {
        billedLessons.add(lesson);
      }
    }
  }

  print('========== current unit : ${billedLessons.length}, ${course.pattern.value} ==========');
  if (billedLessons.length > course.pattern.value) {
    print('billedLessons.length > course.pattern.value');
    return Failure(CalculateError.notEnoughAmount);
  }

  DateTime courseDate = (billedLessons.isEmpty
          ? course.timeTable.startDate
          : (nowTime.isAfter(course.timeTable.startDate) ? nowTime : course.timeTable.startDate))
      .toLocal();
  print('reCal start from: $courseDate, billed length: ${billedLessons.length}');
  while (billedLessons.length < course.pattern.value.toInt() && course.timeTable.daysOfWeek.isNotEmpty) {
    if (matchCourseTimeType(
      course.timeTable.startDate,
      courseDate,
      course.timeTable.weekType,
      course.timeTable.daysOfWeek,
    )) {
      var startTime = course.timeTable.lessonStartTime
          .toLocal()
          .copyWith(year: courseDate.year, month: courseDate.month, day: courseDate.day)
          .toUtc();
      var endTime = startTime.add(course.timeTable.duration);
      Lesson? ifExistLesson =
          (notBilledLessons + billedLessons).firstWhereOrNull((element) => element.originalEndTime == endTime);
      if (ifExistLesson != null) {
        print(
            'skip exist lesson ${ifExistLesson.name} at endTime $endTime originalEndTime: ${ifExistLesson.originalEndTime}');
      } else {
        final bool isArchived = endTime.isBefore(nowTime);
        final genLesson = Lesson(
          id: currentLessonsCopy.firstWhereOrNull((element) => element.startTime == startTime)?.id ?? const Uuid().v4(),
          name: "${course.name} @ ${isArchived ? '存档' : "${billedLessons.length + 1}"}",
          user: course.user,
          courseId: course.id,
          startTime: startTime,
          endTime: endTime,
          originalEndTime: endTime,
          status: isArchived ? LessonStatus.archived : LessonStatus.notStarted,
        );
        if (isArchived) {
          notBilledLessons.add(genLesson);
        } else {
          billedLessons.add(genLesson);
        }
      }
    }
    courseDate = courseDate.add(const Duration(days: 1));
  }

  return Success({course: notBilledLessons + billedLessons});
}

bool matchCourseTimeType(DateTime startDate, DateTime targetDate, WeekType weekType, List<String> daysOfWeek) {
  if (!daysOfWeek.contains(getDayOfWeek(targetDate))) {
    return false;
  }
  if (weekType == WeekType.weekly) {
    return true;
  }
  if (weekType == WeekType.biWeekly) {
    var diff = targetDate.difference(startDate).inDays;
    return (diff + 14) % 14 < 7;
  }

  return false;
}
