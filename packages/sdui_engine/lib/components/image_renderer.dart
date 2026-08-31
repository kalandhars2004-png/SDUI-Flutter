import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

class ImageRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final src = PropertyResolver.string(
      props,
      'src',
      PropertyResolver.string(props, 'url', ''),
    );
    final fitStr = props['fit'] as String? ?? style['fit'] as String?;
    final fit = _parseFit(fitStr);
    final width =
        PropertyResolver.doubleOrNull(props, 'width') ??
        PropertyResolver.doubleOrNull(style, 'width');
    final height =
        PropertyResolver.doubleOrNull(props, 'height') ??
        PropertyResolver.doubleOrNull(style, 'height') ??
        160;
    final radius = PropertyResolver.borderRadiusFrom(style);
    final margin = PropertyResolver.marginFrom(style);

    Widget img;
    if (src.isEmpty) {
      img = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: radius != null ? BorderRadius.circular(radius) : null,
        ),
        child: const Icon(Icons.image, color: Colors.grey),
      );
    } else if (src.startsWith('http')) {
      img = Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(width, height, radius),
      );
    } else if (src.startsWith('assets/') || src.startsWith('asset:')) {
      final asset = src.replaceFirst('asset:', '');
      img = Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(width, height, radius),
      );
    } else {
      img = Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(width, height, radius),
      );
    }

    if (radius != null)
      img = ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
    if (margin != EdgeInsets.zero) img = Padding(padding: margin, child: img);

    final onTap = node.events['onTap'];
    if (onTap != null) {
      img = InkWell(
        onTap: () {
          if (onTap is Map)
            context.dispatchAction(Map<String, dynamic>.from(onTap as Map));
          if (onTap is String) context.dispatchActionType(onTap);
        },
        child: img,
      );
    }
    return img;
  }

  Widget _fallback(double? w, double? h, double? r) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: r != null ? BorderRadius.circular(r) : null,
    ),
    child: const Icon(Icons.broken_image, color: Colors.grey),
  );

  BoxFit? _parseFit(String? s) {
    switch (s) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      default:
        return BoxFit.cover;
    }
  }

  @override
  List<PropDescriptor> get propDescriptors => const [
    PropDescriptor(
      key: 'src',
      label: 'Source',
      type: 'string',
      defaultValue: '',
    ),
    PropDescriptor(key: 'width', label: 'Width', type: 'number'),
    PropDescriptor(
      key: 'height',
      label: 'Height',
      type: 'number',
      defaultValue: 160,
    ),
  ];
}
