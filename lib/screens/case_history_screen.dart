import 'package:flutter/material.dart';

import '../services/case_history_service.dart';

class CaseHistoryScreen extends StatefulWidget {
  const CaseHistoryScreen({super.key});

  @override
  State<CaseHistoryScreen> createState() => _CaseHistoryScreenState();
}

class _CaseHistoryScreenState extends State<CaseHistoryScreen> {
  late Future<List<Map<String, Object?>>> _casesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _casesFuture = CaseHistoryService.instance.getCases();
  }

  Future<void> _delete(int id) async {
    await CaseHistoryService.instance.deleteCase(id);
    if (!mounted) return;
    setState(_refresh);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف الحالة من السجل المحلي.')),
    );
  }

  void _showDetails(Map<String, Object?> item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text((item['project_type'] ?? 'حالة هندسية').toString()),
        content: SingleChildScrollView(
          child: Text((item['description'] ?? '').toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _formatDate(Object? raw) {
    final date = DateTime.tryParse((raw ?? '').toString())?.toLocal();
    if (date == null) return 'تاريخ غير متاح';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الحالات'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: () => setState(_refresh),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: _casesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'تعذر فتح السجل المحلي: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final cases = snapshot.data ?? const <Map<String, Object?>>[];
          if (cases.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 54, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('لا توجد حالات محفوظة حتى الآن.'),
                    SizedBox(height: 6),
                    Text(
                      'ستظهر هنا الحالات التي ترسلها من الصفحة الرئيسية.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: cases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = cases[index];
              final id = item['id'] as int;
              final description = (item['description'] ?? '').toString();
              final location = (item['location'] ?? '').toString();

              return Card(
                child: ListTile(
                  onTap: () => _showDetails(item),
                  leading: const CircleAvatar(
                    child: Icon(Icons.engineering_outlined),
                  ),
                  title: Text((item['project_type'] ?? '').toString()),
                  subtitle: Text(
                    '${_formatDate(item['created_at'])}
'
                    '${location.isEmpty ? 'الموقع غير محدد' : location}
'
                    '${description.length > 90 ? '${description.substring(0, 90)}…' : description}',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'حذف الحالة',
                    onPressed: () => _delete(id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
