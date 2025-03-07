import 'package:daydayup/components/lesson.dart';
import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/course_arrangement.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
export 'package:daydayup/utils/course_arrangement.dart' show CalculateError;

class LessonPreview extends StatelessWidget {
  LessonPreview({
    super.key,
    required this.thisCourse,
    this.editedCourse,
    this.thisLesson,
    this.editedLesson,
    required this.validateUserInputFunc,
    this.isCreateNew = false,
  }) {
    assert(thisLesson == null || editedLesson != null, "editedLesson must be provided if thisLesson is provided");
    assert(editedLesson != null || editedCourse != null, "editedLesson or editedCourse must be provided");
  }

  final Course thisCourse;
  final Course? editedCourse;
  final Lesson? thisLesson;
  final Lesson? editedLesson;
  final String Function() validateUserInputFunc;
  final bool isCreateNew;

  final coursesController = Get.find<CoursesController>();

  final RxBool viewCurrent = true.obs;
  final RxBool viewExpected = false.obs;

  @override
  Widget build(BuildContext context) {
    print('build LessonPreview status ${editedLesson?.status}');
    print('thisCourse ${thisCourse.name} ${thisCourse.id}');
    Map<Course, List<Lesson>> expectedLessonsMap = <Course, List<Lesson>>{};

    final check = validateUserInputFunc();
    if (check != "") {
      return Center(child: Text(check));
    }
    bool viewExpected = isCreateNew || viewExpectedLesson(thisCourse, editedCourse, thisLesson, editedLesson);
    print('build preview viewExpected $viewExpected');

    if (viewExpected) {
      try {
        expectedLessonsMap = reCalCourseLessonsMap(thisCourse, editedCourse, editedLesson).getOrThrow();
      } on CalculateError catch (e) {
        switch (e) {
          case CalculateError.notEnoughAmount:
            return Center(
                child: Text(
              "❌ 排课失败！\n课时似乎不够啦。\n对于手动修改过的课程，是不会覆盖的噢。",
              style: TextStyle(
                color: Color(0xFF840016),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.9,
              ),
            ));
        }
      } catch (e) {
        return Center(child: Text("未知错误"));
      }

      print('generate expectedLessonsMap length ${expectedLessonsMap.length}');
    }

    print('thisCourse ${thisCourse.name} ${thisCourse.id}');
    for (var entry in expectedLessonsMap.entries) {
      print('generate expectedLessonsMap ${entry.key.name} ${entry.key.id} ${entry.value.length}');
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
          for (var entry in expectedLessonsMap.entries.where((entry) => entry.key.id == thisCourse.id))
            DynamicLessonList(
              title: "修改后该课堂排课 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value.where((lesson) => lesson.status == LessonStatus.notStarted).toList(),
              titleColor: Colors.red[300],
            ),
        if (viewExpected && isCreateNew && editedCourse != null)
          for (var entry in expectedLessonsMap.entries.where((entry) => entry.key.id == thisCourse.id))
            DynamicLessonList(
              title: "新课堂归档 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value.where((lesson) => lesson.status == LessonStatus.archived).toList(),
              titleColor: Colors.green[300],
            ),
        if (viewExpected)
          for (var entry in expectedLessonsMap.entries.where((entry) => entry.key.id == thisCourse.id))
            DynamicLessonList(
              title: "该课堂历史记录 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value
                  .where((lesson) => lesson.status != LessonStatus.notStarted && lesson.status != LessonStatus.archived)
                  .toList(),
              titleColor: Colors.green[300],
            ),
        if (viewExpected && thisCourse.pattern.type == PatternType.costClassTimeUnit)
          for (var entry in expectedLessonsMap.entries.where((entry) => entry.key.id != thisCourse.id))
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

CalResult<CourseLessonMap> reCalCourseLessonsMap(
  Course thisCourse,
  Course? editedCourse,
  Lesson? editedLesson,
) {
  switch (thisCourse.pattern.type) {
    case PatternType.eachSingleLesson:
      return reCalculateLessonsForEachSingle(editedCourse ?? thisCourse, editedLesson);

    case PatternType.costClassTimeUnit:
      return reCalculateLessonsForTimeUnit(editedCourse ?? thisCourse, editedLesson);
  }
}
