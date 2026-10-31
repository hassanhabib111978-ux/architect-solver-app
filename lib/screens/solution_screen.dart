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

  Future<void> _retry() async {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البدائل المقترحة')),
      body: FutureBuilder<List<EngineeringAlternative>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 14),
                  Text('تجري محاولة الاتصال بالخدمة الآمنة...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 14),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          final alternatives = snapshot.data ?? const <EngineeringAlternative>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'المقارنة الأولية',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('نوع المشروع: ${widget.projectType}'),
              const SizedBox(height: 14),
              ...alternatives.asMap().entries.map(
                    (entry) => _AlternativeCard(
                      number: entry.key + 1,
                      alternative: entry.value,
                    ),
                  ),
              const SizedBox(height: 10),
              const _SafetyNotice(),
            ],
          );
        },
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
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البديل $number · ${alternative.category}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              alternative.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 9),
            Text(alternative.description),
            const Divider(height: 24),
            _InfoLine(label: 'التكلفة التقديرية', value: alternative.estimatedCost),
            _InfoLine(label: 'المدة التقديرية', value: alternative.estimatedDuration),
            if (alternative.advantages.isNotEmpty)
              _BulletSection(title: 'المزايا', items: alternative.advantages),
            if (alternative.disadvantages.isNotEmpty)
              _BulletSection(title: 'القيود والملاحظات', items: alternative.disadvantages),
            if (alternative.safetyNotes.isNotEmpty)
              _InfoLine(label: 'اعتبارات السلامة', value: alternative.safetyNotes),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text('$label: $value', style: const TextStyle(height: 1.5)),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Color(0xFFFFF3DF),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'هذه البدائل معلومات أولية للمقارنة وليست مخططات تنفيذية أو اعتماداً هندسياً. يجب التحقق من الأحمال والمواد والتربة والكود المحلي بواسطة مهندس مختص قبل اتخاذ القرار أو التنفيذ.',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }
}
