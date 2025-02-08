import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/text_input.dart';
import 'package:daydayup/utils/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class EditUserPage extends StatelessWidget {
  const EditUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String? userId = args?[0];
    print("userId: $userId");
    return Scaffold(
      appBar: AppBar(
        title: Text(userId == null ? 'New User' : 'Edit User'),
      ),
      body: EditUser(userId: userId),
    );
  }
}

class EditUser extends StatefulWidget {
  const EditUser({super.key, required this.userId});
  final String? userId;

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final settingController = Get.find<SettingController>();
  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      var user = User(
        id: const Uuid().v4(),
        name: '',
        color: RandomColor.getColorObject(Options()),
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditUserInner(user: user),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _EditUserInner(user: settingController.getUser(widget.userId!)),
    );
  }
}

class _EditUserInner extends StatefulWidget {
  const _EditUserInner({required this.user});
  final User user;

  @override
  State<_EditUserInner> createState() => __EditUserInnerState();
}

class __EditUserInnerState extends State<_EditUserInner> {
  final settingController = Get.find<SettingController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        TextInputWidget(
          title: InputTitleEnum.userName,
          onChanged: (value) {
            widget.user.name = value;
          },
          initialValue: widget.user.name,
        ),
        ColorPickerWidget(
          onChanged: (value) {
            // print(value);
            widget.user.color = value;
          },
          initialColor: widget.user.color,
        ),
        ElevatedButton(
          onPressed: () {
            settingController.upsertUser(widget.user);
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
