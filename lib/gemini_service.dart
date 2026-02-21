import 'dart:convert';
import 'dart:io'; 
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = "AIzaSyCJjw4RuSFOeHyafN-FNQzc9Oc9UMgyyUg";

  static const String _endpoint =
  "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$_apiKey";
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
                {"text": prompt},
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
