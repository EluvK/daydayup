// import 'package:daydayup/components/lesson.dart';
import 'package:flutter/material.dart';

class Brief extends StatefulWidget {
  const Brief({super.key});

  @override
  State<Brief> createState() => _BriefState();
}

class _BriefState extends State<Brief> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          // DynamicLessonList(title: '本日课程', course: course, lessons: lessons),
        ],
      ),
    );
  }
}
