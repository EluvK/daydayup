import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditLessonPage extends StatelessWidget {
  const EditLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String? lessonId = args?[0];
    return Scaffold(
      appBar: AppBar(
        title: Text(lessonId == null ? 'New Lesson' : 'Edit Lesson'),
      ),
      body: EditLesson(lessonId: lessonId),
    );
  }
}

class EditLesson extends StatefulWidget {
  const EditLesson({super.key, required this.lessonId});
  final String? lessonId;

  @override
  State<EditLesson> createState() => _EditLessonState();
}

class _EditLessonState extends State<EditLesson> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
