import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

// ─────────────────────────────────────────────────────────────
// Appzillon-style fintech renderers — all keep theme #0F172A primary
// ─────────────────────────────────────────────────────────────

class FintechHeaderRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final title = PropertyResolver.string(props, 'title', 'Good Morning');
    final subtitle = PropertyResolver.string(props, 'subtitle', 'Welcome back');
    final name = PropertyResolver.string(props, 'name', '');
    final showNotif = PropertyResolver.boolVal(props, 'showNotification', true);
    final bg =
        PropertyResolver.colorOrNull(style, 'backgroundColor') ??
        const Color(0xFF0F172A);
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 0;
    final padding = PropertyResolver.paddingFrom(style);
    final effectivePad = padding == EdgeInsets.zero
        ? const EdgeInsets.fromLTRB(16, 14, 16, 14)
        : padding;

    Widget w = Container(
      padding: effectivePad,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isNotEmpty ? name : subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (showNotif)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 20,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
        onTap: () {
          if (onTap is Map)
            context.dispatchAction(Map<String, dynamic>.from(onTap as Map));
          if (onTap is String) context.dispatchActionType(onTap);
        },
        child: w,
      );
    }
    final margin = PropertyResolver.marginFrom(style);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AccountCardRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final bank = PropertyResolver.string(props, 'bankName', 'HDFC Bank');
    final type = PropertyResolver.string(
      props,
      'accountType',
      'Savings Account',
    );
    final number = PropertyResolver.string(props, 'accountNumber', '•••• 4521');
    final balance = PropertyResolver.string(props, 'balance', '₹ 2,45,800.00');
    final currency = PropertyResolver.string(props, 'currency', 'INR');
    final holder = PropertyResolver.string(props, 'holderName', '');
    final bg =
        PropertyResolver.colorOrNull(style, 'backgroundColor') ??
        const Color(0xFF0F172A);
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 16;
    final margin = PropertyResolver.marginFrom(style);
    final showEye = PropertyResolver.boolVal(props, 'showEye', true);

    Widget w = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bank,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (showEye)
                Icon(
                  Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.more_horiz,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            type.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          if (holder.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              holder,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      balance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  currency,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (node.children.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            ...node.children.map(childRenderer),
          ],
        ],
      ),
    );

    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        borderRadius: BorderRadius.circular(radius),
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

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class BalanceHeaderRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final total = PropertyResolver.string(props, 'total', '₹ 5,42,100');
    final change = PropertyResolver.string(props, 'change', '+2.4%');
    final changePositive = !change.startsWith('-');
    final subtitle = PropertyResolver.string(
      props,
      'subtitle',
      'Total Portfolio',
    );
    final bg = PropertyResolver.colorOrNull(style, 'backgroundColor');
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 16;
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changePositive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      changePositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: changePositive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: TextStyle(
                        color: changePositive
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            total,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          if (node.children.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...node.children.map(childRenderer),
          ],
        ],
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class TransactionItemRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final title = PropertyResolver.string(props, 'title', 'Salary Credit');
    final subtitle = PropertyResolver.string(
      props,
      'subtitle',
      'HDFC • Today 09:24 AM',
    );
    final amount = PropertyResolver.string(props, 'amount', '+ ₹ 45,000');
    final isCredit = amount.trim().startsWith('+');
    final iconName = PropertyResolver.string(props, 'icon', 'payments');
    final status = PropertyResolver.string(props, 'status', '');
    final amountColor =
        PropertyResolver.colorOrNull(props, 'amountColor') ??
        PropertyResolver.colorOrNull(style, 'amountColor');
    final margin = PropertyResolver.marginFrom(style);
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 12;

    Widget w = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconFor(iconName),
              size: 18,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status.toLowerCase() == 'success'
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: status.toLowerCase() == 'success'
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color:
                  amountColor ??
                  (isCredit
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );

    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        borderRadius: BorderRadius.circular(radius),
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

  IconData _iconFor(String n) {
    switch (n) {
      case 'payments':
        return Icons.payments;
      case 'shopping':
        return Icons.shopping_bag;
      case 'food':
        return Icons.restaurant;
      case 'fuel':
        return Icons.local_gas_station;
      case 'transfer':
        return Icons.swap_horiz;
      case 'bill':
        return Icons.receipt_long;
      case 'atm':
        return Icons.atm;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class LoanCardRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final title = PropertyResolver.string(props, 'title', 'Personal Loan');
    final amount = PropertyResolver.string(props, 'amount', '₹ 3,20,000');
    final due = PropertyResolver.string(
      props,
      'due',
      'Due: 15 Sep • EMI ₹ 12,400',
    );
    final progress = PropertyResolver.doubleVal(props, 'progress', 0.62);
    final progressLabel = PropertyResolver.string(
      props,
      'progressLabel',
      '62% paid',
    );
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 16;
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.request_quote,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  progressLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            due,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF0F172A),
            ),
          ),
          if (node.children.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...node.children.map(childRenderer),
          ],
        ],
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        borderRadius: BorderRadius.circular(radius),
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

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class CreditScoreRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final score = PropertyResolver.intVal(props, 'score', 782);
    final max = PropertyResolver.intVal(props, 'maxScore', 900);
    final label = PropertyResolver.string(props, 'label', 'Excellent');
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 16;
    final margin = PropertyResolver.marginFrom(style);
    final pct = (score / max).clamp(0, 1).toDouble();
    Widget w = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF16A34A),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '/$max',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Credit Score',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Updated today • Bureau: CIBIL',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class QuickActionsRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final rawActions = props['actions'];
    List<Map<String, dynamic>> actions;
    if (rawActions is List) {
      actions = rawActions
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      actions = const [
        {'icon': 'send', 'label': 'Send'},
        {'icon': 'request', 'label': 'Request'},
        {'icon': 'bill', 'label': 'Bills'},
        {'icon': 'topup', 'label': 'Top-up'},
      ];
    }
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 12;
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PropertyResolver.string(props, 'title', 'Quick Actions'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length.clamp(0, 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (c, i) {
              final a = actions[i];
              final label = (a['label'] ?? 'Action').toString();
              final icon = (a['icon'] ?? 'send').toString();
              final onTap = a['action'];
              Widget item = Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(
                      _iconFor(icon),
                      size: 18,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
              if (onTap is Map || onTap is String) {
                item = InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (onTap is Map)
                      context.dispatchAction(
                        Map<String, dynamic>.from(onTap as Map),
                      );
                    if (onTap is String) context.dispatchActionType(onTap);
                  },
                  child: item,
                );
              }
              return item;
            },
          ),
          if (node.children.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...node.children.map(childRenderer),
          ],
        ],
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  IconData _iconFor(String n) {
    switch (n) {
      case 'send':
        return Icons.send;
      case 'request':
        return Icons.call_received;
      case 'bill':
        return Icons.receipt_long;
      case 'topup':
        return Icons.phone_android;
      case 'scan':
        return Icons.qr_code_scanner;
      case 'history':
        return Icons.history;
      case 'invest':
        return Icons.trending_up;
      case 'cards':
        return Icons.credit_card;
      default:
        return Icons.bolt;
    }
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class KycBannerRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final status = PropertyResolver.string(
      props,
      'status',
      'pending',
    ); // pending, verified, rejected
    final title = PropertyResolver.string(
      props,
      'title',
      status == 'verified' ? 'KYC Verified' : 'Complete your KYC',
    );
    final subtitle = PropertyResolver.string(
      props,
      'subtitle',
      status == 'verified'
          ? 'You have full access'
          : 'Verify identity to unlock higher limits',
    );
    final btnText = PropertyResolver.string(
      props,
      'buttonText',
      status == 'verified' ? 'View' : 'Verify Now',
    );
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 12;
    final margin = PropertyResolver.marginFrom(style);
    Color bg, border;
    IconData icon;
    if (status == 'verified') {
      bg = const Color(0xFFDCFCE7);
      border = const Color(0xFF86EFAC);
      icon = Icons.verified;
    } else if (status == 'rejected') {
      bg = const Color(0xFFFEE2E2);
      border = const Color(0xFFFCA5A5);
      icon = Icons.error;
    } else {
      bg = const Color(0xFFFEF3C7);
      border = const Color(0xFFFCD34D);
      icon = Icons.warning_amber;
    }

    Widget w = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () {
              final ev = node.events['onTap'];
              if (ev is Map)
                context.dispatchAction(Map<String, dynamic>.from(ev as Map));
              else if (ev is String)
                context.dispatchActionType(ev);
              else
                context.dispatchActionType('show_snackbar', {
                  'message': btnText,
                });
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              btnText,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class ChartRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final title = PropertyResolver.string(props, 'title', 'Spending Overview');
    final period = PropertyResolver.string(props, 'period', 'Last 6 months');
    final valuesRaw = props['values'];
    List<double> values;
    if (valuesRaw is List)
      values = valuesRaw.map((e) => (e as num).toDouble()).toList();
    else
      values = [40, 65, 45, 80, 55, 70];
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 16;
    final margin = PropertyResolver.marginFrom(style);
    final maxVal = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    Widget w = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  period,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < values.length; i++) ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (values[i] / maxVal * 64).clamp(8, 64),
                          decoration: BoxDecoration(
                            color: i == values.length - 1
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ['J', 'F', 'M', 'A', 'M', 'J'][i % 6],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != values.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          if (node.children.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...node.children.map(childRenderer),
          ],
        ],
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class InputFieldRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final label = PropertyResolver.string(props, 'label', 'Amount');
    final hint = PropertyResolver.string(props, 'hint', 'Enter amount');
    final value = PropertyResolver.string(props, 'value', '');
    final prefix = PropertyResolver.string(props, 'prefix', '₹');
    final error = PropertyResolver.string(props, 'error', '');
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 10;
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: error.isNotEmpty
                  ? Colors.red.shade300
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              if (prefix.isNotEmpty) ...[
                Text(
                  prefix,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 18, color: Colors.grey.shade300),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : hint,
                  style: TextStyle(
                    color: value.isNotEmpty
                        ? const Color(0xFF0F172A)
                        : Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: value.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        if (error.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            error,
            style: TextStyle(fontSize: 11, color: Colors.red.shade600),
          ),
        ],
        if (node.children.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...node.children.map(childRenderer),
        ],
      ],
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        borderRadius: BorderRadius.circular(radius),
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

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class OtpFieldRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final length = PropertyResolver.intVal(props, 'length', 4);
    final label = PropertyResolver.string(props, 'label', 'Enter OTP');
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int i = 0; i < length.clamp(3, 6); i++) ...[
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: i == 0
                          ? const Color(0xFF0F172A)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      i == 0 ? '•' : '',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              if (i != length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Resend in 00:42',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class SwitchTileRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final title = PropertyResolver.string(props, 'title', 'Enable Biometric');
    final subtitle = PropertyResolver.string(
      props,
      'subtitle',
      'Use fingerprint to login',
    );
    final value = PropertyResolver.boolVal(props, 'value', true);
    final margin = PropertyResolver.marginFrom(style);
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 12;
    Widget w = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              value ? Icons.fingerprint : Icons.fingerprint_outlined,
              size: 18,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              final ev = node.events['onChanged'] ?? node.events['onTap'];
              if (ev is Map)
                context.dispatchAction(Map<String, dynamic>.from(ev as Map));
              else if (ev is String)
                context.dispatchActionType(ev);
              else
                context.dispatchActionType('show_snackbar', {
                  'message': '$title: ${v ? "On" : "Off"}',
                });
            },
          ),
        ],
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AlertBannerRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final type = PropertyResolver.string(
      props,
      'type',
      'info',
    ); // info, warning, success, error
    final message = PropertyResolver.string(
      props,
      'message',
      'Your transaction is being processed.',
    );
    final title = PropertyResolver.string(props, 'title', '');
    final margin = PropertyResolver.marginFrom(style);
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 10;
    Color bg, border, iconColor;
    IconData icon;
    switch (type) {
      case 'warning':
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFCD34D);
        iconColor = const Color(0xFFD97706);
        icon = Icons.warning_amber;
        break;
      case 'success':
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF86EFAC);
        iconColor = const Color(0xFF16A34A);
        icon = Icons.check_circle;
        break;
      case 'error':
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFCA5A5);
        iconColor = const Color(0xFFDC2626);
        icon = Icons.error_outline;
        break;
      default:
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFF93C5FD);
        iconColor = const Color(0xFF2563EB);
        icon = Icons.info_outline;
    }
    Widget w = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
                if (node.children.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...node.children.map(childRenderer),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => context.dispatchActionType('show_snackbar', {
              'message': 'Dismissed',
            }),
            child: Icon(Icons.close, size: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class BadgeRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final label = PropertyResolver.string(props, 'label', 'Verified');
    final variant = PropertyResolver.string(
      props,
      'variant',
      'success',
    ); // success, warning, neutral, primary
    final margin = PropertyResolver.marginFrom(style);
    Color bg, fg, border;
    switch (variant) {
      case 'warning':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        border = const Color(0xFFFCD34D);
        break;
      case 'neutral':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        border = Colors.grey.shade300;
        break;
      case 'primary':
        bg = const Color(0xFF0F172A);
        fg = Colors.white;
        border = const Color(0xFF0F172A);
        break;
      default:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        border = const Color(0xFF86EFAC);
    }
    Widget w = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    if (node.children.isNotEmpty) {
      w = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          w,
          const SizedBox(height: 8),
          ...node.children.map(childRenderer),
        ],
      );
    }
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}
