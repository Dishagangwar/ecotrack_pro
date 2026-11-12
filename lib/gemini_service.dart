import 'dart:convert';
import 'dart:io'; 
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get _endpoint =>
  "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$_apiKey";
  /// Keeps replies short and well structured so they render nicely
  /// in the chat bubbles instead of arriving as a wall of text.
  static const String _styleGuide = """
You are EcoBot, a friendly sustainability assistant inside a mobile app.
Answer in Markdown, kept short enough to read on a phone:
- Lead with one short sentence that answers the question directly.
- Then at most 3-4 bullet points, one line each.
- Bold only the key term in a bullet, not whole sentences.
- No headings, no tables, no emoji spam, no closing pep talk.
Stay under 120 words unless the user asks for detail.
""";

  static Future<String> getResponse(String prompt) async {
    try {
      print("🟡 Gemini request: $prompt");

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "$_styleGuide\n\nUser question: $prompt"},
              ],
            },
          ],
        }),
      );

      print("🟢 STATUS CODE: ${response.statusCode}");
      print("🟢 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "Gemini error ${response.statusCode}";
      }
    } catch (e) {
      print("🔴 GEMINI EXCEPTION: $e");
      return "Gemini exception occurred";
    }
  }
  static Future<String> _convertToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Analyze Image
  static Future<String> analyzeImage(File imageFile) async {
    final base64Image = await _convertToBase64(imageFile);

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": """
You are an environmental sustainability expert.

1. Identify the item.
2. Is it eco-friendly? (Yes/No + why)
3. Estimated carbon impact (Low/Medium/High)
4. 3 eco-friendly suggestions.

Keep response short and structured.
"""
              },
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception("Gemini API Error: ${response.body}");
    }
  }
}
