import 'package:flutter/material.dart';

import '../services/case_history_service.dart';
import 'case_history_screen.dart';
import 'cost_calculator_screen.dart';
import 'guide_screen.dart';
import 'site_image_screen.dart';
import 'solution_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _projectType = 'مبنى سكني';
  bool _openingSolutions = false;

  static const _projectTypes = [
    'مبنى سكني',
    'مبنى تجاري',
    'ترميم وصيانة',
    'أعمال طرق وبنية تحتية',
    'أعمال تشطيبات',
    'أخرى',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _showSolutions() async {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();
    final projectType = _projectType;

    setState(() => _openingSolutions = true);
    try {
      try {
        await CaseHistoryService.instance.saveCase(
          description: description,
          projectType: projectType,
          location: location,
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر حفظ الحالة محلياً، لكن يمكنك متابعة طلبك.'),
            ),
          );
        }
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SolutionScreen(
            description: description,
            projectType: projectType,
            location: location,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingSolutions = false);
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مساعد البدائل الهندسية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF176B67), Color(0xFF2C8B7D)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.architecture, color: Colors.white, size: 38),
                  SizedBox(height: 12),
                  Text(
                    'حلّل المشكلة وقارن البدائل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'أدخل تفاصيل الحالة للحصول على مقارنة أولية بين التكلفة والجودة وسرعة التنفيذ عند ربط الخدمة.',
                    style: TextStyle(color: Colors.white, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'نوع المشروع',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _projectType,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.apartment),
                    ),
                    items: _projectTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _projectType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'وصف المشكلة أو المطلوب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 5,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'اشرح الحالة، الأبعاد التقريبية، المواد الموجودة، والقيود المعروفة...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 15) {
                        return 'اكتب وصفاً لا يقل عن 15 حرفاً.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'موقع المشروع (اختياري)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'المدينة أو المنطقة',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _openingSolutions ? null : _showSolutions,
                    icon: _openingSolutions
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.compare_arrows),
                    label: const Text('عرض البدائل الهندسية'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _open(const SiteImageScreen()),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('تصوير الموقع'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _open(const CaseHistoryScreen()),
                    icon: const Icon(Icons.history),
                    label: const Text('سجل الحالات'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _open(const CostCalculatorScreen()),
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('حاسبة التكلفة'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _open(const GuideScreen()),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('دليل إرشادي'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'تنبيه: التطبيق أداة مساعدة أولية، ولا يحل محل المعاينة والاختبارات والمخططات أو مراجعة المهندس المختص.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.6, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
