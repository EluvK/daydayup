import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/day_of_week_picker.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:daydayup/utils/user_picker.dart';
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
      body: ViewCourse(courseId: courseId),
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

  late final course = coursesController.getCourse(widget.courseId);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          // 基本信息
          Align(alignment: Alignment.topLeft, child: Text('基本信息')),
          TextViewWidget(title: InputTitleEnumWraper(InputTitleEnum.courseName), value: course.name),
          TextViewWidget(title: InputTitleEnumWraper(InputTitleEnum.anyDescription), value: course.description),
          ViewWidget(
            title: InputTitleEnumWraper(InputTitleEnum.userName),
            value: Row(
              children: [
                // Spacer(),
                Expanded(child: UserAvatar(user: course.user, isSelected: false)),
              ],
            ),
          ),
          Divider(),
          // 计费方式
          Align(alignment: Alignment.topLeft, child: Text('计费方式')),
          if (course.pattern.type == PatternType.costClassTimeUnit && course.groupId != null)
            TextViewWidget(
              title: InputTitleEnumWraper(InputTitleEnum.courseGroupName),
              value: coursesController.getCourseGroup(course.groupId!).name,
            ),
          if (course.pattern.type == PatternType.costClassTimeUnit)
            TextViewWidget(
              title: NumberInputEnumWraper(NumberInputEnum.courseCostClassTimeUnit),
              value: course.pattern.value.toString(),
            ),
          if (course.pattern.type == PatternType.eachSingleLesson)
            TextViewWidget(
              title: NumberInputEnumWraper(NumberInputEnum.courseLength),
              value: course.pattern.value.toString(),
            ),

          Divider(),
          // 时间周期
          Align(alignment: Alignment.topLeft, child: Text('时间周期')),
          TimeViewWidget(
            title: TimeTitleEnumWraper(TimeTitleEnum.courseFirstDayTime),
            value: course.timeTable.startDate,
            formatter: DateFormat.yMd(),
          ),
          TimeViewWidget(
            title: TimeTitleEnumWraper(TimeTitleEnum.courseStartTime),
            value: course.timeTable.lessonStartTime,
            formatter: DateFormat.Hm(),
          ),
          TextViewWidget(
            title: TimeTitleEnumWraper(TimeTitleEnum.courseDuration),
            value: durationFormatter(course.timeTable.duration),
          ),
          TimeViewWidget(
            title: TimeTitleEnumWraper(TimeTitleEnum.courseEndTime),
            value: course.timeTable.lessonStartTime.add(course.timeTable.duration),
            formatter: DateFormat.Hm(),
          ),
          TextViewWidget(
            title: TimeTitleEnumWraper(TimeTitleEnum.dayOfWeek),
            value: concatSelectedDays(course.timeTable.daysOfWeek),
          ),
        ],
      ),
    );
  }
}
