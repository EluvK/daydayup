import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerWidget extends StatelessWidget {
  ColorPickerWidget({
    super.key,
    required this.onChanged,
    required this.initialColor,
  });

  final focusNode = FocusNode();
  final void Function(Color) onChanged;
  final Color initialColor;

  late final ValueNotifier<Color> color = ValueNotifier(initialColor);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final Color newColor = await showColorPickerDialog(
            context,
            color.value,
            title: Text(
              '选择颜色',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subheading: Text('调整深浅'),
            width: 40,
            height: 40,
            showColorCode: true,
            showColorName: true,
            pickersEnabled: <ColorPickerType, bool>{
              ColorPickerType.both: false,
              ColorPickerType.primary: true,
              ColorPickerType.accent: false,
              ColorPickerType.bw: false,
              ColorPickerType.custom: false,
              ColorPickerType.wheel: true,
            },
            pickerTypeLabels: <ColorPickerType, String>{
              ColorPickerType.primary: '常规',
              ColorPickerType.wheel: '轮盘',
            },
            actionButtons: const ColorPickerActionButtons(
              okButton: true,
              closeButton: true,
              dialogActionButtons: false,
            ),
            transitionBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2, Widget widget) {
              final double curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
              return Transform(
                transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                child: Opacity(
                  opacity: a1.value,
                  child: widget,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          );
          color.value = newColor;
          onChanged(newColor);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Material(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: Icon(
                      Icons.color_lens,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // flex: 1,
                child: Text(
                  '标注颜色',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: color,
                builder: (context, color, _) {
                  return ColorIndicator(
                    width: 40,
                    height: 40,
                    borderRadius: 8,
                    color: color,
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
