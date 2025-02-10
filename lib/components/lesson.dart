import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/user_picker.dart';
import 'package:flutter/material.dart';
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
        "${DateFormat.Hm().format(lesson.startTime.toLocal())} - ${DateFormat.Hm().format(lesson.endTime.toLocal())}";
    if (showDate) {
      time = "${DateFormat.yMd().format(lesson.startTime.toLocal())} $time";
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
          print(lesson.name);
        },
        child: Row(
          children: [
            Column(
              children: [
                if (showUser) UserAvatar(user: course.user, isSelected: false),
                SizedBox(height: 4),
                lessonStatusWidget(lesson),
              ],
            ),
            Expanded(
              child: ListTile(
                onTap: null,
                trailing: IconButton(
                  onPressed: () {
                    // todo
                    // view lesson?
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
}
