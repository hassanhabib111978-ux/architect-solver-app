import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const sections = <(String, String, IconData)>[
    (
      'قبل اختيار أي بديل',
      'حدد طبيعة المشكلة وموقعها وأبعادها، واجمع المخططات وتقارير الاختبارات وسجل المواد والتنفيذ إن توفرت. لا تعتمد على وصف مختصر وحده.',
      Icons.fact_check_outlined,
    ),
    (
      'الأعمال الإنشائية',
      'تغيير الأعمدة أو الجسور أو البلاطات أو الأساسات، وكذلك القص والثقب والتدعيم، يتطلب مراجعة مهندس إنشائي للمخططات والأحمال والكود المعتمد قبل التنفيذ.',
      Icons.foundation_outlined,
    ),
    (
      'التربة والأساسات',
      'لا يمكن اختيار نوع الأساس أو معالجة التربة من اسم نوع التربة وحده. يلزم تقرير جيوتقني يوضح طبقات التربة ومنسوب المياه وقدرة التحمل والهبوط المتوقع.',
      Icons.terrain_rounded,
    ),
    (
      'الخرسانة والمعالجة',
      'لا تعتمد على عدد أيام ثابت لفك الشدات أو تحميل الخرسانة. يجب الرجوع إلى مقاومة الخرسانة الفعلية ومتطلبات التصميم والمواصفات وتعليمات المهندس المسؤول.',
      Icons.construction_rounded,
    ),
    (
      'التكلفة والمدة',
      'الأرقام التقديرية تتغير حسب السوق والموقع وتوفر العمالة والمعدات وظروف الموقع. اطلب عروض أسعار موثقة وحدد نطاق العمل والعملة ووحدة القياس.',
      Icons.price_change_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دليل السلامة والإرشاد')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF173F3C), Color(0xFF287B70)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFFE8C98F),
                  size: 30,
                ),
                SizedBox(height: 12),
                Text(
                  'مرجعك قبل اتخاذ القرار',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'نقاط عملية تساعدك على تجهيز المعلومات ومراجعة البدائل بأمان.',
                  style: TextStyle(
                    color: Color(0xFFD8E8E3),
                    fontSize: 12,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 19),
          const Text(
            'موضوعات الدليل',
            style: TextStyle(
              color: Color(0xFF1D433E),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...sections.asMap().entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3F0),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        entry.value.$3,
                        color: const Color(0xFF28766C),
                        size: 21,
                      ),
                    ),
                    title: Text(
                      entry.value.$1,
                      style: const TextStyle(
                        color: Color(0xFF264640),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      'الموضوع ${entry.key + 1}',
                      style: const TextStyle(
                        color: Color(0xFF9AA7A2),
                        fontSize: 10,
                      ),
                    ),
                    iconColor: const Color(0xFF24756B),
                    collapsedIconColor: const Color(0xFF8A9A94),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(17, 0, 17, 17),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          entry.value.$2,
                          style: const TextStyle(
                            color: Color(0xFF64756F),
                            height: 1.75,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1DFCC)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB46C32),
                  size: 23,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'عند وجود تشققات متزايدة أو هبوط أو تشوه أو أصوات غير معتادة في عنصر إنشائي، أوقف العمل وأبعد الأشخاص عن منطقة الخطر واطلب معاينة مهندس مختص فوراً.',
                    style: TextStyle(
                      color: Color(0xFF805733),
                      fontSize: 11,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'هذه إرشادات عامة وليست مواصفات تنفيذية أو بديلاً عن الكود المحلي والمهندس المسؤول.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF96A29D),
              fontSize: 10,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
