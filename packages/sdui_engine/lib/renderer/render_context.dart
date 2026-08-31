import 'package:flutter/material.dart';

import '../registry/action_registry.dart';
import '../registry/component_registry.dart';
import '../theme/sdui_theme.dart';

typedef SduiActionCallback = void Function(
  String actionType,
  Map<String, dynamic> params,
);
typedef SduiDataProvider = dynamic Function(String key);

class RenderContext {
  final BuildContext context;
  final ComponentRegistry componentRegistry;
  final ActionRegistry actionRegistry;
  final SduiTheme theme;
  final SduiActionCallback? onAction;
  final SduiDataProvider? dataProvider;
  final Map<String, dynamic> data;

  const RenderContext({
    required this.context,
    required this.componentRegistry,
    required this.actionRegistry,
    this.theme = SduiTheme.light,
    this.onAction,
    this.dataProvider,
    this.data = const {},
  });

  RenderContext copyWith({
    BuildContext? context,
    ComponentRegistry? componentRegistry,
    ActionRegistry? actionRegistry,
    SduiTheme? theme,
    SduiActionCallback? onAction,
    SduiDataProvider? dataProvider,
    Map<String, dynamic>? data,
  }) {
    return RenderContext(
      context: context ?? this.context,
      componentRegistry: componentRegistry ?? this.componentRegistry,
      actionRegistry: actionRegistry ?? this.actionRegistry,
      theme: theme ?? this.theme,
      onAction: onAction ?? this.onAction,
      dataProvider: dataProvider ?? this.dataProvider,
      data: data ?? this.data,
    );
  }

  Future<void> dispatchAction(Map<String, dynamic> eventConfig) async {
    await actionRegistry.execute(this, eventConfig);
  }

  Future<void> dispatchActionType(
    String type, [
    Map<String, dynamic> params = const {},
  ]) async {
    await actionRegistry.executeByType(this, type, params);
  }
}
