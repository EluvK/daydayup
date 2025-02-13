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

  final mainPageAtStartup = 1.obs;
  DateTime lastUpdateLessonStatusTime = DateTime.now();

  // running cache
  final currentMainPage = 0.obs;

  @override
  Future<void> onInit() async {
    _beginInit = true;
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

    mainPageAtStartup.value = box.read('mainPageAtStartup') ?? 1;
    currentMainPage.value = mainPageAtStartup.value;

    if (box.read('lastUpdateLessonStatusTime') != null) {
      lastUpdateLessonStatusTime = DateTime.parse(box.read('lastUpdateLessonStatusTime'));
    } else {
      lastUpdateLessonStatusTime = DateTime.fromMicrosecondsSinceEpoch(0).toUtc();
    }
    print('lastUpdateLessonStatusTime is $lastUpdateLessonStatusTime');

    super.onInit();
    _initialized = true;
  }

  bool _beginInit = false;
  bool _initialized = false;
  Future<void> ensureInitialization() async {
    if (!_beginInit) {
      await onInit();
    }
    while (!_initialized) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    return;
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

  User getUser(String userId) {
    return users.firstWhere((user) => user.id == userId);
  }

  void upsertUser(User user) {
    if (users.contains(user)) {
      users[users.indexWhere((u) => u.id == user.id)] = user;
    } else {
      users.add(user);
    }
    DataBase().upsertUser(user);
  }

  int getMainPageAtStartup() {
    return mainPageAtStartup.value;
  }

  void setMainPageAtStartup(int index) {
    mainPageAtStartup.value = index;
    box.write('mainPageAtStartup', index);
  }

  int getCurrentMainPage() {
    return currentMainPage.value;
  }

  void setCurrentMainPage(int index) {
    currentMainPage.value = index;
  }

  DateTime getLastUpdateLessonStatusTime() {
    return lastUpdateLessonStatusTime;
  }

  void setLastUpdateLessonStatusTime(DateTime time) {
    time = time.toUtc();
    lastUpdateLessonStatusTime = time;
    box.write('lastUpdateLessonStatusTime', time.toString());
  }
}
