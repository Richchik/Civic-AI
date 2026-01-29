import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // 🔐 Gemini API Key
  static const String _apiKey = "_";

  // ✅ Stable Gemini model
  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey";

  Future<Map<String, dynamic>> classifyIssue(String description) async {
    final prompt = """
You are an AI system for a civic issue reporting app.

Analyze the issue description and respond ONLY in valid JSON format with these keys:
- category (one word, e.g., Infrastructure, Garbage, Water, Electricity, Crime)
- urgency (Low, Medium, High)
- summary (short 1-line explanation)

Issue description:
"$description"
""";

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.2,
          "maxOutputTokens": 200,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Gemini API Error: ${response.body}");
    }

    final data = jsonDecode(response.body);

    // 🔒 Safe extraction
    final text =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'];

    if (text == null) {
      throw Exception("Invalid Gemini response");
    }

    // 🧠 Parse AI JSON safely
    final cleaned = text.trim().replaceAll('```json', '').replaceAll('```', '');

    return jsonDecode(cleaned);
  }
}
