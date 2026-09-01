import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdui_builder/sdui_builder.dart';
import 'package:sdui_engine/sdui_engine.dart';

import 'screens/manage_json_screen.dart';
import 'services/sdui_graphql_service.dart';
import 'widgets/custom_components.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlaygroundApp());
}

class PlaygroundApp extends StatefulWidget {
  const PlaygroundApp({super.key});

  @override
  State<PlaygroundApp> createState() => _PlaygroundAppState();
}

class _PlaygroundAppState extends State<PlaygroundApp> {
  late final SduiEngine engine;
  late final BuilderController controller;
  late final SduiGraphqlService gqlService;
  int _tab = 0; // 0 = builder, 1 = preview, 2 = demo, 3 = manage

  @override
  void initState() {
    super.initState();
    engine = SduiEngine();
    // === APPZILLON PLUGIN (proves extension layer, not hardcoded) ===
    engine.registerPlugin(AppzillonPlugin());
    // === CUSTOM COMPONENT INJECTION (proves host can still inject alongside Appzillon) ===
    engine.registerComponent('custom.customer_card', CustomerCardRenderer());
    engine.registerComponent('profile_card', ProfileCardRenderer());
    engine.registerComponent('product_card', ProductCardRenderer());
    engine.registerComponent('custom_card', ProfileCardRenderer());
    engine.registerAction('open_payment', OpenPaymentAction());

    // GraphQL — strictly API level, MySQL behind Java
    gqlService = SduiGraphqlService.create(endpoint: 'http://127.0.0.1:8080/graphql');

    // initial document: demo welcome screen
    final initialDoc = UiDocument(
      version: '1.0',
      root: UiNode(
        type: 'column',
        style: {'gap': 12, 'padding': 16},
        children: [
          UiNode(
            type: 'text',
            props: {'text': 'Welcome to SDUI'},
            style: {'fontSize': 26, 'fontWeight': 'bold', 'color': '#0F172A'},
          ),
          UiNode(
            type: 'text',
            props: {
              'text': 'Build UI visually → Generate JSON → Load JSON → Render natively',
            },
            style: {'fontSize': 13, 'color': '#64748B'},
          ),
          UiNode(type: 'divider', props: {'thickness': 1}),
          UiNode(
            type: 'card',
            style: {'borderRadius': 16, 'padding': 16},
            children: [
              UiNode(
                type: 'text',
                props: {'text': 'Drag components from the left palette'},
                style: {'fontSize': 14, 'fontWeight': 'medium'},
              ),
              UiNode(
                type: 'text',
                props: {
                  'text': 'Try Profile Card (custom injected component) from code',
                },
                style: {'fontSize': 12, 'color': '#64748B'},
              ),
              UiNode(
                type: 'button',
                props: {'text': 'Continue'},
                style: {'borderRadius': 10},
                events: {
                  'onTap': {
                    'action': 'show_snackbar',
                    'message': 'Hello from SDUI!',
                  },
                },
              ),
            ],
          ),
          UiNode(
            type: 'profile_card',
            props: {
              'name': 'Kalandhar S',
              'role': 'SDUI Architect',
              'avatar': 'https://i.pravatar.cc/150?img=11',
            },
            style: {'backgroundColor': '#FFFFFF', 'borderRadius': 16},
          ),
        ],
      ),
    );

    controller = BuilderController(engine: engine, initial: initialDoc);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDUI Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopTabs(tab: _tab, engine: engine, onChanged: (i) => setState(() => _tab = i)),
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    BuilderScreen(
                      controller: controller,
                      onSaveToServer: (name, json) async {
                        if (controller.loadedTemplateId != null) {
                          await gqlService.updateTemplate(id: controller.loadedTemplateId!, name: name, json: json);
                          controller.loadedTemplateName = name;
                          if (mounted) setState(() {});
                        } else {
                          final created = await gqlService.saveTemplate(name: name, json: json);
                          controller.loadedTemplateId = created.id;
                          controller.loadedTemplateName = created.name;
                          if (mounted) setState(() {});
                        }
                      },
                    ),
                    _PreviewTab(controller: controller, engine: engine),
                    _DemoTab(engine: engine),
                    ManageJsonScreen(controller: controller, service: gqlService, onLoaded: () => setState(() => _tab = 0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final int tab;
  final SduiEngine engine;
  final ValueChanged<int> onChanged;
  const _TopTabs({required this.tab, required this.engine, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        final isCompact = w < 640;
        final isVeryCompact = w < 420;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 16, vertical: 8),
          child: Row(
            children: [
              // Tabs - scrollable if needed
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TabBtn(label: 'Builder', icon: Icons.view_quilt, selected: tab == 0, onTap: () => onChanged(0), compact: isCompact),
                      const SizedBox(width: 8),
                      _TabBtn(label: isCompact ? 'Preview' : 'Preview (Engine)', icon: Icons.phone_iphone, selected: tab == 1, onTap: () => onChanged(1), compact: isCompact),
                      const SizedBox(width: 8),
                      _TabBtn(label: isCompact ? 'Demo' : 'Custom Injection Demo', icon: Icons.extension, selected: tab == 2, onTap: () => onChanged(2), compact: isCompact),
                      const SizedBox(width: 8),
                      _TabBtn(label: isCompact ? 'Manage' : 'Manage JSON', icon: Icons.storage, selected: tab == 3, onTap: () => onChanged(3), compact: isCompact),
                    ],
                  ),
                ),
              ),
              if (!isVeryCompact) const SizedBox(width: 12),
              if (!isVeryCompact)
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        isCompact ? 'SDUI v1.0' : 'SDUI v1.0 • ${engine.componentRegistry.length} components • Appzillon • Generic',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.icon, required this.selected, required this.onTap, this.compact = false});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 7 : 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0xFF0F172A) : Colors.grey.shade200),
          boxShadow: selected ? [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: compact ? 13 : 14, color: selected ? Colors.white : Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: compact ? 11 : 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF334155))),
        ]),
      ),
    );
  }
}

