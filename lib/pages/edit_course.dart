import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/color_picker.dart';
import 'package:daydayup/utils/dangerous_zone.dart';
import 'package:daydayup/utils/day_of_week_picker.dart';
import 'package:daydayup/utils/double_click.dart';
import 'package:daydayup/utils/lesson_preview.dart';
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
            if (!isFocus) setState(() {});
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
            setState(() {});
          },
          candidateUsers: settingController.users,
          initialUser: [editCourse.user],
        ),
        ColorPickerWidget(
          onChanged: (color) {
            editCourse.color = color;
            setState(() {});
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
          },
          initialValue: editCourse.timeTable.startDate,
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseStartTime,
          onChange: (date) {
            editCourse.timeTable.lessonStartTime = date.toLocal();
            setState(() {});
          },
          initialValue: editCourse.timeTable.lessonStartTime,
        ),
        DurationPickerWidget(
          initialValue: editCourse.timeTable.duration,
          onChange: (duration) {
            print('get duration: $duration');
            editCourse.timeTable.duration = duration;
            setState(() {});
          },
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.courseEndTime,
          onChange: (date) {
            print('set end time: $date');
            editCourse.timeTable.duration = date.toLocal().difference(editCourse.timeTable.lessonStartTime);
            print('course length: ${editCourse.timeTable.duration}');
            setState(() {});
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
            setState(() {});
          },
        ),
        Divider(),

        // 保存
        ElevatedButton(
          onPressed: () async {
            var check = validateUserInputResponse();
            if (check.isNotEmpty) {
              Get.snackbar('❌ 错误', check);
              return;
            } else {
              if (viewExpectedLesson(widget.course, editCourse, null, null)) {
                print('on save: editCourse:$editCourse');
                Map<Course, List<Lesson>> expectedLessonsMap;
                try {
                  expectedLessonsMap = reCalCourseLessonsMap(widget.course, editCourse, null).getOrThrow();
                } on CalculateError {
                  Get.snackbar('错误', '生成课程出错');
                  return;
                } catch (e) {
                  Get.snackbar('错误', '生成课程出错 - 未知');
                  return;
                }
                for (var entry in expectedLessonsMap.entries) {
                  print('on insert db: ${entry.key} ${entry.value.length}');
                  await coursesController.upsertCourse(entry.key, entry.value);
                }
              }
              Get.offAllNamed('/');
              Get.toNamed('/view-course', arguments: [editCourse.id]);
            }
          },
          child: Text('保存课程信息'),
        ),
        Divider(),

        LessonPreview(
          thisCourse: widget.isCreateNew ? editCourse : widget.course,
          editedCourse: editCourse,
          thisLesson: null,
          editedLesson: null,
          validateUserInputFunc: validateUserInputResponse,
          isCreateNew: widget.isCreateNew,
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

  void updateDayOfWeek(DateTime date) {
    var newDayOfWeek = getDayOfWeek(date);
    print('updateDayOfWeek: $newDayOfWeek');
    if (editCourse.timeTable.daysOfWeek.contains(newDayOfWeek)) {
      return;
    }
    editCourse.timeTable.daysOfWeek = [newDayOfWeek];
    // editCourse.timeTable.daysOfWeek.clear();
    // editCourse.timeTable.daysOfWeek.add(newDayOfWeek);
  }

  String validateUserInputResponse() {
    if (editCourse.name.isEmpty) {
      return '课程名称不能为空';
    }
    // if (editCourse.timeTable.daysOfWeek.isEmpty) {
    //   return '请选择星期几上课';
    // }
    switch (editCourse.pattern.type) {
      case PatternType.costClassTimeUnit:
        if (editCourse.groupId == null) {
          return '请选择课程组';
        }
        break;
      case PatternType.eachSingleLesson:
        break;
    }
    if (editCourse.pattern.value <= 0) {
      return '课时/节数应该大于0';
    }
    if (editCourse.timeTable.duration.inMinutes == 0) {
      return '课程时长不应该为0';
    }
    return '';
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
            if (!isFocus) setState(() {});
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
          if (!isFocus) setState(() {});
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
