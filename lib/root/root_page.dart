import 'package:digit_kttn/map/map_page.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/Qsute.png'),
          ),
          title: const Text('Qステ', textAlign: TextAlign.center),
          centerTitle: true,
          actions: const [
            SignOutButton(
              variant: ButtonVariant.text,
            )
          ]),
      body: MapPage(),
    );
  }
}
