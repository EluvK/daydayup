import 'package:daydayup/model/course.dart';
import 'package:flutter/material.dart';

class UserPicker extends StatefulWidget {
  const UserPicker({
    super.key,
    this.allowMultiple = false,
    required this.onChanged,
    required this.candidateUsers,
    required this.initialUser,
  });

  final bool allowMultiple;
  final void Function(List<String>) onChanged;
  final List<User> candidateUsers;
  final List<User> initialUser;

  @override
  State<UserPicker> createState() => _UserPickerState();
}

class _UserPickerState extends State<UserPicker> {
  List<String> selectedUserIds = [];

  @override
  void initState() {
    selectedUserIds = widget.initialUser.map((e) => e.id).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('painting user: ${widget.candidateUsers}');
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
        child: Row(
          children: [
            Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                height: 32,
                width: 32,
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              // flex: 1,
              child: Text(
                '用户',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Flexible(
                flex: 3,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 56),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final user in widget.candidateUsers)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              print("selectedUsers: $selectedUserIds");
                              print("candidateUsers: ${widget.candidateUsers}");
                              if (widget.allowMultiple) {
                                if (selectedUserIds.contains(user.id)) {
                                  if (selectedUserIds.length == 1) {
                                    return;
                                  }
                                  selectedUserIds.remove(user.id);
                                } else {
                                  selectedUserIds.add(user.id);
                                }
                              } else {
                                selectedUserIds = [user.id];
                              }
                              widget.onChanged(selectedUserIds);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.all(4),
                            // width: 120,
                            // height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    selectedUserIds.contains(user.id) ? user.color.withAlpha(200) : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                if (selectedUserIds.contains(user.id))
                                  BoxShadow(
                                    color: user.color.withAlpha(120),
                                    spreadRadius: 3,
                                    blurRadius: 1,
                                  ),
                              ],
                              color: user.color.withAlpha(100),
                              borderRadius: BorderRadius.circular(12), // 调整圆角大小
                            ),
                            child: Center(
                              child: Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: selectedUserIds.contains(user.id) ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
