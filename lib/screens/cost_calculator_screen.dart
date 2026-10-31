import 'package:flutter/material.dart';

class CostCalculatorScreen extends StatefulWidget {
  const CostCalculatorScreen({super.key});

  @override
  State<CostCalculatorScreen> createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends State<CostCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _alternativeController = TextEditingController();

  double? _difference;
  double? _percentage;

  @override
  void dispose() {
    _currentController.dispose();
    _alternativeController.dispose();
    super.dispose();
  }

  double? _readAmount(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final current = _readAmount(_currentController.text)!;
    final alternative = _readAmount(_alternativeController.text)!;
    setState(() {
      _difference = current - alternative;
      _percentage = current == 0
          ? null
          : ((current - alternative) / current) * 100;
    });
  }

  String? _validateAmount(String? value) {
    final amount = value == null ? null : _readAmount(value);
    if (amount == null || amount < 0) {
      return 'أدخل رقماً صحيحاً موجباً أو صفراً.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = (_difference ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة مقارنة التكلفة')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF173F3C), Color(0xFF257B70)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFE7C68D),
                  size: 29,
                ),
                SizedBox(height: 12),
                Text(
                  'هل البديل أوفر؟',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'أدخل تكلفة الحل الحالي والبديل لمقارنة الفرق والنسبة الحسابية بينهما.',
                  style: TextStyle(
                    color: Color(0xFFD7E7E2),
                    fontSize: 12,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _CostFieldHeading(
                      number: '01',
                      title: 'الحل الحالي',
                    ),
                    const SizedBox(height: 9),
                    TextFormField(
                      controller: _currentController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'تكلفة الحل الحالي',
                        hintText: 'مثال: 12500',
                        prefixIcon: Icon(Icons.request_quote_outlined),
                      ),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 20),
                    const _CostFieldHeading(
                      number: '02',
                      title: 'البديل المقترح',
                    ),
                    const SizedBox(height: 9),
                    TextFormField(
                      controller: _alternativeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'تكلفة البديل',
                        hintText: 'مثال: 9800',
                        prefixIcon: Icon(Icons.currency_exchange_rounded),
                      ),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 13),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF9A7A48),
                          size: 17,
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'استخدم العملة ووحدة القياس نفسيهما في الرقمين.',
                            style: TextStyle(
                              color: Color(0xFF8A7D68),
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    FilledButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate_rounded),
                      label: const Text('احسب فرق التكلفة'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_difference != null) ...[
            const SizedBox(height: 17),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSaving
                    ? const Color(0xFFEAF5EF)
                    : const Color(0xFFFFF2E7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSaving
                      ? const Color(0xFFD4E9DD)
                      : const Color(0xFFF0DECC),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSaving
                            ? Icons.trending_down_rounded
                            : Icons.trending_up_rounded,
                        color: isSaving
                            ? const Color(0xFF287A58)
                            : const Color(0xFFB46D31),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSaving ? 'الوفر الحسابي' : 'الزيادة الحسابية',
                        style: TextStyle(
                          color: isSaving
                              ? const Color(0xFF28634C)
                              : const Color(0xFF8E572E),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _difference!.abs().toStringAsFixed(2),
                    style: TextStyle(
                      color: isSaving
                          ? const Color(0xFF1E6A4C)
                          : const Color(0xFF995D31),
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (_percentage != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      '${_percentage!.abs().toStringAsFixed(1)}٪ مقارنة بالتكلفة الحالية',
                      style: const TextStyle(
                        color: Color(0xFF64756E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(color: Color(0x338A9A90)),
                  const SizedBox(height: 8),
                  const Text(
                    'هذه مقارنة حسابية مباشرة، ولا تشمل فروق الجودة أو الصيانة أو المخاطر أو تغير الأسعار ما لم تُدخل ضمن التكاليف.',
                    style: TextStyle(
                      color: Color(0xFF718078),
                      fontSize: 11,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CostFieldHeading extends StatelessWidget {
  const _CostFieldHeading({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F1EE),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF176B64),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF264640),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
