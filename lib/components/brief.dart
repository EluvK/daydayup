import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Brief extends StatelessWidget {
  const Brief({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日程'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BriefTable(),
      ),
    );
  }
}

class BriefTable extends StatefulWidget {
  const BriefTable({super.key});

  @override
  State<BriefTable> createState() => _BriefTableState();
}

class _BriefTableState extends State<BriefTable> {
  final coursesController = Get.find<CoursesController>();
  // late final todayLessons = coursesController.eachDateLessons[]

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // maybe add a user filter
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "今日: ${_today()}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        Divider(),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '本周: ${_thisWeek()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

DateTime _todayDate() {
  return keepOnlyDay(DateTime.now());
}

DateTime _thisWeekBeginDate() {
  return keepOnlyDay(DateTime.now().subtract(Duration(days: DateTime.now().weekday)));
}

DateTime _thisWeekEndDate() {
  return keepOnlyDay(DateTime.now().add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday)));
}

String _today() {
  return DateFormat.MMMEd().format(_todayDate());
}

String _thisWeek() {
  var from = DateFormat.MMMd().format(_thisWeekBeginDate());
  var to = DateFormat.MMMd().format(_thisWeekEndDate());
  return '$from - $to';
}
