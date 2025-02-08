import 'package:flutter/material.dart';

class DayOfWeekPickerWidget extends StatefulWidget {
  const DayOfWeekPickerWidget({super.key, required this.initialSelectedDays, required this.onChanged});

  final List<String> initialSelectedDays;
  final void Function(List<String>) onChanged;

  @override
  State<DayOfWeekPickerWidget> createState() => _DayOfWeekPickerWidgetState();
}

class _DayOfWeekPickerWidgetState extends State<DayOfWeekPickerWidget> {
  List<String> selectedDays = [];

  @override
  void initState() {
    selectedDays = widget.initialSelectedDays;
    super.initState();
  }

  String concatSelectedDays() {
    return '每${selectedDays.join('、')}上课';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          children: [
            Row(
              children: [
                Material(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    height: 32,
                    width: 32,
                    child: Center(
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // flex: 1,
                  child: Text(
                    concatSelectedDays(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: daysOfWeek.map((day) {
                final bool isSelected = selectedDays.contains(day);
                final bool isWeekend = day == '周六' || day == '周日';
                return Material(
                  color: isSelected
                      ? Colors.blue
                      : isWeekend
                          ? Colors.blueGrey[300]
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      if (isSelected) {
                        selectedDays.remove(day);
                      } else {
                        selectedDays.add(day);
                      }
                      selectedDays.sort((a, b) => daysOfWeek.indexOf(a).compareTo(daysOfWeek.indexOf(b)));
                      setState(() {});
                      widget.onChanged(selectedDays);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(day),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> daysOfWeek = [
  '周一',
  '周二',
  '周三',
  '周四',
  '周五',
  '周六',
  '周日',
];

String getDayOfWeek(DateTime date) {
  return daysOfWeek[date.weekday - 1];
}
