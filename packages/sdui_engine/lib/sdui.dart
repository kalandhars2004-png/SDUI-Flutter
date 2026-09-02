import 'package:flutter/material.dart' hide CallbackAction;

import 'core/ui_document.dart';
import 'core/ui_node.dart';
import 'parser/sdui_parser.dart';
import 'parser/sdui_serializer.dart';
import 'registry/action_registry.dart';
import 'registry/component_registry.dart';
import 'renderer/component_renderer.dart';
import 'renderer/render_context.dart';
import 'renderer/sdui_renderer.dart';
import 'theme/sdui_theme.dart';
import 'actions/action_handler.dart';
import 'components/built_in.dart';

abstract class SduiPlugin {
  String get name;
  String get version => '1.0';
  void register(SduiEngine engine);
}

/// Main engine entry point.
/// Generic, reusable. Host apps inject components & actions.
class SduiEngine {
  final ComponentRegistry componentRegistry;
  final ActionRegistry actionRegistry;
  final SduiParser parser;
  final SduiSerializer serializer;
  late final SduiRenderer renderer;
  SduiTheme theme;
  SduiDataProvider? dataProvider;

  SduiEngine({
    ComponentRegistry? componentRegistry,
    ActionRegistry? actionRegistry,
    SduiTheme? theme,
    this.parser = const SduiParser(),
    this.serializer = const SduiSerializer(),
  }) : componentRegistry = componentRegistry ?? ComponentRegistry(),
       actionRegistry = actionRegistry ?? ActionRegistry(),
       theme = theme ?? SduiTheme.light {
    renderer = SduiRenderer(componentRegistry: this.componentRegistry);
    // register built-ins if empty
    if (this.componentRegistry.length == 0) {
      registerBuiltIns(this.componentRegistry);
    }
    // register default actions if empty
    if (this.actionRegistry.registeredTypes.isEmpty) {
      this.actionRegistry.register('show_dialog', ShowDialogAction());
      this.actionRegistry.register('show_snackbar', ShowSnackbarAction());
      this.actionRegistry.register('navigate', NavigateAction());
      this.actionRegistry.register('callback', CallbackAction());
      // alias: showDialog etc
      this.actionRegistry.register('open_url', CallbackAction());
      this.actionRegistry.register('api', CallbackAction());
    }
  }

  void registerComponent(String type, ComponentRenderer renderer) {
    componentRegistry.register(type, renderer);
  }

  void registerAction(String type, ActionHandler handler) {
    actionRegistry.register(type, handler);
  }

  void registerPlugin(SduiPlugin plugin) {
    plugin.register(this);
  }

  void registerDataProvider(SduiDataProvider provider) {
    dataProvider = provider;
  }

  UiDocument parse(Map<String, dynamic> json) => parser.parse(json);

  UiDocument parseJsonString(String jsonString) =>
      parser.parseJsonString(jsonString);

  Map<String, dynamic> toJson(UiDocument doc) => serializer.toJson(doc);

  String toJsonString(UiDocument doc, {bool pretty = true}) =>
      serializer.toJsonString(doc, pretty: pretty);

  /// Render from UiDocument
  Widget renderDocument(
    UiDocument doc,
    BuildContext context, {
    SduiActionCallback? onAction,
    Map<String, dynamic> data = const {},
    SduiDataProvider? dataProvider,
  }) {
    final rc = RenderContext(
      context: context,
      componentRegistry: componentRegistry,
      actionRegistry: actionRegistry,
      theme: theme,
      onAction: onAction,
      data: data,
      dataProvider: dataProvider ?? this.dataProvider,
    );
    return renderer.renderNode(doc.root, rc);
  }

  /// Render from raw JSON map
  Widget render(
    Map<String, dynamic> json,
    BuildContext context, {
    SduiActionCallback? onAction,
    Map<String, dynamic> data = const {},
    SduiDataProvider? dataProvider,
  }) {
    final doc = parse(json);
    return renderDocument(doc, context, onAction: onAction, data: data, dataProvider: dataProvider);
  }

  /// Render from UiNode directly
  Widget renderNode(
    UiNode node,
    BuildContext context, {
    SduiActionCallback? onAction,
    SduiDataProvider? dataProvider,
    Map<String, dynamic> data = const {},
  }) {
    final rc = RenderContext(
      context: context,
      componentRegistry: componentRegistry,
      actionRegistry: actionRegistry,
      theme: theme,
      onAction: onAction,
      dataProvider: dataProvider ?? this.dataProvider,
      data: data,
    );
    return renderer.renderNode(node, rc);
  }
}

/// High-level widget for host apps: SduiView(data: json, engine: engine)
class SduiView extends StatelessWidget {
  final Map<String, dynamic> data;
  final SduiEngine engine;
  final SduiActionCallback? onAction;
  final Map<String, dynamic> stateData;
  final SduiTheme? theme;
  final SduiDataProvider? dataProvider;

  const SduiView({
    super.key,
    required this.data,
    required this.engine,
    this.onAction,
    this.stateData = const {},
    this.theme,
    this.dataProvider,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? engine.theme;
    final previous = engine.theme;
    final prevProvider = engine.dataProvider;
    if (dataProvider != null) engine.dataProvider = dataProvider;
    Widget w;
    try {
      w = engine.render(data, context, onAction: onAction, data: stateData, dataProvider: dataProvider);
    } catch (e) {
      w = _errorWidget(e.toString());
    } finally {
      engine.theme = previous;
      engine.dataProvider = prevProvider;
    }
    return w;
  }

  Widget _errorWidget(String msg) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Text(
              'SDUI Render Error',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(msg, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
      ],
    ),
  );
}

/// Also support rendering from UiDocument
class SduiDocumentView extends StatelessWidget {
  final UiDocument document;
  final SduiEngine engine;
  final SduiActionCallback? onAction;

  const SduiDocumentView({
    super.key,
    required this.document,
    required this.engine,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) =>
      engine.renderDocument(document, context, onAction: onAction);
}
