import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:flutter/material.dart';

class StatusPicker extends StatelessWidget {
  const StatusPicker({super.key, required this.status, required this.onChange});

  final LessonStatus status;
  final void Function(LessonStatus) onChange;

  final InputTitleEnum title = InputTitleEnum.lessonStatus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
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
              child: Text(title.title, style: Theme.of(context).textTheme.bodyMedium),
            ),
            SegmentedButton(
              segments: [
                for (final eachStatus in LessonStatus.values)
                  ButtonSegment<LessonStatus>(
                    value: eachStatus,
                    tooltip: eachStatus.name,
                    label: Text(
                      eachStatus.name,
                      style: TextStyle(
                        color: eachStatus.color,
                        fontWeight: status == eachStatus ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  )
              ],
              selected: {status},
              showSelectedIcon: false,
              onSelectionChanged: (Set<LessonStatus> newSelection) {
                print('newSelection: $newSelection');
                onChange(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
