import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextViewWidget extends StatelessWidget {
  const TextViewWidget({super.key, required this.title, required this.value});

  final dynamic title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ViewWidget(
      title: title,
      value: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TimeViewWidget extends StatelessWidget {
  const TimeViewWidget({super.key, required this.title, required this.value, required this.formatter});

  final dynamic title;
  final DateTime value;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    return ViewWidget(
      title: title,
      value: Text(
        formatter.format(value.toLocal()),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// title should have .icon, .title, .color
class ViewWidget extends StatelessWidget {
  const ViewWidget({super.key, required this.title, required this.value});

  final TitleClass title;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
            Expanded(child: Text(title.title, style: Theme.of(context).textTheme.bodyMedium)),
            Flexible(flex: 2, child: Center(child: value)),
          ],
        ),
      ),
    );
  }
}

abstract class TitleClass {
  Color get color;
  IconData get icon;
  String get title;
}

class InputTitleEnumWrapper implements TitleClass {
  final InputTitleEnum value;

  InputTitleEnumWrapper(this.value);

  @override
  Color get color => value.color;
  @override
  IconData get icon => value.icon;
  @override
  String get title => value.title;
}

class NumberInputEnumWrapper implements TitleClass {
  final NumberInputEnum value;

  NumberInputEnumWrapper(this.value);

  @override
  Color get color => value.color;
  @override
  IconData get icon => value.icon;
  @override
  String get title => value.title;
}

class TimeTitleEnumWrapper implements TitleClass {
  final TimeTitleEnum value;

  TimeTitleEnumWrapper(this.value);

  @override
  Color get color => value.color;
  @override
  IconData get icon => value.icon;
  @override
  String get title => value.title;
}
