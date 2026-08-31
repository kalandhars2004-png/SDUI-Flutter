import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/component_definition.dart';
import '../state/builder_controller.dart';
import '../widgets/component_palette.dart';
import '../widgets/canvas.dart';
import '../widgets/property_inspector.dart';
import '../widgets/json_viewer.dart';

class BuilderScreen extends StatefulWidget {
  final BuilderController controller;
  const BuilderScreen({super.key, required this.controller});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _Header(controller: widget.controller),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                // Desktop XL >=1100
                if (w >= 1100) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 260,
                        child: ComponentPalette(
                          onAddTap: (def) => widget.controller.addNode(def),
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.grey.shade200),
                      Expanded(
                        child: BuilderCanvas(controller: widget.controller),
                      ),
                      VerticalDivider(width: 1, color: Colors.grey.shade200),
                      SizedBox(
                        width: 340,
                        child: PropertyInspector(controller: widget.controller),
                      ),
                    ],
                  );
                }
                // Desktop/Tablet 760-1099
                if (w >= 760) {
                  final paletteW = w < 900 ? 220.0 : 240.0;
                  final inspectorW = w < 900 ? 300.0 : 320.0;
                  return Row(
                    children: [
                      SizedBox(
                        width: paletteW,
                        child: ComponentPalette(
                          onAddTap: (def) => widget.controller.addNode(def),
                          compact: w < 900,
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.grey.shade200),
                      Expanded(
                        child: BuilderCanvas(controller: widget.controller),
                      ),
                      VerticalDivider(width: 1, color: Colors.grey.shade200),
                      SizedBox(
                        width: inspectorW,
                        child: PropertyInspector(controller: widget.controller),
                      ),
                    ],
                  );
                }
                // Compact tablet 600-759
                if (w >= 600) {
                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 180,
                              child: ComponentPalette(
                                onAddTap: (def) =>
                                    widget.controller.addNode(def),
                                compact: true,
                              ),
                            ),
                            VerticalDivider(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            Expanded(
                              child: BuilderCanvas(
                                controller: widget.controller,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      SizedBox(
                        height: (h * 0.36).clamp(280, 360).toDouble(),
                        child: PropertyInspector(
                          controller: widget.controller,
                          isBottomSheet: true,
                        ),
                      ),
                    ],
                  );
                }
                // Mobile <600
                return Column(
                  children: [
                    // Top horizontal palette
                    SizedBox(
                      height: 96,
                      child: _HorizontalPalette(controller: widget.controller),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    Expanded(
                      child: BuilderCanvas(controller: widget.controller),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    SizedBox(
                      height: (h * 0.34).clamp(260, 320).toDouble(),
                      child: PropertyInspector(
                        controller: widget.controller,
                        isBottomSheet: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalPalette extends StatelessWidget {
  final BuilderController controller;
  const _HorizontalPalette({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Show key components in horizontal scroll, compact chips
    final defs = [
      ..._pick(['column', 'row', 'container', 'stack']),
      ..._pick(['text', 'button', 'image', 'icon']),
      ..._pick(['card', 'list']),
    ];
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'COMPONENTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'tap to add • drag to canvas',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Text(
                '${defs.length} items',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: defs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final def = defs[i]!;
                return _HChip(def: def, onTap: () => controller.addNode(def));
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ComponentDefinition?> _pick(List<String> types) {
    return types
        .map((t) {
          try {
            return ComponentCatalog.byType(t);
          } catch (_) {
            return null;
          }
        })
        .whereType<ComponentDefinition>()
        .toList();
  }
}

class _HChip extends StatelessWidget {
  final ComponentDefinition def;
  final VoidCallback onTap;
  const _HChip({required this.def, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(def.icon, size: 14, color: const Color(0xFF334155)),
            ),
            const SizedBox(width: 8),
            Text(
              def.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final BuilderController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final isCompact = w < 720;
          final isVeryCompact = w < 520;
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.view_quilt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              if (!isVeryCompact)
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SDUI Builder',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isCompact)
                        const Text(
                          'Generic Flutter Server-Driven UI',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              if (!isCompact) const SizedBox(width: 14),
              if (!isCompact)
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Engine: Connected',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 12,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 8),
                          AnimatedBuilder(
                            animation: controller,
                            builder: (_, __) => Text(
                              'Components: ${controller.componentCount}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Schema: v1.0',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              _HeaderActions(controller: controller, compact: isCompact),
            ],
          );
        },
      ),
    );
  }
}

extension on BuilderController {
  int get componentCount => document.root.children.length;
}

class _HeaderActions extends StatelessWidget {
  final BuilderController controller;
  final bool compact;
  const _HeaderActions({required this.controller, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Always show full labels — ensures Generate JSON is never truncated
        final isNarrow =
            compact; // compact = w<720, still show full but tighter spacing
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconBtn(
              icon: Icons.undo,
              tooltip: 'Undo',
              onPressed: controller.canUndo ? controller.undo : null,
            ),
            const SizedBox(width: 6),
            _iconBtn(
              icon: Icons.redo,
              tooltip: 'Redo',
              onPressed: controller.canRedo ? controller.redo : null,
            ),
            const SizedBox(width: 6),
            _iconBtn(
              icon: Icons.delete_sweep,
              tooltip: 'Clear canvas',
              onPressed: () => _confirmClear(context),
            ),
            SizedBox(width: isNarrow ? 8 : 10),
            OutlinedButton.icon(
              onPressed: () => _loadJson(context),
              icon: Icon(Icons.folder_open, size: isNarrow ? 14 : 16),
              label: Text(
                'Load JSON',
                style: TextStyle(
                  fontSize: isNarrow ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 10 : 14,
                  vertical: isNarrow ? 8 : 10,
                ),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(isNarrow ? 90 : 110, isNarrow ? 32 : 36),
              ),
            ),
            SizedBox(width: isNarrow ? 6 : 8),
            FilledButton.icon(
              onPressed: () => _generateJson(context),
              icon: Icon(Icons.code, size: isNarrow ? 14 : 16),
              label: Text(
                'Generate JSON',
                style: TextStyle(
                  fontSize: isNarrow ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 12 : 16,
                  vertical: isNarrow ? 8 : 10,
                ),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(isNarrow ? 132 : 150, isNarrow ? 32 : 36),
                elevation: 2,
                shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
    bool filled = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: filled ? const Color(0xFFF1F5F9) : Colors.white,
          side: BorderSide(color: Colors.grey.shade200),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  Future<void> _generateJson(BuildContext context) async {
    // Show small loading to avoid freeze perception
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final json = await controller.generateJsonAsync(pretty: true);
      if (context.mounted) Navigator.pop(context); // close loading
      if (context.mounted) JsonPreviewDialog.show(context, json);
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Generate failed: $e')));
    }
  }

  Future<void> _loadJson(BuildContext context) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Load JSON'),
        content: const Text('Choose how to load JSON'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, 'file'),
            child: const Text('Pick File'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, 'paste'),
            child: const Text('Paste JSON'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (choice == null) return;
    if (choice == 'file') {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
          withData: true,
        );
        if (result == null || result.files.isEmpty) return;
        final file = result.files.first;
        String? content;
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          if (context.mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not read file bytes')),
            );
          return;
        }
        if (content == null) return;
        if (context.mounted) await _applyJson(context, content);
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Load failed: $e')));
      }
    } else if (choice == 'paste') {
      if (!context.mounted) return;
      final ctrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Paste JSON'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: ctrl,
              maxLines: 14,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '{"version":"1.0","type":"column",...}',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Load'),
            ),
          ],
        ),
      );
      if (ok == true && ctrl.text.trim().isNotEmpty) {
        if (context.mounted) await _applyJson(context, ctrl.text);
      }
    }
  }

  Future<void> _applyJson(BuildContext context, String content) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await controller.loadFromJsonStringAsync(content);
      if (context.mounted) Navigator.pop(context);
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JSON loaded — canvas reconstructed')),
        );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid JSON: $e'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      if (context.mounted)
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Validation Error'),
            content: SingleChildScrollView(child: Text(e.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('OK'),
              ),
            ],
          ),
        );
    }
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Clear canvas?'),
        content: const Text('This will remove all components.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.clear();
              Navigator.pop(c);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
