import 'package:daydayup/components/brief.dart';
import 'package:daydayup/components/calendar.dart';
import 'package:daydayup/components/courses.dart';
import 'package:daydayup/components/setting.dart';
import 'package:daydayup/controller/setting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetResponsiveView {
  HomePage({super.key});

  @override
  Widget? phone() {
    return PhoneHomePageTab();
  }

  @override
  Widget? desktop() {
    return Placeholder();
  }
}

class PhoneHomePageTab extends StatefulWidget {
  const PhoneHomePageTab({super.key});

  @override
  State<PhoneHomePageTab> createState() => _PhoneHomePageTabState();
}

class _PhoneHomePageTabState extends State<PhoneHomePageTab> {
  late List<Widget> listScreens;
  late PageController _pageController;
  final settingController = Get.find<SettingController>();

  @override
  void initState() {
    super.initState();
    listScreens = [
      Brief(),
      Calendar(),
      Courses(),
      Setting(),
    ];
    _pageController = PageController(initialPage: settingController.getCurrentMainPage());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            settingController.setCurrentMainPage(index);
          });
        },
        children: listScreens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: settingController.getCurrentMainPage(),
        onTap: (int index) {
          setState(() {
            settingController.setCurrentMainPage(index);
            _pageController.jumpToPage(index);
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '日程'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: '日历'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '课程列表'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
