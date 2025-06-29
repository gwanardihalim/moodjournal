import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodjournal/screens/add_moodjournal_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openAddMood(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMoodJournalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ⛔️ jika belum login
    if (user == null) {
      return Scaffold(
        body: _GradientBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Anda belum login',
                    style: GoogleFonts.poppins(color: Colors.white)),
                const SizedBox(height: 20),
                _PrimaryButton(
                  title: 'Login',
                  onTap: () => Navigator.pushNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      // 🌌 gradient body
      body: _GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 🔹 custom header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Mood Journal',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.logout, color: Colors.tealAccent),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('moods')
                      .where('uid', isEqualTo: user.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // error
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      );
                    }
                    // loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // kosong
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _EmptyState();
                    }

                    // sukses
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 80),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        // parsing data
                        final emoji = data['emoji'] ?? '❓';
                        final note =
                            (data['moodNote'] as String?)?.trim() ?? '(Tanpa catatan)';
                        final time = data['moodTime'] ?? 'Waktu tidak tersedia';
                        final date =
                            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final formattedDate =
                            '${date.day}/${date.month}/${date.year}';

                        return _MoodCard(
                          emoji: emoji,
                          note: note,
                          time: time,
                          date: formattedDate,
                          onDelete: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('moods')
                                  .doc(doc.id)
                                  .delete();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menghapus: $e',
                                      style: GoogleFonts.poppins()),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // 🔹 FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        onPressed: () => _openAddMood(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F1B3A), Color(0xFF100F1F)],
        ),
      ),
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _PrimaryButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient:
              const LinearGradient(colors: [Colors.tealAccent, Color(0xFF00D1FF)]),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Belum ada mood journal',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Tekan tombol + untuk menambahkan',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final String emoji;
  final String note;
  final String time;
  final String date;
  final VoidCallback onDelete;

  const _MoodCard({
    required this.emoji,
    required this.note,
    required this.time,
    required this.date,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2B2940),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(note,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Waktu: $time',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            Text('Tanggal: $date',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
