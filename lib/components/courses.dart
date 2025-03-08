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
                  child: Text(' 新增课程 '),
                ),
                PopupMenuItem<String>(
                  value: 'add_course_group',
                  child: Text(' 新增课程组 '),
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
            final courses = coursesController.courses;
            final courseGroups = coursesController.courseGroups;

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
                      (MapEntry<String, List<Course>> e) =>
                          courseGroupWidget(courseGroups.firstWhere((element) => element.id == e.key), e.value),
                    )
                    .toList(),
                if (noGroupCourses.isNotEmpty)
                  [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "课程",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: noGroupCourses.length,
                      itemBuilder: (context, index) {
                        var course = noGroupCourses[index];
                        return CourseTile(course: course, status: coursesController.courseStatus[course.id]!);
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

  Widget courseGroupWidget(CourseGroup courseGroup, List<Course> courses) {
    var sumUsedAmount = courses.fold(
        0.0, (previousValue, element) => previousValue + coursesController.courseStatus[element.id]!.totalCost);
    var title = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(courseGroup.name),
        Text("剩余 ${(courseGroup.totalAmount - sumUsedAmount).toString()} 课时",
            style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
      ],
    );
    return ExpansionTile(
      initiallyExpanded: courses.isNotEmpty,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: title,
      trailing: IconButton(
        icon: Icon(Icons.more_horiz),
        onPressed: () async {
          await Get.toNamed('/view-course-group', arguments: [courseGroup.id]);
        },
      ),
      children: courses.isEmpty
          ? [
              Text('...'),
            ]
          : courses.map((e) => CourseTile(course: e, status: coursesController.courseStatus[e.id]!)).toList(),
    );
  }
}

class CourseTile extends StatelessWidget {
  const CourseTile({
    super.key,
    required this.course,
    required this.status,
    // this.editable = false,
    this.showUser = true,
  });

  final Course course;
  final CourseStatus status;
  // final bool editable;
  final bool showUser;

  @override
  Widget build(BuildContext context) {
    var daysOfWeek = concatSelectedDays(course.timeTable.weekType, course.timeTable.daysOfWeek);
    var time =
        "${DateFormat.Hm().format(course.timeTable.startDate.toLocal())}-${DateFormat.Hm().format(course.timeTable.startDate.toLocal().add(course.timeTable.duration))}";
    if (course.description.isNotEmpty) {
      time = "$time\n${course.description}";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      decoration: BoxDecoration(
        // color: course.color.withAlpha(24),
        border: Border.all(width: 0.5),
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          colors: [course.color.withAlpha(96), course.color.withAlpha(168)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/view-course', arguments: [course.id]);
        },
        child: Row(
          children: [
            // ConstrainedBox(
            //   constraints: BoxConstraints(minWidth: 60),
            //   child: Column(
            //     children: [
            //       if (showUser) UserAvatar(user: course.user, isSelected: false),
            //       SizedBox(height: 4),
            //     ],
            //   ),
            // ),
            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                onTap: null,
                trailing: null,
                // ? IconButton(
                //     onPressed: () async {
                //       await Get.toNamed('/edit-course', arguments: [course.id]);
                //     },
                //     icon: Icon(Icons.edit),
                //   )
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(course.name),
                    Text(status.fmt()),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("$daysOfWeek, $time")),
                    UserAvatar(user: course.user, isSelected: false),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
