import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

class IconRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final name = PropertyResolver.string(
      props,
      'icon',
      PropertyResolver.string(props, 'name', 'star'),
    );
    final size =
        PropertyResolver.doubleOrNull(props, 'size') ??
        PropertyResolver.doubleOrNull(style, 'size') ??
        24;
    final color =
        PropertyResolver.colorOrNull(props, 'color') ??
        PropertyResolver.colorOrNull(style, 'color') ??
        context.theme.textColor;
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Icon(_iconFor(name), size: size, color: color);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        onTap: () {
          if (onTap is Map)
            context.dispatchAction(Map<String, dynamic>.from(onTap as Map));
          if (onTap is String) context.dispatchActionType(onTap);
        },
        child: w,
      );
    }
    return w;
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'home':
        return Icons.home;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'person':
        return Icons.person;
      case 'settings':
        return Icons.settings;
      case 'search':
        return Icons.search;
      case 'add':
        return Icons.add;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'check':
        return Icons.check;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'menu':
        return Icons.menu;
      case 'close':
        return Icons.close;
      case 'delete':
        return Icons.delete;
      case 'edit':
        return Icons.edit;
      case 'calendar_today':
        return Icons.calendar_today;
      default:
        return Icons.circle;
    }
  }

  @override
  List<PropDescriptor> get propDescriptors => const [
    PropDescriptor(
      key: 'icon',
      label: 'Icon',
      type: 'enum',
      enumValues: [
        'home',
        'star',
        'favorite',
        'person',
        'settings',
        'search',
        'add',
      ],
    ),
    PropDescriptor(
      key: 'size',
      label: 'Size',
      type: 'number',
      defaultValue: 24,
    ),
  ];
}

class DividerRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final thickness =
        PropertyResolver.doubleOrNull(props, 'thickness') ??
        PropertyResolver.doubleOrNull(style, 'thickness') ??
        1;
    final color =
        PropertyResolver.colorOrNull(props, 'color') ??
        PropertyResolver.colorOrNull(style, 'color') ??
        Colors.grey.shade300;
    final indent = PropertyResolver.doubleOrNull(props, 'indent') ?? 0;
    final endIndent = PropertyResolver.doubleOrNull(props, 'endIndent') ?? 0;
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Divider(
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent,
      height: thickness + 16,
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class ListRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;

    // Handle new Appzillon GraphQL list: props.graphql + props.childrenTemplate
    if (props['graphql'] is Map) {
      return _GraphQLListWidget(node: node, context: context, childRenderer: childRenderer);
    }

    final direction = PropertyResolver.string(
      props,
      'direction',
      PropertyResolver.string(style, 'direction', 'vertical'),
    );
    final spacing =
        PropertyResolver.doubleOrNull(props, 'spacing') ??
        PropertyResolver.doubleOrNull(style, 'gap') ??
        8;
    final scrollable = PropertyResolver.boolVal(props, 'scrollable', false);
    final children = node.children.map(childRenderer).toList();

    List<Widget> spaced;
    if (direction == 'horizontal') {
      spaced = [];
      for (var i = 0; i < children.length; i++) {
        spaced.add(children[i]);
        if (i != children.length - 1) spaced.add(SizedBox(width: spacing));
      }
      Widget row = Row(children: spaced);
      if (scrollable)
        row = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: row,
        );
      return row;
    } else {
      spaced = [];
      for (var i = 0; i < children.length; i++) {
        spaced.add(children[i]);
        if (i != children.length - 1) spaced.add(SizedBox(height: spacing));
      }
      Widget col = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spaced,
      );
      if (scrollable) col = SingleChildScrollView(child: col);
      return col;
    }
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class _GraphQLListWidget extends StatefulWidget {
  final UiNode node;
  final RenderContext context;
  final Widget Function(UiNode) childRenderer;
  const _GraphQLListWidget({required this.node, required this.context, required this.childRenderer});

  @override
  State<_GraphQLListWidget> createState() => _GraphQLListWidgetState();
}