class _PreviewTab extends StatelessWidget {
  final BuilderController controller;
  final SduiEngine engine;
  const _PreviewTab({required this.controller, required this.engine});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final json = controller.generateJsonMap();
        return Container(
          color: const Color(0xFFF1F5F9),
          child: LayoutBuilder(builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 500;
            final horizontalMargin = isMobile ? 12.0 : 24.0;
            final maxW = isMobile ? constraints.maxWidth - horizontalMargin * 2 : 420.0;
            final maxH = isMobile ? constraints.maxHeight - 32 : 720.0;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
                child: Container(
                  margin: EdgeInsets.all(horizontalMargin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 10 : 12),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.red.shade400, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.amber.shade400, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green.shade400, shape: BoxShape.circle)),
                              const Spacer(),
                              Flexible(child: Text('Live Preview • SduiView', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: isMobile ? 10 : 11, letterSpacing: 0.5))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final rootType = (json['type']?.toString() ?? '').toLowerCase();
                              final isScrollableRoot = rootType == 'singlechildscrollview';
                              final view = SduiView(data: json, engine: engine, onAction: (type, params) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action: $type'))));
                              if (isScrollableRoot) {
                                // Root already scrollable — avoid nested SingleChildScrollView (freeze fix for big JSON)
                                return Padding(padding: EdgeInsets.all(isMobile ? 12 : 16), child: view);
                              }
                              return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 12 : 16), child: view);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _DemoTab extends StatelessWidget {
  final SduiEngine engine;
  const _DemoTab({required this.engine});

  @override
  Widget build(BuildContext context) {
    final demoJsons = _demoCases;
    return Container(
      color: const Color(0xFFF8FAFC),
      child: LayoutBuilder(builder: (context, c) {
        final isMobile = c.maxWidth < 640;
        return ListView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.extension, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Extension Demo', style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text('These JSONs use custom components injected by the host app without modifying the engine core.', style: TextStyle(color: Colors.grey.shade600, fontSize: isMobile ? 12 : 13, height: 1.4)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...demoJsons.map((d) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _DemoCard(title: d['title'] as String, subtitle: d['desc'] as String, json: d['json'] as Map<String, dynamic>, engine: engine))),
          ],
        );
      }),
    );
  }

  static const _demoCases = [
    {
      'title': 'Scenario A — Column + Text + Button + Card',
      'desc': 'Basic nesting; Generate JSON → Load JSON round-trip',
      'json': {
        'version': '1.0',
        'type': 'column',
        'style': {'gap': 12, 'padding': 16},
        'children': [
          {'type': 'text', 'props': {'text': 'Welcome'}, 'style': {'fontSize': 24, 'fontWeight': 'bold'}},
          {'type': 'button', 'props': {'text': 'Continue'}, 'events': {'onTap': {'action': 'show_snackbar', 'message': 'Continued'}}},
          {
            'type': 'card',
            'style': {'borderRadius': 16, 'padding': 16},
            'children': [
              {'type': 'text', 'props': {'text': 'Card content here'}, 'style': {'fontSize': 14}},
              {'type': 'divider'},
              {
                'type': 'row',
                'style': {'gap': 8},
                'children': [
                  {'type': 'icon', 'props': {'icon': 'star', 'size': 18}},
                  {'type': 'text', 'props': {'text': 'Star item'}, 'style': {'fontSize': 13}}
                ]
              }
            ]
          }
        ]
      }
    },
    {
      'title': 'Scenario C — Custom profile_card injection',
      'desc': 'Host app registered profile_card; JSON renders without engine change',
      'json': {
        'version': '1.0',
        'type': 'column',
        'style': {'gap': 12, 'padding': 16},
        'children': [
          {'type': 'text', 'props': {'text': 'Custom Components'}, 'style': {'fontSize': 20, 'fontWeight': 'bold'}},
          {'type': 'profile_card', 'props': {'name': 'Demo User', 'role': 'Verified Creator', 'avatar': 'https://i.pravatar.cc/150?img=68'}},
          {'type': 'product_card', 'props': {'title': 'Noise Cancelling Headphones', 'price': '\$199', 'image': 'https://picsum.photos/500/300'}},
          {'type': 'button', 'props': {'text': 'Pay Now'}, 'events': {'onTap': {'action': 'open_payment', 'amount': '199'}}}
        ]
      }
    },
    {
      'title': 'Unknown component fallback',
      'desc': 'Engine shows friendly placeholder instead of crashing',
      'json': {
        'version': '1.0',
        'type': 'column',
        'style': {'gap': 12, 'padding': 16},
        'children': [
          {'type': 'text', 'props': {'text': 'Known block'}, 'style': {'fontSize': 16}},
          {'type': 'custom_banner', 'props': {'title': 'This type is not registered'}},
          {'type': 'text', 'props': {'text': 'Still renders after error'}, 'style': {'color': '#64748B'}},
        ]
      }
    },
  ];
}

class _DemoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Map<String, dynamic> json;
  final SduiEngine engine;
  const _DemoCard({required this.title, required this.subtitle, required this.json, required this.engine});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isMobile = c.maxWidth < 500;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 14 : 20, 14, isMobile ? 14 : 20, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: isMobile ? 13 : 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade600, height: 1.3)),
              ]),
            ),
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: EdgeInsets.all(isMobile ? 10 : 16),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: SduiView(data: json, engine: engine, onAction: (t, p) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action $t: $p')))),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 10 : 16, 0, isMobile ? 10 : 16, isMobile ? 10 : 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    _pretty(json),
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 11, height: 1.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _pretty(Map<String, dynamic> j) => const JsonEncoder.withIndent('  ').convert(j);
}
