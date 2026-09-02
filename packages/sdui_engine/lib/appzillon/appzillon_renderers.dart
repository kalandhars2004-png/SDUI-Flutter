import 'package:flutter/material.dart';
import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

// PAGE
class AppzillonHeaderRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final style = node.style;
    final title = PropertyResolver.string(props, 'title', PropertyResolver.string(props, 'text', 'Header'));
    final subtitle = PropertyResolver.string(props, 'subtitle', '');
    final bg = PropertyResolver.colorOrNull(style, 'backgroundColor') ?? PropertyResolver.colorOrNull(props, 'backgroundColor') ?? Colors.white;
    final titleColor = PropertyResolver.colorOrNull(props, 'titleColor') ?? PropertyResolver.colorOrNull(style, 'titleColor') ?? (bg == Colors.white ? const Color(0xFF1A1A1A) : Colors.white);
    final titleSize = PropertyResolver.doubleOrNull(props, 'titleSize') ?? PropertyResolver.doubleOrNull(style, 'titleSize') ?? 16;
    final titleWeight = PropertyResolver.fontWeightFrom(props['titleWeight'] ?? style['titleWeight'] ?? '600');
    final iconColor = PropertyResolver.colorOrNull(props, 'iconColor') ?? (bg == Colors.white ? Colors.black : Colors.white);
    final showBack = PropertyResolver.boolVal(props, 'showBack', false);
    final padding = PropertyResolver.paddingFrom(style);
    final effectivePad = padding == EdgeInsets.zero ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14) : padding;
    final letterSpacing = PropertyResolver.doubleOrNull(props, 'letterSpacing') ?? 0;
    Widget w = Container(
      padding: effectivePad,
      decoration: BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(children: [
        if (showBack) ...[InkWell(onTap: () { final ev = node.events['onTap']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); }, child: Icon(Icons.arrow_back, color: iconColor, size: 22)), const SizedBox(width: 12)],
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: titleColor, fontWeight: titleWeight, fontSize: titleSize, letterSpacing: letterSpacing)), if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: titleColor.withValues(alpha: 0.7), fontSize: 11))])),
        if (node.children.isNotEmpty) ...node.children.map(childRenderer),
        if (!showBack) Icon(Icons.more_horiz, color: iconColor, size: 20),
      ]),
    );
    final onTap = node.events['onTap'];
    if (onTap != null && !showBack) w = InkWell(onTap: () { if (onTap is Map) context.dispatchAction(Map<String, dynamic>.from(onTap as Map)); }, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonSidebarRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final style = node.style;
    final bg = PropertyResolver.colorOrNull(style, 'backgroundColor') ?? const Color(0xFF1E293B);
    final width = PropertyResolver.doubleOrNull(node.props, 'width') ?? 220;
    final children = node.children.map(childRenderer).toList();
    return Container(
      width: width,
      decoration: BoxDecoration(color: bg, border: Border(right: BorderSide(color: Colors.grey.shade800))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(14), decoration: const BoxDecoration(color: Color(0xFF0F172A)), child: Text(PropertyResolver.string(node.props, 'title', 'Menu'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        if (children.isEmpty) ...[ListTile(leading: const Icon(Icons.dashboard, color: Colors.white70), title: const Text('Dashboard', style: TextStyle(color: Colors.white)), onTap: () {}), ListTile(leading: const Icon(Icons.account_balance, color: Colors.white70), title: const Text('Accounts', style: TextStyle(color: Colors.white70)), onTap: () {})] else ...children,
      ]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonFooterRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final bg = PropertyResolver.colorOrNull(node.props, 'backgroundColor') ?? PropertyResolver.colorOrNull(node.style, 'backgroundColor') ?? Colors.white;
    final activeColor = PropertyResolver.colorOrNull(node.props, 'activeColor') ?? const Color(0xFF0052FF);
    final items = node.props['items'];
    if (items is List) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            final label = m['label'] as String? ?? '';
            final iconName = m['icon'] as String? ?? 'home';
            final isActive = m['active'] == true;
            final color = isActive ? activeColor : Colors.grey;
            IconData icon;
            switch (iconName) {
              case 'home': icon = Icons.home; break;
              case 'receipt': icon = Icons.receipt_long; break;
              case 'public': icon = Icons.public; break;
              case 'person': icon = Icons.person; break;
              default: icon = Icons.circle;
            }
            final onClick = m['onClick'] as String?;
            final payload = m['payload'];
            Widget w = Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 22), const SizedBox(height: 2), Text(label, style: TextStyle(color: isActive ? activeColor : Colors.grey, fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400))]);
            if (onClick != null) {
              w = InkWell(
                onTap: () {
                  final ev = {'action': onClick, 'payload': payload};
                  context.dispatchAction(Map<String, dynamic>.from(ev));
                },
                child: w,
              );
            }
            return Expanded(child: w);
          }).toList(),
        ),
      );
    }
    final text = PropertyResolver.string(node.props, 'text', PropertyResolver.string(node.props, 'title', '© 2026 Appzillon • Footer'));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(children: [Expanded(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))), if (node.children.isNotEmpty) ...node.children.map(childRenderer)]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

