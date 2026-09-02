import 'package:flutter/material.dart';
import 'package:sdui_builder/sdui_builder.dart';
import 'package:sdui_engine/sdui_engine.dart';
import '../services/sdui_graphql_service.dart';

enum StudioSection { project, design, data, logic, navigation, theme, json, run }

class StudioShell extends StatefulWidget {
  final BuilderController controller;
  final SduiGraphqlService gqlService;
  const StudioShell({super.key, required this.controller, required this.gqlService});

  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  StudioSection _section = StudioSection.design;
  String _selectedScreen = 'Dashboard';
  bool _leftCollapsed = false;
  bool _rightCollapsed = false;
  bool _bottomCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _TopBar(
            controller: widget.controller,
            gqlService: widget.gqlService,
            section: _section,
            onSection: (s) => setState(() => _section = s),
          ),
          Expanded(
            child: Row(
              children: [
                _ProjectExplorer(
                  collapsed: _leftCollapsed,
                  onToggle: () => setState(() => _leftCollapsed = !_leftCollapsed),
                  selectedSection: _section,
                  onSection: (s) => setState(() => _section = s),
                  selectedScreen: _selectedScreen,
                  onScreen: (s) => setState(() => _selectedScreen = s),
                  controller: widget.controller,
                ),
                VerticalDivider(width: 1, color: Colors.grey.shade200),
                Expanded(child: _Workspace(section: _section, controller: widget.controller, gqlService: widget.gqlService, selectedScreen: _selectedScreen)),
                VerticalDivider(width: 1, color: Colors.grey.shade200),
                _InspectorPanel(
                  collapsed: _rightCollapsed,
                  onToggle: () => setState(() => _rightCollapsed = !_rightCollapsed),
                  controller: widget.controller,
                  section: _section,
                ),
              ],
            ),
          ),
          _BottomPanel(collapsed: _bottomCollapsed, onToggle: () => setState(() => _bottomCollapsed = !_bottomCollapsed), controller: widget.controller),
          _StatusBar(controller: widget.controller),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final BuilderController controller;
  final SduiGraphqlService gqlService;
  final StudioSection section;
  final ValueChanged<StudioSection> onSection;
  const _TopBar({required this.controller, required this.gqlService, required this.section, required this.onSection});

