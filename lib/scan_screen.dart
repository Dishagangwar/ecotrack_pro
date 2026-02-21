import 'dart:io';
import 'package:ecotrack_pro/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ScanCheckScreen extends StatefulWidget {
  const ScanCheckScreen({Key? key}) : super(key: key);

  @override
  State<ScanCheckScreen> createState() => _ScanCheckScreenState();
}

class _ScanCheckScreenState extends State<ScanCheckScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  late AnimationController _controller;
  late Animation<double> _animation;

  bool hasResult = false;
  bool isLoading = false;
  String resultText = "";

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  /// PICK IMAGE + CALL GEMINI
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
      isLoading = true;
      hasResult = false;
    });

    try {
      final result =
          await GeminiService.analyzeImage(_selectedImage!);

      setState(() {
        resultText = result;
        hasResult = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        resultText =
            "Failed to analyze image. Please check internet or API key.";
        hasResult = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061826),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// TITLE
                const Text(
                  "Scan & Check",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BFFF),
                  ),
                ),

                const SizedBox(height: 30),

                /// SCAN AREA
                _buildScanArea(),

                const SizedBox(height: 30),

                /// BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: Icons.camera_alt,
                        label: "Camera",
                        onTap: () =>
                            _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.photo,
                        label: "Gallery",
                        onTap: () =>
                            _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// LOADING
                if (isLoading)
                  const CircularProgressIndicator(
                    color: Color(0xFF00BFFF),
                  ),

                const SizedBox(height: 20),

                /// RESULT CARD
                if (hasResult) _glassResultCard(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// SCAN BOX UI
  Widget _buildScanArea() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0A2438),
                Color(0xFF0D2E45),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF00BFFF)
                  .withOpacity(0.4 + (_animation.value * 0.4)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFFF)
                    .withOpacity(_animation.value * 0.5),
                blurRadius: 25,
                spreadRadius: 2,
              )
            ],
          ),
          child: _selectedImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.camera_alt_rounded,
                      size: 70,
                      color: Color(0xFF00BFFF),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Scan an Appliance or Food Item",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
        );
      },
    );
  }

  /// BUTTON UI
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00BFFF),
              Color(0xFF0096FF),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00BFFF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// RESULT CARD
  Widget _glassResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Scan Result",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00BFFF),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            resultText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
