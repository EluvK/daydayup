import 'dart:io';
import 'dart:ui';

import 'package:daydayup/controller/courses.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/home.dart';
import 'package:daydayup/pages/edit_course.dart';
import 'package:daydayup/pages/edit_course_group.dart';
import 'package:daydayup/pages/edit_lesson.dart';
import 'package:daydayup/pages/edit_user.dart';
import 'package:daydayup/pages/view_course.dart';
import 'package:daydayup/pages/view_lesson.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  await GetStorage.init('DDUStorage');

  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Get.putAsync(() async {
    final controller = SettingController();
    return controller;
  });
  final settingController = Get.find<SettingController>();
  await settingController.ensureInitialization();

  await Get.putAsync(() async {
    final controller = CoursesController();
    return controller;
  });
  final coursesController = Get.find<CoursesController>();
  await coursesController.ensureInitialization();

  Intl.defaultLocale = 'zh_CN';
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var app = GetMaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/edit-course', page: () => EditCoursePage()),
        GetPage(name: '/view-course', page: () => ViewCoursePage()),
        GetPage(name: '/edit-course-group', page: () => EditCourseGroupPage()),
        GetPage(name: '/edit-user', page: () => EditUserPage()),
        GetPage(name: '/edit-lesson', page: () => EditLessonPage()),
        GetPage(name: '/view-lesson', page: () => ViewLessonPage()),
      ],
      themeMode: ThemeMode.light,
      theme: FlexThemeData.light(
        scheme: FlexScheme.blumineBlue,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
        ),
        tones: FlexTones.material(Brightness.light).onMainsUseBW(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: 'lxgw',
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.blumineBlue,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 14,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
        ),
        tones: FlexTones.material(Brightness.dark).onMainsUseBW(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: 'lxgw',
      ),
    );
    return app;
  }
}