// POPUP
class AppzillonModalRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', 'Modal');
    final radius = PropertyResolver.borderRadiusFrom(node.style) ?? 16;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))), IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {})])),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(padding: const EdgeInsets.all(16), child: node.children.isEmpty ? const Text('Modal content') : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: node.children.map(childRenderer).toList())),
        ]),
      ),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonDialogRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', 'Dialog');
    final message = PropertyResolver.string(node.props, 'message', '');
    return AlertDialog(
      title: Text(title),
      content: message.isNotEmpty ? Text(message) : (node.children.isEmpty ? const Text('Dialog content') : Column(mainAxisSize: MainAxisSize.min, children: node.children.map(childRenderer).toList())),
      actions: [TextButton(onPressed: () {}, child: const Text('Cancel')), FilledButton(onPressed: () {}, child: const Text('OK'))],
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonPopOverRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final text = PropertyResolver.string(node.props, 'text', 'PopOver');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.info, color: Colors.white, size: 14), const SizedBox(width: 6), Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))), if (node.children.isNotEmpty) ...node.children.map(childRenderer)]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

// LAYOUT - reuse core but wrap with namespace
class AppzillonRowRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final gap = PropertyResolver.doubleOrNull(node.style, 'gap') ?? 8;
    final padding = PropertyResolver.paddingFrom(node.style);
    List<Widget> kids = node.children.map(childRenderer).toList();
    if (kids.isEmpty) return Container(padding: padding == EdgeInsets.zero ? const EdgeInsets.all(12) : padding, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8), color: Colors.grey.shade50), child: const Text('Row (empty)', style: TextStyle(color: Colors.grey, fontSize: 11)));
    List<Widget> spaced = [];
    for (int i = 0; i < kids.length; i++) {
      spaced.add(Expanded(child: kids[i]));
      if (i != kids.length - 1) spaced.add(SizedBox(width: gap));
    }
    Widget w = Row(children: spaced);
    if (padding != EdgeInsets.zero) w = Padding(padding: padding, child: w);
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: w);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonColumnRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final gap = PropertyResolver.doubleOrNull(node.style, 'gap') ?? 10;
    final padding = PropertyResolver.paddingFrom(node.style);
    List<Widget> kids = node.children.map(childRenderer).toList();
    if (kids.isEmpty) return Container(padding: padding == EdgeInsets.zero ? const EdgeInsets.all(12) : padding, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.grey.shade50), child: const Text('Column (empty)', style: TextStyle(color: Colors.grey, fontSize: 11)));
    List<Widget> spaced = [];
    for (int i = 0; i < kids.length; i++) {
      spaced.add(kids[i]);
      if (i != kids.length - 1) spaced.add(SizedBox(height: gap));
    }
    Widget w = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: spaced);
    if (padding != EdgeInsets.zero) w = Padding(padding: padding, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

// PANELS
class AppzillonSimplePanelRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', 'Panel');
    final radius = PropertyResolver.borderRadiusFrom(node.style) ?? 12;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(top: Radius.circular(12)), border: Border(bottom: BorderSide(color: Colors.grey.shade200))), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
        Padding(padding: const EdgeInsets.all(12), child: node.children.isEmpty ? const Text('Panel content', style: TextStyle(color: Colors.grey)) : Column(children: node.children.map(childRenderer).toList())),
      ]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonTabRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'label', PropertyResolver.string(node.props, 'title', 'Tab'));
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))), child: Row(children: [const Icon(Icons.tab, color: Colors.white, size: 14), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))])),
        Padding(padding: const EdgeInsets.all(12), child: node.children.isEmpty ? const Text('Tab content') : Column(children: node.children.map(childRenderer).toList())),
      ]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonAccordionRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', 'Accordion');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
      child: ExpansionTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), children: [Padding(padding: const EdgeInsets.all(12), child: node.children.isEmpty ? const Text('Accordion content') : Column(children: node.children.map(childRenderer).toList()))]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonCarouselRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final children = node.children.map(childRenderer).toList();
    if (children.isEmpty) {
      return Container(height: 120, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: const Center(child: Text('Carousel (empty)', style: TextStyle(color: Colors.grey))));
    }
    return SizedBox(height: 140, child: PageView(children: children.map((w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: w)).toList()));
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonCollapsibleRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', 'Collapsible');
    final collapsed = PropertyResolver.boolVal(node.props, 'collapsed', false);
    return ExpansionTile(initiallyExpanded: !collapsed, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), children: [Padding(padding: const EdgeInsets.all(12), child: node.children.isEmpty ? const Text('Collapsible content') : Column(children: node.children.map(childRenderer).toList()))]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonPanelSectionRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', 'Section');
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: const Color(0xFF0F172A), width: 3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(title.toUpperCase(), style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1))),
        Divider(height: 1, color: Colors.grey.shade200),
        Padding(padding: const EdgeInsets.all(12), child: node.children.isEmpty ? const Text('Section content') : Column(children: node.children.map(childRenderer).toList())),
      ]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

