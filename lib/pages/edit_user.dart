import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditUserPage extends StatelessWidget {
  const EditUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String? userId = args?[0];
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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
