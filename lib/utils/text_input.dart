import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                  decoration: InputDecoration(
                      // border: OutlineInputBorder(),
                      // labelText: 'Enter your username',
                      ),
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