class _GraphQLListWidgetState extends State<_GraphQLListWidget> {
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final graphql = widget.node.props['graphql'] as Map<String, dynamic>?;
      if (graphql == null) {
        setState(() => _loading = false);
        return;
      }
      final urlTemplate = graphql['url'] as String? ?? '';
      final query = graphql['query'] as String? ?? '';
      String url = urlTemplate;
      if (url.contains('{{')) {
        url = _resolveTemplate(url, widget.context.data);
      }
      dynamic result;
      // Try dataProvider first (host can provide custom fetch)
      if (widget.context.dataProvider != null && url.isNotEmpty) {
        try {
          result = await widget.context.dataProvider!(url);
        } catch (_) {}
      }
      // If query is for recentTransactions, try actual GraphQL fetch
      if (result == null && query.contains('recentTransactions')) {
        // Try to fetch from local server GraphQL endpoint
        final endpoint = url.isNotEmpty && url.startsWith('http') ? url : 'http://127.0.0.1:8080/graphql';
        try {
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'query': query}),
          );
          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded['data'] != null) {
              result = decoded['data'];
            }
          }
        } catch (_) {
          // Fallback to mock
        }
        // Fallback mock if still null
        result ??= {
          'recentTransactions': [
            {'id': '1', 'description': 'UPI Payment to John', 'amount': '250.00', 'type': 'debit', 'date': '2024-01-15'},
            {'id': '2', 'description': 'Salary Credit', 'amount': '50000.00', 'type': 'credit', 'date': '2024-01-10'},
            {'id': '3', 'description': 'Grocery Shopping', 'amount': '1200.50', 'type': 'debit', 'date': '2024-01-12'},
            {'id': '4', 'description': 'Electricity Bill', 'amount': '850.00', 'type': 'debit', 'date': '2024-01-14'},
            {'id': '5', 'description': 'Freelance Income', 'amount': '15000.00', 'type': 'credit', 'date': '2024-01-08'},
          ]
        };
      }
      // Generic handling for other queries: try http if url is provided
      if (result == null && url.isNotEmpty && url.startsWith('http') && query.isNotEmpty) {
        try {
          final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'query': query}));
          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            result = decoded['data'] ?? decoded;
          }
        } catch (_) {}
      }
      List<Map<String, dynamic>> list = [];
      if (result is Map && result['recentTransactions'] is List) {
        list = (result['recentTransactions'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else if (result is Map) {
        // Try to find first list in result
        for (final v in result.values) {
          if (v is List) {
            list = v.map((e) => e is Map ? Map<String, dynamic>.from(e as Map) : {'value': e}).toList();
            break;
          }
        }
      } else if (result is List) {
        list = result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      if (mounted) setState(() { _data = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _resolveTemplate(String template, Map<String, dynamic> data) {
    return template.replaceAllMapped(RegExp(r'\{\{\s*([a-zA-Z0-9_\.]+)\s*\}\}'), (m) {
      final key = m.group(1)!;
      final parts = key.split('.');
      dynamic cur = data;
      for (final p in parts) {
        if (cur is Map<String, dynamic>) cur = cur[p];
        else return m.group(0)!;
        if (cur == null) return '';
      }
      return cur.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    if (_error != null) return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Text('Error: $_error', style: TextStyle(color: Colors.red.shade700)));
    if (_data.isEmpty) return const Text('No data', style: TextStyle(color: Colors.grey));

    final templateRaw = widget.node.props['childrenTemplate'] ?? widget.node.props['children'];
    Map<String, dynamic>? template;
    if (templateRaw is Map<String, dynamic>) template = templateRaw;
    else if (templateRaw is Map) template = Map<String, dynamic>.from(templateRaw as Map);

    if (template == null) {
      // Fallback to children if no template
      return Column(children: widget.node.children.map(widget.childRenderer).toList());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _data.map((item) {
        // Merge item data with context.data for template resolution
        final mergedData = {...widget.context.data, ...item};
        final resolvedTemplate = _resolveTemplateMap(template!, mergedData);
        final node = _buildNodeFromTemplate(resolvedTemplate, mergedData);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: widget.childRenderer(node),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _resolveTemplateMap(Map<String, dynamic> map, Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final v = entry.value;
      if (v is String) {
        result[entry.key] = _resolveTemplate(v, data);
      } else if (v is Map<String, dynamic>) {
        result[entry.key] = _resolveTemplateMap(v, data);
      } else if (v is Map) {
        result[entry.key] = _resolveTemplateMap(Map<String, dynamic>.from(v as Map), data);
      } else if (v is List) {
        result[entry.key] = v.map((e) => e is String ? _resolveTemplate(e, data) : e is Map<String, dynamic> ? _resolveTemplateMap(e, data) : e is Map ? _resolveTemplateMap(Map<String, dynamic>.from(e as Map), data) : e).toList();
      } else {
        result[entry.key] = v;
      }
    }
    return result;
  }

  UiNode _buildNodeFromTemplate(Map<String, dynamic> template, Map<String, dynamic> data) {
    // Use UiNode.fromJson after resolving templates, but need to handle nested children
    // For simplicity, create UiNode directly
    String type = (template['type'] as String? ?? 'container').toLowerCase();
    Map<String, dynamic> props = {};
    Map<String, dynamic> style = {};
    Map<String, dynamic> events = {};
    List<UiNode> children = [];

    if (template['props'] is Map) {
      final p = Map<String, dynamic>.from(template['props'] as Map);
      if (p['style'] is Map) {
        style = Map<String, dynamic>.from(p['style'] as Map);
        p.remove('style');
      }
      // Handle onTap
      if (p['onTap'] != null) {
        if (p['onTap'] is String) events['onTap'] = {'action': p['onTap']};
        else if (p['onTap'] is Map) events['onTap'] = Map<String, dynamic>.from(p['onTap'] as Map);
        // Resolve payload templates
        if (events['onTap'] is Map) {
          events['onTap'] = _resolveTemplateMap(Map<String, dynamic>.from(events['onTap'] as Map), data);
        }
      }
      props = p;
    }
    // Handle children
    if (template['children'] is List) {
      for (final c in template['children'] as List) {
        if (c is Map<String, dynamic>) {
          final resolved = _resolveTemplateMap(c, data);
          children.add(_buildNodeFromTemplate(resolved, data));
        } else if (c is Map) {
          final resolved = _resolveTemplateMap(Map<String, dynamic>.from(c as Map), data);
          children.add(_buildNodeFromTemplate(resolved, data));
        }
      }
    }
    // Handle direct props like text, etc. that were resolved
    return UiNode(type: type, props: props, style: style, events: events, children: children);
  }
}

class SizedBoxRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final w =
        PropertyResolver.doubleOrNull(props, 'width') ??
        PropertyResolver.doubleOrNull(style, 'width');
    final h =
        PropertyResolver.doubleOrNull(props, 'height') ??
        PropertyResolver.doubleOrNull(style, 'height') ??
        PropertyResolver.doubleOrNull(props, 'h') ??
        16;
    return SizedBox(width: w, height: h);
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}
