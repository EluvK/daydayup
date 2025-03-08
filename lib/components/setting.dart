import 'package:daydayup/controller/setting.dart';
import 'package:daydayup/model/course.dart';
import 'package:daydayup/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: UserSetting(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AppSetting(),
          )
        ],
      ),
    );
  }
}

class UserSetting extends StatefulWidget {
  const UserSetting({super.key});

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  final settingController = Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var users = settingController.users;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '用户列表',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Buttons
                ],
              )
            ],
          ),
          Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length + 1,
            itemBuilder: (context, index) {
              return index == users.length
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildNewUserTile(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildUserTile(users[index]),
                    );
            },
          ),
        ],
      );
    });
  }

  Widget _buildNewUserTile() {
    return ElevatedButton(
      onPressed: () {
        Get.toNamed('/edit-user');
      },
      child: ListTile(
        leading: Icon(Icons.add),
        title: Text('创建用户'),
      ),
    );
  }

  Widget _buildUserTile(User user) {
    print(user.color);
    return ElevatedButton(
      onPressed: () {
        Get.toNamed('/edit-user', arguments: [user.id]);
      },
      child: ListTile(
        leading: Icon(Icons.circle, color: user.color),
        title: Text(user.name),
        onTap: null,
      ),
    );
  }
}

class AppSetting extends StatefulWidget {
  const AppSetting({super.key});

  @override
  State<AppSetting> createState() => _AppSettingState();
}

class _AppSettingState extends State<AppSetting> {
  final settingController = Get.find<SettingController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'APP设置',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Divider(),
        mainPageSelector(),
        SizedBox(height: 8),
        aboutAppWidget(),
        if (isDebug()) Text('// 调试功能'),
        if (isDebug())
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("检查截至日期"),
              TextButton(
                onLongPress: () {
                  settingController.setLastUpdateLessonStatusTime(DateTime(1970));
                  setState(() {});
                },
                onPressed: null,
                child: Text(DateFormat.yMMMd().format(settingController.getLastUpdateLessonStatusTime().toLocal())),
              )
            ],
          ),
      ],
    );
  }

  Widget aboutAppWidget() {
    return ElevatedButton(
      onPressed: () {
        Get.toNamed('/about');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("关于 APP"),
          Text(" $VERSION "),
        ],
      ),
    );
  }

  Widget mainPageSelector() {
    return ElevatedButton(
      onPressed: () {
        settingController.setMainPageAtStartup((settingController.getMainPageAtStartup() + 1) % 4);
        setState(() {});
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("启动展示页面"),
          DropdownButton<int>(
            isDense: true,
            value: settingController.getMainPageAtStartup(),
            onChanged: (int? value) {
              settingController.setMainPageAtStartup(value!);
              setState(() {});
            },
            items: [
              DropdownMenuItem(value: 0, child: Row(children: [Icon(Icons.home), Text('  日程  ')])),
              DropdownMenuItem(value: 1, child: Row(children: [Icon(Icons.calendar_month), Text('  日历  ')])),
              DropdownMenuItem(value: 2, child: Row(children: [Icon(Icons.book), Text('  课程  ')])),
              DropdownMenuItem(value: 3, child: Row(children: [Icon(Icons.settings), Text('  设置  ')])),
            ],
          )
        ],
      ),
    );
  }
}
