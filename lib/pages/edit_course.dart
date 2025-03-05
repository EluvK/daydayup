import 'package:daydayup/components/lesson.dart';
import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/color_picker.dart';
import 'package:daydayup/utils/course_arrangement.dart';
import 'package:daydayup/utils/dangerous_zone.dart';
import 'package:daydayup/utils/day_of_week_picker.dart';
import 'package:daydayup/utils/double_click.dart';
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
          weekType: WeekType.weekly,
          daysOfWeek: [],
          lessonStartTime: DateTime.now(),
          duration: Duration(hours: 2),
        ),
        pattern: Pattern(type: PatternType.eachSingleLesson, value: 10),
        color: RandomColor.getColorObject(Options(luminosity: Luminosity.dark)),
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseInner(course: course, isCreateNew: true),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditCourseInner(course: coursesController.getCourse(widget.courseId!), isCreateNew: false),
      );
    }
  }
}

class _EditCourseInner extends StatefulWidget {
  const _EditCourseInner({required this.course, required this.isCreateNew});
  final Course course;
  final bool isCreateNew;

  @override
  State<_EditCourseInner> createState() => __EditCourseInnerState();
}

class __EditCourseInnerState extends State<_EditCourseInner> {
  final settingController = Get.find<SettingController>();
  final coursesController = Get.find<CoursesController>();

  late Course editCourse;

  late final List<Lesson> currentLessons = coursesController.getCourseLessons(widget.course.id);

  final RxMap<Course, List<Lesson>> expectedLessonsMap = <Course, List<Lesson>>{}.obs;
  final RxMap<Course, List<Lesson>> createNewViewLessonsMap = <Course, List<Lesson>>{}.obs;

  final RxBool viewCurrentFutureLessons = true.obs;
  final RxBool viewExpectedFutureLessons = false.obs;

