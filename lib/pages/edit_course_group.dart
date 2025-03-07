import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/dangerous_zone.dart';
import 'package:daydayup/utils/double_click.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:daydayup/utils/view_widget.dart';
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
        title: Text(courseGroupId == null ? '创建课程组' : '修改课程组'),
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
        description: '',
        totalAmount: 0,
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseGroupInner(courseGroup: courseGroup, isCreateNew: true),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _EditCourseGroupInner(courseGroup: coursesController.getCourseGroup(widget.courseGroupId!)),
    );
  }
}

class _EditCourseGroupInner extends StatefulWidget {
  const _EditCourseGroupInner({required this.courseGroup, this.isCreateNew = false});

  final CourseGroup courseGroup;
  final bool isCreateNew;

  @override
  State<_EditCourseGroupInner> createState() => __EditCourseGroupInnerState();
}

class __EditCourseGroupInnerState extends State<_EditCourseGroupInner> {
  final coursesController = Get.find<CoursesController>();

  late CourseGroup editedCourseGroup;

  late final ValueNotifier<CourseGroupBill> newBill = ValueNotifier(CourseGroupBill(
    id: Uuid().v4(),
    groupId: widget.courseGroup.id,
    description: '',
    time: DateTime.now(),
    amount: 0,
  ));

  @override
  void initState() {
    editedCourseGroup = widget.courseGroup.clone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextInputWidget(
            title: InputTitleEnum.courseGroupName,
            onChanged: (value) {
              editedCourseGroup.name = value;
            },
            initialValue: editedCourseGroup.name),
        TextInputWidget(
          title: InputTitleEnum.anyDescription,
          onChanged: (value) {
            editedCourseGroup.description = value;
          },
          initialValue: editedCourseGroup.description,
          optional: true,
        ),
        TextViewWidget(
          title: NumberInputEnumWrapper(NumberInputEnum.courseGroupTimeUnit),
          value: editedCourseGroup.totalAmount.toString(),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            if (!validateUserInput(saveCourse: true)) return;
            await coursesController.upsertCourseGroup(editedCourseGroup);
            Get.offAllNamed('/');
            if (widget.isCreateNew) {
              Get.toNamed('/edit-course-group', arguments: [editedCourseGroup.id]);
            } else {
              Get.toNamed('/view-course-group', arguments: [editedCourseGroup.id]);
            }
          },
          child: Text(widget.isCreateNew ? '创建课程组信息' : '更新课程组信息'),
        ),
        Divider(),
        Visibility(
            visible: !widget.isCreateNew,
            child: Column(
              children: [
                NumberInputWidget(
                  title: NumberInputEnum.courseGroupBillAdd,
                  initialValue: newBill.value.amount,
                  onChanged: (double value) {
                    newBill.value.amount = value;
                  },
                ),
                TimePickerWidget(
                  timeTitle: TimeTitleEnum.courseGroupBillAddTime,
                  onChange: (value) {
                    newBill.value.time = value;
                  },
                  initialValue: newBill.value.time,
                ),
                TextInputWidget(
                  title: InputTitleEnum.anyDescription,
                  onChanged: (value) {
                    newBill.value.description = value;
                  },
                  initialValue: newBill.value.description,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (!validateUserInput()) return;
                    print('bill: ${newBill.value} ${newBill.value.toJson()}');
                    await coursesController.addCourseGroupBill(newBill.value);
                    Get.offAllNamed('/');
                    Get.toNamed('/view-course-group', arguments: [editedCourseGroup.id]);
                  },
                  child: const Text('补充课时'),
                ),
                Divider(),
              ],
            )),
        if (!widget.isCreateNew)
          DangerousZone(children: [
            Text("    删除课程组将同时删除课程组下的所有课程、课堂记录以及课时账单。\n"),
            DoubleClickButton(
              buttonBuilder: (onPressed) => ElevatedButton(
                onPressed: onPressed,
                child: const Text('删除课程组', style: TextStyle(color: Colors.red)),
              ),
              onDoubleClick: () async {
                await coursesController.deleteCourseGroup(editedCourseGroup.id);
                Get.offAllNamed('/');
              },
              firstClickHint: "删除课程组",
            ),
          ]),
      ],
    );
  }

  bool validateUserInput({bool saveCourse = false}) {
    if (editedCourseGroup.name.isEmpty) {
      Get.snackbar('❌ 错误', '请填写课程组名称');
      return false;
    }

    if (saveCourse || widget.isCreateNew) return true;
    if (newBill.value.amount <= 0) {
      Get.snackbar('❌ 错误', '课时数必须大于0');
      return false;
    }
    return true;
  }
}
