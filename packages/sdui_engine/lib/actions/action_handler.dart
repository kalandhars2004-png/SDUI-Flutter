import 'package:flutter/material.dart';

import '../renderer/render_context.dart';

abstract class ActionHandler {
  Future<void> handle(RenderContext context, Map<String, dynamic> params);
}

/// Built-in: show_dialog
class ShowDialogAction implements ActionHandler {
  @override
  Future<void> handle(
    RenderContext context,
    Map<String, dynamic> params,
  ) async {
    final title = params['title'] as String? ?? 'Dialog';
    final message = params['message'] as String? ?? '';
    if (context.context.mounted) {
      await showDialog(
        context: context.context,
        builder: (c) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

/// Built-in: show_snackbar
class ShowSnackbarAction implements ActionHandler {
  @override
  Future<void> handle(
    RenderContext context,
    Map<String, dynamic> params,
  ) async {
    final message = params['message'] as String? ?? 'Action';
    if (context.context.mounted) {
      ScaffoldMessenger.of(context.context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

/// Built-in: navigate (push named route or simple)
class NavigateAction implements ActionHandler {
  @override
  Future<void> handle(
    RenderContext context,
    Map<String, dynamic> params,
  ) async {
    final route = params['route'] as String?;
    if (route != null && context.context.mounted) {
      Navigator.of(context.context).pushNamed(route);
    }
  }
}

/// Built-in: callback - invokes RenderContext.onAction callback if provided
class CallbackAction implements ActionHandler {
  @override
  Future<void> handle(
    RenderContext context,
    Map<String, dynamic> params,
  ) async {
    final name = params['name'] as String? ?? params['action'] as String?;
    if (name != null) {
      context.onAction?.call(name, params);
    }
  }
}