  @override
  void initState() {
    editCourse = widget.course.clone();
    if (widget.isCreateNew) {
      updateDayOfWeek(editCourse.timeTable.startDate);
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
            editCourse.name = value;
          },
          initialValue: editCourse.name,
          onFocusChange: (isFocus) {
            if (!isFocus) {
              tryCalculateExpectedLessons();
            }
          },
        ),
        TextInputWidget(
          title: InputTitleEnum.anyDescription,
          onChanged: (value) {
            editCourse.description = value;
          },
          initialValue: editCourse.description,
          optional: true,
        ),
        UserPicker(
          onChanged: (selectedUserIds) {
            print("onChanged: $selectedUserIds");
            editCourse.user = settingController.users.firstWhere((element) => element.id == selectedUserIds.first);
            tryCalculateExpectedLessons();
          },
          candidateUsers: settingController.users,
          initialUser: [editCourse.user],
        ),
        ColorPickerWidget(
          onChanged: (color) {
            editCourse.color = color;
            tryCalculateExpectedLessons();
          },
          initialColor: editCourse.color,
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
                  selected: {editCourse.pattern.type},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<PatternType> newSelection) {
                    editCourse.pattern.type = newSelection.first;
                    if (editCourse.pattern.type == PatternType.costClassTimeUnit) {
                      editCourse.pattern.value = 1;
                    } else {
                      editCourse.pattern.value = 10;
                    }

                    setState(() {});
                    // tryCalculateExpectedLessons(); // todo uncomment this line
                  },
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity(horizontal: -1, vertical: -2),
                  ),
                ),
              ],
            )),
        if (editCourse.pattern.type == PatternType.costClassTimeUnit)
          for (var i in _buildCourseGroupInfo()) i,
        if (editCourse.pattern.type == PatternType.eachSingleLesson)
          for (var i in _buildSingleCourseInfo()) i,
        Divider(),

        // 时间周期
        Align(alignment: Alignment.topLeft, child: Text('时间周期')),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseFirstDayTime,
          onChange: (date) {
            editCourse.timeTable.startDate = date.toLocal();
            setState(() {
              updateDayOfWeek(date);
            });
            tryCalculateExpectedLessons();
          },
          initialValue: editCourse.timeTable.startDate,
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseStartTime,
          onChange: (date) {
            editCourse.timeTable.lessonStartTime = date.toLocal();
            // recalculate course end time
            setState(() {});
            tryCalculateExpectedLessons();
          },
          initialValue: editCourse.timeTable.lessonStartTime,
        ),
        DurationPickerWidget(
          initialValue: editCourse.timeTable.duration,
          onChange: (duration) {
            print('get duration: $duration');
            editCourse.timeTable.duration = duration;
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
            editCourse.timeTable.duration = date.toLocal().difference(editCourse.timeTable.lessonStartTime);
            print('course length: ${editCourse.timeTable.duration}');
            setState(() {});
            tryCalculateExpectedLessons();
          },
          initialValue: editCourse.timeTable.lessonStartTime.add(editCourse.timeTable.duration),
        ),
        DayOfWeekPickerWidget(
          initialWeekType: editCourse.timeTable.weekType,
          initialSelectedDays: editCourse.timeTable.daysOfWeek,
          onChanged: (type, days) {
            print('day of week: $days');
            editCourse.timeTable.weekType = type;
            editCourse.timeTable.daysOfWeek = days;
            // recalculate course day of week
            tryCalculateExpectedLessons();
          },
        ),
        Divider(),

        // 保存
        ElevatedButton(
          onPressed: () async {
            if (validateUserInput(showError: true)) {
              await tryCalculateExpectedLessons();

              switch (editCourse.pattern.type) {
                case PatternType.eachSingleLesson:
                  List<Lesson> newLessons = reCalculateLessonsForEachSingle(currentLessons, editCourse);
                  await coursesController.upsertCourse(editCourse, newLessons);
                  break;
                case PatternType.costClassTimeUnit:
                  Map<Course, List<Lesson>> allNewLessons = reCalculateLessonsForTimeUnit(editCourse);
                  for (var course in allNewLessons.keys) {
                    await coursesController.upsertCourse(course, allNewLessons[course]!);
                  }
                  break;
              }
              Get.offAllNamed('/');
              Get.toNamed('/view-course', arguments: [editCourse.id]);
            }
          },
          child: Text('保存课程信息'),
        ),
        Divider(),

        // 新课程预览 - self
        if (widget.isCreateNew)
          for (var entry in createNewViewLessonsMap.entries.where((entry) => entry.key.name == editCourse.name))
            DynamicLessonList(
              title: "该课堂预览 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value,
              titleColor: Colors.red[300],
              editable: false,
            ),
        // 新课程预览 - others (if any in the same group)
        if (widget.isCreateNew && editCourse.pattern.type == PatternType.costClassTimeUnit)
          for (var entry in createNewViewLessonsMap.entries.where((entry) => entry.key.name != editCourse.name))
            DynamicLessonList(
              title: "组内其它课堂预览 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value,
              titleColor: Colors.red[300],
              editable: false,
            ),

        // 修改前课程安排预览（修改后不再可见）
        if (viewCurrentFutureLessons.value)
          DynamicLessonList(
            title: "该课堂排课",
            course: editCourse,
            lessons: currentLessons.where((element) => element.status == LessonStatus.notStarted).toList(),
          ),

        if (viewExpectedFutureLessons.value)
          for (var entry in expectedLessonsMap.entries.where((entry) => entry.key.name == editCourse.name))
            DynamicLessonList(
              title: "修改后该课堂排课 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value.where((lesson) => lesson.status == LessonStatus.notStarted).toList(),
              titleColor: Colors.red[300],
            ),
        if (viewExpectedFutureLessons.value && editCourse.pattern.type == PatternType.costClassTimeUnit)
          for (var entry in expectedLessonsMap.entries.where((entry) => entry.key.name != editCourse.name))
            DynamicLessonList(
              title: "修改后其它课堂排课 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value.where((lesson) => lesson.status == LessonStatus.notStarted).toList(),
              titleColor: Colors.red[300],
            ),

        // 已完成课程
        if (!widget.isCreateNew)
          DynamicLessonList(
            title: "已结束课堂",
            course: editCourse,
            lessons: currentLessons
                .where(
                    (element) => element.status != LessonStatus.notStarted && element.endTime.isBefore(DateTime.now()))
                .toList(),
          ),

        Divider(),

        if (!widget.isCreateNew)
          DangerousZone(children: [
            Text("    删除课程将同时删除课程下的所有课堂记录。\n"),
            DoubleClickButton(
              buttonBuilder: (onPressed) => ElevatedButton(
                onPressed: onPressed,
                child: const Text('删除课程', style: TextStyle(color: Colors.red)),
              ),
              onDoubleClick: () async {
                await coursesController.deleteCourse(editCourse.id);
                Get.offAllNamed('/');
              },
              firstClickHint: "删除课程",
            ),
          ]),
      ],
    );
  }

  Future<void> tryCalculateExpectedLessons() async {
    if (!validateUserInput()) return;
    if (widget.isCreateNew) {
      switch (editCourse.pattern.type) {
        case PatternType.eachSingleLesson:
          createNewViewLessonsMap.value = {editCourse: reCalculateLessonsForEachSingle(currentLessons, editCourse)};
          break;
        case PatternType.costClassTimeUnit:
          createNewViewLessonsMap.value = reCalculateLessonsForTimeUnit(editCourse);

          break;
      }
      setState(() {
        viewCurrentFutureLessons.value = false;
        viewExpectedFutureLessons.value = false;
      });
      return;
    }
    switch (editCourse.pattern.type) {
      case PatternType.eachSingleLesson:
        expectedLessonsMap.value = {editCourse: reCalculateLessonsForEachSingle(currentLessons, editCourse)};
        break;
      case PatternType.costClassTimeUnit:
        expectedLessonsMap.value = reCalculateLessonsForTimeUnit(editCourse);
        break;
    }
    setState(() {
      viewExpectedFutureLessons.value = true;
      viewCurrentFutureLessons.value = false;
    });
  }

  void updateDayOfWeek(DateTime date) {
    var dayOfWeek = getDayOfWeek(date);
    print('day of week: $dayOfWeek');
    if (editCourse.timeTable.daysOfWeek.contains(dayOfWeek)) {
      return;
    }
    editCourse.timeTable.daysOfWeek.add(dayOfWeek);
  }

  bool validateUserInput({bool showError = false}) {
    if (editCourse.name.isEmpty) {
      if (showError) Get.snackbar('❌ 错误', '课程名称不能为空');
      return false;
    }
    // if (editCourse.timeTable.daysOfWeek.isEmpty) {
    //   if (showError) Get.snackbar('❌ 错误', '请选择星期几上课');
    //   return false;
    // }
    switch (editCourse.pattern.type) {
      case PatternType.costClassTimeUnit:
        if (editCourse.groupId == null) {
          if (showError) Get.snackbar('❌ 错误', '请选择课程组');
          return false;
        }
        break;
      case PatternType.eachSingleLesson:
        break;
    }
    if (editCourse.pattern.value <= 0) {
      if (showError) Get.snackbar('❌ 错误', '课时/节数应该大于0');
      return false;
    }
    if (editCourse.timeTable.duration.inMinutes == 0) {
      if (showError) Get.snackbar('❌ 错误', '课程时长不应该为0');
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
          initialValue: editCourse.pattern.value,
          onChanged: (value) {
            editCourse.pattern.value = value;
          },
          onFocusChange: (isFocus) {
            if (!isFocus) {
              tryCalculateExpectedLessons();
            }
          },
        ),
    ];
  }

  List<Widget> _buildSingleCourseInfo() {
    return [
      NumberInputWidget(
        title: NumberInputEnum.courseLength,
        initialValue: editCourse.pattern.value,
        onChanged: (value) {
          editCourse.pattern.value = value;
        },
        onFocusChange: (isFocus) {
          if (!isFocus) {
            tryCalculateExpectedLessons();
          }
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
                child: Center(child: Icon(Icons.bookmarks_rounded, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              // flex: 1,
              child: Text('课程组', style: Theme.of(context).textTheme.bodyMedium),
            ),
            Flexible(
              flex: 2,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 36),
                child: DropdownButton<String>(
                  value: editCourse.groupId,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      editCourse.groupId = newValue;
                    });
                    tryCalculateExpectedLessons();
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
