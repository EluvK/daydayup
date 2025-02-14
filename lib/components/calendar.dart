import 'dart:collection';

import 'package:daydayup/components/lesson.dart';
import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日历'),
      ),
      body: const CalendarTable(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add your onPressed code here!
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.add),
      // ),
    );
    // return CalendarTable();
  }
}

class CalendarTable extends StatefulWidget {
  const CalendarTable({super.key});

  @override
  State<CalendarTable> createState() => _CalendarTableState();
}

class _CalendarTableState extends State<CalendarTable> {
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(keepOnlyDay(DateTime.now()));
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final coursesController = Get.find<CoursesController>();

  @override
  void initState() {
    super.initState();

    _selectedDays.add(_focusedDay.value);
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    super.dispose();
  }

  bool get canClearSelection => _rangeStart != null || _rangeEnd != null;

  bool get canToggleOnRange => _rangeSelectionMode != RangeSelectionMode.toggledOn;

  List<Lesson> _getEventsForDay(DateTime day) {
    return coursesController.eachDateLessons[utc2LocalDay(day)] ?? [];
  }

  // List<Lesson> _getEventsForRange(DateTime start, DateTime end) {
  //   final days = daysInRange(start, end);
  //   return [
  //     for (final d in days) ..._getEventsForDay(d),
  //   ];
  // }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print('_onDaySelected: $selectedDay, focusedDay: $focusedDay');
    setState(() {
      _selectedDays.clear();
      _selectedDays.add(utc2LocalDay(selectedDay));
      _focusedDay.value = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    print('_onRangeSelected: $start, $end, $focusedDay');
    if (start != null) {
      start = utc2LocalDay(start);
    }
    if (end != null) {
      end = utc2LocalDay(end);
    }
    setState(() {
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _selectedDays.clear();
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedDays.addAll(daysInRange(start, end));
    } else if (start != null) {
      _selectedDays.add(start);
    } else if (end != null) {
      _selectedDays.add(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, _) {
            return _CalendarHeader(
              focusedDay: value,
              onTodayButtonTap: () {
                setState(() => _focusedDay.value = DateTime.now());
              },
              clearButtonVisible: canClearSelection,
              onClearButtonTap: () {
                setState(() {
                  // reset the selected day
                  _onDaySelected(_focusedDay.value, _focusedDay.value);
                });
              },
              toggleOnRangeVisible: canToggleOnRange,
              onToggleOnRangeTap: () {
                setState(() {
                  _onRangeSelected(_selectedDays.firstOrNull, _selectedDays.firstOrNull, _focusedDay.value);
                });
              },
              onLeftArrowTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              onRightArrowTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            );
          },
        ),
        TableCalendar<Lesson>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          focusedDay: _focusedDay.value,
          headerVisible: false,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.twoWeeks: '2 weeks',
          },
          calendarBuilders: CalendarBuilders<Lesson>(
            // change the dot style under calendar day
            singleMarkerBuilder: (context, day, event) {
              return Container(
                height: 6.0,
                width: 6.0,
                margin: const EdgeInsets.all(0.5),
                decoration: BoxDecoration(
                  // provide your own condition here
                  color: coursesController.courses.firstWhere((element) => element.id == event.courseId).color,
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          selectedDayPredicate: (day) => _selectedDays.contains(day),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          holidayPredicate: (day) {
            // Every 20th day of the month will be treated as a holiday
            // return day.day == 20;
            return false;
          },
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          onCalendarCreated: (controller) => _pageController = controller,
          onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
        ),
        const SizedBox(height: 8.0),
        Divider(),
        // ? maybe support range selection
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              (_selectedDays.length == 1)
                  ? DateFormat.MMMEd().format(_selectedDays.first) // selected one day
                  : ((_rangeStart != null && _rangeEnd != null)
                      ? '${DateFormat.MMMEd().format(_rangeStart!)} - ${DateFormat.MMMEd().format(_rangeEnd!)}' // selected full range
                      : (_rangeStart != null || _rangeEnd != null)
                          ? '... - ${DateFormat.MMMEd().format(_rangeStart!)} - ...' // selected one side of range
                          : '点击日期查看日程'), // no selection
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        Obx(
          () {
            var lists = _selectedDays
                .map((e) => coursesController.eachDateLessons[e] ?? [])
                .expand((element) => element)
                .toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                var lesson = lists[index];
                var course = coursesController.courses.firstWhere((element) => element.id == lesson.courseId);
                return LessonTile(
                  course: course,
                  lesson: lesson,
                  showDate: _rangeSelectionMode == RangeSelectionMode.toggledOn,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;
  final VoidCallback onToggleOnRangeTap;
  final bool toggleOnRangeVisible;

  const _CalendarHeader({
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
    required this.onToggleOnRangeTap,
    required this.toggleOnRangeVisible,
  });

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          Text(
            headerText,
            style: const TextStyle(fontSize: 26.0),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          if (clearButtonVisible)
            IconButton(
              icon: const Icon(Icons.clear, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          if (toggleOnRangeVisible)
            IconButton(
              icon: const Icon(Icons.compare_arrows, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onToggleOnRangeTap,
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}
