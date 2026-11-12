import 'package:ecotrack_pro/dashboard_screen.dart';
import 'package:ecotrack_pro/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class EcoBotChatScreen extends StatefulWidget {
  const EcoBotChatScreen({super.key});

  @override
  State<EcoBotChatScreen> createState() => _EcoBotChatScreenState();
}

class _EcoBotChatScreenState extends State<EcoBotChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        _botIntro(),
        ...messages.map((msg) => _chatBubble(msg)),
        if (_isTyping) _typingIndicator(),
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
        border: Border.all(color: accentBlue.withValues(alpha: 0.4)),
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
    // Let bubbles grow with the screen instead of a fixed 280px.
    final maxWidth = MediaQuery.of(context).size.width * 0.78;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: isUser ? Colors.black : cardDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser
                ? accentBlue.withValues(alpha: 0.5)
                : Colors.white24,
          ),
        ),
        child: isUser
            ? SelectableText(
                msg['text']!,
                style: const TextStyle(color: Colors.white, height: 1.4),
              )
            : _botMessage(msg['text']!),
      ),
    );
  }

  /// Gemini replies come back as Markdown, so render them properly
  /// instead of showing raw ** and * characters.
  Widget _botMessage(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.eco, size: 14, color: accentBlue),
            SizedBox(width: 6),
            Text(
              "EcoBot",
              style: TextStyle(
                color: accentBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MarkdownBody(
          data: text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.white, height: 1.45),
            strong: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            em: const TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
            listBullet: const TextStyle(color: Colors.white, height: 1.45),
            h1: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
            h2: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            h3: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            code: TextStyle(
              color: accentBlue,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              fontFamily: "monospace",
              fontSize: 13,
            ),
            codeblockDecoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            blockquoteDecoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            blockSpacing: 10,
          ),
        ),
      ],
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(accentBlue),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "EcoBot is thinking...",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
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
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              minLines: 1,
              maxLines: 4,
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
            color: _isTyping ? Colors.white30 : accentBlue,
            onPressed: _isTyping ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // 🔹 SEND MESSAGE
  void _sendMessage() {
    if (_controller.text.trim().isEmpty || _isTyping) return;

    final userText = _controller.text.trim();
    setState(() {
      messages.add({"role": "user", "text": userText});
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    sendMessageToGemini(userText);
  }

  Future<void> sendMessageToGemini(String userMessage) async {
    try {
      final response = await GeminiService.getResponse(userMessage);
      if (!mounted) return;

      setState(() {
        messages.add({"role": "bot", "text": response});
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.add({
          "role": "bot",
          "text": "⚠️ Sorry, I couldn't respond right now.",
        });
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }
}
