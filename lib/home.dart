import 'package:daydayup/components/calendar.dart';
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
  int tabIndex = 0;
  late List<Widget> listScreens;
  @override
  void initState() {
    super.initState();
    listScreens = [
      Placeholder(),
      Calendar(),
      Placeholder(),
      Placeholder(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: tabIndex, children: listScreens),
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Theme.of(context).primaryColor,
        // selectedItemColor: Colors.black,
        // unselectedItemColor: Colors.white,
        currentIndex: tabIndex,
        onTap: (int index) {
          setState(() {
            tabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      // backgroundColor: Theme.of(context).primaryColor,
    );
  }
}