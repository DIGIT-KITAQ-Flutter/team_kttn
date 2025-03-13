import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

/// ログイン中のユーザーを取得
User? getCurrentUser() {
  return _auth.currentUser;
}

/// ユーザーのUIDを取得
String? getCurrentUserId() {
  return _auth.currentUser?.uid;
}
