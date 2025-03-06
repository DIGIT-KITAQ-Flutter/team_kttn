import 'package:digit_kttn/main.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  // int _selectedIndex = 0;
  final pages = [
    const MyHomePage(
      title: '',
    ),
    // const ProfilePage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [
        SignOutButton(
          variant: ButtonVariant.text,
        )
      ]),
      body: pages[0],
    );
  }
}
