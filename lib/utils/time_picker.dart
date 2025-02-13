import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';

class TimePickerWidget extends StatelessWidget {
  TimePickerWidget({
    super.key,
    required this.timeTitle,
    this.initialValue,
    this.onChange,
  });

  final TimeTitleEnum timeTitle;
  final DateTime? initialValue;
  final void Function(DateTime)? onChange;

  late final DateTimePickerType pickerType = timeTitle.pickerType;
  late final ValueNotifier<DateTime> date = ValueNotifier(initialValue?.toLocal() ?? DateTime.now());

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
              withSecond: false,
              // withSecond: DateTimePickerType.time == pickerType,
              // customOptions: DateTimePickerType.time == pickerType
              //     ? BoardPickerCustomOptions(
              //         seconds: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
              //       )
              //     : null,
            ),
            // Specify if you want changes in the picker to take effect immediately.
            valueNotifier: date,
            controller: controller,
            onChanged: (value) {
              date.value = value;
              if (onChange != null) {
                onChange!(value.toUtc());
              }
            },
          );
          if (result != null) {
            date.value = result;
            if (onChange != null) {
              onChange!(result.toUtc());
            }
            print('result: $result');
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
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
                        // withSecond: DateTimePickerType.time == pickerType,
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
  courseFirstDayTime, // 首次日期
  courseStartTime, // 开始时间
  courseDuration, // 课程时长
  courseEndTime, // 结束时间
  dayOfWeek, // 星期几
  courseGroupBillAddTime, // 课程组账单添加时间
  lessonStartDateTime, // 课堂开始日期时间
  lessonEndDateTime, // 课堂结束日期时间
}

extension TimeTitleEnumExtension on TimeTitleEnum {
  String get title {
    switch (this) {
      case TimeTitleEnum.courseFirstDayTime:
        return '首次日期';
      case TimeTitleEnum.courseStartTime:
        return '开始时间';
      case TimeTitleEnum.courseDuration:
        return '课程时长';
      case TimeTitleEnum.courseEndTime:
        return '结束时间';
      case TimeTitleEnum.dayOfWeek:
        return '上课时间';
      case TimeTitleEnum.courseGroupBillAddTime:
        return '账单添加时间';
      case TimeTitleEnum.lessonStartDateTime:
        return '课堂开始时间';
      case TimeTitleEnum.lessonEndDateTime:
        return '课堂结束时间';
    }
  }

  IconData get icon {
    switch (this) {
      case TimeTitleEnum.courseFirstDayTime:
        return Icons.calendar_month;
      case TimeTitleEnum.courseStartTime:
        return Icons.vertical_align_top_rounded;
      case TimeTitleEnum.courseDuration:
        return Icons.schedule_rounded;
      case TimeTitleEnum.courseEndTime:
        return Icons.vertical_align_bottom_rounded;
      case TimeTitleEnum.dayOfWeek:
        return Icons.calendar_today;
      case TimeTitleEnum.courseGroupBillAddTime:
        return Icons.attach_money_rounded;
      case TimeTitleEnum.lessonStartDateTime:
        return Icons.vertical_align_top_rounded;
      case TimeTitleEnum.lessonEndDateTime:
        return Icons.vertical_align_bottom_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TimeTitleEnum.courseFirstDayTime:
        return Colors.pink;
      case TimeTitleEnum.courseStartTime:
        return Colors.green;
      case TimeTitleEnum.courseDuration:
        return Colors.pink;
      case TimeTitleEnum.courseEndTime:
        return Colors.green;
      case TimeTitleEnum.dayOfWeek:
        return Colors.blue;
      case TimeTitleEnum.courseGroupBillAddTime:
        return Colors.blue;
      case TimeTitleEnum.lessonStartDateTime:
        return Colors.green;
      case TimeTitleEnum.lessonEndDateTime:
        return Colors.green;
    }
  }

  DateTimePickerType get pickerType {
    switch (this) {
      case TimeTitleEnum.courseFirstDayTime:
        return DateTimePickerType.date;
      case TimeTitleEnum.courseStartTime:
        return DateTimePickerType.time;
      case TimeTitleEnum.courseDuration:
        // return DateTimePickerType.time; // not accurate description.
        throw Exception('DurationPickerWidget should be used for course duration');
      case TimeTitleEnum.courseEndTime:
        return DateTimePickerType.time;
      case TimeTitleEnum.dayOfWeek:
        throw Exception('DayOfWeekPickerWidget should be used for day of week');
      case TimeTitleEnum.courseGroupBillAddTime:
        return DateTimePickerType.datetime;
      case TimeTitleEnum.lessonStartDateTime:
        return DateTimePickerType.datetime;
      case TimeTitleEnum.lessonEndDateTime:
        return DateTimePickerType.datetime;
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

// Duration Picker
class DurationPickerWidget extends StatelessWidget {
  DurationPickerWidget({super.key, required this.initialValue, required this.onChange});

  final Duration initialValue;
  final void Function(Duration) onChange;

  final durationTitle = TimeTitleEnum.courseDuration;

  late final ValueNotifier<Duration> duration = ValueNotifier(initialValue);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final resultDateTime = await showBoardDateTimePickerForTime(
            context: context,
            initialDate: DateTime.now().copyWith(
              hour: initialValue.inHours,
              minute: initialValue.inMinutes.remainder(60),
            ),
            onResult: (BoardTimeResult result) {
              duration.value = Duration(hours: result.hour, minutes: result.minute);
              onChange(duration.value);
            },
            options: BoardDateTimeOptions(
              pickerSubTitles: BoardDateTimeItemTitles(
                hour: '小时',
                minute: '分钟',
              ),
              customOptions: BoardPickerCustomOptions(
                minutes: [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
              ),
            ),
          );
          if (resultDateTime != null) {
            duration.value = Duration(hours: resultDateTime.hour, minutes: resultDateTime.minute);
            onChange(duration.value);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
          child: Row(children: [
            Material(
              color: durationTitle.color,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 32,
                width: 32,
                child: Center(
                  child: Icon(
                    durationTitle.icon,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                durationTitle.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: duration,
              builder: (context, data, _) {
                return Text(
                  durationFormatter(data),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}

String durationFormatter(Duration duration) {
  return '${duration.inHours}小时${duration.inMinutes.remainder(60)}分钟';
}
