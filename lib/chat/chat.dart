import 'package:digit_kttn/chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: const ChatScreen(
        stationId: 'station_123',
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String stationId;
  const ChatScreen({super.key, required this.stationId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> choices = ["少ない・普通", "渋滞", "超渋滞"];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_textController.text.isEmpty) return;

    await sendMessageToFirestore(
      message: _textController.text,
      crowdingLevel: "chat", // デフォルト値（ボタン選択時は変更）
      stationId: "station_123",
      userId: "user_456",
    );

    _textController.clear();
    _scrollToBottom();
  }

  void _handleChoice(String choice) async {
    await sendMessageToFirestore(
      message: "", // メッセージなし
      crowdingLevel: choice,
      stationId: "station_123",
      userId: "user_456",
    );
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
      appBar: AppBar(title: Text("${widget.stationId} のチャット")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('station_chats')
                  .where('station_id', isEqualTo: widget.stationId)
                  .where('crowding_level', isEqualTo: 'chat')
                  .orderBy('created_message', descending: false) // 新着順にソート
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print(snapshot);
                  return const Center(child: Text('エラーが発生しました'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print(snapshot);
                  return const Center(child: Text('チャット履歴はありません'));
                }

                // Firestoreのデータをmessagesに格納
                final chatData = snapshot.data!.docs;
                final messages = chatData.map((doc) {
                  return doc['message']?.toString() ?? ''; // 文字列に変換
                }).toList();

                return ListView.builder(
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
