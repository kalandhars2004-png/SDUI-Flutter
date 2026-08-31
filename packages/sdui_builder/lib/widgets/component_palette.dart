import 'package:flutter/material.dart';

import '../models/appzillon_catalog.dart';
import '../models/component_definition.dart';

class ComponentPalette extends StatefulWidget {
  final void Function(ComponentDefinition def)? onAddTap;
  final bool compact;
  const ComponentPalette({super.key, this.onAddTap, this.compact = false});

  @override
  State<ComponentPalette> createState() => _ComponentPaletteState();
}

class _ComponentPaletteState extends State<ComponentPalette> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  final Map<String, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()),
    );
    // default all expanded
    for (final cat in AppzillonComponentCatalog.grouped.keys) {
      _expanded[cat] = true;
    }
    // also expand legacy
    for (final cat in ComponentCatalog.grouped.keys) {
      _expanded['legacy_$cat'] = false;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Source is Appzillon + legacy, but appzillon is primary
    final appzillonAll = AppzillonComponentCatalog.all;
    final legacyAll = ComponentCatalog.all;

    final filteredAppzillon = _query.isEmpty
        ? appzillonAll
        : appzillonAll
              .where(
                (d) =>
                    d.label.toLowerCase().contains(_query) ||
                    d.type.toLowerCase().contains(_query) ||
                    d.category.toLowerCase().contains(_query),
              )
              .toList();

    final filteredLegacy = _query.isEmpty
        ? legacyAll
        : legacyAll
              .where(
                (d) =>
                    d.label.toLowerCase().contains(_query) ||
                    d.type.toLowerCase().contains(_query) ||
                    d.category.toLowerCase().contains(_query),
              )
              .toList();
    // Deduplicate legacy types already covered by Appzillon global (e.g., text, button)
    final appzillonTypes = filteredAppzillon
        .map((e) => e.type.toLowerCase())
        .toSet();
    final dedupedLegacy = filteredLegacy
        .where((d) => !appzillonTypes.contains(d.type.toLowerCase()))
        .toList();

    // Group appzillon
    final Map<String, List<ComponentDefinition>> grouped = {};
    for (final d in filteredAppzillon) {
      grouped.putIfAbsent(d.category, () => []).add(d);
    }
    const order = [
      'Page',
      'Popup',
      'Layout',
      'Panels',
      'Containers',
      'Elements',
    ];
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));

    final legacyGrouped = <String, List<ComponentDefinition>>{};
    for (final d in dedupedLegacy) {
      legacyGrouped.putIfAbsent(d.category, () => []).add(d);
    }

    final headerPadding = widget.compact
        ? const EdgeInsets.fromLTRB(12, 12, 12, 8)
        : const EdgeInsets.fromLTRB(16, 16, 16, 12);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: headerPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'APPZILLON COMPONENTS',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: widget.compact ? 10 : 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${filteredAppzillon.length + dedupedLegacy.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search Header, Chart, Input...',
                    hintStyle: TextStyle(
                      fontSize: widget.compact ? 11 : 12,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: widget.compact ? 16 : 18,
                      color: Colors.grey.shade400,
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () => _searchCtrl.clear(),
                            tooltip: 'Clear',
                          ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: widget.compact ? 8 : 10,
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                      borderSide: const BorderSide(
                        color: Color(0xFF0F172A),
                        width: 1.2,
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: widget.compact ? 12 : 13),
                ),
                const SizedBox(height: 4),
                Text(
                  _query.isEmpty
                      ? 'Drag into canvas • 6 categories • global names'
                      : '${filteredAppzillon.length + dedupedLegacy.length} found',
                  style: TextStyle(
                    fontSize: widget.compact ? 10 : 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: (filteredAppzillon.isEmpty && filteredLegacy.isEmpty)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Colors.grey.shade400,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No components',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try "chart", "input", "header"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      widget.compact ? 8 : 8,
                      8,
                      widget.compact ? 8 : 8,
                      12,
                    ),
                    children: [
                      // Appzillon categories collapsible
                      ...sortedKeys.map(
                        (cat) => _CategorySection(
                          category: cat,
                          items: grouped[cat]!,
                          expanded: _query.isNotEmpty
                              ? true
                              : (_expanded[cat] ?? true),
                          compact: widget.compact,
                          onToggle: () => setState(
                            () => _expanded[cat] = !(_expanded[cat] ?? true),
                          ),
                          onAddTap: widget.onAddTap,
                        ),
                      ),
                      if (dedupedLegacy.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Divider(height: 1, color: Colors.grey.shade200),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                          child: Text(
                            'GENERIC (legacy) • matches for "${_query}"',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        ...legacyGrouped.entries.map(
                          (e) => _CategorySection(
                            category: e.key,
                            items: e.value,
                            expanded: true,
                            compact: widget.compact,
                            onToggle: () {},
                            onAddTap: widget.onAddTap,
                            isLegacy: true,
                          ),
                        ),
                      ],
                      // Fintech quick hint when no query
                      if (_query.isEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Appzillon Plugin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    Text(
                                      '${appzillonAll.length} components • global names • friend JSON ready',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<ComponentDefinition> items;
  final bool expanded;
  final bool compact;
  final VoidCallback onToggle;
  final void Function(ComponentDefinition def)? onAddTap;
  final bool isLegacy;
  const _CategorySection({
    required this.category,
    required this.items,
    required this.expanded,
    required this.compact,
    required this.onToggle,
    this.onAddTap,
    this.isLegacy = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: isLegacy ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLegacy
                    ? Colors.grey.shade200
                    : color.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isLegacy ? Colors.grey.shade400 : color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: compact ? 10 : 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: isLegacy
                          ? Colors.grey.shade600
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isLegacy
                        ? Colors.white
                        : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isLegacy ? Colors.grey.shade600 : color,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 6),
          ...items.map(
            (def) => _PaletteItem(
              def: def,
              onAddTap: onAddTap,
              compact: compact,
              isAppzillon: !isLegacy,
            ),
          ),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Page':
        return const Color(0xFF0F172A);
      case 'Popup':
        return const Color(0xFFDC2626);
      case 'Layout':
        return const Color(0xFF3B82F6);
      case 'Panels':
        return const Color(0xFF7C3AED);
      case 'Containers':
        return const Color(0xFF0891B2);
      case 'Elements':
        return const Color(0xFF16A34A);
      default:
        return Colors.grey;
    }
  }
}

class _PaletteItem extends StatelessWidget {
  final ComponentDefinition def;
  final void Function(ComponentDefinition def)? onAddTap;
  final bool compact;
  final bool isAppzillon;
  const _PaletteItem({
    required this.def,
    this.onAddTap,
    this.compact = false,
    this.isAppzillon = true,
  });

  @override
  Widget build(BuildContext context) {
    final dragData = def;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 6 : 7, left: 2, right: 2),
      child: LongPressDraggable<ComponentDefinition>(
        data: dragData,
        feedback: _dragFeedback(),
        childWhenDragging: Opacity(opacity: 0.4, child: _card()),
        child: Draggable<ComponentDefinition>(
          data: dragData,
          feedback: _dragFeedback(),
          child: _card(),
        ),
      ),
    );
  }

  Widget _dragFeedback() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(def.icon, size: 16, color: const Color(0xFF0F172A)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                def.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card() {
    final vPad = compact ? 8.0 : 9.0;
    final hPad = compact ? 10.0 : 12.0;
    return InkWell(
      onTap: onAddTap != null ? () => onAddTap!(def) : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAppzillon
                ? const Color(0xFF0F172A).withValues(alpha: 0.10)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 5 : 6),
              decoration: BoxDecoration(
                color: isAppzillon
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                def.icon,
                size: compact ? 12 : 14,
                color: isAppzillon ? Colors.white : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    def.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    def.type,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: isAppzillon
                          ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                          : Colors.grey.shade500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add,
              size: compact ? 12 : 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
