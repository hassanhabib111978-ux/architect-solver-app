import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const sections = <(String, String)>[
    (
      'قبل اختيار أي بديل',
      'حدد طبيعة المشكلة وموقعها وأبعادها، واجمع المخططات وتقارير الاختبارات وسجل المواد والتنفيذ إن توفرت. لا تعتمد على وصف مختصر وحده.'
    ),
    (
      'الأعمال الإنشائية',
      'تغيير الأعمدة أو الجسور أو البلاطات أو الأساسات، وكذلك القص والثقب والتدعيم، يتطلب مراجعة مهندس إنشائي للمخططات والأحمال والكود المعتمد قبل التنفيذ.'
    ),
    (
      'التربة والأساسات',
      'لا يمكن اختيار نوع الأساس أو معالجة التربة من اسم نوع التربة وحده. يلزم تقرير جيوتقني يوضح طبقات التربة ومنسوب المياه وقدرة التحمل والهبوط المتوقع.'
    ),
    (
      'الخرسانة والمعالجة',
      'لا تعتمد على عدد أيام ثابت لفك الشدات أو تحميل الخرسانة. يجب الرجوع إلى مقاومة الخرسانة الفعلية ومتطلبات التصميم والمواصفات وتعليمات المهندس المسؤول.'
    ),
    (
      'التكلفة والمدة',
      'الأرقام التقديرية تتغير حسب السوق والموقع وتوفر العمالة والمعدات وظروف الموقع. اطلب عروض أسعار موثقة وحدد نطاق العمل والعملة ووحدة القياس.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دليل السلامة والإرشاد')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'إرشادات عامة تساعدك على تجهيز المعلومات ومراجعة البدائل، ولا تمثل مواصفات تنفيذية أو بديلاً عن الكود المحلي.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 12),
          ...sections.map(
            (section) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                title: Text(
                  section.$1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(section.$2, style: const TextStyle(height: 1.7)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'عند وجود تشققات متزايدة أو هبوط أو تشوه أو أصوات غير معتادة في عنصر إنشائي، أوقف العمل وأبعد الأشخاص عن منطقة الخطر واطلب معاينة مهندس مختص فوراً.',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
