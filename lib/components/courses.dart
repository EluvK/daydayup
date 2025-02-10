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
        title: Text('课程列表'),
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
            var courseGroups = coursesController.courseGroups;

            final Map<String, List<Course>> groupCourses = {};
            List<Course> noGroupCourses = [];

            for (var group in courseGroups) {
              groupCourses[group.id] = [];
            }
            for (var course in courses) {
              if (course.groupId == null) {
                noGroupCourses.add(course);
              } else {
                groupCourses.putIfAbsent(course.groupId!, () => []).add(course);
              }
            }
            print('groupCourses: $groupCourses');
            print('noGroupCourses: $noGroupCourses');

            print('courses: $courses');

            return ListView(
              children: [
                groupCourses.entries
                    .map(
                      (MapEntry<String, List<Course>> e) => ExpansionTile(
                        initiallyExpanded: e.value.isNotEmpty,
                        childrenPadding: const EdgeInsets.only(bottom: 8),
                        title: Text(courseGroups.firstWhere((element) => element.id == e.key).name),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            await Get.toNamed('/edit-course-group', arguments: [e.key]);
                            setState(() {});
                          },
                        ),
                        children: e.value.isEmpty
                            ? [
                                Text('...'),
                              ]
                            : e.value.map((e) => _buildCourseTile(e)).toList(),
                      ),
                    )
                    .toList(),
                if (noGroupCourses.isNotEmpty)
                  [
                    // Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: noGroupCourses.length,
                      itemBuilder: (context, index) {
                        var course = noGroupCourses[index];
                        return _buildCourseTile(course);
                      },
                    )
                  ],
              ].expand((element) => element).toList(),
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
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Get.toNamed('/edit-course', arguments: [course.id]);
              setState(() {});
            },
          ),
          subtitle: Text("${course.timeTable.startDate.toString()} (${course.description})"),
          textColor: course.color,
          onTap: () {
            Get.toNamed('/view-course', arguments: [course.id]);
          },
        ),
      ),
    );
  }
}
