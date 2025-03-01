import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/dangerous_zone.dart';
import 'package:daydayup/utils/double_click.dart';
import 'package:daydayup/utils/status_picker.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:daydayup/utils/view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class EditLessonPage extends StatelessWidget {
  const EditLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String? courseId = args?[0];
    final String? lessonId = args?[1];
    return Scaffold(
      appBar: AppBar(
        title: Text(lessonId == null ? '手动添加课堂单元' : '编辑课堂单元'),
      ),
      body: EditLesson(courseId: courseId, lessonId: lessonId),
    );
  }
}

class EditLesson extends StatefulWidget {
  const EditLesson({super.key, required this.courseId, required this.lessonId});
  final String? courseId;
  final String? lessonId;

  @override
  State<EditLesson> createState() => _EditLessonState();
}

class _EditLessonState extends State<EditLesson> {
  final coursesController = Get.find<CoursesController>();
  final settingController = Get.find<SettingController>();
  @override
  Widget build(BuildContext context) {
    if (widget.lessonId == null || widget.courseId == null) {
      Course? course = coursesController.courses.firstOrNull;
      var lesson = Lesson(
        courseId: course?.id ?? '',
        id: const Uuid().v4(),
        name: "${course?.name ?? ''} @ 手动添加",
        user: settingController.getDefaultUser(),
        startTime: DateTime.now().subtract(Duration(hours: 1)),
        endTime: DateTime.now(),
        status: LessonStatus.finished,
      );

      return _EditLessonInner(lesson: lesson, isCreateNew: true);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _EditLessonInner(
        lesson: coursesController.getCourseLesson(widget.courseId!, widget.lessonId!),
        isCreateNew: false,
      ),
    );
  }
}

class _EditLessonInner extends StatefulWidget {
  const _EditLessonInner({required this.lesson, required this.isCreateNew});
  final Lesson lesson;
  final bool isCreateNew;

  @override
  State<_EditLessonInner> createState() => __EditLessonInnerState();
}

class __EditLessonInnerState extends State<_EditLessonInner> {
  final coursesController = Get.find<CoursesController>();
  final settingController = Get.find<SettingController>();
  late final lessonOriginalStatus = widget.lesson.status;

  late Lesson editLesson;

  @override
  void initState() {
    editLesson = widget.lesson.clone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 基本信息
        Align(alignment: Alignment.topLeft, child: Text('基本信息')),
        if (!widget.isCreateNew)
          TextViewWidget(
              title: InputTitleEnumWrapper(InputTitleEnum.courseName),
              value: coursesController.getCourse(widget.lesson.courseId).name),
        if (widget.isCreateNew) _buildCourseSelector(),

        TextInputWidget(
          title: InputTitleEnum.lessonName,
          onChanged: (value) {
            editLesson.name = value;
          },
          initialValue: editLesson.name,
        ),
        StatusPicker(
          status: editLesson.status,
          onChange: (value) {
            setState(() {
              editLesson.status = value;
              if (value != lessonOriginalStatus) {
                // might need to update course arrangement
                reCalculateLessons(value, lessonOriginalStatus);
              }
            });
          },
        ),

        UserViewWidget(user: editLesson.user),
        Divider(),

        // 时间信息
        Align(alignment: Alignment.topLeft, child: Text('时间信息')),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.lessonStartDateTime,
          initialValue: editLesson.startTime,
          onChange: (value) {
            setState(() {
              editLesson.startTime = value;
              editLesson.endTime = value.add(coursesController.getCourse(editLesson.courseId).timeTable.duration);
            });
          },
        ),
        TimePickerWidget(
          timeTitle: TimeTitleEnum.lessonEndDateTime,
          initialValue: editLesson.endTime,
          onChange: (value) {
            editLesson.endTime = value;
          },
        ),
        Divider(),

        // 保存
        ElevatedButton(
          onPressed: () async {
            if (validateUserInput()) {
              await coursesController.upsertLesson(editLesson);
              Get.offAllNamed('/');
              Get.toNamed('/view-lesson', arguments: [editLesson.courseId, editLesson.id]);
            }
          },
          child: const Text('保存'),
        ),
        Divider(),

        // 课程影响预览

        if (!widget.isCreateNew)
          DangerousZone(children: [
            // Text('    删除课堂\n'),
            DoubleClickButton(
              buttonBuilder: (onPressed) => ElevatedButton(
                onPressed: onPressed,
                child: const Text('删除课堂'),
              ),
              onDoubleClick: () async {
                await coursesController.deleteLesson(editLesson.courseId, editLesson.id);
                Get.offAllNamed('/');
                Get.toNamed('/view-course', arguments: [editLesson.courseId]);
              },
              firstClickHint: '删除课堂',
            ),
          ]),
      ],
    );
  }

  Widget _buildCourseSelector() {
    var courses = coursesController.courses();
    if (courses.isEmpty) {
      return Align(
        alignment: Alignment.center,
        child: const Text('没有课程，请先去课程标签页面添加课程'),
      );
    }
    var items = courses.map((Course course) {
      return DropdownMenuItem<String>(
        value: course.id,
        child: Text(course.name),
      );
    }).toList();

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
        child: Row(
          children: [
            Material(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                height: 32,
                width: 32,
                child: Center(child: Icon(Icons.class_, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('课程', style: Theme.of(context).textTheme.bodyMedium),
            ),
            Flexible(
              flex: 2,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 36),
                child: DropdownButton<String>(
                  value: editLesson.courseId,
                  isExpanded: true,
                  onChanged: (String? value) {
                    setState(() {
                      if (value != null) {
                        var course = coursesController.getCourse(value);
                        var now = DateTime.now();
                        var startTime = course.timeTable.lessonStartTime
                            .toLocal()
                            .copyWith(year: now.year, month: now.month, day: now.day);
                        var endTime = startTime.add(course.timeTable.duration);
                        editLesson = editLesson.copyWith(
                          courseId: value,
                          name: "${course.name} @ 手动添加",
                          user: course.user,
                          startTime: startTime,
                          endTime: endTime,
                        );
                      }
                    });
                  },
                  items: items,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool validateUserInput() {
    final coursesController = Get.find<CoursesController>();
    final now = DateTime.now();
    if (editLesson.status == LessonStatus.notStarted && editLesson.endTime.isBefore(now)) {
      Get.snackbar('错误', '课程时间已过，状态不能为未完成');
      return false;
    }
    if (editLesson.startTime.isAfter(editLesson.endTime)) {
      Get.snackbar('错误', '开始时间不能晚于结束时间');
      return false;
    }
    if (editLesson.name.isEmpty) {
      Get.snackbar('错误', '课程名称不能为空');
      return false;
    }
    if (editLesson.id.isEmpty ||
        coursesController.courses.firstWhereOrNull((element) => element.id == editLesson.courseId) == null) {
      Get.snackbar('错误', '课程ID不能为空');
      return false;
    }

    return true;
  }

  void reCalculateLessons(LessonStatus newStatus, LessonStatus oldStatus) {
    // todo some work here.
    if (newStatus == oldStatus) {
      // clear work
      return;
    }
    // if (newStatus)
  }
}
