import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digit_kttn/map/map_screen.dart';
import 'package:flutter/material.dart';

class BottomWidget extends StatefulWidget {
  const BottomWidget({super.key});

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  // FirestoreからStation_Chatsを取得（created_messageの新着順）
  Stream<QuerySnapshot> getChats() {
    return FirebaseFirestore.instance
        .collection('station_chats')
        .where('crowding_level', isEqualTo: 'chat')
        .orderBy('created_message', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            MapScreen(),
            Positioned(
              top: 10.0,
              left: 10.0,
              right: 10.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '検索',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) {},
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  color: Colors.white,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getChats(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        print(snapshot);
                        return Center(child: CircularProgressIndicator());
                      }

                      var chats = snapshot.data!.docs;

                      if (chats.isEmpty) {
                        return Center(child: Text('投稿がありません'));
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: chats.length,
                        itemBuilder: (BuildContext context, int index) {
                          var chat =
                              chats[index].data() as Map<String, dynamic>;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/default_icon.png'),
                            ),
                            title: Text(chat['message'] ?? 'メッセージなし'),
                            subtitle: Text(chat['created_message'] != null
                                ? chat['created_message'].toDate().toString()
                                : '日時不明'),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
