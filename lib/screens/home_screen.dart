import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> plans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('plans')
        .where('uid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      plans.clear();
      plans.addAll(
        snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'plan': data['planner'],
            'time': data['time'],
            'completedDates': List<String>.from(data['completedDates'] ?? []),
          };
        }),
      );
    });
  }

  bool isCompletedToday(List<String> completedDates) {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    return completedDates.contains(todayStr);
  }

  Future<void> _toggleCompletion(int index) async {
    final plan = plans[index];
    final completedDates = List<String>.from(plan['completedDates']);
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    if (completedDates.contains(todayStr)) {
      completedDates.remove(todayStr);
    } else {
      completedDates.add(todayStr);
    }

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('plans')
        .doc(plan['id'])
        .update({'completedDates': completedDates});

    // Update local state
    setState(() {
      plans[index]['completedDates'] = completedDates;
    });
  }

  Future<void> _addPlan() async {
    final result = await Navigator.pushNamed(context, '/add');
    if (result != null && result is Map<String, String>) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newPlan = {
        'uid': user.uid,
        'planner': result['planner'],
        'time': result['time'],
        'completedDates': [],
        'createdAt': FieldValue.serverTimestamp(),
      };

      //await FirebaseFirestore.instance.collection('plans').add(newPlan);
      await _loadPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Mood Journal',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: plans.isEmpty
          ? Center(
              child: Text(
                'Belum ada mood',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                final completedDates = plan['completedDates'] as List<String>;
                final today = DateTime.now();
                final todayStr = "${today.year}-${today.month}-${today.day}";
                final isCompleted = completedDates.contains(todayStr);

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      plan['plan'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isCompleted ? Colors.greenAccent : Colors.white,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      'Waktu: ${plan['time']}',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCompleted ? Colors.green : Colors.white,
                      ),
                      onPressed: () => _toggleCompletion(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlan,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
