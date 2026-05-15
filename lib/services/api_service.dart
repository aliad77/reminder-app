import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _quoteUrl = 'https://api.quotable.io/random';

  Future<Map<String, String>> fetchQuote() async {
    try {
      final response = await http
          .get(Uri.parse(_quoteUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'content': data['content'] as String? ?? '',
          'author': data['author'] as String? ?? 'Unknown',
        };
      }
      return _fallbackQuote();
    } catch (_) {
      return _fallbackQuote();
    }
  }

  Map<String, String> _fallbackQuote() => {
        'content': 'The secret of getting ahead is getting started.',
        'author': 'Mark Twain',
      };
}