  void _showImportDialog(BuildContext context) {
    final jsonCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String? error;
    bool saving = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Import JSON', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Template name', hintText: 'e.g., Dashboard', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true, filled: true, fillColor: const Color(0xFFF8FAFC))),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: TextField(controller: jsonCtrl, maxLines: 10, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12), hintText: '{"version":"1.0","type":"column",...}'), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                ),
                if (error != null) ...[const SizedBox(height: 8), Text(error!, style: TextStyle(color: Colors.red.shade600, fontSize: 12))],
                const SizedBox(height: 12),
                Row(children: [
                  Text('Paste JSON or load from templates', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final templates = await gqlService.fetchTemplates();
                        if (templates.isNotEmpty && ctx.mounted) {
                          showModalBottomSheet(
                            context: ctx,
                            builder: (_) => ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                const Text('Select Template', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 8),
                                ...templates.map((t) => ListTile(
                                  title: Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  subtitle: Text('${t.id.substring(0, 8)}...', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontFamily: 'monospace')),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    nameCtrl.text = t.name;
                                    jsonCtrl.text = t.json;
                                    setDialogState(() {});
                                  },
                                )),
                              ],
                            ),
                          );
                        }
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.folder_open, size: 14),
                    label: const Text('From Server', style: TextStyle(fontSize: 11)),
                  ),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: saving ? null : () async {
                final name = nameCtrl.text.trim();
                final jsonStr = jsonCtrl.text.trim();
                if (jsonStr.isEmpty) { setDialogState(() => error = 'JSON required'); return; }
                setDialogState(() { saving = true; error = null; });
                try {
                  await controller.loadFromJsonStringAsync(jsonStr, templateName: name.isNotEmpty ? name : null);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Imported ${name.isNotEmpty ? name : "JSON"} successfully')));
                } catch (e) {
                  setDialogState(() { error = 'Parse error: $e'; saving = false; });
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
              child: saving ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveToServerDialog(BuildContext context) async {
    final nameCtrl = TextEditingController(text: controller.loadedTemplateName ?? 'Untitled');
    bool saving = false;
    String? error;
    final isUpdate = controller.loadedTemplateId != null;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isUpdate ? 'Update Template' : 'Save to Server', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Template name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true, filled: true, fillColor: const Color(0xFFF8FAFC))),
                const SizedBox(height: 8),
                if (isUpdate) Text('Will update existing template "${controller.loadedTemplateName ?? ''}"', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                if (error != null) ...[const SizedBox(height: 8), Text(error!, style: TextStyle(color: Colors.red.shade600, fontSize: 12))],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: saving ? null : () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) { setDialogState(() => error = 'Name required'); return; }
                setDialogState(() { saving = true; error = null; });
                try {
                  final json = await controller.generateJsonAsync(pretty: true);
                  if (isUpdate) {
                    await gqlService.updateTemplate(id: controller.loadedTemplateId!, name: name, json: json);
                  } else {
                    final saved = await gqlService.saveTemplate(name: name, json: json);
                    controller.loadedTemplateId = saved.id;
                  }
                  controller.loadedTemplateName = name;
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('${isUpdate ? "Updated" : "Saved"} "$name" to server')));
                } catch (e) {
                  setDialogState(() { error = e.toString(); saving = false; });
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
              child: saving ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isUpdate ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Text('SDUI Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
            child: Row(children: [
              const Text('Banking App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 14),
              const SizedBox(width: 10),
              Container(width: 1, height: 14, color: Colors.white24),
              const SizedBox(width: 10),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('Draft', style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)), child: const Text('● Engine Connected', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.w600))),
            ]),
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.undo, color: Colors.white70, size: 18), onPressed: controller.canUndo ? controller.undo : null, tooltip: 'Undo (Ctrl+Z)'),
          IconButton(icon: const Icon(Icons.redo, color: Colors.white70, size: 18), onPressed: controller.canRedo ? controller.redo : null, tooltip: 'Redo (Ctrl+Y)'),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _showImportDialog(context),
            icon: const Icon(Icons.file_download, size: 14, color: Colors.white70),
            label: const Text('Import', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withValues(alpha: 0.15)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), visualDensity: VisualDensity.compact),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _showSaveToServerDialog(context),
            icon: const Icon(Icons.cloud_upload, size: 14, color: Colors.white70),
            label: Text(controller.loadedTemplateId != null ? 'Update DB' : 'Save to DB', style: const TextStyle(color: Colors.white, fontSize: 12)),
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withValues(alpha: 0.15)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), visualDensity: VisualDensity.compact),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.verified, size: 14, color: Colors.white70),
            label: const Text('Validate', style: TextStyle(color: Colors.white, fontSize: 12)),
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withValues(alpha: 0.15)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), visualDensity: VisualDensity.compact),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulate: Opening entire app in new tab...')));
            },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Run', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F6FFF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Publish', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ProjectExplorer extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;
  final StudioSection selectedSection;
  final ValueChanged<StudioSection> onSection;
  final String selectedScreen;
  final ValueChanged<String> onScreen;
  final BuilderController controller;
  const _ProjectExplorer({required this.collapsed, required this.onToggle, required this.selectedSection, required this.onSection, required this.selectedScreen, required this.onScreen, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Container(
        width: 48,
        color: Colors.white,
        child: Column(children: [
          IconButton(icon: const Icon(Icons.chevron_right, size: 18), onPressed: onToggle, tooltip: 'Expand'),
          const Divider(height: 1),
          for (final s in StudioSection.values)
            IconButton(
              icon: Icon(_iconForSection(s), size: 18, color: selectedSection == s ? const Color(0xFF0F172A) : Colors.grey.shade500),
              onPressed: () => onSection(s),
              tooltip: s.name,
              style: IconButton.styleFrom(backgroundColor: selectedSection == s ? const Color(0xFFF1F5F9) : Colors.transparent),
            ),
        ]),
      );
    }
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Row(children: [
              const Text('PROJECT EXPLORER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF64748B))),
              const Spacer(),
              IconButton(icon: const Icon(Icons.chevron_left, size: 16), onPressed: onToggle, tooltip: 'Collapse', visualDensity: VisualDensity.compact),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _ExplorerSection(
                  title: 'Project',
                  icon: Icons.folder_special,
                  children: [
                    _ExplorerItem(icon: Icons.dashboard, label: 'Banking App', subtitle: 'v1 • Draft', active: selectedSection == StudioSection.project, onTap: () => onSection(StudioSection.project)),
                  ],
                ),
                _ExplorerSection(
                  title: 'Screens',
                  icon: Icons.phone_iphone,
                  actionIcon: Icons.add,
                  onAction: () {},
                  children: [
                    for (final name in ['Login', 'Dashboard', 'Accounts', 'Account Details', 'Transactions', 'Transfer', 'Profile', 'Settings'])
                      _ExplorerItem(
                        icon: Icons.article_outlined,
                        label: name,
                        active: selectedScreen == name && selectedSection == StudioSection.design,
                        trailing: name == 'Dashboard' ? Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(4)), child: const Text('initial', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))) : null,
                        onTap: () {
                          onScreen(name);
                          onSection(StudioSection.design);
                        },
                      ),
                  ],
                ),
                _ExplorerSection(
                  title: 'Data',
                  icon: Icons.storage,
                  children: [
                    _ExplorerItem(icon: Icons.dataset, label: 'Data Sources', subtitle: 'MySQL, Mock', onTap: () => onSection(StudioSection.data)),
                    _ExplorerItem(icon: Icons.search, label: 'Queries', subtitle: 'getUsers, getDashboard', onTap: () => onSection(StudioSection.data)),
                    _ExplorerItem(icon: Icons.api, label: 'APIs', subtitle: 'REST • GraphQL', onTap: () => onSection(StudioSection.data)),
                  ],
                ),
                _ExplorerSection(
                  title: 'Logic',
                  icon: Icons.bolt,
                  children: [
                    _ExplorerItem(icon: Icons.flash_on, label: 'Actions', onTap: () => onSection(StudioSection.logic)),
                    _ExplorerItem(icon: Icons.route, label: 'Navigation', onTap: () => onSection(StudioSection.navigation)),
                  ],
                ),
                _ExplorerSection(
                  title: 'Design',
                  icon: Icons.palette,
                  children: [
                    _ExplorerItem(icon: Icons.color_lens, label: 'Theme', onTap: () => onSection(StudioSection.theme)),
                    _ExplorerItem(icon: Icons.code, label: 'JSON', onTap: () => onSection(StudioSection.json)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForSection(StudioSection s) {
    switch (s) {
      case StudioSection.project: return Icons.folder_special;
      case StudioSection.design: return Icons.design_services;
      case StudioSection.data: return Icons.storage;
      case StudioSection.logic: return Icons.bolt;
      case StudioSection.navigation: return Icons.navigation;
      case StudioSection.theme: return Icons.palette;
      case StudioSection.json: return Icons.code;
      case StudioSection.run: return Icons.play_arrow;
    }
  }
}

class _ExplorerSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  const _ExplorerSection({required this.title, required this.icon, required this.children, this.actionIcon, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: const Color(0xFF0F172A)),
            const SizedBox(width: 6),
            Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF0F172A))),
            const Spacer(),
            if (actionIcon != null) InkWell(onTap: onAction, child: Icon(actionIcon, size: 14, color: Colors.grey.shade600)),
          ]),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _ExplorerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool active;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _ExplorerItem({required this.icon, required this.label, this.subtitle, this.active = false, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(color: active ? const Color(0xFF0F172A) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: active ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? Colors.white : const Color(0xFF334155)), overflow: TextOverflow.ellipsis),
                if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 10, color: active ? Colors.white70 : Colors.grey.shade500), overflow: TextOverflow.ellipsis),
              ]),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _Workspace extends StatelessWidget {
  final StudioSection section;
  final BuilderController controller;
  final SduiGraphqlService gqlService;
  final String selectedScreen;
  const _Workspace({required this.section, required this.controller, required this.gqlService, required this.selectedScreen});

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case StudioSection.design:
        return _DesignWorkspace(controller: controller, selectedScreen: selectedScreen);
      case StudioSection.data:
        return _DataWorkspace(controller: controller, gqlService: gqlService);
      case StudioSection.logic:
        return _LogicWorkspace(controller: controller);
      case StudioSection.navigation:
        return _NavigationWorkspace(controller: controller);
      case StudioSection.theme:
        return _ThemeWorkspace(controller: controller);
      case StudioSection.json:
        return _JsonWorkspace(controller: controller);
      case StudioSection.run:
        return _RunWorkspace(controller: controller);
      case StudioSection.project:
        return _ProjectDashboard(controller: controller);
    }
  }
}

