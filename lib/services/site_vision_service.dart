import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SiteVisionService {
  SiteVisionService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = String.fromEnvironment('API_BASE_URL');

  Future<String> analyzeImage({
    required XFile image,
    required String siteNotes,
  }) async {
    if (_baseUrl.trim().isEmpty) {
      throw const SiteVisionException(
        'تحليل الصور غير متاح بعد. يجب إعداد الخادم الآمن أولاً.',
      );
    }

    final baseUri = Uri.tryParse(_baseUrl);
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      throw const SiteVisionException('عنوان خادم الخدمة غير صالح.');
    }

    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      throw const SiteVisionException('الصورة المختارة فارغة أو تعذر قراءتها.');
    }
    if (bytes.length > 12 * 1024 * 1024) {
      throw const SiteVisionException('حجم الصورة أكبر من الحد المسموح (12 ميغابايت).');
    }

    final extension = image.name.toLowerCase().split('.').last;
    final mimeType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    late final http.Response response;
    try {
      response = await _client
          .post(
            baseUri.resolve('/v1/engineering/site-image'),
            headers: const {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'image_base64': base64Encode(bytes),
              'mime_type': mimeType,
              'site_notes': siteNotes.trim(),
            }),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const SiteVisionException(
        'تعذر الاتصال بخادم تحليل الصور. تحقق من الاتصال وحاول مجدداً.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SiteVisionException(
        'تعذر تحليل الصورة (رمز الخادم: ${response.statusCode}).',
      );
    }

    late final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw const SiteVisionException('استجابة الخادم ليست بصيغة JSON صحيحة.');
    }

    final result = decoded is Map<String, dynamic>
        ? (decoded['analysis'] ?? decoded['report'] ?? decoded['result'])
        : null;

    if (result is! String || result.trim().isEmpty) {
      throw const SiteVisionException('لم يُرجع الخادم تقريراً صالحاً للصورة.');
    }

    return result.trim();
  }

  void dispose() {
    _client.close();
  }
}

class SiteVisionException implements Exception {
  const SiteVisionException(this.message);

  final String message;

  @override
  String toString() => message;
}
