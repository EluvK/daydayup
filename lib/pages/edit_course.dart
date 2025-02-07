import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
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
      return _EditCourseInner(course: course);
    } else {
      return _EditCourseInner(course: courseController.getCourse(widget.courseId!));
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
        TextField(
          decoration: InputDecoration(
            labelText: 'Course Name',
          ),
          controller: TextEditingController(text: widget.course.name),
          onChanged: (value) {
            widget.course.name = value;
          },
        ),
        TextField(
          decoration: InputDecoration(
            labelText: 'Description',
          ),
          controller: TextEditingController(text: widget.course.description),
          onChanged: (value) {
            widget.course.description = value;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final user in settingController.users)
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.course.user = user;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.course.user == user ? user.color.withAlpha(200) : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (widget.course.user == user)
                        BoxShadow(
                          color: user.color.withAlpha(120),
                          spreadRadius: 4,
                          blurRadius: 5,
                        ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: user.color.withAlpha(100),
                    child: Center(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: widget.course.user == user ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // todo course color
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
