import 'package:flutter/material.dart';
import 'package:sdui_engine/sdui_engine.dart';

/// Example of host-app custom component injection.
/// This proves the engine is generic and extensible without core modification.

class ProfileCardRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final name = props['name'] as String? ?? 'Demo User';
    final role = props['role'] as String? ?? 'Flutter Developer';
    final avatar =
        props['avatar'] as String? ?? 'https://i.pravatar.cc/150?img=32';
    final bg =
        PropertyResolver.colorOrNull(style, 'backgroundColor') ?? Colors.white;
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 16;

    Widget w = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(avatar),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Custom Component',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Color(0xFF3B82F6), size: 20),
        ],
      ),
    );

    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () {
          if (onTap is Map) {
            context.dispatchAction(Map<String, dynamic>.from(onTap));
          }
          if (onTap is String) context.dispatchActionType(onTap);
        },
        child: w,
      );
    }
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: w);
  }

  @override
  List<PropDescriptor> get propDescriptors => const [
    PropDescriptor(
      key: 'name',
      label: 'Name',
      type: 'string',
      defaultValue: 'Demo User',
    ),
    PropDescriptor(
      key: 'role',
      label: 'Role',
      type: 'string',
      defaultValue: 'Flutter Developer',
    ),
    PropDescriptor(key: 'avatar', label: 'Avatar URL', type: 'string'),
  ];
}

class ProductCardRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final title = props['title'] as String? ?? 'Sample Product';
    final price = props['price'] as String? ?? '\$29.99';
    final image = props['image'] as String? ?? 'https://picsum.photos/400/300';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              image,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 140,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final ev = node.events['onTap'];
                      if (ev is Map) {
                        context.dispatchAction(Map<String, dynamic>.from(ev));
                      } else {
                        context.dispatchActionType('show_snackbar', {
                          'message': 'Added $title to cart',
                        });
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  List<PropDescriptor> get propDescriptors => const [
    PropDescriptor(
      key: 'title',
      label: 'Title',
      type: 'string',
      defaultValue: 'Sample Product',
    ),
    PropDescriptor(
      key: 'price',
      label: 'Price',
      type: 'string',
      defaultValue: '\$29.99',
    ),
  ];
}

class CustomerCardRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final name = props['name'] as String? ?? 'John Doe';
    final tier = props['tier'] as String? ?? 'Gold';
    final id = props['customerId'] as String? ?? 'CUST-4521';
    final bg = PropertyResolver.colorOrNull(node.style, 'backgroundColor') ?? const Color(0xFF0F172A);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        CircleAvatar(radius: 22, backgroundColor: Colors.white.withValues(alpha: 0.15), child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), Text('ID: $id • $tier', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)), if (node.children.isNotEmpty) ...node.children.map(childRenderer)])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: Text(tier, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 11))),
      ]),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class LoadScreenAction implements ActionHandler {
  @override
  Future<void> handle(RenderContext context, Map<String, dynamic> params) async {
    final file = params['file'] as String? ?? params['payload']?['file'] as String? ?? 'unknown';
    if (context.context.mounted) {
      ScaffoldMessenger.of(context.context).showSnackBar(SnackBar(content: Text('Load screen: $file')));
    }
  }
}

class ShowTransactionDetailAction implements ActionHandler {
  @override
  Future<void> handle(RenderContext context, Map<String, dynamic> params) async {
    final payload = params['payload'] as Map<String, dynamic>? ?? params;
    final id = payload['id'] ?? params['id'] ?? '';
    final desc = payload['description'] ?? params['description'] ?? '';
    final amount = payload['amount'] ?? params['amount'] ?? '';
    final date = payload['date'] ?? params['date'] ?? '';
    if (context.context.mounted) {
      showDialog(
        context: context.context,
        builder: (c) => AlertDialog(
          title: Text(desc.isNotEmpty ? desc : 'Transaction $id'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Amount: ₹ $amount', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0052FF))),
            const SizedBox(height: 8),
            Text('Date: $date', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('ID: $id', style: TextStyle(color: Colors.grey.shade500, fontFamily: 'monospace', fontSize: 11)),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
        ),
      );
    }
  }
}

/// Custom action example
class OpenPaymentAction implements ActionHandler {
  @override
  Future<void> handle(
    RenderContext context,
    Map<String, dynamic> params,
  ) async {
    final amount = params['amount'] ?? '0';
    if (context.context.mounted) {
      ScaffoldMessenger.of(context.context).showSnackBar(
        SnackBar(
          content: Text('Opening payment for \$$amount (custom action)'),
        ),
      );
    }
  }
}
