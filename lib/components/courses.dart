import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/day_of_week_picker.dart';
import 'package:daydayup/utils/user_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  final coursesController = Get.find<CoursesController>();

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
                [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "课程组课程",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                groupCourses.entries
                    .map(
                      (MapEntry<String, List<Course>> e) => ExpansionTile(
                        initiallyExpanded: e.value.isNotEmpty,
                        childrenPadding: const EdgeInsets.only(bottom: 8),
                        title: Text(courseGroups.firstWhere((element) => element.id == e.key).name),
                        trailing: IconButton(
                          icon: Icon(Icons.more_horiz),
                          onPressed: () async {
                            await Get.toNamed('/view-course-group', arguments: [e.key]);
                          },
                        ),
                        children: e.value.isEmpty
                            ? [
                                Text('...'),
                              ]
                            : e.value.map((e) => CourseTile(course: e, editable: false)).toList(),
                      ),
                    )
                    .toList(),
                if (noGroupCourses.isNotEmpty)
                  [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "其它课程",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: noGroupCourses.length,
                      itemBuilder: (context, index) {
                        var course = noGroupCourses[index];
                        return CourseTile(course: course, editable: false);
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
}

class CourseTile extends StatelessWidget {
  const CourseTile({
    super.key,
    required this.course,
    this.editable = true,
    this.showUser = true,
  });

  final Course course;
  final bool editable;
  final bool showUser;

  @override
  Widget build(BuildContext context) {
    // todo add day of week status
    var daysOfWeek = concatSelectedDays(course.timeTable.daysOfWeek);
    var time =
        "${DateFormat.Hm().format(course.timeTable.startDate.toLocal())}-${DateFormat.Hm().format(course.timeTable.startDate.toLocal().add(course.timeTable.duration))}";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: course.color.withAlpha(24),
        border: Border.all(width: 0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/view-course', arguments: [course.id]);
        },
        child: Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 60),
              child: Column(
                children: [
                  if (showUser) UserAvatar(user: course.user, isSelected: false),
                  SizedBox(height: 4),
                ],
              ),
            ),
            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                onTap: null,
                trailing: editable
                    ? IconButton(
                        onPressed: () async {
                          await Get.toNamed('/edit-course', arguments: [course.id]);
                        },
                        icon: Icon(Icons.edit),
                      )
                    : null,
                title: Text(course.name),
                subtitle: Text("$daysOfWeek, $time"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
