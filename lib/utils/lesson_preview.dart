import 'package:daydayup/components/lesson.dart';
import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/course_arrangement.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LessonPreview extends StatelessWidget {
  LessonPreview(
      {super.key,
      required this.thisCourse,
      this.editedCourse,
      this.thisLesson,
      this.editedLesson,
      required this.validateUserInputFunc}) {
    assert(thisLesson == null || editedLesson != null, "editedLesson must be provided if thisLesson is provided");
    assert(editedLesson != null || editedCourse != null, "editedLesson or editedCourse must be provided");
  }

  final Course thisCourse;
  final Course? editedCourse;

  final Lesson? thisLesson;
  final Lesson? editedLesson;

  final String Function() validateUserInputFunc;

  final coursesController = Get.find<CoursesController>();

  final RxBool viewCurrent = true.obs;
  final RxBool viewExpected = false.obs;

  @override
  Widget build(BuildContext context) {
    print('build LessonPreview status ${editedLesson?.status}');
    Map<Course, List<Lesson>> expectedLessonsMap = <Course, List<Lesson>>{};

    final check = validateUserInputFunc();
    if (check != "") {
      return Text(check);
    }

    bool viewExpected = viewExpectedLesson(thisCourse, editedCourse, thisLesson, editedLesson);

    if (viewExpected) {
      expectedLessonsMap = reCalCourseLessonsMap(thisCourse, editedCourse, thisLesson, editedLesson);
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        if (!viewExpected)
          DynamicLessonList(
            title: "该课堂排课",
            course: thisCourse,
            lessons: coursesController
                .getCourseLessons(thisCourse.id)
                .where((element) => element.status == LessonStatus.notStarted)
                .toList(),
          ),
        if (viewExpected)
          for (var entry in expectedLessonsMap.entries.where((entry) => entry.key.name == thisCourse.name))
            DynamicLessonList(
              title: "修改后该课堂排课 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value.where((lesson) => lesson.status == LessonStatus.notStarted).toList(),
              titleColor: Colors.red[300],
            ),
        if (viewExpected && thisCourse.pattern.type == PatternType.costClassTimeUnit)
          for (var entry in expectedLessonsMap.entries.where((entry) => entry.key.name != thisCourse.name))
            DynamicLessonList(
              title: "修改后其它课堂排课 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value.where((lesson) => lesson.status == LessonStatus.notStarted).toList(),
              titleColor: Colors.red[300],
            ),
      ],
    );
  }
}

bool viewExpectedLesson(Course thisCourse, Course? editedCourse, Lesson? thisLesson, Lesson? editedLesson) {
  if (editedLesson != null && thisLesson != null) {
    // 修改课堂模式
    if (editedLesson.toJson().toString() != thisLesson.toJson().toString()) {
      return true;
    }
  } else {
    assert(editedCourse != null, "editedCourse must be provided if editedLesson is not provided");
    // 修改课程信息
    if (editedCourse!.toJson().toString() != thisCourse.toJson().toString()) {
      return true;
    }
  }
  return false;
}

Map<Course, List<Lesson>> reCalCourseLessonsMap(
  Course thisCourse,
  Course? editedCourse,
  Lesson? thisLesson,
  Lesson? editedLesson,
) {
  final coursesController = Get.find<CoursesController>();
  late final List<Lesson> currentLessons = coursesController.getCourseLessons(thisCourse.id);
  switch (thisCourse.pattern.type) {
    case PatternType.eachSingleLesson:
      final List<Lesson> editLessons = currentLessons.map((e) => e.clone()).toList();
      if (editedLesson != null) {
        editLessons[editLessons.indexWhere((element) => element.id == editedLesson.id)] = editedLesson;
      }
      return {thisCourse: reCalculateLessonsForEachSingle(editLessons, editedCourse ?? thisCourse)};

    case PatternType.costClassTimeUnit:
      double deltaTimeUnit = 0;
      if (thisLesson != null && editedLesson != null) {
        if ((thisLesson.status == LessonStatus.notStarted || thisLesson.status == LessonStatus.canceled) &&
            (editedLesson.status == LessonStatus.finished || editedLesson.status == LessonStatus.notAttended)) {
          deltaTimeUnit = thisCourse.pattern.value;
        }
        if ((thisLesson.status == LessonStatus.finished || thisLesson.status == LessonStatus.notAttended) &&
            (editedLesson.status == LessonStatus.notStarted || editedLesson.status == LessonStatus.canceled)) {
          deltaTimeUnit = -thisCourse.pattern.value;
        }
      }
      return reCalculateLessonsForTimeUnit(thisCourse, editLesson: editedLesson, deltaTimeUnit: deltaTimeUnit);
  }
}
