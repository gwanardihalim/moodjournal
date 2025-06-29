import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Selamat datang di Mood Journal!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seenGetStarted', true);

                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Mulai"),
            ),
          ],
        ),
      ),
    );
  }
}
