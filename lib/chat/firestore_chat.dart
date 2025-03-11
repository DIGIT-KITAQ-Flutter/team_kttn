import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendMessageToFirestore({
  required String message,
  required String crowdingLevel,
  required String stationId,
  required String userId,
}) async {
  final firestore = FirebaseFirestore.instance;
  final chatId = "test_id_${DateTime.now().millisecondsSinceEpoch}"; // 一意のID
  final timestamp = Timestamp.now();

  await firestore.collection('station_chats').add({
    'chat_id': chatId,
    'created_message': timestamp,
    'created_record': timestamp,
    'crowding_level': crowdingLevel,
    'message': message,
    'station_id': stationId,
    'user_id': userId,
  });
}

Future<List<Map<String, dynamic>>> getChatHistoryForStation(
    String stationId) async {
  final firestore = FirebaseFirestore.instance;

  // 'station_chats' コレクションから指定した station_id を持つチャット履歴を取得
  QuerySnapshot querySnapshot = await firestore
      .collection('station_chats')
      .where('station_id', isEqualTo: stationId)
      .where('crowding_level', isEqualTo: 'chat')
      .orderBy('created_message', descending: true) // 新しいメッセージ順に並べる
      .get();

  // クエリ結果をリストに変換
  List<Map<String, dynamic>> chatHistory = querySnapshot.docs.map((doc) {
    return doc.data() as Map<String, dynamic>;
  }).toList();

  return chatHistory;
}
