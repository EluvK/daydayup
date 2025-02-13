import 'dart:math';

import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/user_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.course,
    required this.lesson,
    this.showDate = false,
    this.showUser = true,
  });

  final Course course;
  final Lesson lesson;
  final bool showDate;
  final bool showUser;

  @override
  Widget build(BuildContext context) {
    var time =
        "${DateFormat.Hm().format(lesson.startTime.toLocal())}-${DateFormat.Hm().format(lesson.endTime.toLocal())}";
    if (showDate) {
      time =
          "${DateFormat.yMd().format(lesson.startTime.toLocal())},${DateFormat.E().format(lesson.startTime.toLocal())},$time";
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: course.color.withAlpha(24),
        border: Border.all(width: 0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/view-lesson', arguments: [course.id, lesson.id]);
          print(lesson.name);
        },
        child: Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 60),
              child: Column(
                children: [
                  if (showUser) UserAvatar(user: course.user, isSelected: false),
                  SizedBox(height: 4),
                  lessonStatusWidget(lesson),
                ],
              ),
            ),
            Expanded(
              child: ListTile(
                onTap: null,
                trailing: IconButton(
                  onPressed: () {
                    Get.toNamed('/edit-lesson', arguments: [course.id, lesson.id]);
                  },
                  icon: Icon(Icons.edit),
                ),
                title: Text(lesson.name),
                subtitle: Text(time),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget lessonStatusWidget(Lesson lesson) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    margin: const EdgeInsets.only(left: 4),
    decoration: BoxDecoration(
      color: lesson.status.color,
      border: Border.all(width: 0.5, color: Colors.transparent),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      lesson.status.name,
      style: const TextStyle(color: Colors.white),
    ),
  );
}

class DynamicLessonList extends StatefulWidget {
  const DynamicLessonList({
    super.key,
    required this.title,
    required this.course,
    required this.lessons,
    this.titleColor,
  });

  final String title;
  final Course course;
  final List<Lesson> lessons;
  final Color? titleColor;

  @override
  State<DynamicLessonList> createState() => _DynamicLessonListState();
}

class _DynamicLessonListState extends State<DynamicLessonList> {
  int _maxShow = 5;

  void _loadMore() {
    setState(() {
      _maxShow += 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            '${widget.title} (${widget.lessons.length})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.titleColor,
                ),
          ),
        ),
        for (var i = 0; i < min(_maxShow, widget.lessons.length); i++)
          LessonTile(
            course: widget.course,
            lesson: widget.lessons[i],
            showDate: true,
            showUser: false,
          ),
        if (widget.lessons.length > _maxShow) ...[
          TextButton(
            onPressed: _loadMore,
            child: Text('显示更多课程 ...${widget.lessons.length - _maxShow} '),
          ),
        ],
      ],
    );
  }
}
