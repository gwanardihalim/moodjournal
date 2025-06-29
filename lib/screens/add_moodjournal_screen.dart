import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMoodJournalScreen extends StatefulWidget {
  const AddMoodJournalScreen({super.key});

  @override
  State<AddMoodJournalScreen> createState() => _AddMoodJournalScreenState();
}

class _AddMoodJournalScreenState extends State<AddMoodJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _moodNoteController = TextEditingController();
  TimeOfDay? _selectedTime;

  // 🔹 daftar emoji & yang terpilih
  final List<String> _emojis = ['😊', '😔', '😡', '😭', '😄', '😴'];
  String? _selectedEmoji;

  @override
  void dispose() {
    _moodNoteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            onPrimary: Colors.white,
            surface: Color(0xFF2B2940),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveMood() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedTime == null || _selectedEmoji == null) return;

    final formattedTime = _selectedTime!.format(context);

    final newMood = {
      'emoji': _selectedEmoji,
      'moodNote': _moodNoteController.text.trim(),
      'moodTime': formattedTime,
      'uid': user.uid,
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('moods').add(newMood);

    Navigator.pop(context, {
      'emoji': _selectedEmoji,
      'moodNote': _moodNoteController.text.trim(),
      'moodTime': formattedTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _selectedTime != null && _selectedEmoji != null;

    return Scaffold(
      // 🌌 gradasi latar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F1B3A), Color(0xFF100F1F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tambah Mood',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 🔹 pilihan emoji dalam Card
                  Text('Pilih Emoji',
                      style: GoogleFonts.poppins(
                          color: Colors.tealAccent, fontSize: 16)),
                  const SizedBox(height: 12),
                  Card(
                    color: const Color(0xFF2B2940),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _emojis.map((e) {
                          final selected = e == _selectedEmoji;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedEmoji = e),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? Colors.tealAccent
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? Colors.tealAccent
                                      : Colors.white24,
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                e,
                                style: TextStyle(
                                  fontSize: 26,
                                  color: selected
                                      ? Colors.black
                                      : Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 🔹 catatan mood (opsional) di dalam Card
                  Card(
                    color: const Color(0xFF2B2940),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: TextFormField(
                        controller: _moodNoteController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Catatan Mood (opsional)',
                          hintStyle: GoogleFonts.poppins(color: Colors.white60),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 🔹 pemilih waktu
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedTime != null
                              ? 'Waktu: ${_selectedTime!.format(context)}'
                              : 'Belum memilih waktu',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.timer, size: 18),
                        label: Text('Pilih Jam',
                            style: GoogleFonts.poppins(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // 🔹 tombol simpan full‑width dengan gradient
                  GestureDetector(
                    onTap: canSave ? _saveMood : null,
                    child: Opacity(
                      opacity: canSave ? 1 : 0.4,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Colors.tealAccent, Color(0xFF00D1FF)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Simpan',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
