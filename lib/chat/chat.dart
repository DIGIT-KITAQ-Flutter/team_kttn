import 'package:digit_kttn/chat/firestore_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final int station_id;
  final String name;

  const ChatScreen({super.key, required this.station_id, required this.name});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> choices = ["少ない・普通", "渋滞", "超渋滞"];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirestoreChatService _chatService = FirestoreChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **メッセージ送信**
  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ログインしていません")),
      );
      return;
    }

    await _chatService.sendMessage(
      message: _textController.text.trim(),
      crowdingLevel: "chat",
      stationId: widget.station_id,
      userId: userId,
    );

    _textController.clear();
    _scrollToBottom();
  }

  /// **スクロールを一番下に移動**
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// **混雑状況を送信**
  void _handleChoice(String choice) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ログインしていません")),
      );
      return;
    }

    await _chatService.sendMessage(
      message: "",
      crowdingLevel: choice,
      stationId: widget.station_id,
      userId: userId,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.name} のチャット")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getChatStream(widget.station_id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('エラーが発生しました'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('1時間以内のチャット履歴はありません'));
                }

                final chatData = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: chatData.length,
                  itemBuilder: (context, index) {
                    final chat =
                        chatData[index].data() as Map<String, dynamic>? ?? {};
                    final bool isMe = chat['user_id'] == _auth.currentUser?.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(chat['message'] ?? ''),
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
                  child: const Text("送信"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
