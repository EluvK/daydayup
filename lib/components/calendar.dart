import 'dart:collection';

import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarTable();
  }
}

class CalendarTable extends StatefulWidget {
  const CalendarTable({super.key});

  @override
  State<CalendarTable> createState() => _CalendarTableState();
}

class _CalendarTableState extends State<CalendarTable> {
  late final ValueNotifier<List<Lesson>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime _selectedDay = DateTime.now();
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  // RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  // DateTime? _rangeStart;
  // DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDays.add(_focusedDay.value);
    // todo
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  // bool get canClearSelection => _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  List<Lesson> _getEventsForDay(DateTime day) {
    // return kEvents[day] ?? [];
    return [];
  }

  // List<Lesson> _getEventsForDays(Iterable<DateTime> days) {
  //   return [
  //     for (final d in days) ..._getEventsForDay(d),
  //   ];
  // }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print('selectedDay: $selectedDay, focusedDay: $focusedDay');
    print('current selectedDay: $_selectedDay');
    setState(() {
      if (_selectedDay != selectedDay) {
        _selectedDay = selectedDay;
      }

      _focusedDay.value = focusedDay;
      // _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });
    // _selectedEvents.value = _getEventsForDays(_selectedDays);
    _selectedEvents.value = _getEventsForDay(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    var body = Column(
      children: [
        // todo add a filter
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, _) {
            return _CalendarHeader(
              focusedDay: value,
              // clearButtonVisible: canClearSelection,
              onTodayButtonTap: () {
                setState(() => _focusedDay.value = DateTime.now());
              },
              onClearButtonTap: () {
                setState(() {
                  // _rangeStart = null;
                  // _rangeEnd = null;
                  _selectedDays.clear();
                  _selectedEvents.value = [];
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
          focusedDay: _focusedDay.value,
          headerVisible: false,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.twoWeeks: '2 weeks',
          },
          // selectedDayPredicate: (day) => _selectedDays.contains(day),
          selectedDayPredicate: (day) => _selectedDay == day,
          // rangeStartDay: _rangeStart,
          // rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          // rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          holidayPredicate: (day) {
            // Every 20th day of the month will be treated as a holiday
            // return day.day == 20;
            return false;
          },
          onDaySelected: _onDaySelected,
          // onRangeSelected: _onRangeSelected,
          onCalendarCreated: (controller) => _pageController = controller,
          onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Lesson>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => print('${value[index]}'),
                      title: Text('${value[index]}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
    return body;
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  // final bool clearButtonVisible;

  const _CalendarHeader({
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    // required this.clearButtonVisible,
  });

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: const TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          // if (clearButtonVisible)
          //   IconButton(
          //     icon: const Icon(Icons.clear, size: 20.0),
          //     visualDensity: VisualDensity.compact,
          //     onPressed: onClearButtonTap,
          //   ),
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
