import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class EditCourseGroupPage extends StatelessWidget {
  const EditCourseGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String? courseGroupId = args?[0];
    return Scaffold(
      appBar: AppBar(
        title: Text(courseGroupId == null ? 'New Course Group' : 'Edit Course Group'),
      ),
      body: EditCourseGroup(courseGroupId: courseGroupId),
    );
  }
}

class EditCourseGroup extends StatefulWidget {
  const EditCourseGroup({super.key, required this.courseGroupId});

  final String? courseGroupId;

  @override
  State<EditCourseGroup> createState() => _EditCourseGroupState();
}

class _EditCourseGroupState extends State<EditCourseGroup> {
  final coursesController = Get.find<CoursesController>();

  @override
  Widget build(BuildContext context) {
    if (widget.courseGroupId == null) {
      // new one
      var courseGroup = CourseGroup(
        id: const Uuid().v4(),
        name: '',
        leftTimeUnit: 0,
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseGroupInner(courseGroup: courseGroup),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _EditCourseGroupInner(courseGroup: coursesController.getCourseGroup(widget.courseGroupId!)),
    );
  }
}

class _EditCourseGroupInner extends StatefulWidget {
  const _EditCourseGroupInner({required this.courseGroup});

  final CourseGroup courseGroup;

  @override
  State<_EditCourseGroupInner> createState() => __EditCourseGroupInnerState();
}

class __EditCourseGroupInnerState extends State<_EditCourseGroupInner> {
  final coursesController = Get.find<CoursesController>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextInputWidget(
          title: InputTitleEnum.courseGroupName,
          onChanged: (value) {
            widget.courseGroup.name = value;
          },
          initialValue: widget.courseGroup.name,
        ),
        NumberInputWidget(
          title: NumberInputEnum.courseGroupTimeUnit,
          initialValue: widget.courseGroup.leftTimeUnit,
          onChanged: (double value) {
            widget.courseGroup.leftTimeUnit = value;
          },
        ),
        Divider(),
        ElevatedButton(
          onPressed: () {
            coursesController.upsertCourseGroup(widget.courseGroup);
            Get.back();
          },
          child: const Text('保存课程组信息'),
        ),
      ],
    );
  }
}