// CONTAINERS
class AppzillonBreadcrumbRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final itemsRaw = node.props['items'];
    List<String> items;
    if (itemsRaw is List) items = itemsRaw.map((e) => e.toString()).toList();
    else items = [PropertyResolver.string(node.props, 'text', 'Home'), 'Category', 'Current'];
    if (node.children.isNotEmpty) items = node.children.map((c) => c.props['text']?.toString() ?? c.type).toList();
    return Row(children: [
      for (int i = 0; i < items.length; i++) ...[
        Text(items[i], style: TextStyle(color: i == items.length - 1 ? const Color(0xFF0F172A) : Colors.grey.shade600, fontWeight: i == items.length - 1 ? FontWeight.w600 : FontWeight.w400, fontSize: 12)),
        if (i != items.length - 1) Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400)),
      ]
    ]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonChartRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', 'Chart');
    final valuesRaw = node.props['values'];
    List<double> values;
    if (valuesRaw is List) values = valuesRaw.map((e) => (e as num).toDouble()).toList();
    else values = [30, 60, 45, 80, 55];
    final maxV = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        SizedBox(height: 80, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (int i = 0; i < values.length; i++) ...[
            Expanded(child: Container(height: (values[i] / maxV * 60).clamp(8, 60), decoration: BoxDecoration(color: i == values.length - 1 ? const Color(0xFF0F172A) : Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
            if (i != values.length - 1) const SizedBox(width: 6),
          ]
        ])),
        if (node.children.isNotEmpty) ...[const SizedBox(height: 10), ...node.children.map(childRenderer)],
      ]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonFormRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', '');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (title.isNotEmpty) ...[Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))), const SizedBox(height: 12), Divider(height: 1, color: Colors.grey.shade200), const SizedBox(height: 12)],
        if (node.children.isEmpty) const Text('Form fields go here', style: TextStyle(color: Colors.grey, fontSize: 12)) else ...node.children.map(childRenderer),
      ]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonGaugeRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final value = PropertyResolver.doubleVal(node.props, 'value', 0.65);
    final label = PropertyResolver.string(node.props, 'label', '${(value * 100).toInt()}%');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [SizedBox(width: 90, height: 90, child: CircularProgressIndicator(value: value.clamp(0, 1), strokeWidth: 8, color: const Color(0xFF0F172A), backgroundColor: Colors.grey.shade200)), Text(label, style: const TextStyle(fontWeight: FontWeight.w800)) ])),
        if (node.children.isNotEmpty) ...[const SizedBox(height: 10), ...node.children.map(childRenderer)],
      ]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonListRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final gap = PropertyResolver.doubleOrNull(node.style, 'gap') ?? 8;
    List<Widget> kids = node.children.map(childRenderer).toList();
    if (kids.isEmpty) return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: const Text('List (empty)', style: TextStyle(color: Colors.grey, fontSize: 11)));
    List<Widget> spaced = [];
    for (int i = 0; i < kids.length; i++) {
      spaced.add(kids[i]);
      if (i != kids.length - 1) spaced.add(SizedBox(height: gap));
    }
    return Column(children: spaced);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonMenuRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final itemsRaw = node.props['items'];
    List<String> items;
    if (itemsRaw is List) items = itemsRaw.map((e) => e.toString()).toList();
    else items = ['Item 1', 'Item 2', 'Item 3'];
    if (node.children.isNotEmpty) return Column(children: node.children.map(childRenderer).toList());
    return Column(
      children: items.map((t) => ListTile(dense: true, title: Text(t, style: const TextStyle(fontSize: 13)), leading: const Icon(Icons.circle, size: 8), onTap: () { final ev = node.events['onTap']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); })).toList(),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonNavbarRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final title = PropertyResolver.string(node.props, 'title', 'Navbar');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [const Icon(Icons.menu, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))), const Icon(Icons.search, color: Colors.white70, size: 18), if (node.children.isNotEmpty) ...node.children.map(childRenderer)]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonTableRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final headersRaw = node.props['headers'];
    List<String> headers;
    if (headersRaw is List) headers = headersRaw.map((e) => e.toString()).toList();
    else headers = ['Column 1', 'Column 2', 'Column 3'];
    final rowsRaw = node.props['rows'];
    List<List<String>> rows;
    if (rowsRaw is List) rows = rowsRaw.map((r) => (r as List).map((e) => e.toString()).toList()).toList();
    else rows = [['Cell 1', 'Cell 2', 'Cell 3'], ['Cell 4', 'Cell 5', 'Cell 6']];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(Colors.grey.shade100),
        columns: headers.map((h) => DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)))).toList(),
        rows: rows.map((r) => DataRow(cells: r.map((c) => DataCell(Text(c, style: const TextStyle(fontSize: 12)))).toList())).toList(),
      ),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