class _DesignWorkspace extends StatelessWidget {
  final BuilderController controller;
  final String selectedScreen;
  const _DesignWorkspace({required this.controller, required this.selectedScreen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Screen toolbar
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            children: [
              Text(selectedScreen, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
              const SizedBox(width: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [const Icon(Icons.desktop_windows, size: 12, color: Colors.grey), const SizedBox(width: 4), const Text('Desktop', style: TextStyle(fontSize: 11)), const Icon(Icons.arrow_drop_down, size: 14)])),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)), child: Row(children: [const Icon(Icons.remove, size: 12), const SizedBox(width: 6), const Text('100%', style: TextStyle(fontSize: 11)), const SizedBox(width: 6), const Icon(Icons.add, size: 12)])),
              const Spacer(),
              IconButton(icon: const Icon(Icons.grid_on, size: 16, color: Colors.grey), onPressed: () {}, tooltip: 'Grid'),
              IconButton(icon: const Icon(Icons.center_focus_strong, size: 16, color: Colors.grey), onPressed: () {}, tooltip: 'Guides'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              // Collapsible Component Palette
              Container(width: 240, color: Colors.white, child: ComponentPalette(onAddTap: (def) => controller.addNode(def))),
              VerticalDivider(width: 1, color: Colors.grey.shade200),
              // Canvas
              Expanded(child: BuilderCanvas(controller: controller)),
              VerticalDivider(width: 1, color: Colors.grey.shade200),
              // Layer Tree
              Container(
                width: 220,
                color: Colors.white,
                child: _LayerTree(controller: controller),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LayerTree extends StatelessWidget {
  final BuilderController controller;
  const _LayerTree({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))), child: const Text('LAYERS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF0F172A)))),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [_buildNode(controller.root, 0)],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNode(UiNode node, int depth) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => controller.select(node.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: controller.selectedId == node.id ? const Color(0xFF0F172A) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(children: [
                Icon(_iconFor(node.type), size: 12, color: controller.selectedId == node.id ? Colors.white : Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(child: Text('${node.type} • ${node.id.substring(0, 6)}', style: TextStyle(fontSize: 11, color: controller.selectedId == node.id ? Colors.white : const Color(0xFF334155)), overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ),
          ...node.children.map((c) => _buildNode(c, depth + 1)),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'text': return Icons.text_fields;
      case 'column': return Icons.view_column;
      case 'row': return Icons.view_week;
      default: return Icons.widgets;
    }
  }
}

class _DataWorkspace extends StatelessWidget {
  final BuilderController controller;
  final SduiGraphqlService gqlService;
  const _DataWorkspace({required this.controller, required this.gqlService});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('DATA', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 11, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          _SectionCard(title: 'Data Sources', subtitle: 'MySQL, REST API, Mock Data', children: [
            _DataSourceTile(icon: Icons.storage, name: 'primaryMysql', desc: 'MySQL • sdui', status: 'Connected'),
            _DataSourceTile(icon: Icons.api, name: 'restApi', desc: 'REST • https://api.example.com', status: 'Connected'),
          ]),
          _SectionCard(title: 'Queries', subtitle: 'getUsers, getDashboard, getTransactions', children: [
            ListTile(dense: true, title: const Text('getUsers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), subtitle: const Text('SELECT id,name FROM users', style: TextStyle(fontSize: 11, fontFamily: 'monospace')), trailing: const Icon(Icons.play_arrow, size: 16), onTap: () {}),
            ListTile(dense: true, title: const Text('getDashboard', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), subtitle: const Text('SELECT balance FROM accounts', style: TextStyle(fontSize: 11, fontFamily: 'monospace')), trailing: const Icon(Icons.play_arrow, size: 16), onTap: () {}),
          ]),
          _SectionCard(title: 'Server Templates', subtitle: 'Stored in MySQL via GraphQL', children: [
            _ServerTemplatesSection(controller: controller, gqlService: gqlService),
          ]),
          _SectionCard(title: 'Bindings', subtitle: '{{user.name}} → Text', children: [
            Padding(padding: const EdgeInsets.all(12), child: Text('Select a Text component to bind {{user.name}}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
          ]),
        ],
      ),
    );
  }
}

class _ServerTemplatesSection extends StatefulWidget {
  final BuilderController controller;
  final SduiGraphqlService gqlService;
  const _ServerTemplatesSection({required this.controller, required this.gqlService});
  @override
  State<_ServerTemplatesSection> createState() => _ServerTemplatesSectionState();
}

class _ServerTemplatesSectionState extends State<_ServerTemplatesSection> {
  late Future<List<SduiTemplateModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.gqlService.fetchTemplates();
  }

  void _refresh() {
    setState(() => _future = widget.gqlService.fetchTemplates());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SduiTemplateModel>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
        if (snap.hasError) return Padding(padding: const EdgeInsets.all(12), child: Text('GraphQL error:\n${snap.error}', style: TextStyle(color: Colors.red.shade600, fontSize: 12)));
        final items = snap.data ?? [];
        if (items.isEmpty) return Padding(padding: const EdgeInsets.all(12), child: Text('No templates saved yet. Use "Save to DB" in the top bar.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)));
        return Column(children: [
          for (final t in items)
            ListTile(
              dense: true,
              leading: const Icon(Icons.insert_drive_file_outlined, size: 18, color: Color(0xFF0F172A)),
              title: Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text('id: ${t.id.substring(0, 8)}...', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontFamily: 'monospace')),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.download, size: 18), tooltip: 'Load into editor', onPressed: () async {
                  try {
                    await widget.controller.loadFromJsonStringAsync(t.json, templateId: t.id, templateName: t.name);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loaded "${t.name}" into editor')));
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load failed: $e'), backgroundColor: Colors.red.shade400));
                  }
                }),
                IconButton(icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400), tooltip: 'Delete', onPressed: () async {
                  await widget.gqlService.deleteTemplate(t.id);
                  if (mounted) _refresh();
                }),
              ]),
            ),
          Divider(height: 1, color: Colors.grey.shade200),
          TextButton(onPressed: _refresh, child: const Text('Refresh')),
        ]);
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.subtitle, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 11))])),
        Divider(height: 1, color: Colors.grey.shade200),
        ...children,
      ]),
    );
  }
}

