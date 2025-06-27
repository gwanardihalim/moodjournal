import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPlannerScreen extends StatefulWidget {
  const AddPlannerScreen({super.key});

  @override
  State<AddPlannerScreen> createState() => _AddPlannerScreenState();
}

class _AddPlannerScreenState extends State<AddPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plannerController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _plannerController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _savePlanner() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedTime == null) return;

    final formattedTime = _selectedTime!.format(context);

    final newPlanner = {
      'planner': _plannerController.text.trim(),
      'time': formattedTime,
      'completedDates': [],
      'uid': user.uid,
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('plans').add(newPlanner);

    // Kembali ke halaman sebelumnya dan kirim data kembali (jika diperlukan)
    Navigator.pop(context, {
      'planner': _plannerController.text.trim(),
      'time': formattedTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Tambah Kegiatan',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _plannerController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nama Kegiatan',
                  labelStyle: GoogleFonts.poppins(color: Colors.white),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
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
                  ElevatedButton(
                    onPressed: _pickTime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Pilih Jam', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedTime != null) {
                    _savePlanner();
                  }
                },
                child: Text('Simpan', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
