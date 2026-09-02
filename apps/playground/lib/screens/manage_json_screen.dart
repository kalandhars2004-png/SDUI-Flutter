import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sdui_builder/sdui_builder.dart';
import '../services/sdui_graphql_service.dart';

// Screen A — paste/pick → save via GraphQL (MySQL behind) → list → Load UI → redirect to Main drag-drop
class ManageJsonScreen extends StatefulWidget {
  final BuilderController controller; // same instance as Main
  final SduiGraphqlService service;
  final VoidCallback? onLoaded; // to switch tab / pop

  const ManageJsonScreen({super.key, required this.controller, required this.service, this.onLoaded});

  @override
  State<ManageJsonScreen> createState() => _ManageJsonScreenState();
}

class _ManageJsonScreenState extends State<ManageJsonScreen> {
  final _nameCtrl = TextEditingController();
  final _jsonCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: true);
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    if (f.bytes != null) {
      _jsonCtrl.text = utf8.decode(f.bytes!);
      // try to derive name from file
      if (_nameCtrl.text.isEmpty) _nameCtrl.text = f.name.replaceAll('.json', '');
      setState(() {});
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final jsonStr = _jsonCtrl.text.trim();
    if (name.isEmpty || jsonStr.isEmpty) {
      setState(() => _error = 'Name and JSON required');
      return;
    }
    // validate via engine parser (same validator as canvas)
    try {
      widget.controller.engine.parseJsonString(jsonStr);
    } catch (e) {
      setState(() => _error = 'Invalid SDUI JSON: $e');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await widget.service.saveTemplate(name: name, json: jsonStr);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to MySQL via GraphQL')));
      _jsonCtrl.clear();
      setState(() {});
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadIntoMain(SduiTemplateModel t) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      await widget.controller.loadFromJsonStringAsync(t.json, templateId: t.id, templateName: t.name);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loaded "${t.name}" into Main — now edit & Save to DB as new')));
      widget.onLoaded?.call();
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load failed: $e'), backgroundColor: Colors.red.shade400));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manage JSON — GraphQL + MySQL', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: LayoutBuilder(builder: (context, c) {
        final isWide = c.maxWidth > 900;
        final form = _buildForm();
        final list = _buildList();
        if (isWide) {
          return Row(children: [SizedBox(width: 420, child: form), VerticalDivider(width: 1, color: Colors.grey.shade200), Expanded(child: list)]);
        }
        return Column(children: [SizedBox(height: 340, child: form), Divider(height: 1, color: Colors.grey.shade200), Expanded(child: list)]);
      }),
    );
  }

  Widget _buildForm() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('ADD JSON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Name *', hintText: 'e.g., HomeScreen v1', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true, filled: true, fillColor: const Color(0xFFF8FAFC))),
          const SizedBox(height: 12),
          Row(children: [
            OutlinedButton.icon(onPressed: _pickFile, icon: const Icon(Icons.folder_open, size: 16), label: const Text('Pick JSON file')),
            const SizedBox(width: 8),
            Text('or paste below', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ]),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: TextField(
              controller: _jsonCtrl,
              maxLines: 14,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12), hintText: '{"version":"1.0","type":"column",...}'),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: TextStyle(color: Colors.red.shade600, fontSize: 12))],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cloud_upload, size: 16),
              label: Text(_saving ? 'Saving via GraphQL...' : 'Save to MySQL (GraphQL)'),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Stored as TEXT/MEDIUMTEXT in MySQL sdui_template table, strictly via GraphQL mutation saveTemplate', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              Text('SAVED TEMPLATES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.grey.shade600)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () => setState(() {}), tooltip: 'Refresh'),
            ]),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: FutureBuilder<List<SduiTemplateModel>>(
              future: widget.service.fetchTemplates(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snap.hasError) return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('GraphQL error:\n${snap.error}', style: TextStyle(color: Colors.red.shade600, fontSize: 12))));
                final items = snap.data ?? [];
                if (items.isEmpty) return Center(child: Text('No templates yet\nSave JSON above', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)));
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = items[i];
                    final preview = t.json.length > 80 ? '${t.json.substring(0, 80)}...' : t.json;
                    return Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)]),
                      child: ListTile(
                        title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('id: ${t.id.substring(0, 8)}... • v${t.version ?? '1.0'}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontFamily: 'monospace')),
                          const SizedBox(height: 4),
                          Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontFamily: 'monospace')),
                        ]),
                        trailing: Wrap(spacing: 6, children: [
                          FilledButton(onPressed: () => _loadIntoMain(t), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), visualDensity: VisualDensity.compact), child: const Text('Load UI', style: TextStyle(fontSize: 11))),
                          IconButton(icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400), onPressed: () async { await widget.service.deleteTemplate(t.id); if (context.mounted) setState(() {}); }, tooltip: 'Delete'),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
