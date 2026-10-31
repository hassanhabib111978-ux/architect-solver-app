import 'package:flutter/material.dart';

import '../models/engineering_alternative.dart';
import '../services/ai_service.dart';

class SolutionScreen extends StatefulWidget {
  const SolutionScreen({
    super.key,
    required this.description,
    required this.projectType,
    required this.location,
  });

  final String description;
  final String projectType;
  final String location;

  @override
  State<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen> {
  late final AiService _service;
  late Future<List<EngineeringAlternative>> _future;

  @override
  void initState() {
    super.initState();
    _service = AiService();
    _future = _load();
  }

  Future<List<EngineeringAlternative>> _load() {
    return _service.generateAlternatives(
      description: widget.description,
      projectType: widget.projectType,
      location: widget.location,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مقارنة البدائل'),
      ),
      body: FutureBuilder<List<EngineeringAlternative>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }

          if (snapshot.hasError) {
            return _ServiceUnavailableState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final alternatives = snapshot.data ?? const <EngineeringAlternative>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
            children: [
              _ComparisonHeader(
                projectType: widget.projectType,
                location: widget.location,
                count: alternatives.length,
              ),
              const SizedBox(height: 17),
              const Text(
                'الخيارات المتاحة',
                style: TextStyle(
                  color: Color(0xFF1C403B),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...alternatives.asMap().entries.map(
                    (entry) => _AlternativeCard(
                      number: entry.key + 1,
                      alternative: entry.value,
                    ),
                  ),
              const SizedBox(height: 8),
              const _SafetyNotice(),
            ],
          );
        },
      ),
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader({
    required this.projectType,
    required this.location,
    required this.count,
  });

  final String projectType;
  final String location;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF153F3D), Color(0xFF20796F)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fact_check_rounded, color: Color(0xFFE6C58C)),
              SizedBox(width: 8),
              Text(
                'ملخص طلب المقارنة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            projectType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 21,
            ),
          ),
          if (location.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFBBD7D0),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(color: Color(0xFFD5E6E1)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count بدائل للمقارنة',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({
    required this.number,
    required this.alternative,
  });

  final int number;
  final EngineeringAlternative alternative;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
            color: const Color(0xFFEAF3F0),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF176B64),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      number.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alternative.category.isEmpty
                            ? 'البديل المقترح'
                            : alternative.category,
                        style: const TextStyle(
                          color: Color(0xFF55716B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alternative.title,
                        style: const TextStyle(
                          color: Color(0xFF193F3A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alternative.description,
                  style: const TextStyle(
                    color: Color(0xFF50645F),
                    height: 1.65,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.payments_outlined,
                        label: 'التكلفة التقديرية',
                        value: alternative.estimatedCost,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.schedule_rounded,
                        label: 'مدة التنفيذ',
                        value: alternative.estimatedDuration,
                      ),
                    ),
                  ],
                ),
                if (alternative.advantages.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  _BulletSection(
                    title: 'نقاط القوة',
                    items: alternative.advantages,
                    icon: Icons.add_circle_outline_rounded,
                    color: const Color(0xFF287A63),
                  ),
                ],
                if (alternative.disadvantages.isNotEmpty) ...[
                  const SizedBox(height: 13),
                  _BulletSection(
                    title: 'القيود والملاحظات',
                    items: alternative.disadvantages,
                    icon: Icons.info_outline_rounded,
                    color: const Color(0xFFB47C31),
                  ),
                ],
                if (alternative.safetyNotes.isNotEmpty) ...[
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E9),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.health_and_safety_outlined,
                          color: Color(0xFFB47C31),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alternative.safetyNotes,
                            style: const TextStyle(
                              color: Color(0xFF72572F),
                              height: 1.55,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F7),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE8EEEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: const Color(0xFF28776E)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7C8C86),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.trim().isEmpty ? 'غير محدد' : value,
            style: const TextStyle(
              color: Color(0xFF284640),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF294A44),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(top: 5, right: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: TextStyle(color: color)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Color(0xFF63746E),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1EE),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF176B64),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 19),
            const Text(
              'جارٍ تجهيز المقارنة',
              style: TextStyle(
                color: Color(0xFF1F4942),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'نتحقق من الاتصال بالخدمة الآمنة لاسترجاع البدائل.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF82918B), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceUnavailableState extends StatelessWidget {
  const _ServiceUnavailableState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5ECE8)),
          ),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E5),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Color(0xFFB77935),
                  size: 32,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'خدمة البدائل غير متصلة حالياً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1F433D),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF71827C),
                  height: 1.6,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E7),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF0E1C9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB47C31),
            size: 21,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'هذه البدائل معلومات أولية للمقارنة وليست مخططات تنفيذية أو اعتماداً هندسياً. يجب التحقق من الأحمال والمواد والتربة والكود المحلي بواسطة مهندس مختص قبل اتخاذ القرار أو التنفيذ.',
              style: TextStyle(
                color: Color(0xFF715A37),
                fontSize: 11,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
