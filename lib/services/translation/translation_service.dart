import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  final String apiKey; // Your DeepL API Key
  final String baseUrl = 'https://api-free.deepl.com/v2/translate';

  TranslationService(this.apiKey);

  Future<String> translate(String text, String targetLang) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'auth_key': apiKey,
        'text': text,
        'target_lang': targetLang,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['translations'][0]['text'];
    } else {
      throw Exception('Failed to translate text');
    }
  }
}