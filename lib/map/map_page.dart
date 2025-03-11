import 'package:flutter/material.dart';
import 'package:digit_kttn/map/bottom_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomWidget(),
    );
  }
}
