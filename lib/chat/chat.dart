import 'package:flutter/material.dart';

// void main() {
//   runApp(const ChatApp());
// }

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Choices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> messages = [];
  List<String> choices = ["少ない・普通", "渋滞", "超渋滞"];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleChoice(String choice) {
    setState(() {
      messages.add("$choice");
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_textController.text.isEmpty) return;

    setState(() {
      messages.add("${_textController.text}");
    });

    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("会話")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: messages[index].startsWith("あなた")
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: messages[index].startsWith("あなた")
                          ? Colors.blue[200]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(messages[index]),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: choices.map((choice) {
                return ElevatedButton(
                  onPressed: () => _handleChoice(choice),
                  child: Text(choice),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "メッセージを入力...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
ElevatedButton(
  onPressed: _sendMessage,
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(width: 5),
      Text("送信"), // テキスト
    ],
  ),
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
