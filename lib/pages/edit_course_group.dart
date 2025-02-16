import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
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
        restAmount: 0,
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseGroupInner(courseGroup: courseGroup, newGroup: true),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _EditCourseGroupInner(courseGroup: coursesController.getCourseGroup(widget.courseGroupId!).clone()),
    );
  }
}

class _EditCourseGroupInner extends StatefulWidget {
  const _EditCourseGroupInner({required this.courseGroup, this.newGroup = false});

  final CourseGroup courseGroup;
  final bool newGroup;

  @override
  State<_EditCourseGroupInner> createState() => __EditCourseGroupInnerState();
}

class __EditCourseGroupInnerState extends State<_EditCourseGroupInner> {
  final coursesController = Get.find<CoursesController>();
  bool shouldSaveFirst = true;
  late final ValueNotifier<CourseGroupBill> newBill = ValueNotifier(CourseGroupBill(
    id: Uuid().v4(),
    groupId: widget.courseGroup.id,
    description: '',
    time: DateTime.now(),
    amount: 0,
  ));

  @override
  void initState() {
    shouldSaveFirst = widget.newGroup;
    newCourseGroupBill();
    super.initState();
  }

  void newCourseGroupBill() {
    newBill.value = CourseGroupBill(
      id: Uuid().v4(),
      groupId: widget.courseGroup.id,
      description: '',
      time: DateTime.now(),
      amount: 0,
    );
  }

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
        TextInputWidget(
          title: InputTitleEnum.anyDescription,
          onChanged: (value) {
            widget.courseGroup.description = value;
          },
          initialValue: widget.courseGroup.description,
        ),
        TextViewWidget(
          title: NumberInputEnumWrapper(NumberInputEnum.courseGroupTimeUnit),
          value: widget.courseGroup.restAmount.toString(),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            if (!validateUserInput(saveCourse: true)) return;
            await coursesController.upsertCourseGroup(widget.courseGroup);
            shouldSaveFirst ? shouldSaveFirst = false : Get.back();
            setState(() {});
          },
          child: Text(shouldSaveFirst ? '保存课程组信息' : '更新课程组信息'),
        ),
        Divider(),
        Visibility(
            visible: shouldSaveFirst == false,
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
                    setState(() {
                      newCourseGroupBill();
                      // todo refresh course group
                    });
                  },
                  child: const Text('补充课时'),
                ),
              ],
            )),
        Divider(),
        informations(),
        Divider(),
        // dangerZone,
        ElevatedButton(
          // todo make it click twice to delete
          onPressed: () {
            coursesController.deleteCourseGroup(widget.courseGroup.id);
            Get.back();
          },
          child: const Text('删除课程组', style: TextStyle(color: Colors.red)),
        )
      ],
    );
  }

  bool validateUserInput({bool saveCourse = false}) {
    if (widget.courseGroup.name.isEmpty) {
      Get.snackbar('❌ 错误', '请填写课程组名称');
      return false;
    }

    if (saveCourse || shouldSaveFirst) return true;
    if (newBill.value.amount <= 0) {
      Get.snackbar('❌ 错误', '课时数必须大于0');
      return false;
    }
    return true;
  }

  Widget informations() {
    // var courses = coursesController.courses.where((element) => element.groupId == widget.courseGroup.id).toList();
    return Column(
      children: [
        _infoBills(),
      ],
    );
  }

  Widget _infoBills() {
    return FutureBuilder<List<CourseGroupBill>>(
      future: coursesController.getCourseGroupBills(widget.courseGroup.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        var bills = snapshot.data!;
        return Column(
          children: [
            for (var bill in bills)
              ListTile(
                title: Text(bill.description),
                subtitle: Text('${bill.amount} at ${bill.time}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // coursesController.deleteCourseGroupBill(bill.id);
                    setState(() {});
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
