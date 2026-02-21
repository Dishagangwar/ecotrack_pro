import 'package:ecotrack_pro/dashboard_screen.dart';
import 'package:ecotrack_pro/gemini_service.dart';
import 'package:flutter/material.dart';

class EcoBotChatScreen extends StatefulWidget {
  const EcoBotChatScreen({super.key});

  @override
  State<EcoBotChatScreen> createState() => _EcoBotChatScreenState();
}

class _EcoBotChatScreenState extends State<EcoBotChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF020B16),
              Color(0xFF071A2D),
              Color(0xFF050B14),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(child: _chatArea()),
              _inputField(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 HEADER
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: accentBlue),
              SizedBox(width: 10),
              Text(
                "Eco-Bot Consultant",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Ask any question about sustainability, recycling or reducing your footprint.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 🔹 CHAT AREA
  Widget _chatArea() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _botIntro(),
        ...messages.map((msg) => _chatBubble(msg)),
      ],
    );
  }

  Widget _botIntro() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentBlue.withOpacity(0.4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🤖 I am EcoBot",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "I am powered by Gemini AI to help you live greener.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.black : cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? accentBlue.withOpacity(0.5)
                : Colors.white24,
          ),
        ),
        child: Text(
          msg['text']!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // 🔹 INPUT FIELD
  Widget _inputField() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Ask me anything...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            color: accentBlue,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  // 🔹 SEND MESSAGE
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;
    setState(() {
      messages.add({"role": "user", "text": userText});
    });

    _controller.clear();

    // 🔥 THIS IS WHERE GEMINI API WILL BE CALLED
    sendMessageToGemini(userText);
  }

  // 🔹 GEMINI API PLACEHOLDER
  Future<void> sendMessageToGemini(String userMessage) async {
  try {
    final response = await GeminiService.getResponse(userMessage);

    setState(() {
      messages.add({
        "role": "bot",
        "text": response,
      });
    });
  } catch (e) {
    setState(() {
      messages.add({
        "role": "bot",
        "text": "⚠️ Sorry, I couldn't respond right now.",
      });
    });
  }
}

}
