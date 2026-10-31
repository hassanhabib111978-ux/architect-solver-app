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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F625D), Color(0xFF278A7B)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.architecture_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('مساعد البدائل الهندسية'),
                  SizedBox(height: 2),
                  Text(
                    'قرارات أوضح لمشاريع أفضل',
                    style: TextStyle(
                      color: Color(0xFF788984),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الدليل الإرشادي',
            onPressed: () => _open(const GuideScreen()),
            icon: const Icon(Icons.help_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            _HeroPanel(),
            const SizedBox(height: 17),
            const _WorkflowStrip(),
            const SizedBox(height: 24),
            const _SectionHeading(
              eyebrow: 'ابدأ من هنا',
              title: 'ما طبيعة الحالة التي تعمل عليها؟',
              subtitle: 'أدخل التفاصيل الأساسية لنرتب لك مسار المقارنة.',
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _FieldLabel(
                        icon: Icons.domain_rounded,
                        title: 'نوع المشروع',
                      ),
                      const SizedBox(height: 9),
                      DropdownButtonFormField<String>(
                        initialValue: _projectType,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: 'اختر نوع المشروع',
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
                          if (value != null) {
                            setState(() => _projectType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 19),
                      const _FieldLabel(
                        icon: Icons.edit_note_rounded,
                        title: 'وصف المشكلة أو المطلوب',
                      ),
                      const SizedBox(height: 9),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 4,
                        maxLines: 7,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText:
                              'اشرح الحالة، الأبعاد التقريبية، المواد الموجودة، والقيود المعروفة...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 15) {
                            return 'اكتب وصفاً واضحاً لا يقل عن 15 حرفاً.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 19),
                      const _FieldLabel(
                        icon: Icons.location_on_outlined,
                        title: 'موقع المشروع',
                        optional: true,
                      ),
                      const SizedBox(height: 9),
                      TextFormField(
                        controller: _locationController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'المدينة أو المنطقة',
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed:
                            _openingSolutions ? null : _showSolutions,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_openingSolutions)
                              const SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(Icons.compare_arrows_rounded),
                            const SizedBox(width: 9),
                            Text(
                              _openingSolutions
                                  ? 'جارٍ تجهيز الحالة...'
                                  : 'اعرض البدائل الهندسية',
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_back_rounded, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      const Text(
                        'سيتم حفظ وصف الحالة على هذا الجهاز ضمن سجل الحالات.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF899792),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            const _SectionHeading(
              eyebrow: 'أدوات العمل',
              title: 'كل ما تحتاجه في موقعك',
              subtitle: 'اختصارات سريعة لتنظيم الصور والحسابات والمعلومات.',
            ),
            const SizedBox(height: 13),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              childAspectRatio: 1.48,
              children: [
                _QuickActionTile(
                  icon: Icons.add_a_photo_rounded,
                  title: 'تصوير الموقع',
                  subtitle: 'أضف صورة وملاحظات',
                  tint: const Color(0xFFE5F2EF),
                  iconColor: const Color(0xFF176C63),
                  onTap: () => _open(const SiteImageScreen()),
                ),
                _QuickActionTile(
                  icon: Icons.history_rounded,
                  title: 'سجل الحالات',
                  subtitle: 'راجع أعمالك السابقة',
                  tint: const Color(0xFFEAF0F8),
                  iconColor: const Color(0xFF4C6E99),
                  onTap: () => _open(const CaseHistoryScreen()),
                ),
                _QuickActionTile(
                  icon: Icons.calculate_rounded,
                  title: 'حاسبة التكلفة',
                  subtitle: 'قارن فرق التكاليف',
                  tint: const Color(0xFFFFF1DF),
                  iconColor: const Color(0xFFB87928),
                  onTap: () => _open(const CostCalculatorScreen()),
                ),
                _QuickActionTile(
                  icon: Icons.menu_book_rounded,
                  title: 'الدليل الإرشادي',
                  subtitle: 'ملاحظات هندسية مهمة',
                  tint: const Color(0xFFF0EAF8),
                  iconColor: const Color(0xFF8061A1),
                  onTap: () => _open(const GuideScreen()),
                ),
              ],
            ),
            const SizedBox(height: 19),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF1E1C7)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.health_and_safety_outlined,
                    color: Color(0xFFB87928),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'المخرجات إرشادية أولية للمقارنة فقط، ولا تستبدل المعاينة والاختبارات والمخططات أو مراجعة المهندس المختص.',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.65,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'مساعد البدائل الهندسية  •  إصدار تجريبي',
                style: TextStyle(
                  color: Color(0xFF9AA6A2),
                  fontSize: 10,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF123F3D), Color(0xFF176D65), Color(0xFF268879)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -38,
              top: -48,
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 38,
              bottom: -76,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(21, 22, 21, 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFE6BE79),
                          size: 15,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'رفيقك في اتخاذ القرار الهندسي',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 19),
                  const Text(
                    'من المشكلة إلى\nالبديل الأنسب.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1.24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'نظّم تفاصيل الحالة، وقارن الحلول من حيث التكلفة والجودة ووقت التنفيذ.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 13,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 17),
                  const Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _HeroPill(icon: Icons.payments_outlined, label: 'التكلفة'),
                      _HeroPill(icon: Icons.verified_outlined, label: 'الجودة'),
                      _HeroPill(icon: Icons.schedule_rounded, label: 'الوقت'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE8C88F), size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowStrip extends StatelessWidget {
  const _WorkflowStrip();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('01', 'صف الحالة'),
      ('02', 'قارن البدائل'),
      ('03', 'تحقق ونفّذ'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECEA)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Text(
                    steps[i].$1,
                    style: const TextStyle(
                      color: Color(0xFFB47C31),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[i].$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF49615C),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (i < steps.length - 1)
              const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFFB7C4BF),
                size: 19,
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFFB47C31),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF183D3A),
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7D8D88),
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.icon,
    required this.title,
    this.optional = false,
  });

  final IconData icon;
  final String title;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF28776E), size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF254541),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          const Text(
            'اختياري',
            style: TextStyle(
              color: Color(0xFF9AA7A2),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE6ECEA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF23423E),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8B9994),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