// ELEMENTS
class AppzillonBadgeRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'text', PropertyResolver.string(node.props, 'label', 'Badge'));
    final variant = PropertyResolver.string(node.props, 'variant', 'primary');
    Color bg, fg;
    if (variant == 'success') { bg = const Color(0xFFDCFCE7); fg = const Color(0xFF166534); } else if (variant == 'warning') { bg = const Color(0xFFFEF3C7); fg = const Color(0xFF92400E); } else { bg = const Color(0xFF0F172A); fg = Colors.white; }
    Widget w = Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)));
    if (node.children.isNotEmpty) w = Column(children: [w, ...node.children.map(childRenderer)]);
    final onTap = node.events['onTap'];
    if (onTap != null) w = InkWell(onTap: () { if (onTap is Map) context.dispatchAction(Map<String, dynamic>.from(onTap as Map)); }, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonBulletsRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final itemsRaw = node.props['items'];
    List<String> items;
    if (itemsRaw is List) items = itemsRaw.map((e) => e.toString()).toList();
    else if (node.children.isNotEmpty) items = node.children.map((c) => c.props['text']?.toString() ?? c.type).toList();
    else items = ['Bullet 1', 'Bullet 2', 'Bullet 3'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: items.map((t) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.circle)), const SizedBox(width: 8), Expanded(child: Text(t, style: const TextStyle(fontSize: 13))) ]))).toList());
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonButtonRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'text', PropertyResolver.string(node.props, 'label', 'Button'));
    final enabled = PropertyResolver.boolVal(node.props, 'enabled', true);
    final radius = PropertyResolver.borderRadiusFrom(node.style) ?? 8;
    void onTap() {
      final ev = node.events['onTap'] ?? node.events['onPressed'];
      if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
      else if (ev is String) context.dispatchActionType(ev);
      else ScaffoldMessenger.of(context.context).showSnackBar(SnackBar(content: Text('Tapped: $label')));
    }
    Widget w = ElevatedButton(onPressed: enabled ? onTap : null, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))), child: Text(label));
    if (node.children.isNotEmpty) w = Column(children: [w, ...node.children.map(childRenderer)]);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonCardNumberRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final number = PropertyResolver.string(node.props, 'text', PropertyResolver.string(node.props, 'number', '4111 1111 1111 1111'));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [const Icon(Icons.credit_card, size: 20, color: Color(0xFF0F172A)), const SizedBox(width: 10), Expanded(child: Text(number, style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w600, fontFamily: 'monospace'))), const Icon(Icons.copy, size: 16, color: Colors.grey)]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonCheckRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'label', PropertyResolver.string(node.props, 'text', 'Check'));
    final value = PropertyResolver.boolVal(node.props, 'value', PropertyResolver.boolVal(node.props, 'checked', false));
    return Row(children: [Checkbox(value: value, onChanged: (v) { final ev = node.events['onChanged'] ?? node.events['onTap']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); }), Text(label, style: const TextStyle(fontSize: 13))]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonCheckGroupRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final itemsRaw = node.props['items'] ?? node.props['options'];
    List<String> items;
    if (itemsRaw is List) items = itemsRaw.map((e) => e.toString()).toList();
    else if (node.children.isNotEmpty) items = node.children.map((c) => c.props['label']?.toString() ?? c.props['text']?.toString() ?? c.type).toList();
    else items = ['Option A', 'Option B', 'Option C'];
    return Column(children: items.map((t) => CheckboxListTile(value: false, onChanged: (_) { final ev = node.events['onChanged']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); }, title: Text(t, style: const TextStyle(fontSize: 13)), controlAffinity: ListTileControlAffinity.leading, dense: true)).toList());
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonDropdownRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'label', '');
    final hint = PropertyResolver.string(node.props, 'hint', 'Select');
    final itemsRaw = node.props['items'] ?? node.props['options'];
    List<String> items;
    if (itemsRaw is List) items = itemsRaw.map((e) => e.toString()).toList();
    else items = ['Option 1', 'Option 2'];
    final value = PropertyResolver.string(node.props, 'value', '');
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label.isNotEmpty ? label : null, hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), filled: true, fillColor: Colors.white),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: (v) { final ev = node.events['onChanged'] ?? node.events['onTap']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); },
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonDropdownListRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    // Reuse dropdown but show as list
    return AppzillonDropdownRenderer().render(node, context, childRenderer);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonExternalLinkRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final text = PropertyResolver.string(node.props, 'text', PropertyResolver.string(node.props, 'label', 'External Link'));
    final url = PropertyResolver.string(node.props, 'url', PropertyResolver.string(node.props, 'href', 'https://example.com'));
    return InkWell(
      onTap: () { final ev = node.events['onTap']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); else ScaffoldMessenger.of(context.context).showSnackBar(SnackBar(content: Text('Open $url'))); },
      child: Row(mainAxisSize: MainAxisSize.min, children: [Text(text, style: const TextStyle(color: Color(0xFF2563EB), decoration: TextDecoration.underline, fontSize: 13)), const SizedBox(width: 4), const Icon(Icons.open_in_new, size: 14, color: Color(0xFF2563EB))]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonFileRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final name = PropertyResolver.string(node.props, 'name', PropertyResolver.string(node.props, 'fileName', 'document.pdf'));
    final size = PropertyResolver.string(node.props, 'size', '2.4 MB');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white),
      child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.insert_drive_file, color: Color(0xFF2563EB), size: 18)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text(size, style: TextStyle(color: Colors.grey.shade600, fontSize: 11))])), const Icon(Icons.download, size: 18, color: Colors.grey)]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonHyperlinkRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final text = PropertyResolver.string(node.props, 'text', 'Hyperlink');
    return InkWell(
      onTap: () { final ev = node.events['onTap']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); },
      child: Text(text, style: const TextStyle(color: Color(0xFF2563EB), decoration: TextDecoration.underline)),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonIconRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final name = PropertyResolver.string(node.props, 'icon', PropertyResolver.string(node.props, 'name', 'star'));
    final size = PropertyResolver.doubleOrNull(node.props, 'size') ?? 24;
    final color = PropertyResolver.colorOrNull(node.props, 'color') ?? const Color(0xFF0F172A);
    IconData icon;
    switch (name.toLowerCase()) {
      case 'dashboard': icon = Icons.dashboard; break;
      case 'widgets': icon = Icons.widgets; break;
      case 'edit': icon = Icons.edit; break;
      default: icon = Icons.star;
    }
    return Icon(icon, size: size, color: color);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonImageRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final src = PropertyResolver.string(node.props, 'src', PropertyResolver.string(node.props, 'url', ''));
    final height = PropertyResolver.doubleOrNull(node.props, 'height') ?? 160;
    if (src.isEmpty) return Container(height: height, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image));
    if (src.startsWith('http')) return Image.network(src, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: height, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)));
    return Image.network(src, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: height, color: Colors.grey.shade200));
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonInputRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'label', '');
    final hint = PropertyResolver.string(node.props, 'hint', PropertyResolver.string(node.props, 'placeholder', ''));
    final value = PropertyResolver.string(node.props, 'value', '');
    final required = PropertyResolver.boolVal(node.props, 'required', false);
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(labelText: label.isNotEmpty ? '${label}${required ? " *" : ""}' : null, hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), filled: true, fillColor: Colors.white),
      onChanged: (v) { final ev = node.events['onChanged']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); },
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonInputWithButtonRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final hint = PropertyResolver.string(node.props, 'hint', 'Enter value');
    final btnText = PropertyResolver.string(node.props, 'buttonText', 'Go');
    return Row(children: [Expanded(child: TextField(decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), filled: true, fillColor: Colors.white))), const SizedBox(width: 8), FilledButton(onPressed: () { final ev = node.events['onTap']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); }, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A)), child: Text(btnText))]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonLabelRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final text = PropertyResolver.string(node.props, 'text', PropertyResolver.string(node.props, 'label', 'Label'));
    final color = PropertyResolver.colorOrNull(node.props, 'color') ?? Colors.grey.shade700;
    return Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500));
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonProgressBarRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final value = PropertyResolver.doubleVal(node.props, 'value', 0.5);
    final color = PropertyResolver.colorOrNull(node.props, 'color') ?? const Color(0xFF0F172A);
    return LinearProgressIndicator(value: value.clamp(0, 1), color: color, backgroundColor: Colors.grey.shade200);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonProgressStepsRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final stepsRaw = node.props['steps'];
    List<String> steps;
    if (stepsRaw is List) steps = stepsRaw.map((e) => e.toString()).toList();
    else steps = ['Step 1', 'Step 2', 'Step 3'];
    final current = PropertyResolver.intVal(node.props, 'current', 0);
    return Row(children: [
      for (int i = 0; i < steps.length; i++) ...[
        Container(width: 28, height: 28, decoration: BoxDecoration(color: i <= current ? const Color(0xFF0F172A) : Colors.grey.shade300, shape: BoxShape.circle), child: Center(child: i < current ? const Icon(Icons.check, size: 14, color: Colors.white) : Text('${i + 1}', style: TextStyle(color: i <= current ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w700, fontSize: 12)))),
        if (i != steps.length - 1) Expanded(child: Container(height: 2, color: i < current ? const Color(0xFF0F172A) : Colors.grey.shade300)),
      ]
    ]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonRadioRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'label', 'Radio');
    final value = PropertyResolver.boolVal(node.props, 'value', false);
    return Row(children: [Radio(value: true, groupValue: value ? true : null, onChanged: (_) { final ev = node.events['onChanged']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); }), Text(label, style: const TextStyle(fontSize: 13))]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonSeparatorRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final thickness = PropertyResolver.doubleOrNull(node.props, 'thickness') ?? 1;
    final color = PropertyResolver.colorOrNull(node.props, 'color') ?? Colors.grey.shade300;
    final margin = PropertyResolver.doubleOrNull(node.props, 'margin') ?? 0;
    Widget w = Divider(thickness: thickness, color: color, height: thickness + 16);
    if (margin != 0) w = Padding(padding: EdgeInsets.symmetric(vertical: margin), child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonSliderRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final value = PropertyResolver.doubleVal(node.props, 'value', 0.5);
    final min = PropertyResolver.doubleVal(node.props, 'min', 0);
    final max = PropertyResolver.doubleVal(node.props, 'max', 1);
    return Slider(value: value.clamp(min, max), min: min, max: max, activeColor: const Color(0xFF0F172A), onChanged: (v) { final ev = node.events['onChanged']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); });
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonSortCodeRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final code = PropertyResolver.string(node.props, 'code', PropertyResolver.string(node.props, 'value', '12-34-56'));
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white), child: Text(code, style: const TextStyle(fontFamily: 'monospace', letterSpacing: 1, fontWeight: FontWeight.w600)));
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonSortCodeListRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final itemsRaw = node.props['items'] ?? node.props['codes'];
    List<String> items;
    if (itemsRaw is List) items = itemsRaw.map((e) => e.toString()).toList();
    else items = ['12-34-56', '65-43-21'];
    return Column(children: items.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: AppzillonSortCodeRenderer().render(UiNode(type: 'appzillon.sort_code', props: {'code': c}), context, childRenderer))).toList());
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonStepperRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final value = PropertyResolver.intVal(node.props, 'value', 1);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () { final ev = node.events['onChanged']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); }, style: IconButton.styleFrom(side: BorderSide(color: Colors.grey.shade300))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w600))),
      IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () { final ev = node.events['onChanged']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); }, style: IconButton.styleFrom(side: BorderSide(color: Colors.grey.shade300))),
    ]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonTagsRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final itemsRaw = node.props['items'] ?? node.props['tags'];
    List<String> items;
    if (itemsRaw is List) items = itemsRaw.map((e) => e.toString()).toList();
    else items = ['Tag 1', 'Tag 2'];
    return Wrap(spacing: 6, runSpacing: 6, children: items.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 12)), backgroundColor: const Color(0xFFF1F5F9), side: BorderSide(color: Colors.grey.shade200))).toList());
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonTextRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final text = PropertyResolver.string(node.props, 'text', PropertyResolver.string(node.props, 'value', 'Text'));
    final fontSize = PropertyResolver.doubleOrNull(node.style, 'fontSize') ?? 14;
    final color = PropertyResolver.colorOrNull(node.style, 'color') ?? const Color(0xFF0F172A);
    final weight = PropertyResolver.fontWeightFrom(node.style['fontWeight'] ?? node.props['fontWeight']);
    final align = PropertyResolver.textAlignFrom(node.style['textAlign'] ?? node.props['textAlign']);
    return Text(text, textAlign: align, style: TextStyle(fontSize: fontSize, color: color, fontWeight: weight));
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonTextareaRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'label', '');
    final hint = PropertyResolver.string(node.props, 'hint', '');
    final value = PropertyResolver.string(node.props, 'value', '');
    return TextField(maxLines: 4, controller: TextEditingController(text: value), decoration: InputDecoration(labelText: label.isNotEmpty ? label : null, hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white));
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AppzillonToggleRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final label = PropertyResolver.string(node.props, 'label', PropertyResolver.string(node.props, 'text', 'Toggle'));
    final value = PropertyResolver.boolVal(node.props, 'value', false);
    return Row(children: [Switch(value: value, onChanged: (v) { final ev = node.events['onChanged'] ?? node.events['onTap']; if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map)); }), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 13))]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}
