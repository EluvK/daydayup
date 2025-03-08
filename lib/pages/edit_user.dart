import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/dangerous_zone.dart';
import 'package:daydayup/utils/double_click.dart';
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
        title: Text(userId == null ? '创建用户' : '编辑用户'),
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
        color: RandomColor.getColorObject(Options(luminosity: Luminosity.light)),
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _EditUserInner(user: user, isCreateNew: true),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _EditUserInner(
        user: settingController.getUser(widget.userId!),
        isCreateNew: false,
      ),
    );
  }
}

class _EditUserInner extends StatefulWidget {
  const _EditUserInner({required this.user, required this.isCreateNew});
  final User user;
  final bool isCreateNew;

  @override
  State<_EditUserInner> createState() => __EditUserInnerState();
}

class __EditUserInnerState extends State<_EditUserInner> {
  final settingController = Get.find<SettingController>();

  late User editUser;

  @override
  void initState() {
    editUser = widget.user.clone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        TextInputWidget(
          title: InputTitleEnum.userName,
          onChanged: (value) {
            editUser.name = value;
          },
          initialValue: editUser.name,
          autoFocus: widget.isCreateNew,
        ),
        ColorPickerWidget(
          onChanged: (value) {
            // print(value);
            editUser.color = value;
          },
          initialColor: editUser.color,
        ),
        ElevatedButton(
          onPressed: () async {
            if (!validateUserInput()) return;
            if (widget.isCreateNew) {
              await settingController.addNewUser(editUser);
            } else {
              await settingController.updateUser(editUser);
            }
            Get.back();
          },
          child: const Text('Save'),
        ),
        if (!widget.isCreateNew && widget.user.id != "default")
          DangerousZone(
            children: [
              Text("    删除用户会使得关联的课程组和课堂信息被更改为默认用户。\n    请谨慎操作。"),
              DoubleClickButton(
                buttonBuilder: (onPressed) => ElevatedButton(
                  onPressed: onPressed,
                  child: const Text('删除用户', style: TextStyle(color: Colors.red)),
                ),
                onDoubleClick: () async {
                  await settingController.deleteUser(editUser);
                  Get.offAllNamed('/');
                },
                firstClickHint: "删除用户",
              ),
            ],
          )
      ],
    );
  }

  bool validateUserInput() {
    if (editUser.name.isEmpty) {
      Get.snackbar('❌ 错误', '用户名不能为空');
      return false;
    }
    return true;
  }
}