class _DataSourceTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String desc;
  final String status;
  const _DataSourceTile({required this.icon, required this.name, required this.desc, required this.status});
  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16, color: const Color(0xFF0F172A))), title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), subtitle: Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)), trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)), child: Text(status, style: const TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.w700))));
  }
}

class _LogicWorkspace extends StatelessWidget {
  final BuilderController controller;
  const _LogicWorkspace({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 11, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)), child: Column(children: [
          ListTile(leading: const Icon(Icons.login, size: 18), title: const Text('1. API Call  login', style: TextStyle(fontSize: 13)), subtitle: const Text('POST /api/login', style: TextStyle(fontSize: 11, fontFamily: 'monospace')), trailing: const Icon(Icons.drag_handle, size: 16)),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.navigate_next, size: 18), title: const Text('2. Navigate  dashboard', style: TextStyle(fontSize: 13)), trailing: const Icon(Icons.drag_handle, size: 16)),
        ])),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 14), label: const Text('Add Action'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A))),
      ]),
    );
  }
}

class _NavigationWorkspace extends StatelessWidget {
  final BuilderController controller;
  const _NavigationWorkspace({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('NAVIGATION', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 11, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Text('Initial Screen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)), child: const Row(children: [Text('Login', style: TextStyle(fontSize: 12)), Icon(Icons.arrow_drop_down, size: 16)]))]),
          const SizedBox(height: 12),
          const Text('Routes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final r in ['/login → login', '/dashboard → dashboard', '/accounts → accounts']) Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade200)), child: Text(r, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
        ])),
      ]),
    );
  }
}

