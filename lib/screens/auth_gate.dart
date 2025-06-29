import 'package:moodjournal/screens/home_screen.dart';
import 'package:moodjournal/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 Menunggu data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Belum login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ✅ Sudah login
        return const HomeScreen();
      },
    );
  }
}
