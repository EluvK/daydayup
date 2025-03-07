import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:flutter/material.dart';

class DayOfWeekPickerWidget extends StatelessWidget {
  const DayOfWeekPickerWidget({
    super.key,
    required this.initialWeekType,
    required this.initialSelectedDays,
    required this.onChanged,
  });

  final WeekType initialWeekType;
  final List<String> initialSelectedDays;
  final void Function(WeekType, List<String>) onChanged;

  @override
  Widget build(BuildContext context) {
    List<String> selectedDays = initialSelectedDays;
    WeekType weekType = initialWeekType;
    final TimeTitleEnum title = TimeTitleEnum.dayOfWeek;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          children: [
            Row(
              children: [
                Material(
                  color: title.color,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: Center(child: Icon(title.icon, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // flex: 1,
                  child: Text(
                    "${concatSelectedDays(weekType, selectedDays)}上课",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton(
                  segments: [
                    ButtonSegment<WeekType>(value: WeekType.weekly, label: Text('每周')),
                    ButtonSegment<WeekType>(value: WeekType.biWeekly, label: Text('隔周')),
                  ],
                  selected: {weekType},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<WeekType> selected) {
                    weekType = selected.first;
                    onChanged(weekType, selectedDays);
                  },
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity(horizontal: -1, vertical: -2),
                  ),
                ),
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
                      onChanged(weekType, selectedDays);
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

String concatSelectedDays(WeekType weekType, List<String> selectedDays) {
  if (selectedDays.isEmpty) {
    return '无安排';
  }
  var days = selectedDays.length == 7 ? '每天' : selectedDays.join('、');
  return '${weekType == WeekType.biWeekly ? '每两周' : '每周'}|$days';
}
