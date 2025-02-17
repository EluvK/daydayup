import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewCourseGroupPage extends StatelessWidget {
  const ViewCourseGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String courseGroupId = args[0];
    return Scaffold(
      appBar: AppBar(
        title: Text('课程组详情'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Get.toNamed('/edit-course-group', arguments: [courseGroupId]);
              Get.reload();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ViewCourseGroup(courseGroupId: courseGroupId),
      ),
    );
  }
}

class ViewCourseGroup extends StatefulWidget {
  const ViewCourseGroup({super.key, required this.courseGroupId});
  final String courseGroupId;

  @override
  State<ViewCourseGroup> createState() => _ViewCourseGroupState();
}

class _ViewCourseGroupState extends State<ViewCourseGroup> {
  final coursesController = Get.find<CoursesController>();
  late final courseGroup = coursesController.getCourseGroup(widget.courseGroupId);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Align(alignment: Alignment.centerLeft, child: Text('基本信息')),
        TextViewWidget(title: InputTitleEnumWrapper(InputTitleEnum.courseGroupName), value: courseGroup.name),
        TextViewWidget(title: InputTitleEnumWrapper(InputTitleEnum.anyDescription), value: courseGroup.description),
        TextViewWidget(
          title: NumberInputEnumWrapper(NumberInputEnum.courseGroupTimeUnit),
          value: courseGroup.restAmount.toString(),
        ),
        Divider(),
        Align(alignment: Alignment.centerLeft, child: Text('课程列表')),
        Divider(),
        Align(alignment: Alignment.centerLeft, child: Text('课时记录')),
        _infoBills(),
        Divider(),
      ],
    );
  }

  Widget _infoBills() {
    return FutureBuilder<List<CourseGroupBill>>(
      future: coursesController.getCourseGroupBills(courseGroup.id),
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
