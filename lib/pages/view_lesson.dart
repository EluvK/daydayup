import 'package:daydayup/components/lesson.dart';
import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:daydayup/utils/utils.dart';
import 'package:daydayup/utils/view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ViewLessonPage extends StatelessWidget {
  const ViewLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String courseId = args[0];
    final String lessonId = args[1];
    return Scaffold(
      appBar: AppBar(
        title: Text('课堂单元'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.toNamed('/edit-lesson', arguments: [courseId, lessonId]);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ViewLesson(courseId: courseId, lessonId: lessonId),
      ),
    );
  }
}

class ViewLesson extends StatefulWidget {
  const ViewLesson({super.key, required this.courseId, required this.lessonId});
  final String courseId;
  final String lessonId;

  @override
  State<ViewLesson> createState() => _ViewLessonState();
}

class _ViewLessonState extends State<ViewLesson> {
  final coursesController = Get.find<CoursesController>();
  late final Lesson lesson = coursesController.getCourseLesson(widget.courseId, widget.lessonId);
  late final Course course = coursesController.getCourse(widget.courseId);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 基本信息
        Align(alignment: Alignment.topLeft, child: Text('基本信息')),
        TextViewWidget(title: InputTitleEnumWrapper(InputTitleEnum.courseName), value: course.name),
        TextViewWidget(title: InputTitleEnumWrapper(InputTitleEnum.lessonName), value: lesson.name),
        ViewWidget(title: InputTitleEnumWrapper(InputTitleEnum.lessonStatus), value: lessonStatusWidget(lesson)),
        UserViewWidget(user: lesson.user),
        Divider(),

        // 时间信息
        Align(
            alignment: Alignment.topLeft,
            child: Text('时间信息${lesson.endTime != lesson.originalEndTime ? userModifiedIcon : ''}')),
        TimeViewWidget(
          title: TimeTitleEnumWrapper(TimeTitleEnum.lessonStartDateTime),
          value: lesson.startTime,
          formatter: DateFormat.yMd().add_jm(),
        ),
        TimeViewWidget(
          title: TimeTitleEnumWrapper(TimeTitleEnum.lessonEndDateTime),
          value: lesson.endTime,
          formatter: DateFormat.yMd().add_jm(),
        )
      ],
    );
  }
}
