import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/site_vision_service.dart';

class SiteImageScreen extends StatefulWidget {
  const SiteImageScreen({super.key});

  @override
  State<SiteImageScreen> createState() => _SiteImageScreenState();
}

class _SiteImageScreenState extends State<SiteImageScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _notesController = TextEditingController();
  final SiteVisionService _visionService = SiteVisionService();

  XFile? _image;
  String? _analysis;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _recoverLostImage();
  }

  Future<void> _recoverLostImage() async {
    try {
      final response = await _picker.retrieveLostData();
      final files = response.files;
      if (files != null && files.isNotEmpty && mounted) {
        setState(() {
          _image = files.first;
          _error = null;
        });
      }
    } catch (_) {
      // Recovery is best-effort; the user can choose the image again.
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _visionService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 82,
      );
      if (!mounted || picked == null) return;
      setState(() {
        _image = picked;
        _analysis = null;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'تعذر فتح الكاميرا أو معرض الصور.');
    }
  }

  Future<void> _chooseSource() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('التقاط صورة بالكاميرا'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('اختيار صورة من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyze() async {
    final image = _image;
    if (image == null || _busy) return;

    setState(() {
      _busy = true;
      _error = null;
      _analysis = null;
    });

    try {
      final result = await _visionService.analyzeImage(
        image: image,
        siteNotes: _notesController.text,
      );
      if (mounted) setState(() => _analysis = result);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تصوير الموقع وتحليل الصورة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'التقط صورة للموقع أو اخترها من المعرض، ثم أضف وصفاً يساعد على فهم ما يظهر فيها.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 14),
          if (_image == null)
            InkWell(
              onTap: _chooseSource,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 210,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.teal),
                    SizedBox(height: 10),
                    Text('اضغط لإضافة صورة الموقع'),
                  ],
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(_image!.path),
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _chooseSource,
            icon: const Icon(Icons.image_search_outlined),
            label: Text(_image == null ? 'اختيار صورة' : 'تغيير الصورة'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'ملاحظات عن الصورة (اختياري)',
              hintText: 'مثلاً: شق في جدار، رطوبة، تلف تشطيبات، أو موقع العمل...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _image == null || _busy ? null : _analyze,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.document_scanner_outlined),
            label: Text(_busy ? 'جارٍ إرسال الصورة...' : 'تحليل الصورة'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (_analysis != null) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملاحظات التحليل الأولي',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(_analysis!, style: const TextStyle(height: 1.7)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تنبيه: لا يمكن الجزم بسلامة العناصر الإنشائية أو تشخيص أسباب الشقوق من صورة وحدها. يلزم فحص موقعي وقياسات ومراجعة مهندس مختص قبل اتخاذ قرار تنفيذي.',
              style: TextStyle(color: Colors.black54, height: 1.6, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
