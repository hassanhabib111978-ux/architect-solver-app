import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/engineering_alternative.dart';

class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = String.fromEnvironment('API_BASE_URL');

  Future<List<EngineeringAlternative>> generateAlternatives({
    required String description,
    required String projectType,
    String? location,
  }) async {
    if (_baseUrl.trim().isEmpty) {
      throw const AiServiceException(
        'خدمة الذكاء الاصطناعي غير مربوطة بعد. يجب إعداد خادم آمن أولاً.',
      );
    }

    final baseUri = Uri.tryParse(_baseUrl);
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      throw const AiServiceException('عنوان خادم الخدمة غير صالح.');
    }

    final uri = baseUri.resolve('/v1/engineering/alternatives');

    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'description': description.trim(),
              'project_type': projectType,
              'location': (location ?? '').trim(),
            }),
          )
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      throw const AiServiceException(
        'تعذر الاتصال بالخادم. تحقق من الاتصال وحاول مجدداً.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiServiceException(
        'تعذر إعداد البدائل (رمز الخادم: ${response.statusCode}).',
      );
    }

    late final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw const AiServiceException('استجابة الخادم ليست بصيغة JSON صحيحة.');
    }

    final rawAlternatives = decoded is Map<String, dynamic>
        ? decoded['alternatives']
        : null;

    if (rawAlternatives is! List) {
      throw const AiServiceException('صيغة البدائل الواردة من الخادم غير مكتملة.');
    }

    final alternatives = rawAlternatives
        .whereType<Map>()
        .map(
          (item) => EngineeringAlternative.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);

    if (alternatives.length != 3 ||
        alternatives.any((item) => item.title.isEmpty || item.description.isEmpty)) {
      throw const AiServiceException(
        'يجب أن يعيد الخادم ثلاثة بدائل مكتملة قبل عرض النتيجة.',
      );
    }

    return alternatives;
  }

  void dispose() {
    _client.close();
  }
}

class AiServiceException implements Exception {
  const AiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