class _ThemeWorkspace extends StatelessWidget {
  final BuilderController controller;
  const _ThemeWorkspace({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('THEME', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 11, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        _ColorField(label: 'Primary Color', value: '#172033'),
        _ColorField(label: 'Secondary Color', value: '#4F6FFF'),
        _ColorField(label: 'Background', value: '#F7F8FA'),
        const SizedBox(height: 8),
        Row(children: [const Text('Border Radius', style: TextStyle(fontSize: 12)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)), child: const Text('12', style: TextStyle(fontSize: 12)))]),
      ]),
    );
  }
}

class _ColorField extends StatelessWidget {
  final String label;
  final String value;
  const _ColorField({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [Text(label, style: const TextStyle(fontSize: 12)), const Spacer(), Container(width: 24, height: 24, decoration: BoxDecoration(color: Color(int.parse(value.replaceFirst('#', '0xFF'), radix: 16)), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300))), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)), child: Text(value, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)))]),
    );
  }
}

class _JsonWorkspace extends StatelessWidget {
  final BuilderController controller;
  const _JsonWorkspace({required this.controller});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final json = controller.generateJson(pretty: true);
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(children: [
                const Text('JSON Editor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const Spacer(),
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.format_align_left, size: 14), label: const Text('Format', style: TextStyle(fontSize: 11)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), visualDensity: VisualDensity.compact)),
                const SizedBox(width: 6),
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.verified, size: 14), label: const Text('Validate', style: TextStyle(fontSize: 11)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), visualDensity: VisualDensity.compact)),
              ]),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(child: SelectableText(json, style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 12, height: 1.5))),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RunWorkspace extends StatelessWidget {
  final BuilderController controller;
  const _RunWorkspace({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.play_arrow, color: Colors.white, size: 32)),
        const SizedBox(height: 16),
        const Text('Simulate Entire Application', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Text('Opens the complete project in a new tab with real data, navigation and actions.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.open_in_new, size: 16), label: const Text('Open Simulate (new tab)'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
      ]),
    );
  }
}

