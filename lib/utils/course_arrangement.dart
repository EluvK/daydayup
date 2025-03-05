import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/day_of_week_picker.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

/// 根据传入的当前课程信息，重新推导所有 lesson
///
/// 场景1：修改课程信息后，重新计算课程安排，此时 (mut course, null)
///
/// 场景2：调整某一节课、新建课程后，重新计算课程安排，此时 (course, mut lesson)
Map<Course, List<Lesson>> reCalculateLessonsForTimeUnit(Course course, {Lesson? editLesson, double deltaTimeUnit = 0}) {
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

  // return result
  Map<Course, List<Lesson>> resultCourseLessons = {};
  Map<Course, int> courseCompletedCount = {};
  for (var courseGroupCourse in editCourses) {
    resultCourseLessons[courseGroupCourse] = [];
    courseCompletedCount[courseGroupCourse] = 0;
  }

  // the past shall not be modified by this function
  for (var eachCourse in editCourses) {
    for (var lesson in currentCourseLessons[eachCourse]!) {
      if (lesson.status != LessonStatus.notStarted || lesson.endTime.isBefore(nowTime)) {
        resultCourseLessons[eachCourse]!.add(lesson);
        print("add lesson ${lesson.name}, status ${lesson.status}, endTime: ${lesson.endTime}");
      }
      if (lesson.status == LessonStatus.finished || lesson.status == LessonStatus.notAttended) {
        courseCompletedCount[eachCourse] = courseCompletedCount[eachCourse]! + 1;
      }
    }
  }

  double generateCourseTimeUnitCost = deltaTimeUnit;
  bool generateMore = true;
  DateTime courseDate = nowTime.toUtc();
  for (var eachCourse in editCourses) {
    if (resultCourseLessons[eachCourse]!.isEmpty) {
      courseDate = eachCourse.timeTable.startDate.isBefore(courseDate) ? eachCourse.timeTable.startDate : courseDate;
    }
  }
  courseDate = courseDate.toLocal();
  print('reCal start from: $courseDate');
  while (generateMore) {
    print('try generate for day: $courseDate');
    print('current unit : $generateCourseTimeUnitCost, ${courseGroup.restAmount - generateCourseTimeUnitCost}');
    if (courseGroup.restAmount <= generateCourseTimeUnitCost) {
      break;
    }
    generateMore = false;
    for (var eachCourse in editCourses) {
      // print('courseGroupCourse: ${courseGroupCourse.name}, cost: ${courseGroupCourse.pattern.value}');
      if (courseGroup.restAmount - generateCourseTimeUnitCost < eachCourse.pattern.value ||
          eachCourse.timeTable.daysOfWeek.isEmpty) {
        print('cant generate ${eachCourse.name} rest amount: ${courseGroup.restAmount - generateCourseTimeUnitCost}');
        continue;
      }
      generateMore = true;
      print('each Course: ${eachCourse.name}, startDate: ${eachCourse.timeTable.startDate} | ${matchCourseTimeType(
        eachCourse.timeTable.startDate,
        courseDate,
        eachCourse.timeTable.weekType,
        eachCourse.timeTable.daysOfWeek,
      )} | ${!eachCourse.timeTable.startDate.isAfter(courseDate)}');
      if (matchCourseTimeType(
            eachCourse.timeTable.startDate,
            courseDate,
            eachCourse.timeTable.weekType,
            eachCourse.timeTable.daysOfWeek,
          ) &&
          !eachCourse.timeTable.startDate.isAfter(courseDate)) {
        var startTime = eachCourse.timeTable.lessonStartTime
            .toLocal()
            .copyWith(year: courseDate.year, month: courseDate.month, day: courseDate.day)
            .toUtc();
        var endTime = startTime.add(eachCourse.timeTable.duration);
        print("endTime: $endTime");
        if (resultCourseLessons[eachCourse]!.isNotEmpty &&
            resultCourseLessons[eachCourse]!.last.endTime.isAfter(endTime)) {
          // skip duplicate generate course
          continue;
        }
        Lesson? ifExistLesson =
            resultCourseLessons[eachCourse]!.firstWhereOrNull((element) => element.endTime == endTime);
        if (ifExistLesson != null) {
          print('skip exist lesson ${ifExistLesson.name} at endTime $endTime');
        } else {
          final name = "${eachCourse.name} @ ${courseCompletedCount[eachCourse]! + 1}";
          final status = endTime.isBefore(nowTime) ? LessonStatus.finished : LessonStatus.notStarted;
          resultCourseLessons[eachCourse]!.add(Lesson(
            id: currentCourseLessons[eachCourse]!.firstWhereOrNull((element) => element.startTime == startTime)?.id ??
                const Uuid().v4(),
            name: name,
            user: eachCourse.user,
            courseId: eachCourse.id,
            startTime: startTime,
            endTime: endTime,
            status: status,
          ));
          print("generate course $name end at $endTime status: $status");
          courseCompletedCount[eachCourse] = courseCompletedCount[eachCourse]! + 1;
          if (endTime.isAfter(nowTime)) {
            generateCourseTimeUnitCost += eachCourse.pattern.value;
          }
        }
      }
    }
    courseDate = courseDate.add(const Duration(days: 1));
  }

  return resultCourseLessons;
}

/// 根据传入的当前 lessons，和 course 重新推导所有 lesson
///
/// 场景1：修改课程信息后，重新计算课程安排，此时 (currentLessons, mut course)
///
/// 场景2：调整某一节课、新建课程后，重新计算课程安排，此时 (mut currentLessons, course)
List<Lesson> reCalculateLessonsForEachSingle(List<Lesson> currentLessons, Course course) {
  var resultLessons = <Lesson>[];
  var nowTime = DateTime.now();
  var completedCount = 0;

  currentLessons.sort((a, b) => a.startTime.compareTo(b.startTime));
  for (var lesson in currentLessons) {
    // the past && the user-defined status shall not be modified by this function
    if (lesson.status != LessonStatus.notStarted || lesson.endTime.isBefore(nowTime)) {
      resultLessons.add(lesson);
    }
    if (lesson.status == LessonStatus.finished || lesson.status == LessonStatus.notAttended) {
      completedCount++;
    }
  }

  DateTime courseDate = (resultLessons.isEmpty ? course.timeTable.startDate : nowTime).toLocal();
  print('reCal start from: $courseDate, completedCount: $completedCount');
  while (completedCount < course.pattern.value.toInt() && course.timeTable.daysOfWeek.isNotEmpty) {
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
      Lesson? ifExistLesson = resultLessons.firstWhereOrNull((element) => element.endTime == endTime);
      if (ifExistLesson != null) {
        print('skip exist lesson ${ifExistLesson.name} at endTime $endTime');
      } else {
        resultLessons.add(Lesson(
          id: currentLessons.firstWhereOrNull((element) => element.startTime == startTime)?.id ?? const Uuid().v4(),
          name: "${course.name} @ ${completedCount + 1}",
          user: course.user,
          courseId: course.id,
          startTime: startTime,
          endTime: endTime,
          status: endTime.isBefore(nowTime) ? LessonStatus.finished : LessonStatus.notStarted,
        ));
        completedCount++;
      }
    }
    courseDate = courseDate.add(const Duration(days: 1));
  }

  return resultLessons;
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
