import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';

class TimePickerWidget extends StatelessWidget {
  TimePickerWidget({
    super.key,
    required this.timeTitle,
    required this.pickerType,
    this.initialValue,
    this.onChange,
  });

  final TimeTitleEnum timeTitle;
  final DateTimePickerType pickerType;
  final DateTime? initialValue;
  final void Function(DateTime)? onChange;

  late final ValueNotifier<DateTime> date = ValueNotifier(initialValue ?? DateTime.now());

  @override
  Widget build(BuildContext context) {
    final controller = BoardDateTimeController();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await showBoardDateTimePicker(
            context: context,
            pickerType: pickerType,
            initialDate: date.value,
            options: BoardDateTimeOptions(
              languages: BoardPickerLanguages(
                today: '今天',
                tomorrow: '明天',
                yesterday: '昨天',
                now: '现在',
                locale: 'zh',
              ),
              startDayOfWeek: DateTime.monday,
              pickerFormat: PickerFormat.ymd,
              // boardTitle: 'Board Picker',
              // pickerSubTitles: BoardDateTimeItemTitles(year: 'year'),
              withSecond: DateTimePickerType.time == pickerType,
              customOptions: DateTimePickerType.time == pickerType
                  ? BoardPickerCustomOptions(
                      seconds: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
                    )
                  : null,
            ),
            // Specify if you want changes in the picker to take effect immediately.
            valueNotifier: date,
            controller: controller,
            onChanged: (value) {
              date.value = value;
              if (onChange != null) {
                onChange!(value);
              }
            },
          );
          if (result != null) {
            date.value = result;
            if (onChange != null) {
              onChange!(result);
            }
            print('result: $result');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Material(
                color: timeTitle.color,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: Icon(
                      timeTitle.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  timeTitle.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: date,
                builder: (context, data, _) {
                  return Text(
                    BoardDateFormat(pickerType.formatter(
                      withSecond: DateTimePickerType.time == pickerType,
                    )).format(data),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum TimeTitleEnum {
  courseTime,
  firstTime,
}

extension TimeTitleEnumExtension on TimeTitleEnum {
  String get title {
    switch (this) {
      case TimeTitleEnum.courseTime:
        return '课程时间';
      case TimeTitleEnum.firstTime:
        return '首次时间';
    }
  }

  IconData get icon {
    switch (this) {
      case TimeTitleEnum.courseTime:
        return Icons.schedule_rounded;
      case TimeTitleEnum.firstTime:
        return Icons.schedule_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TimeTitleEnum.courseTime:
        return Colors.pink;
      case TimeTitleEnum.firstTime:
        return Colors.pink;
    }
  }
}

extension DateTimePickerTypeExtension on DateTimePickerType {
  String get format {
    switch (this) {
      case DateTimePickerType.date:
        return 'yyyy/MM/dd';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return 'HH:mm';
    }
  }

  String formatter({bool withSecond = false}) {
    switch (this) {
      case DateTimePickerType.date:
        return 'yyyy/MM/dd';
      case DateTimePickerType.datetime:
        return 'yyyy/MM/dd HH:mm';
      case DateTimePickerType.time:
        return withSecond ? 'HH:mm:ss' : 'HH:mm';
    }
  }
}
