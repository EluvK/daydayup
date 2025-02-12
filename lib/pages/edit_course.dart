import 'package:daydayup/components/lesson.dart';
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
        title: Text(courseId == null ? '创建课程计划' : '修改课程计划'),
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

  late final List<Lesson> currentLessons = coursesController.getCourseLessons(widget.course.id);
  late final List<Lesson> notStartedLessons =
      currentLessons.where((element) => element.status == LessonStatus.notStarted).toList();

  final RxList<Lesson> expectedLessons = <Lesson>[].obs;

  final RxBool viewCurrentFutureLessons = true.obs;
  final RxBool viewExpectedFutureLessons = false.obs;

  @override
  void initState() {
    if (widget.course.timeTable.daysOfWeek.isEmpty) {
      updateDayOfWeek(widget.course.timeTable.startDate);
    } else {
      dynamicDayOfWeek.value = widget.course.timeTable.daysOfWeek;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 基本信息
        Align(alignment: Alignment.topLeft, child: Text('基本信息')),
        TextInputWidget(
          title: InputTitleEnum.courseName,
          onChanged: (value) {
            widget.course.name = value;
          },
          initialValue: widget.course.name,
        ),
        TextInputWidget(
          title: InputTitleEnum.anyDescription,
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

        // 计费方式
        Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('计费方式'),
                SegmentedButton(
                  segments: [
                    ButtonSegment<PatternType>(value: PatternType.eachSingleLesson, tooltip: '单节', label: Text('单节')),
                    ButtonSegment<PatternType>(value: PatternType.costClassTimeUnit, tooltip: '课时', label: Text('课时')),
                  ],
                  selected: {widget.course.pattern.type},
                  onSelectionChanged: (Set<PatternType> newSelection) {
                    widget.course.pattern.type = newSelection.first;
                    if (widget.course.pattern.type == PatternType.costClassTimeUnit) {
                      widget.course.pattern.value = 1;
                    } else {
                      widget.course.pattern.value = 10;
                    }
                    setState(() {});
                    // tryCalculateExpectedLessons(); // todo uncomment this line
                  },
                ),
              ],
            )),
        if (widget.course.pattern.type == PatternType.costClassTimeUnit)
          for (var i in _buildCourseGroupInfo()) i,
        if (widget.course.pattern.type == PatternType.eachSingleLesson)
          for (var i in _buildSingleCourseInfo()) i,
        Divider(),

        // 时间周期
        Align(alignment: Alignment.topLeft, child: Text('时间周期')),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseFirstDayTime,
          onChange: (date) {
            widget.course.timeTable.startDate = date;
            setState(() {
              updateDayOfWeek(date);
            });
            tryCalculateExpectedLessons();
          },
          initialValue: widget.course.timeTable.startDate,
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseStartTime,
          onChange: (date) {
            widget.course.timeTable.lessonStartTime = date;
            // recalculate course end time
            setState(() {});
            tryCalculateExpectedLessons();
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
            tryCalculateExpectedLessons();
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
            tryCalculateExpectedLessons();
          },
          initialValue: widget.course.timeTable.lessonStartTime.add(widget.course.timeTable.duration),
        ),
        DayOfWeekPickerWidget(
          initialSelectedDays: dynamicDayOfWeek,
          onChanged: (days) {
            print('day of week: $days');
            widget.course.timeTable.daysOfWeek = days;
            // recalculate course day of week
            tryCalculateExpectedLessons();
          },
        ),
        Divider(),

        // 保存
        ElevatedButton(
          onPressed: () async {
            if (validateUserInput()) {
              await tryCalculateExpectedLessons();
              coursesController.upsertCourse(
                widget.course,
                // todo, make a preview of the lessons
                reCalculateLessonsForEachSingle(currentLessons, widget.course),
              );
              Get.back();
            }
          },
          child: Text('保存课程信息'),
        ),
        Divider(),

        // todo view course status

        // 课程安排预览
        if (viewCurrentFutureLessons.value)
          DynamicLessonList(
            title: "当前计划中，未开始的课程 (${notStartedLessons.length})",
            course: widget.course,
            lessons: notStartedLessons,
          ),
        if (viewExpectedFutureLessons.value)
          DynamicLessonList(
            title: "修改后未来的课程 (${expectedLessons.length})",
            course: widget.course,
            lessons: expectedLessons,
            titleColor: Colors.red[300],
          ),
        Divider(),

        // dangerZone,
        ElevatedButton(
          // todo make it click twice to delete
          onPressed: () {
            coursesController.deleteCourse(widget.course.id);
            Get.back();
          },
          child: const Text('删除课程', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Future<void> tryCalculateExpectedLessons() async {
    if (validateUserInput()) {
      expectedLessons.value = reCalculateLessonsForEachSingle(currentLessons, widget.course);
      print('recalculated lessons: ${expectedLessons.length}');
      setState(() {
        viewExpectedFutureLessons.value = true;
        viewCurrentFutureLessons.value = false;
      });
    }
  }

  void updateDayOfWeek(DateTime date) {
    var dayOfWeek = getDayOfWeek(date);
    print('day of week: $dayOfWeek');
    dynamicDayOfWeek.value = [dayOfWeek];
    widget.course.timeTable.daysOfWeek = [dayOfWeek];
  }

  bool validateUserInput() {
    if (widget.course.name.isEmpty) {
      Get.snackbar('❌ 错误', '课程名称不能为空');
      return false;
    }
    if (widget.course.timeTable.daysOfWeek.isEmpty) {
      Get.snackbar('❌ 错误', '请选择星期几上课');
      return false;
    }
    switch (widget.course.pattern.type) {
      case PatternType.costClassTimeUnit:
        if (widget.course.groupId == null) {
          Get.snackbar('❌ 错误', '请选择课程组');
          return false;
        }
        break;
      case PatternType.eachSingleLesson:
        break;
    }
    if (widget.course.pattern.value <= 0) {
      Get.snackbar('❌ 错误', '课时/节数应该大于0');
      return false;
    }
    if (widget.course.timeTable.duration.inMinutes == 0) {
      Get.snackbar('❌ 错误', '课程时长不应该为0');
      return false;
    }
    return true;
  }

  List<Widget> _buildCourseGroupInfo() {
    return [
      _buildCourseGroupSelector(),
      if (coursesController.courseGroups.isNotEmpty)
        NumberInputWidget(
          title: NumberInputEnum.courseCostClassTimeUnit,
          initialValue: widget.course.pattern.value,
          onChanged: (value) {
            widget.course.pattern.value = value;
          },
        ),
    ];
  }

  List<Widget> _buildSingleCourseInfo() {
    return [
      NumberInputWidget(
        title: NumberInputEnum.courseLength,
        initialValue: widget.course.pattern.value,
        onChanged: (value) {
          widget.course.pattern.value = value;
        },
      ),
    ];
  }

  Widget _buildCourseGroupSelector() {
    if (coursesController.courseGroups.isEmpty) {
      return Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text('还没有课程组，请先创建课程组', style: Theme.of(context).textTheme.bodyMedium),
            ElevatedButton(
              child: Text('点击创建课程组', style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () async {
                // ignore: unused_local_variable
                final result = await Get.toNamed('/edit-course-group');
                // if (result == true) {
                // print('object');
                setState(() {});
                // }
              },
            ),
          ],
        ),
      );
    }
    var items = coursesController.courseGroups.map<DropdownMenuItem<String>>((CourseGroup group) {
      return DropdownMenuItem<String>(
        value: group.id,
        child: Text(group.name),
      );
    }).toList();
    // items.add(DropdownMenuItem<String>(
    //   value: null,
    //   child: Text('🚫不关联'),
    // ));

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
        child: Row(
          children: [
            Material(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                height: 32,
                width: 32,
                child: Center(
                  child: Icon(
                    Icons.bookmarks_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              // flex: 1,
              child: Text(
                '课程组',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Flexible(
              flex: 2,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 36),
                child: DropdownButton<String>(
                  value: widget.course.groupId,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      widget.course.groupId = newValue;
                    });
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                  items: items,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Lesson> reCalculateLessonsForEachSingle(List<Lesson> currentLessons, Course course) {
  var resultLessons = <Lesson>[];
  var nowTime = DateTime.now();
  var completedCount = 0;

  currentLessons.sort((a, b) => a.startTime.compareTo(b.startTime));
  for (var lesson in currentLessons) {
    // the past shall not be modified by this function
    if (lesson.status != LessonStatus.notStarted && lesson.endTime.isBefore(nowTime)) {
      resultLessons.add(lesson);
    }
    if (lesson.status != LessonStatus.notStarted && lesson.status != LessonStatus.canceled) {
      completedCount++;
    }
  }
  var futureCount = course.pattern.value.toInt() - completedCount;

  int generateCount = 0;
  DateTime courseDate = resultLessons.isEmpty ? course.timeTable.startDate : resultLessons.last.endTime;
  while (generateCount < futureCount) {
    if (course.timeTable.daysOfWeek.contains(getDayOfWeek(courseDate))) {
      var startTime = courseDate
          .copyWith(hour: course.timeTable.lessonStartTime.hour, minute: course.timeTable.lessonStartTime.minute)
          .toUtc();
      var endTime = courseDate
          .copyWith(hour: course.timeTable.lessonStartTime.hour, minute: course.timeTable.lessonStartTime.minute)
          .add(course.timeTable.duration)
          .toUtc();
      resultLessons.add(Lesson(
        id: currentLessons.firstWhereOrNull((element) => element.startTime == startTime)?.id ?? const Uuid().v4(),
        name: "${course.name} @ ${resultLessons.length + 1}",
        user: course.user,
        courseId: course.id,
        startTime: startTime,
        endTime: endTime,
        status: LessonStatus.notStarted,
      ));
      generateCount++;
    }
    courseDate = courseDate.add(const Duration(days: 1));
  }

  return resultLessons;
}
