import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/status_picker.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:daydayup/utils/view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditLessonPage extends StatelessWidget {
  const EditLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String? courseId = args?[0];
    final String? lessonId = args?[1];
    return Scaffold(
      appBar: AppBar(
        title: Text(lessonId == null ? '创建课堂单元' : '编辑课堂单元'),
      ),
      body: EditLesson(courseId: courseId, lessonId: lessonId),
    );
  }
}

class EditLesson extends StatefulWidget {
  const EditLesson({super.key, required this.courseId, required this.lessonId});
  final String? courseId;
  final String? lessonId;

  @override
  State<EditLesson> createState() => _EditLessonState();
}

class _EditLessonState extends State<EditLesson> {
  final coursesController = Get.find<CoursesController>();
  @override
  Widget build(BuildContext context) {
    if (widget.lessonId == null || widget.courseId == null) {
      // todo
      return const Placeholder();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _EditLessonInner(lesson: coursesController.getCourseLesson(widget.courseId!, widget.lessonId!).clone()),
    );
  }
}

class _EditLessonInner extends StatefulWidget {
  const _EditLessonInner({required this.lesson});
  final Lesson lesson;

  @override
  State<_EditLessonInner> createState() => __EditLessonInnerState();
}

class __EditLessonInnerState extends State<_EditLessonInner> {
  final coursesController = Get.find<CoursesController>();
  late final Course course = coursesController.getCourse(widget.lesson.courseId);
  late final lessonOriginalStatus = widget.lesson.status;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 基本信息
        Align(alignment: Alignment.topLeft, child: Text('基本信息')),
        TextViewWidget(title: InputTitleEnumWrapper(InputTitleEnum.courseName), value: course.name),
        TextInputWidget(
          title: InputTitleEnum.lessonName,
          onChanged: (value) {
            widget.lesson.name = value;
          },
          initialValue: widget.lesson.name,
        ),
        StatusPicker(
          status: widget.lesson.status,
          onChange: (value) {
            setState(() {
              widget.lesson.status = value;
              if (value != lessonOriginalStatus) {
                // might need to update course arrangement
                reCalculateLessons(value, lessonOriginalStatus);
              }
            });
          },
        ),
        UserViewWidget(user: widget.lesson.user),
        Divider(),

        // 时间信息
        Align(alignment: Alignment.topLeft, child: Text('时间信息')),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.lessonStartDateTime,
          initialValue: widget.lesson.startTime,
          onChange: (value) {
            widget.lesson.startTime = value;
          },
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.lessonEndDateTime,
          initialValue: widget.lesson.endTime,
          onChange: (value) {
            widget.lesson.endTime = value;
          },
        ),
        Divider(),

        // 保存
        ElevatedButton(
          onPressed: () async {
            if (validateUserInput()) {
              await coursesController.updateLesson(widget.lesson);
              Get.offAllNamed('/');
              Get.toNamed('/view-lesson', arguments: [widget.lesson.courseId, widget.lesson.id]);
            }
          },
          child: const Text('保存'),
        ),
        Divider(),

        // 课程影响预览
      ],
    );
  }

  bool validateUserInput() {
    final now = DateTime.now();
    if (widget.lesson.status == LessonStatus.notStarted && widget.lesson.endTime.isBefore(now)) {
      Get.snackbar('错误', '课程时间已过，状态不能为未完成');
      return false;
    }

    return true;
  }

  void reCalculateLessons(LessonStatus newStatus, LessonStatus oldStatus) {
    if (newStatus == oldStatus) {
      // clear work
      return;
    }
    // if (newStatus)
  }
}
