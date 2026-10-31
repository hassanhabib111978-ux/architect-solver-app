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
      _percentage = current == 0 ? null : ((current - alternative) / current) * 100;
    });
  }

  String? _validateAmount(String? value) {
    final amount = value == null ? null : _readAmount(value);
    if (amount == null || amount < 0) return 'أدخل رقماً صحيحاً موجباً أو صفراً.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة مقارنة التكلفة')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'قارن بين تكلفة الحل الحالي والبديل المقترح. استخدم العملة والوحدة نفسيهما في الرقمين.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _currentController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'تكلفة الحل الحالي',
                    suffixText: 'قيمة نقدية',
                  ),
                  validator: _validateAmount,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _alternativeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'تكلفة البديل',
                    suffixText: 'قيمة نقدية',
                  ),
                  validator: _validateAmount,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('احسب الفرق'),
                  ),
                ),
              ],
            ),
          ),
          if (_difference != null) ...[
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _difference! >= 0 ? 'الوفر الحسابي' : 'الزيادة الحسابية',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _difference!.abs().toStringAsFixed(2),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    if (_percentage != null)
                      Text('النسبة مقارنة بالتكلفة الحالية: ${_percentage!.toStringAsFixed(1)}٪'),
                    const SizedBox(height: 8),
                    const Text(
                      'الحساب لا يشمل فروق الجودة أو الصيانة أو المخاطر أو تغير الأسعار ما لم تُدخل ضمن التكاليف.',
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
