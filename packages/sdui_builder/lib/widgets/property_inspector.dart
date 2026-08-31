import 'package:flutter/material.dart';
import 'package:sdui_engine/sdui_engine.dart';

import '../models/property_definition.dart';
import '../state/builder_controller.dart';

class PropertyInspector extends StatelessWidget {
  final BuilderController controller;
  final bool isBottomSheet;
  const PropertyInspector({
    super.key,
    required this.controller,
    this.isBottomSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final node = controller.selectedNode;
        if (node == null) {
          return _emptyState();
        }
        final defs = PropertyCatalog.forType(node.type);
        final grouped = <String, List<PropertyDefinition>>{};
        for (final d in defs) {
          grouped.putIfAbsent(d.group, () => []).add(d);
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: isBottomSheet
                ? Border(top: BorderSide(color: Colors.grey.shade200))
                : Border(left: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, node),
              Divider(height: 1, color: Colors.grey.shade200),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(isBottomSheet ? 14 : 16),
                  children: [
                    ...grouped.entries.map(
                      (e) => _groupSection(context, node, e.key, e.value),
                    ),
                    const SizedBox(height: 12),
                    _dangerZone(context),
                    // extra bottom padding for scroll comfort
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: isBottomSheet
            ? Border(top: BorderSide(color: Colors.grey.shade200))
            : Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(Icons.tune, color: Colors.grey.shade400, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                'No selection',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a component on canvas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                'to edit its properties',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, UiNode node) {
    return Padding(
      padding: EdgeInsets.all(isBottomSheet ? 14 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PROPERTIES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'ID: ${node.id.length > 14 ? node.id.substring(0, 14) : node.id}',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  node.type.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  node.id,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _groupSection(
    BuildContext context,
    UiNode node,
    String group,
    List<PropertyDefinition> defs,
  ) {
    String title;
    switch (group) {
      case 'props':
        title = 'PROPERTIES';
        break;
      case 'style':
        title = 'STYLE';
        break;
      case 'events':
        title = 'EVENTS';
        break;
      default:
        title = group.toUpperCase();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Divider(height: 1, color: Colors.grey.shade100)),
              const SizedBox(width: 8),
              Text(
                '${defs.length}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
        ...defs.map((d) => _field(context, node, d)),
        const SizedBox(height: 6),
        Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }

  Widget _field(BuildContext context, UiNode node, PropertyDefinition def) {
    dynamic current;
    if (def.group == 'props') current = node.props[def.key];
    if (def.group == 'style') current = node.style[def.key];
    if (def.group == 'events') {
      final ev = node.events[def.key];
      if (ev is Map)
        current = ev['action'] ?? ev['type'];
      else
        current = ev;
    }

    Widget control;
    switch (def.type) {
      case 'string':
        control = _StringField(
          initial: current?.toString() ?? '',
          onChanged: (v) => controller.updateSelectedProps(
            def.group,
            def.key,
            v.isEmpty ? null : v,
          ),
        );
        break;
      case 'number':
        control = _NumberField(
          initial: current?.toString() ?? '',
          onChanged: (v) {
            if (v.isEmpty)
              controller.updateSelectedProps(def.group, def.key, null);
            else {
              final n = num.tryParse(v);
              controller.updateSelectedProps(def.group, def.key, n ?? v);
            }
          },
        );
        break;
      case 'boolean':
        control = Align(
          alignment: Alignment.centerLeft,
          child: Switch(
            value: current is bool ? current : false,
            onChanged: (v) =>
                controller.updateSelectedProps(def.group, def.key, v),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
        break;
      case 'enum':
        control = _EnumField(
          value: current?.toString(),
          options: def.enumValues ?? [],
          onChanged: (v) =>
              controller.updateSelectedProps(def.group, def.key, v),
        );
        break;
      case 'color':
        control = _ColorField(
          initial: current?.toString() ?? '',
          onChanged: (v) => controller.updateSelectedProps(
            def.group,
            def.key,
            v.isEmpty ? null : v,
          ),
        );
        break;
      case 'action':
        control = _ActionField(
          value: current?.toString() ?? 'none',
          onChanged: (v) {
            if (v == 'none' || v.isEmpty)
              controller.updateSelectedProps(def.group, def.key, null);
            else
              controller.updateSelectedProps(def.group, def.key, {'action': v});
          },
        );
        break;
      default:
        control = _StringField(
          initial: current?.toString() ?? '',
          onChanged: (v) =>
              controller.updateSelectedProps(def.group, def.key, v),
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            def.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          control,
        ],
      ),
    );
  }

  Widget _dangerZone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ACTIONS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.duplicateSelected(),
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('Duplicate', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.deleteSelected(),
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('Delete', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StringField extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const _StringField({required this.initial, required this.onChanged});
  @override
  State<_StringField> createState() => _StringFieldState();
}

class _StringFieldState extends State<_StringField> {
  late TextEditingController c;
  @override
  void initState() {
    super.initState();
    c = TextEditingController(text: widget.initial);
  }

  @override
  void didUpdateWidget(covariant _StringField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial && c.text != widget.initial)
      c.text = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: c,
      decoration: _dec(),
      style: const TextStyle(fontSize: 13),
      onChanged: widget.onChanged,
      maxLines: 1,
    );
  }

  InputDecoration _dec() => InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.2),
    ),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
  );
}

class _NumberField extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const _NumberField({required this.initial, required this.onChanged});
  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late TextEditingController c;
  @override
  void initState() {
    super.initState();
    c = TextEditingController(text: widget.initial);
  }

  @override
  void didUpdateWidget(covariant _NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial && c.text != widget.initial)
      c.text = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.2),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        suffixText: '#',
        suffixStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
      ),
      style: const TextStyle(fontSize: 13),
      onChanged: widget.onChanged,
    );
  }
}

class _EnumField extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  const _EnumField({
    required this.value,
    required this.options,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0F172A)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
      hint: const Text('Select', style: TextStyle(fontSize: 13)),
      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
      dropdownColor: Colors.white,
      items: options
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _ColorField extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const _ColorField({required this.initial, required this.onChanged});
  @override
  State<_ColorField> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<_ColorField> {
  late TextEditingController c;
  @override
  void initState() {
    super.initState();
    c = TextEditingController(text: widget.initial);
  }

  @override
  void didUpdateWidget(covariant _ColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial && c.text != widget.initial)
      c.text = widget.initial;
  }

  Color? _parse(String s) {
    if (s.isEmpty) return null;
    var hex = s.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
      hex = 'FF$hex';
    }
    final v = int.tryParse(hex, radix: 16);
    if (v != null) return Color(v);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final color = _parse(c.text);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: color != null
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: color == null
              ? Icon(
                  Icons.color_lens_outlined,
                  size: 16,
                  color: Colors.grey.shade400,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: c,
            decoration: InputDecoration(
              hintText: '#0F172A',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0F172A)),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

class _ActionField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _ActionField({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    const opts = [
      'none',
      'show_dialog',
      'show_snackbar',
      'navigate',
      'callback',
      'open_url',
    ];
    return DropdownButtonFormField<String>(
      initialValue: opts.contains(value) ? value : 'none',
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0F172A)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
      dropdownColor: Colors.white,
      items: opts
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: (v) => onChanged(v ?? 'none'),
    );
  }
}
