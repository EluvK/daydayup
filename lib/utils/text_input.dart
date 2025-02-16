import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputWidget extends StatelessWidget {
  TextInputWidget({
    super.key,
    required this.title,
    required this.onChanged,
    required this.initialValue,
    this.onFocusChange,
    this.autoFocus = false,
  });
  final focusNode = FocusNode();

  final InputTitleEnum title;
  final String initialValue;
  final void Function(bool)? onFocusChange;
  final bool autoFocus;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          focusNode.requestFocus();
        },
        onFocusChange: onFocusChange,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
          child: Row(
            children: [
              Material(
                color: title.color,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: Icon(
                      title.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // flex: 1,
                child: Text(
                  title.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Flexible(
                flex: 2,
                child: TextField(
                  autofocus: autoFocus,
                  focusNode: focusNode,
                  controller: TextEditingController(text: initialValue),
                  decoration: InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    print(value);
                    onChanged(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum InputTitleEnum {
  courseGroupName,
  courseName,
  lessonName,
  lessonStatus,
  anyDescription,
  userName,
}

extension InputTitleEnumExtension on InputTitleEnum {
  String get title {
    switch (this) {
      case InputTitleEnum.courseGroupName:
        return '课程组名称';
      case InputTitleEnum.courseName:
        return '课程名称';
      case InputTitleEnum.lessonName:
        return '课堂单元';
      case InputTitleEnum.lessonStatus:
        return '课堂状态';
      case InputTitleEnum.anyDescription:
        return '备注信息';
      case InputTitleEnum.userName:
        return '用户名';
    }
  }

  IconData get icon {
    switch (this) {
      case InputTitleEnum.courseGroupName:
        return Icons.bookmarks_rounded;
      case InputTitleEnum.courseName:
        return Icons.class_;
      case InputTitleEnum.lessonName:
        return Icons.play_lesson;
      case InputTitleEnum.lessonStatus:
        return Icons.star_rounded;
      case InputTitleEnum.anyDescription:
        return Icons.description;
      case InputTitleEnum.userName:
        return Icons.person;
    }
  }

  Color get color {
    switch (this) {
      case InputTitleEnum.courseGroupName:
        return Colors.orange;
      case InputTitleEnum.courseName:
        return Colors.red;
      case InputTitleEnum.lessonName:
        return Colors.blue;
      case InputTitleEnum.lessonStatus:
        return Colors.yellow;
      case InputTitleEnum.anyDescription:
        return Colors.blue;
      case InputTitleEnum.userName:
        return Colors.green;
    }
  }
}

class NumberInputWidget extends StatelessWidget {
  NumberInputWidget({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onChanged,
    this.onFocusChange,
  });
  final focusNode = FocusNode();
  final NumberInputEnum title;
  final double initialValue;
  final void Function(double) onChanged;
  final void Function(bool)? onFocusChange;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onFocusChange: onFocusChange,
        onTap: () {
          focusNode.requestFocus();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
          child: Row(
            children: [
              Material(
                color: title.color,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: Icon(
                      title.icon,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  title.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Flexible(
                flex: 1,
                child: TextField(
                  focusNode: focusNode,
                  controller: TextEditingController(text: initialValue.toString()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: InputDecoration(isDense: true),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  onChanged: (value) {
                    print(value);
                    try {
                      var result = double.parse(value);
                      onChanged(result);
                    } catch (e) {
                      return;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum NumberInputEnum {
  courseLength,
  courseCostClassTimeUnit,
  courseGroupBillAdd,
  courseGroupTimeUnit,
}

extension NumberInputEnumExtension on NumberInputEnum {
  String get title {
    switch (this) {
      case NumberInputEnum.courseLength:
        return '课程节数';
      case NumberInputEnum.courseCostClassTimeUnit:
        return '每节课时';
      case NumberInputEnum.courseGroupBillAdd:
        return '补充课时';
      case NumberInputEnum.courseGroupTimeUnit:
        return '剩余课时';
    }
  }

  IconData get icon {
    switch (this) {
      case NumberInputEnum.courseLength:
        return Icons.repeat_rounded;
      case NumberInputEnum.courseCostClassTimeUnit:
        return Icons.attach_money_rounded;
      case NumberInputEnum.courseGroupBillAdd:
        return Icons.more_time_rounded;
      case NumberInputEnum.courseGroupTimeUnit:
        return Icons.timer_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NumberInputEnum.courseLength:
        return Colors.red;
      case NumberInputEnum.courseCostClassTimeUnit:
        return Colors.red;
      case NumberInputEnum.courseGroupBillAdd:
        return Colors.red;
      case NumberInputEnum.courseGroupTimeUnit:
        return Colors.red;
    }
  }
}
