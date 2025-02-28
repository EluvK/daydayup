import 'package:daydayup/components/lesson.dart';
import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/color_picker.dart';
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

  final RxList<String> dynamicDayOfWeek = <String>[].obs;

  late final List<Lesson> currentLessons = coursesController.getCourseLessons(widget.course.id);
  late final List<Lesson> notStartedLessons =
      currentLessons.where((element) => element.status == LessonStatus.notStarted).toList();

  final RxList<Lesson> expectedLessons = <Lesson>[].obs;
  final RxList<Lesson> createNewViewLessons = <Lesson>[].obs;

  final RxMap<Course, List<Lesson>> expectedLessonsMap = <Course, List<Lesson>>{}.obs;
  final RxMap<Course, List<Lesson>> createNewViewLessonsMap = <Course, List<Lesson>>{}.obs;

  final RxBool viewCurrentFutureLessons = true.obs;
  final RxBool viewExpectedFutureLessons = false.obs;

  @override
  void initState() {
    editCourse = widget.course.clone();
    if (widget.isCreateNew) {
      updateDayOfWeek(editCourse.timeTable.startDate);
    } else {
      dynamicDayOfWeek.value = editCourse.timeTable.daysOfWeek;
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
          initialSelectedDays: dynamicDayOfWeek,
          onChanged: (days) {
            print('day of week: $days');
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

        // todo view course status

        // 新课程预览 - 单课模式
        if (widget.isCreateNew && editCourse.pattern.type == PatternType.eachSingleLesson)
          DynamicLessonList(
            title: "课堂列表预览",
            course: editCourse,
            lessons: createNewViewLessons,
            titleColor: Colors.red[300],
            editable: false,
          ),
        // 新课程预览 - 课程组模式 - self
        if (widget.isCreateNew && editCourse.pattern.type == PatternType.costClassTimeUnit)
          for (var entry in createNewViewLessonsMap.entries.where((entry) => entry.key.name == editCourse.name))
            DynamicLessonList(
              title: "该课堂预览 ${entry.key.name}",
              course: entry.key,
              lessons: entry.value,
              titleColor: Colors.red[300],
              editable: false,
            ),
        // 新课程预览 - 课程组模式 - others
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
            lessons: notStartedLessons,
          ),

        if (viewExpectedFutureLessons.value && editCourse.pattern.type == PatternType.eachSingleLesson)
          DynamicLessonList(
            title: "修改后该课堂排课",
            course: editCourse,
            lessons: expectedLessons.where((lesson) => lesson.status == LessonStatus.notStarted).toList(),
            titleColor: Colors.red[300],
          ),
        if (viewExpectedFutureLessons.value && editCourse.pattern.type == PatternType.costClassTimeUnit)
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

        Divider(),

        if (!widget.isCreateNew)
          DangerousZone(children: [
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
          createNewViewLessons.value = reCalculateLessonsForEachSingle(currentLessons, editCourse);
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
        expectedLessons.value = reCalculateLessonsForEachSingle(currentLessons, editCourse);
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
    dynamicDayOfWeek.value = [dayOfWeek];
    editCourse.timeTable.daysOfWeek = [dayOfWeek];
  }

  bool validateUserInput({bool showError = false}) {
    if (editCourse.name.isEmpty) {
      if (showError) Get.snackbar('❌ 错误', '课程名称不能为空');
      return false;
    }
    if (editCourse.timeTable.daysOfWeek.isEmpty) {
      if (showError) Get.snackbar('❌ 错误', '请选择星期几上课');
      return false;
    }
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

Map<Course, List<Lesson>> reCalculateLessonsForTimeUnit(Course course) {
  var coursesController = Get.find<CoursesController>();
  final courseGroupCourses = coursesController.getCourseGroupCourses(course.groupId!);
  final List<Course> editCourses = courseGroupCourses.map((e) => e.clone()).toList();

  if (editCourses.firstWhereOrNull((element) => element.id == course.id) == null) {
    editCourses.add(course.clone());
  } else {
    editCourses[editCourses.indexWhere((element) => element.id == course.id)] = course.clone();
  }
  final CourseGroup courseGroup = coursesController.getCourseGroup(course.groupId!);

  var currentCourseLessons = <Course, List<Lesson>>{};
  // update course information in editCourses
  for (var i = 0; i < editCourses.length; i++) {
    final courseId = editCourses[i].id;
    currentCourseLessons[editCourses[i]] = coursesController.getCourseLessons(courseId);
  }

  var nowTime = DateTime.now();
  // sort all entry in currentCourseLessons
  for (var courseGroupCourse in editCourses) {
    currentCourseLessons[courseGroupCourse]!.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // return result
  Map<Course, List<Lesson>> resultCourseLessons = {};
  Map<Course, int> courseCompletedCount = {};
  for (var courseGroupCourse in editCourses) {
    resultCourseLessons[courseGroupCourse] = [];
    courseCompletedCount[courseGroupCourse] = 0;
  }

  // the past shall not be modified by this function
  for (var eachCourse in editCourses) {
    for (var lesson in currentCourseLessons[eachCourse]!) {
      if (lesson.status != LessonStatus.notStarted || lesson.endTime.isBefore(nowTime)) {
        resultCourseLessons[eachCourse]!.add(lesson);
        print("add lesson ${lesson.name}, status ${lesson.status}, endTime: ${lesson.endTime}");
      }
      if (lesson.status == LessonStatus.finished || lesson.status == LessonStatus.notAttended) {
        courseCompletedCount[eachCourse] = courseCompletedCount[eachCourse]! + 1;
      }
    }
  }

  double generateCourseTimeUnitCost = 0;
  bool generateMore = true;
  DateTime courseDate = nowTime.toUtc();
  for (var eachCourse in editCourses) {
    if (resultCourseLessons[eachCourse]!.isEmpty) {
      courseDate = eachCourse.timeTable.startDate.isBefore(courseDate) ? eachCourse.timeTable.startDate : courseDate;
    }
  }
  courseDate = courseDate.toLocal();
  print('reCal start from: $courseDate');
  while (generateMore) {
    print('try generate for day: $courseDate');
    print('current unit : $generateCourseTimeUnitCost, ${courseGroup.restAmount - generateCourseTimeUnitCost}');
    if (courseGroup.restAmount <= generateCourseTimeUnitCost) {
      break;
    }
    generateMore = false;
    for (var eachCourse in editCourses) {
      // print('courseGroupCourse: ${courseGroupCourse.name}, cost: ${courseGroupCourse.pattern.value}');
      if (courseGroup.restAmount - generateCourseTimeUnitCost < eachCourse.pattern.value) {
        print('cant generate ${eachCourse.name} rest amount: ${courseGroup.restAmount - generateCourseTimeUnitCost}');
        continue;
      }
      generateMore = true;
    }
    for (var eachCourse in editCourses) {
      print(
          'each Course: ${eachCourse.name}, startDate: ${eachCourse.timeTable.startDate} | ${eachCourse.timeTable.daysOfWeek.contains(getDayOfWeek(courseDate))} | ${!eachCourse.timeTable.startDate.isAfter(courseDate)}');
      if (eachCourse.timeTable.daysOfWeek.contains(getDayOfWeek(courseDate)) &&
          !eachCourse.timeTable.startDate.isAfter(courseDate)) {
        var startTime = eachCourse.timeTable.lessonStartTime
            .toLocal()
            .copyWith(year: courseDate.year, month: courseDate.month, day: courseDate.day)
            .toUtc();
        var endTime = eachCourse.timeTable.lessonStartTime
            .toLocal()
            .copyWith(year: courseDate.year, month: courseDate.month, day: courseDate.day)
            .add(eachCourse.timeTable.duration)
            .toUtc();
        print("endTime: $endTime");
        if (resultCourseLessons[eachCourse]!.isNotEmpty &&
            resultCourseLessons[eachCourse]!.last.endTime.isAfter(endTime)) {
          // skip duplicate generate course
          continue;
        }
        Lesson? ifExistLesson =
            resultCourseLessons[eachCourse]!.firstWhereOrNull((element) => element.endTime == endTime);
        if (ifExistLesson != null) {
          print('skip exist lesson ${ifExistLesson.name} at endTime $endTime');
        } else {
          final name = "${eachCourse.name} @ ${courseCompletedCount[eachCourse]! + 1}";
          final status = endTime.isBefore(nowTime) ? LessonStatus.finished : LessonStatus.notStarted;
          resultCourseLessons[eachCourse]!.add(Lesson(
            id: currentCourseLessons[eachCourse]!.firstWhereOrNull((element) => element.startTime == startTime)?.id ??
                const Uuid().v4(),
            name: name,
            user: eachCourse.user,
            courseId: eachCourse.id,
            startTime: startTime,
            endTime: endTime,
            status: status,
          ));
          print("generate course $name end at $endTime status: $status");
          courseCompletedCount[eachCourse] = courseCompletedCount[eachCourse]! + 1;
          if (endTime.isAfter(nowTime)) {
            generateCourseTimeUnitCost += eachCourse.pattern.value;
          }
        }
      }
    }
    courseDate = courseDate.add(const Duration(days: 1));
  }

  return resultCourseLessons;
}

List<Lesson> reCalculateLessonsForEachSingle(List<Lesson> currentLessons, Course course) {
  var resultLessons = <Lesson>[];
  var nowTime = DateTime.now();
  var completedCount = 0;

  currentLessons.sort((a, b) => a.startTime.compareTo(b.startTime));
  for (var lesson in currentLessons) {
    // the past shall not be modified by this function
    if (lesson.status != LessonStatus.notStarted || lesson.endTime.isBefore(nowTime)) {
      resultLessons.add(lesson);
    }
    if (lesson.status == LessonStatus.finished || lesson.status == LessonStatus.notAttended) {
      completedCount++;
    }
  }

  DateTime courseDate = (resultLessons.isEmpty ? course.timeTable.startDate : nowTime).toLocal();
  print('reCal start from: $courseDate');
  while (completedCount < course.pattern.value.toInt()) {
    if (course.timeTable.daysOfWeek.contains(getDayOfWeek(courseDate))) {
      var startTime = course.timeTable.lessonStartTime
          .toLocal()
          .copyWith(year: courseDate.year, month: courseDate.month, day: courseDate.day)
          .toUtc();
      var endTime = course.timeTable.lessonStartTime
          .toLocal()
          .copyWith(year: courseDate.year, month: courseDate.month, day: courseDate.day)
          .add(course.timeTable.duration)
          .toUtc();
      Lesson? ifExistLesson = resultLessons.firstWhereOrNull((element) => element.endTime == endTime);
      if (ifExistLesson != null) {
        print('skip exist lesson ${ifExistLesson.name} at endTime $endTime');
      } else {
        resultLessons.add(Lesson(
          id: currentLessons.firstWhereOrNull((element) => element.startTime == startTime)?.id ?? const Uuid().v4(),
          name: "${course.name} @ ${completedCount + 1}",
          user: course.user,
          courseId: course.id,
          startTime: startTime,
          endTime: endTime,
          status: endTime.isBefore(nowTime) ? LessonStatus.finished : LessonStatus.notStarted,
        ));
        completedCount++;
      }
    }
    courseDate = courseDate.add(const Duration(days: 1));
  }

  return resultLessons;
}
