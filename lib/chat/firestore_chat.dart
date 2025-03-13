import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **メッセージを Firestore に送信**
  Future<void> sendMessage({
    required String message,
    required String crowdingLevel,
    required int stationId,
    required String userId,
  }) async {
    final chatId = "test_id_${DateTime.now().millisecondsSinceEpoch}";
    final timestamp = Timestamp.now();

    await _firestore.collection('station_chats').add({
      'chat_id': chatId,
      'created_message': timestamp,
      'created_record': timestamp,
      'crowding_level': crowdingLevel,
      'message': message,
      'station_id': stationId,
      'user_id': userId,
    });
  }

  /// **リアルタイムで1時間以内のチャット履歴を取得**
  Stream<QuerySnapshot> getChatStream(int stationId) {
    Timestamp oneHourAgo = Timestamp.fromMillisecondsSinceEpoch(
      DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
    );

    return _firestore
        .collection('station_chats')
        .where('station_id', isEqualTo: stationId)
        .where('crowding_level', isEqualTo: 'chat')
        .where('created_record', isGreaterThanOrEqualTo: oneHourAgo)
        .orderBy('created_record', descending: false)
        .orderBy('created_message', descending: false)
        .snapshots();
  }
}
