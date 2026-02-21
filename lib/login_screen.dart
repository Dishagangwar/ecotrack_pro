import 'package:ecotrack_pro/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart'; // replace with your main screen

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);
const Color borderBlue = Color(0xFF1E3A5F);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071A2D), Color(0xFF050B14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "EcoTrack Pro",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "AI-Powered Sustainability Platform",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),

                Container(
                  width: 360,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderBlue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _tab("🔐 Login", true, () {}),
                          const SizedBox(width: 10),
                          _tab("📝 Sign Up", false, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignUpScreen()),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 25),

                      const Text("Email", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      _input("Enter your registered email",
                          controller: _emailController),

                      const SizedBox(height: 20),

                      const Text("Password", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      _input("••••••••",
                          isPassword: true, controller: _passwordController),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: accentBlue),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: accentBlue,
                                )
                              : const Text(
                                  "🚀 LOGIN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Please enter email and password");
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSnack("Login successful!");

      // Reset CarbonTracker when a new user logs in
      // Optional: you can load previous user data from Firebase here
      // CarbonTracker().reset();

      // Navigate to main screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Login failed");
    } catch (e) {
      _showSnack("Error: $e");
    }

    setState(() {
      _loading = false;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _tab(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _input(String hint,
      {bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility, color: Colors.white54)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
