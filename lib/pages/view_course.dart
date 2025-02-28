import 'package:daydayup/components/lesson.dart';
import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/day_of_week_picker.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:daydayup/utils/view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ViewCoursePage extends StatelessWidget {
  const ViewCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String courseId = args[0];
    return Scaffold(
      appBar: AppBar(
        title: Text('课程详情'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Get.toNamed('/edit-course', arguments: [courseId]);
              Get.reload();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ViewCourse(courseId: courseId),
      ),
    );
  }
}

class ViewCourse extends StatefulWidget {
  const ViewCourse({super.key, required this.courseId});
  final String courseId;

  @override
  State<ViewCourse> createState() => _ViewCourseState();
}

class _ViewCourseState extends State<ViewCourse> {
  final coursesController = Get.find<CoursesController>();

  late final Course course = coursesController.getCourse(widget.courseId);
  late final List<Lesson> lessons = coursesController.getCourseLessons(widget.courseId);
  late final List<Lesson> notStartedLessons =
      lessons.where((lesson) => lesson.status == LessonStatus.notStarted).toList();
  late final List<Lesson> pastLessons = lessons.where((lesson) => lesson.status != LessonStatus.notStarted).toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 基本信息
        Align(alignment: Alignment.topLeft, child: Text('基本信息')),
        TextViewWidget(title: InputTitleEnumWrapper(InputTitleEnum.courseName), value: course.name),
        TextViewWidget(title: InputTitleEnumWrapper(InputTitleEnum.anyDescription), value: course.description),
        UserViewWidget(user: course.user),
        Divider(),

        // 计费方式
        Align(alignment: Alignment.topLeft, child: Text('计费方式')),
        if (course.pattern.type == PatternType.costClassTimeUnit && course.groupId != null)
          TextViewWidget(
            title: InputTitleEnumWrapper(InputTitleEnum.courseGroupName),
            value: coursesController.getCourseGroup(course.groupId!).name,
          ),
        if (course.pattern.type == PatternType.costClassTimeUnit)
          TextViewWidget(
            title: NumberInputEnumWrapper(NumberInputEnum.courseCostClassTimeUnit),
            value: course.pattern.value.toString(),
          ),
        if (course.pattern.type == PatternType.eachSingleLesson)
          TextViewWidget(
            title: NumberInputEnumWrapper(NumberInputEnum.courseLength),
            value: course.pattern.value.toString(),
          ),
        Divider(),

        // 时间周期
        Align(alignment: Alignment.topLeft, child: Text('时间周期')),
        TimeViewWidget(
          title: TimeTitleEnumWrapper(TimeTitleEnum.courseFirstDayTime),
          value: course.timeTable.startDate,
          formatter: DateFormat.yMd(),
        ),
        TimeViewWidget(
          title: TimeTitleEnumWrapper(TimeTitleEnum.courseStartTime),
          value: course.timeTable.lessonStartTime,
          formatter: DateFormat.Hm(),
        ),
        TextViewWidget(
          title: TimeTitleEnumWrapper(TimeTitleEnum.courseDuration),
          value: durationFormatter(course.timeTable.duration),
        ),
        TimeViewWidget(
          title: TimeTitleEnumWrapper(TimeTitleEnum.courseEndTime),
          value: course.timeTable.lessonStartTime.add(course.timeTable.duration),
          formatter: DateFormat.Hm(),
        ),
        TextViewWidget(
          title: TimeTitleEnumWrapper(TimeTitleEnum.dayOfWeek),
          value: concatSelectedDays(course.timeTable.weekType, course.timeTable.daysOfWeek),
        ),
        Divider(),

        // 课程安排
        // Align(alignment: Alignment.topLeft, child: Text('课程列表')),
        DynamicLessonList(title: '未开始课程', course: course, lessons: notStartedLessons),
        Divider(),
        DynamicLessonList(title: '历史课程', course: course, lessons: pastLessons),
        Divider(),
      ],
    );
  }
}
