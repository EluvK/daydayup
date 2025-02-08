import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Courses extends StatelessWidget {
  const Courses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: [
          // PopupMenuButton<String>(icon: Icon(Icons.add), itemBuilder: itemBuilder),
          PopupMenuButton<String>(
            icon: Icon(Icons.add), // 使用 add icon
            onSelected: (String value) {
              if (value == 'add_course') {
                Get.toNamed('/edit-course');
              } else if (value == 'add_course_group') {
                Get.toNamed('/edit-course-group');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'add_course',
                  child: Text('新增课程'),
                ),
                PopupMenuItem<String>(
                  value: 'add_course_group',
                  child: Text('新增课程组'),
                ),
              ];
            },
          ),
        ],
      ),
      body: CoursesTable(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          Get.toNamed('/edit-course');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CoursesTable extends StatefulWidget {
  const CoursesTable({super.key});

  @override
  State<CoursesTable> createState() => _CoursesTableState();
}

class _CoursesTableState extends State<CoursesTable> {
  var coursesController = Get.find<CoursesController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            var courses = coursesController.courses;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                var course = courses[index];
                return _buildCourseTile(course);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCourseTile(Course course) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: course.color.withAlpha(48), width: 2),
          borderRadius: BorderRadius.circular(16),
          color: course.color.withAlpha(24),
        ),
        child: ListTile(
          title: Text(course.name),
          subtitle: Text("${course.timeTable.startDate.toString()} (${course.description})"),
          textColor: course.color,
          onTap: () {
            Get.toNamed('/edit-course', arguments: [course.id]);
          },
        ),
      ),
    );
  }
}
