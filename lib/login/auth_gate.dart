import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digit_kttn/root/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  /// Firestore にユーザー情報を保存するメソッド
  Future<void> saveUserToFirestore(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Firestore に既にデータがあるか確認
    final docSnapshot = await userRef.get();
    if (!docSnapshot.exists) {
      // ユーザー情報を Firestore に保存
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'icon_url': 'assets/images/default_icon.png', // デフォルトアイコンURL（必要に応じて変更）
        'created_record': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
          );
        }

        // ログインユーザーがいる場合、Firestore にユーザー情報を保存
        final user = snapshot.data!;
        saveUserToFirestore(user);

        return const RootPage();
      },
    );
  }
}
