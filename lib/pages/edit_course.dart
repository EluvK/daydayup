import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/color_picker.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:daydayup/utils/user_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class EditCoursePage extends StatelessWidget {
  const EditCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String? courseId = args?[0];
    return Scaffold(
      appBar: AppBar(
        title: Text(courseId == null ? 'New Course' : 'Edit Course'),
      ),
      body: EditCourse(courseId: courseId),
    );
  }
}

class EditCourse extends StatefulWidget {
  const EditCourse({super.key, required this.courseId});
  final String? courseId;

  @override
  State<EditCourse> createState() => _EditCourseState();
}

class _EditCourseState extends State<EditCourse> {
  final courseController = Get.find<CoursesController>();
  final settingController = Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    if (widget.courseId == null) {
      // new one
      var course = Course(
        id: const Uuid().v4(),
        name: '',
        user: settingController.getDefaultUser(),
        description: '',
        pattern: Pattern(startDate: DateTime.now(), daysOfWeek: [], duration: Duration(hours: 2), courseLength: 10),
        color: RandomColor.getColorObject(Options()),
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseInner(course: course),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseInner(course: courseController.getCourse(widget.courseId!)),
      );
    }
  }
}

class _EditCourseInner extends StatefulWidget {
  const _EditCourseInner({required this.course});
  final Course course;

  @override
  State<_EditCourseInner> createState() => __EditCourseInnerState();
}

class __EditCourseInnerState extends State<_EditCourseInner> {
  final settingController = Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10.0,
      children: [
        TextInputWidget(
          title: InputTitleEnum.courseName,
          onChanged: (value) {
            widget.course.name = value;
          },
          initialValue: widget.course.name,
        ),
        TextInputWidget(
          title: InputTitleEnum.courseDescription,
          onChanged: (value) {
            widget.course.description = value;
          },
          initialValue: widget.course.description,
        ),
        UserPicker(
          onChanged: (selectedUserIds) {
            print("onChanged: $selectedUserIds");
            widget.course.user = settingController.users.firstWhere((element) => element.id == selectedUserIds.first);
          },
          candidateUsers: settingController.users,
        ),
        ColorPickerWidget(
          onChanged: (color) {
            widget.course.color = color;
          },
          initialColor: widget.course.color,
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseFirstDayTime,
          onChange: (date) {
            widget.course.pattern.startDate = date;
          },
          initialValue: widget.course.pattern.startDate,
        ),
        ElevatedButton(
          onPressed: () {
            final courseController = Get.find<CoursesController>();
            courseController.upsertCourse(
              widget.course,
              [
                // todo,
              ],
            );
            Get.back();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
