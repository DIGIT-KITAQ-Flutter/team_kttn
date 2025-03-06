import 'package:digit_kttn/chat/chat.dart';
import 'package:flutter/material.dart';

// Map画面です。ここを編集してください。
// 今は簡易的にボタンを配置して押したらChat画面に遷移するようにしています。
// ボタンが駅のイメージです。

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: IconButton(
          icon: const Icon(Icons.location_on, color: Colors.red, size: 40),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen()),
            );
          },
        ),
      ),
    );
  }
}
