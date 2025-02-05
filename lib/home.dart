import 'package:daydayup/components/brief.dart';
import 'package:daydayup/components/calendar.dart';
import 'package:daydayup/components/courses.dart';
import 'package:daydayup/components/setting.dart';
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
  int tabIndex = 1;
  late List<Widget> listScreens;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    listScreens = [
      Brief(),
      Calendar(),
      Courses(),
      Setting(),
    ];
    _pageController = PageController(initialPage: tabIndex);
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
            tabIndex = index;
          });
        },
        children: listScreens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (int index) {
          setState(() {
            tabIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
