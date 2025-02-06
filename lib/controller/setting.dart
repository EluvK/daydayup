import 'package:daydayup/model/course.dart';
import 'package:daydayup/model/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingController extends GetxController {
  final box = GetStorage('DDUStorage');

  // app settings
  final themeMode = ThemeMode.system.obs;

  // user settings
  final RxList<User> users = <User>[].obs;
  final RxString defaultUserId = ''.obs;

  @override
  void onInit() async {
    // app settings
    String themeText = box.read('theme') ?? 'system';
    print('read theme from box $themeText');
    try {
      themeMode.value = ThemeMode.values.firstWhere((e) => e.toString() == themeText);
    } catch (_) {
      print('theme not found, setting to system');
      themeMode.value = ThemeMode.system;
    }

    // user settings
    users.value = await DataBase().getUsers();
    if (box.read('defaultUserId') == null ||
        users.firstWhereOrNull((user) => user.id == box.read('defaultUserId')) == null) {
      box.write('defaultUserId', users.first.id);
      defaultUserId.value = users.first.id;
    } else {
      defaultUserId.value = box.read('defaultUserId');
    }

    super.onInit();
  }

  setThemeMode(ThemeMode theme) {
    print('setting theme: $theme');
    themeMode.value = theme;
    Get.changeThemeMode(themeMode.value);
    box.write('theme', themeMode.value.toString());
  }

  setDefaultUser(String userId) {
    defaultUserId.value = userId;
    box.write('defaultUserId', userId);
  }

  User getDefaultUser() {
    return users.firstWhere((user) => user.id == defaultUserId.value);
  }
}
