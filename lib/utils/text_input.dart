import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputWidget extends StatelessWidget {
  TextInputWidget({
    super.key,
    required this.title,
    required this.onChanged,
    required this.initialValue,
  });
  final focusNode = FocusNode();

  final InputTitleEnum title;
  final String initialValue;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                // flex: 1,
                child: Text(
                  title.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Flexible(
                flex: 2,
                child: TextField(
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
  courseName,
  courseDescription,
  userName,
}

extension InputTitleEnumExtension on InputTitleEnum {
  String get title {
    switch (this) {
      case InputTitleEnum.courseName:
        return '课程名称';
      case InputTitleEnum.courseDescription:
        return '课程描述';
      case InputTitleEnum.userName:
        return '用户名';
    }
  }

  IconData get icon {
    switch (this) {
      case InputTitleEnum.courseName:
        return Icons.class_;
      case InputTitleEnum.courseDescription:
        return Icons.description;
      case InputTitleEnum.userName:
        return Icons.person;
    }
  }

  Color get color {
    switch (this) {
      case InputTitleEnum.courseName:
        return Colors.red;
      case InputTitleEnum.courseDescription:
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
  });
  final focusNode = FocusNode();
  final NumberInputEnum title;
  final int initialValue;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(isDense: true),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  onChanged: (value) {
                    print(value);
                    onChanged(int.parse(value));
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
}

extension NumberInputEnumExtension on NumberInputEnum {
  String get title {
    switch (this) {
      case NumberInputEnum.courseLength:
        return '课程节数';
    }
  }

  IconData get icon {
    switch (this) {
      case NumberInputEnum.courseLength:
        return Icons.repeat_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NumberInputEnum.courseLength:
        return Colors.red;
    }
  }
}
