import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/color_picker.dart';
import 'package:daydayup/utils/day_of_week_picker.dart';
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
  final coursesController = Get.find<CoursesController>();
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
        timeTable: CourseTimeTable(
          startDate: DateTime.now(),
          daysOfWeek: [],
          lessonStartTime: DateTime.now(),
          duration: Duration(hours: 2),
        ),
        pattern: Pattern(type: PatternType.eachSingleLesson, value: 10),
        color: RandomColor.getColorObject(Options(luminosity: Luminosity.dark)),
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseInner(course: course),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseInner(course: coursesController.getCourse(widget.courseId!)),
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
  final coursesController = Get.find<CoursesController>();

  final RxList<String> dynamicDayOfWeek = <String>[].obs;
  final RxList<Lesson> lessons = <Lesson>[].obs;

  @override
  void initState() {
    dynamicDayOfWeek.value = widget.course.timeTable.daysOfWeek;
    lessons.value = coursesController.getCourseLessons(widget.course.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
          initialUser: [widget.course.user],
        ),
        ColorPickerWidget(
          onChanged: (color) {
            widget.course.color = color;
          },
          initialColor: widget.course.color,
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text('时间记录')),
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseFirstDayTime,
          onChange: (date) {
            widget.course.timeTable.startDate = date;
            setState(() {
              var dayOfWeek = getDayOfWeek(date);
              print('day of week: $dayOfWeek');
              dynamicDayOfWeek.value = [dayOfWeek];
              widget.course.timeTable.daysOfWeek = [dayOfWeek];
            });
          },
          initialValue: widget.course.timeTable.startDate,
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseStartTime,
          onChange: (date) {
            widget.course.timeTable.lessonStartTime = date;
            // recalculate course end time
            setState(() {});
          },
          initialValue: widget.course.timeTable.lessonStartTime,
        ),
        DurationPickerWidget(
          initialValue: widget.course.timeTable.duration,
          onChange: (duration) {
            print('get duration: $duration');
            widget.course.timeTable.duration = duration;
            // recalculate course end time
            setState(() {});
          },
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseEndTime,
          onChange: (date) {
            print('set end time: $date');
            // recalculate course length
            widget.course.timeTable.duration = date.difference(widget.course.timeTable.lessonStartTime);
            print('course length: ${widget.course.timeTable.duration}');
            setState(() {});
          },
          initialValue: widget.course.timeTable.lessonStartTime.add(widget.course.timeTable.duration),
        ),
        // NumberInputWidget(
        //   title: NumberInputEnum.courseLength,
        //   initialValue: widget.course.timeTable.courseLength,
        //   onChanged: (value) {
        //     widget.course.timeTable.courseLength = value;
        //   },
        // ),
        // 其它统计方式?
        DayOfWeekPickerWidget(
          initialSelectedDays: dynamicDayOfWeek,
          onChanged: (days) {
            print('day of week: $days');
            widget.course.timeTable.daysOfWeek = days;
            // recalculate course day of week
          },
        ),
        Divider(),
        ElevatedButton(
          onPressed: () {
            coursesController.upsertCourse(
              widget.course,
              [
                // todo,
              ],
            );
            Get.back();
          },
          child: Text('保存课程信息'),
        ),
        Divider(),
        // todo view course status

        // todo view lesson list
      ],
    );
  }
}