class _ProjectDashboard extends StatelessWidget {
  final BuilderController controller;
  const _ProjectDashboard({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BANKING APPLICATION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 0.5, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            Row(children: [
              _StatCard(label: 'Screens', value: '8'),
              const SizedBox(width: 12),
              _StatCard(label: 'Components', value: '46'),
              const SizedBox(width: 12),
              _StatCard(label: 'Queries', value: '7'),
              const SizedBox(width: 12),
              _StatCard(label: 'APIs', value: '4'),
            ]),
            const SizedBox(height: 24),
            const Text('Recent Screens', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [for (final s in ['Dashboard', 'Accounts', 'Transfer']) Chip(label: Text(s), backgroundColor: Color(0xFFF1F5F9))]),
            const SizedBox(height: 24),
            Wrap(spacing: 8, children: [
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 14), label: const Text('New Screen'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A))),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file, size: 14), label: const Text('Import JSON')),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.play_arrow, size: 14), label: const Text('Simulate')),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
        child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF0F172A))), Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))]),
      ),
    );
  }
}

class _InspectorPanel extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;
  final BuilderController controller;
  final StudioSection section;
  const _InspectorPanel({required this.collapsed, required this.onToggle, required this.controller, required this.section});

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Container(width: 48, color: Colors.white, child: Column(children: [IconButton(icon: const Icon(Icons.chevron_right, size: 18), onPressed: onToggle), const Divider(height: 1), const Icon(Icons.tune, color: Colors.grey)]));
    }
    return Container(
      width: 300,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Row(children: [
              const Text('INSPECTOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF0F172A))),
              const Spacer(),
              IconButton(icon: const Icon(Icons.chevron_right, size: 16), onPressed: onToggle, visualDensity: VisualDensity.compact),
            ]),
          ),
          Expanded(child: PropertyInspector(controller: controller)),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;
  final BuilderController controller;
  const _BottomPanel({required this.collapsed, required this.onToggle, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: collapsed ? 32 : 160,
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: [
                  Icon(collapsed ? Icons.expand_less : Icons.expand_more, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  const Text('Console • Queries • Network • Runtime Data • Validation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  const Spacer(),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Engine connected', style: TextStyle(color: Color(0xFF22C55E), fontSize: 11)),
                ],
              ),
            ),
          ),
          if (!collapsed)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: const [
                  Text('✓ Engine connected', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontFamily: 'monospace')),
                  Text('✓ Project loaded', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontFamily: 'monospace')),
                  Text('✓ Screen dashboard loaded', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontFamily: 'monospace')),
                  Text('✓ Query getDashboard executed • 12 records', style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final BuilderController controller;
  const _StatusBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
      child: Row(
        children: [
          const Text('Project: Banking App', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 12),
          Container(width: 1, height: 12, color: Colors.white24),
          const SizedBox(width: 12),
          const Text('Version: 1', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 12),
          const Text('Environment: Development', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const Spacer(),
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('Engine: Connected • JSON: Valid • DB: Connected', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
