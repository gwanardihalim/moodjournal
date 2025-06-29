import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  Future<void> _register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // ✅ AuthGate otomatis mengarahkan ke HomeScreen saat berhasil
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌌 latar gradasi
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F1B3A), Color(0xFF100F1F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Buat Akun',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (_error != null) ...[
                    Text(_error!,
                        style: GoogleFonts.poppins(color: Colors.red)),
                    const SizedBox(height: 16),
                  ],

                  // 🔹 Email
                  _InputCard(
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle:
                            GoogleFonts.poppins(color: Colors.white60),
                        border: InputBorder.none,
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Masukkan email' : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Password
                  _InputCard(
                    child: TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle:
                            GoogleFonts.poppins(color: Colors.white60),
                        border: InputBorder.none,
                      ),
                      obscureText: true,
                      validator: (v) =>
                          v!.length < 6 ? 'Minimal 6 karakter' : null,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 🔹 Tombol daftar
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        _register();
                      }
                    },
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
                          'Daftar',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 kembali ke login
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Sudah punya akun? Login',
                        style:
                            GoogleFonts.poppins(color: Colors.tealAccent),
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

/// Kartu input gelap dengan radius 16 px
class _InputCard extends StatelessWidget {
  final Widget child;
  const _InputCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2B2940),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: child,
      ),
    );
  }
}
