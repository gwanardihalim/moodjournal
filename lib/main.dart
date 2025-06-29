import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodjournal/screens/add_moodjournal_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'screens/auth_gate.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final seenGetStarted = prefs.getBool('seen_get_started') ?? false;

  runApp(MyApp(showGetStarted: !seenGetStarted));
}

class MyApp extends StatelessWidget {
  final bool showGetStarted;
  const MyApp({super.key, required this.showGetStarted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(primary: Colors.amber),
      ),
      initialRoute: showGetStarted ? '/get-started' : '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/add': (context) => const AddMoodJournalScreen(),
      },
    );
  }
}
