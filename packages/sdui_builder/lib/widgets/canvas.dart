import 'package:flutter/material.dart';
import 'package:sdui_engine/sdui_engine.dart';

import '../models/appzillon_catalog.dart';
import '../models/component_definition.dart';
import '../state/builder_controller.dart';

class BuilderCanvas extends StatelessWidget {
  final BuilderController controller;
  const BuilderCanvas({super.key, required this.controller});

  bool _canHaveChildren(UiNode node) {
    final az = AppzillonComponentCatalog.byType(node.type);
    if (az != null) return az.canHaveChildren;
    final def = ComponentCatalog.byType(node.type);
    if (def != null) return def.canHaveChildren;
    return _isContainerStatic(node.type);
  }

  bool _canDrop(UiNode target, Object data) {
    if (data is ComponentDefinition) return _canHaveChildren(target);
    if (data is UiNode) {
      if (data.id == target.id) return false;
      if (!_canHaveChildren(target)) return false;
      if (_isDescendant(data, target.id)) return false;
      return true;
    }
    return false;
  }

  bool _isDescendant(UiNode ancestor, String targetId) {
    for (final child in ancestor.children) {
      if (child.id == targetId) return true;
      if (_isDescendant(child, targetId)) return true;
    }
    return false;
  }

  static bool _isContainerStatic(String type) => {
    'column',
    'row',
    'container',
    'card',
    'list',
    'stack',
    'padding',
    'center',
  }.contains(type);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          color: const Color(0xFFF1F5F9),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 500;
              final canvasMargin = isMobile ? 8.0 : 12.0;
              return Container(
                width: double.infinity,
                height: double.infinity,
                margin: EdgeInsets.all(canvasMargin),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DragTarget<ComponentDefinition>(
                    onWillAcceptWithDetails: (d) =>
                        _canDrop(controller.root, d.data),
                    onAcceptWithDetails: (details) =>
                        controller.addNode(details.data),
                    builder: (context, candidate, rejected) {
                      final isHoverValid = candidate.isNotEmpty;
                      final isHoverInvalid = rejected.isNotEmpty;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              child: _buildNode(
                                context,
                                controller.root,
                                isRoot: true,
                                isMobile: isMobile,
                              ),
                            ),
                          ),
                          if (isHoverValid)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.04),
                                  border: Border.all(
                                    color: const Color(0xFF0F172A),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_circle,
                                    size: 32,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ),
                          if (isHoverInvalid)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2)
                                      .withValues(alpha: 0.9),
                                  border: Border.all(
                                    color: const Color(0xFFEF4444),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFEF4444),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.block,
                                          color: Color(0xFFEF4444),
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Cannot nest here',
                                          style: TextStyle(
                                            color: Color(0xFF991B1B),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (controller.root.children.isEmpty &&
                              !isHoverValid &&
                              !isHoverInvalid)
                            Positioned.fill(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.dashboard_customize,
                                          color: Colors.grey.shade400,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Canvas empty',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Drag components from the left',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'or tap a component to add',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNode(
    BuildContext context,
    UiNode node, {
    bool isRoot = false,
    bool isMobile = false,
  }) {
    final isSelected = controller.selectedId == node.id;
    final canHaveChildren = _canHaveChildren(node);
    Widget content;

    if (canHaveChildren || isRoot) {
      if (node.children.isEmpty) {
        content = DragTarget<ComponentDefinition>(
          onWillAcceptWithDetails: (d) => _canDrop(node, d.data),
          onAcceptWithDetails: (details) =>
              controller.addNode(details.data, parentId: node.id),
          builder: (context, candidate, rejected) {
            final isValid = candidate.isNotEmpty;
            final isInvalid = rejected.isNotEmpty;
            return Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: isRoot ? 24 : 80),
              padding: EdgeInsets.all(
                isRoot ? (isValid || isInvalid ? 10 : 4) : 12,
              ),
              decoration: BoxDecoration(
                color: isInvalid
                    ? const Color(0xFFFEF2F2)
                    : isValid
                    ? const Color(0xFFEFF6FF)
                    : (isRoot ? Colors.transparent : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isInvalid
                      ? const Color(0xFFEF4444)
                      : isValid
                      ? const Color(0xFF3B82F6)
                      : (isRoot ? Colors.transparent : Colors.grey.shade200),
                  width: (isValid || isInvalid) ? 1.5 : 1,
                ),
              ),
              child: isRoot
                  ? (isValid
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: Center(
                              child: Text(
                                'Drop here',
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : isInvalid
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.block,
                                    size: 16,
                                    color: Color(0xFFEF4444),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Cannot nest • leaf selected',
                                    style: TextStyle(
                                      color: Color(0xFF991B1B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(height: 8))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                node.type,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${node.children.length} items',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isInvalid
                                  ? Icons.block
                                  : Icons.add_circle_outline,
                              size: 14,
                              color: isInvalid
                                  ? const Color(0xFFEF4444)
                                  : isValid
                                  ? const Color(0xFF3B82F6)
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isInvalid
                                    ? 'Cannot nest into ${node.type}'
                                    : isValid
                                    ? 'Drop to add'
                                    : 'Empty ${node.type} — drag here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isInvalid
                                      ? const Color(0xFF991B1B)
                                      : isValid
                                      ? const Color(0xFF3B82F6)
                                      : Colors.grey.shade400,
                                  fontWeight: isInvalid
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            );
          },
        );
      } else {
        final gap =
            (node.style['gap'] as num?)?.toDouble() ??
            (node.props['spacing'] as num?)?.toDouble() ??
            (node.type == 'row' || node.type == 'column' ? 10 : 8);
        List<Widget> childWidgets = node.children
            .map((c) => _buildNode(context, c, isMobile: isMobile))
            .toList();

        Widget inner;
        if (node.type == 'row') {
          inner = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < childWidgets.length; i++) ...[
                Flexible(child: childWidgets[i]),
                if (i != childWidgets.length - 1) SizedBox(width: gap),
              ],
            ],
          );
          inner = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(child: inner),
          );
        } else {
          // For big lists, use builder to avoid building all at once (freeze fix for big JSON)
          if (childWidgets.length > 12) {
            inner = ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: childWidgets.length,
              separatorBuilder: (_, __) => SizedBox(height: gap),
              itemBuilder: (_, i) => RepaintBoundary(child: childWidgets[i]),
            );
          } else {
            List<Widget> spaced = [];
            for (int i = 0; i < childWidgets.length; i++) {
              spaced.add(RepaintBoundary(child: childWidgets[i]));
              if (i != childWidgets.length - 1)
                spaced.add(SizedBox(height: gap));
            }
            inner = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: spaced,
            );
          }
        }

        inner = _wrapWithStyle(node, inner);

        content = DragTarget<ComponentDefinition>(
          onWillAcceptWithDetails: (d) => _canDrop(node, d.data),
          onAcceptWithDetails: (details) =>
              controller.addNode(details.data, parentId: node.id),
          builder: (context, candidate, rejected) {
            final isValid = candidate.isNotEmpty;
            final isInvalid = rejected.isNotEmpty;
            return Container(
              decoration: isInvalid
                  ? BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFEF4444),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFFEF2F2).withValues(alpha: 0.5),
                    )
                  : isValid
                  ? BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF3B82F6),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.035),
                    )
                  : null,
              padding: (isValid || isInvalid) ? const EdgeInsets.all(4) : null,
              child: Stack(
                children: [
                  inner,
                  if (isInvalid)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Invalid',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }
    } else {
      content = _leafPreview(context, node);
    }

    if (isRoot) {
      return GestureDetector(
        onTap: () => controller.select(node.id),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  border: Border.all(color: const Color(0xFF0F172A), width: 1),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: content,
        ),
      );
    }

    return _SelectableWrapper(
      node: node,
      isSelected: isSelected,
      onTap: () => controller.select(node.id),
      onDelete: () => controller.deleteNode(node.id),
      onDuplicate: () {
        controller.select(node.id);
        controller.duplicateSelected();
      },
      controller: controller,
      child: content,
      canDropCheck: _canDrop,
    );
  }

  Widget _wrapWithStyle(UiNode node, Widget child) {
    final style = node.style;
    final props = node.props;
    switch (node.type) {
      case 'container':
        final color =
            PropertyResolver.colorOrNull(style, 'color') ??
            PropertyResolver.colorOrNull(style, 'backgroundColor') ??
            PropertyResolver.colorOrNull(props, 'color');
        final radius = PropertyResolver.borderRadiusFrom(style);
        final borderColor = PropertyResolver.colorOrNull(style, 'borderColor');
        final borderWidth = PropertyResolver.doubleOrNull(style, 'borderWidth');
        final padding = PropertyResolver.paddingFrom(style);
        final margin = PropertyResolver.marginFrom(style);
        final width =
            PropertyResolver.doubleOrNull(props, 'width') ??
            PropertyResolver.doubleOrNull(style, 'width');
        final height =
            PropertyResolver.doubleOrNull(props, 'height') ??
            PropertyResolver.doubleOrNull(style, 'height');
        Widget w = Container(
          width: width,
          height: height,
          padding: padding == EdgeInsets.zero ? null : padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: radius != null
                ? BorderRadius.circular(radius)
                : BorderRadius.circular(8),
            border: borderColor != null
                ? Border.all(color: borderColor, width: borderWidth ?? 1)
                : Border.all(color: Colors.transparent),
          ),
          child: child,
        );
        if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
        if (color == null && borderColor == null) {
          w = Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius ?? 8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: w,
          );
        }
        return w;
      case 'card':
      case 'balance_card':
      case 'loan_card':
        final color =
            PropertyResolver.colorOrNull(style, 'color') ??
            PropertyResolver.colorOrNull(style, 'backgroundColor');
        final radius = PropertyResolver.borderRadiusFrom(style) ?? 12;
        final padding = PropertyResolver.paddingFrom(style);
        final margin = PropertyResolver.marginFrom(style);
        Widget w = Container(
          padding: padding == EdgeInsets.zero
              ? const EdgeInsets.all(8)
              : padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: child,
        );
        if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
        return w;
      case 'column':
      case 'row':
      case 'list':
        final pad = PropertyResolver.paddingFrom(style);
        if (pad != EdgeInsets.zero) return Padding(padding: pad, child: child);
        return child;
      case 'padding':
        final pad = PropertyResolver.paddingFrom(style) != EdgeInsets.zero
            ? PropertyResolver.paddingFrom(style)
            : PropertyResolver.paddingFrom(props);
        final p2 = pad == EdgeInsets.zero && props['padding'] is num
            ? EdgeInsets.all((props['padding'] as num).toDouble())
            : pad;
        if (p2 != EdgeInsets.zero) return Padding(padding: p2, child: child);
        return Padding(padding: const EdgeInsets.all(8), child: child);
      case 'center':
        return Center(child: child);
      case 'stack':
        final align = PropertyResolver.alignmentFrom(
          style['alignment'],
          Alignment.topLeft,
        );
        return Stack(alignment: align, children: [child]);
      default:
        final pad = PropertyResolver.paddingFrom(style);
        final mar = PropertyResolver.marginFrom(style);
        final col =
            PropertyResolver.colorOrNull(style, 'color') ??
            PropertyResolver.colorOrNull(style, 'backgroundColor');
        final rad = PropertyResolver.borderRadiusFrom(style);
        Widget w = child;
        if (pad != EdgeInsets.zero) w = Padding(padding: pad, child: w);
        if (col != null || rad != null)
          w = Container(
            decoration: BoxDecoration(
              color: col,
              borderRadius: rad != null ? BorderRadius.circular(rad) : null,
              border: col != null
                  ? null
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: w,
          );
        if (mar != EdgeInsets.zero) w = Padding(padding: mar, child: w);
        return w;
    }
  }

  Widget _leafPreview(BuildContext context, UiNode node) {
    try {
      final rc = RenderContext(
        context: context,
        componentRegistry: controller.engine.componentRegistry,
        actionRegistry: controller.engine.actionRegistry,
        theme: controller.engine.theme,
        onAction: (t, p) =>
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Action: $t'))),
      );
      return controller.engine.renderer.renderNode(node, rc);
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: Colors.red.shade400),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Preview error: $e',
                style: TextStyle(color: Colors.red.shade700, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class _SelectableWrapper extends StatelessWidget {
  final UiNode node;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final Widget child;
  final BuilderController controller;
  final bool Function(UiNode target, Object data) canDropCheck;
  const _SelectableWrapper({
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
    required this.child,
    required this.controller,
    required this.canDropCheck,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Draggable<UiNode>(
        data: node,
        feedback: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0F172A)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _iconFor(node.type),
                  size: 14,
                  color: const Color(0xFF0F172A),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    node.type,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.35,
          child: _decorated(child, isInvalidHover: false),
        ),
        child: DragTarget<Object>(
          onWillAcceptWithDetails: (d) => canDropCheck(node, d.data),
          onAcceptWithDetails: (details) {
            final data = details.data;
            if (data is ComponentDefinition)
              controller.addNode(data, parentId: node.id);
            else if (data is UiNode)
              controller.moveNode(data.id, node.id, node.children.length);
          },
          builder: (context, candidate, rejected) {
            final isValidHover = candidate.isNotEmpty;
            final isInvalidHover = rejected.isNotEmpty;
            return _decorated(
              child,
              hovering: isValidHover,
              isInvalidHover: isInvalidHover,
            );
          },
        ),
      ),
    );
  }

  Widget _decorated(
    Widget child, {
    bool hovering = false,
    bool isInvalidHover = false,
  }) {
    Color borderColor;
    if (isInvalidHover)
      borderColor = const Color(0xFFEF4444);
    else if (hovering)
      borderColor = const Color(0xFF3B82F6);
    else if (isSelected)
      borderColor = const Color(0xFF0F172A);
    else
      borderColor = Colors.transparent;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: (isSelected || hovering || isInvalidHover) ? 1.4 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(3), child: child),
          if (isSelected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onDuplicate,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.copy, size: 12, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(width: 1, height: 12, color: Colors.white24),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (hovering)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          if (isInvalidHover)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.block, size: 12, color: Color(0xFFEF4444)),
                        SizedBox(width: 4),
                        Text(
                          'Not allowed',
                          style: TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'button':
        return Icons.smart_button;
      case 'image':
        return Icons.image;
      case 'card':
        return Icons.credit_card;
      case 'row':
        return Icons.view_week;
      case 'column':
        return Icons.view_column;
      case 'account_card':
        return Icons.account_balance_wallet;
      case 'transaction_item':
        return Icons.receipt;
      case 'loan_card':
        return Icons.request_quote;
      default:
        return Icons.widgets;
    }
  }
}
