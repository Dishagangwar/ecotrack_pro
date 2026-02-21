import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

const Color bgDark = Color(0xFF050B14);
const Color cardDark = Color(0xFF0B1623);
const Color accentBlue = Color(0xFF00B2FF);
const Color borderBlue = Color(0xFF1E3A5F);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  Future<void> _signUp() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();
  final username = _usernameController.text.trim();

  if (email.isEmpty || password.isEmpty || username.isEmpty) {
    _showSnack("Please fill all fields");
    return;
  }

  if (password != confirmPassword) {
    _showSnack("Passwords do not match");
    return;
  }

  setState(() => _loading = true);

  try {
    final uid = await AuthService().createUserAndCarbonFootprint(
      email: email,
      password: password,
      username: username,
    );

    if (uid != null) {
      _showSnack("Account created successfully 🎉");

      // optional: small delay so snackbar is visible
      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _showSnack("Signup failed. Please try again.");
    }
  } catch (e) {
    _showSnack(e.toString());
  } finally {
    setState(() => _loading = false);
  }
}

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

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
                          _tab("🔐 Login", false, () {
                            Navigator.pop(context);
                          }),
                          const SizedBox(width: 10),
                          _tab("📝 Sign Up", true, () {}),
                        ],
                      ),
                      const SizedBox(height: 25),

                      _label("Enter email"),
                      _input("example@gmail.com",
                          controller: _emailController),

                      const SizedBox(height: 20),

                      _label("Enter username"),
                      _input("exampl@123",
                          controller: _usernameController),

                      const SizedBox(height: 20),

                      _label("Set Password"),
                      _input(
                        "",
                        controller: _passwordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 20),

                      _label("Confirm Password"),
                      _input(
                        "",
                        controller: _confirmPasswordController,
                        isPassword: true,
                      ),

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
                          onPressed: _loading ? null : _signUp,
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: accentBlue,
                                )
                              : const Text(
                                  "✨ CREATE ACCOUNT",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }

  Widget _input(
    String hint, {
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
