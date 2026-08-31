import 'package:flutter/material.dart';
import 'package:sdui_engine/sdui_engine.dart';

import 'property_definition.dart';

class ComponentDefinition {
  final String type;
  final String label;
  final String category; // Layout, Basic, Content, Fintech, etc. Also PAGE, POPUP for Appzillon
  final String name; // alias for label (spec)
  final IconData icon;
  final Map<String, dynamic> defaultProps;
  final Map<String, dynamic> defaultStyle;
  final Map<String, dynamic> defaultEvents;
  final bool canHaveChildren;
  final bool acceptsChildren; // spec alias
  final List<PropertyDefinition> properties;

  const ComponentDefinition({
    required this.type,
    required this.label,
    required this.category,
    required this.icon,
    this.defaultProps = const {},
    this.defaultStyle = const {},
    this.defaultEvents = const {},
    this.canHaveChildren = false,
    List<PropertyDefinition>? properties,
    bool? acceptsChildren,
    String? name,
  }) : properties = properties ?? const [],
       acceptsChildren = acceptsChildren ?? canHaveChildren,
       name = name ?? label;

  UiNode createNode() => UiNode(
    type: type,
    props: Map<String, dynamic>.from(defaultProps),
    style: Map<String, dynamic>.from(defaultStyle),
    events: Map<String, dynamic>.from(defaultEvents),
    children: [],
  );
}

class ComponentCatalog {
  static List<ComponentDefinition> get all => [
    // Layout
    ComponentDefinition(
      type: 'column',
      label: 'Column',
      category: 'Layout',
      icon: Icons.view_column,
      canHaveChildren: true,
      defaultStyle: {'gap': 12, 'padding': 12},
    ),
    ComponentDefinition(
      type: 'row',
      label: 'Row',
      category: 'Layout',
      icon: Icons.view_week,
      canHaveChildren: true,
      defaultStyle: {'gap': 12, 'padding': 8},
    ),
    ComponentDefinition(
      type: 'container',
      label: 'Container',
      category: 'Layout',
      icon: Icons.crop_square,
      canHaveChildren: true,
      defaultStyle: {'padding': 16, 'borderRadius': 12, 'color': '#FFFFFF'},
      defaultProps: {'width': null, 'height': null},
    ),
    ComponentDefinition(
      type: 'stack',
      label: 'Stack',
      category: 'Layout',
      icon: Icons.layers,
      canHaveChildren: true,
    ),
    ComponentDefinition(
      type: 'padding',
      label: 'Padding',
      category: 'Layout',
      icon: Icons.padding,
      canHaveChildren: true,
      defaultStyle: {'padding': 16},
    ),
    ComponentDefinition(
      type: 'center',
      label: 'Center',
      category: 'Layout',
      icon: Icons.center_focus_strong,
      canHaveChildren: true,
    ),
    // Basic
    ComponentDefinition(
      type: 'text',
      label: 'Text',
      category: 'Basic',
      icon: Icons.text_fields,
      defaultProps: {'text': 'Hello World'},
      defaultStyle: {'fontSize': 16, 'color': '#0F172A'},
    ),
    ComponentDefinition(
      type: 'button',
      label: 'Button',
      category: 'Basic',
      icon: Icons.smart_button,
      defaultProps: {'text': 'Continue', 'variant': 'elevated'},
      defaultStyle: {'borderRadius': 10},
      defaultEvents: {
        'onTap': {'action': 'show_snackbar', 'message': 'Button tapped'},
      },
    ),
    ComponentDefinition(
      type: 'image',
      label: 'Image',
      category: 'Basic',
      icon: Icons.image,
      defaultProps: {'src': 'https://picsum.photos/400/200', 'height': 160},
      defaultStyle: {'borderRadius': 12},
    ),
    ComponentDefinition(
      type: 'icon',
      label: 'Icon',
      category: 'Basic',
      icon: Icons.star,
      defaultProps: {'icon': 'star', 'size': 24},
      defaultStyle: {'color': '#0F172A'},
    ),
    ComponentDefinition(
      type: 'divider',
      label: 'Divider',
      category: 'Basic',
      icon: Icons.horizontal_rule,
      defaultProps: {'thickness': 1},
    ),
    // Content
    ComponentDefinition(
      type: 'card',
      label: 'Card',
      category: 'Content',
      icon: Icons.credit_card,
      canHaveChildren: true,
      defaultStyle: {'borderRadius': 16, 'padding': 16, 'elevation': 2},
      defaultProps: {
        'title': 'Card Title',
        'subtitle': 'Card subtitle goes here',
      },
    ),
    ComponentDefinition(
      type: 'list',
      label: 'List',
      category: 'Content',
      icon: Icons.list,
      canHaveChildren: true,
      defaultStyle: {'gap': 8},
      defaultProps: {'direction': 'vertical'},
    ),
    // ── Fintech — Appzillon style ──────────────────────
    ComponentDefinition(
      type: 'fintech_header',
      label: 'Fintech Header',
      category: 'Fintech',
      icon: Icons.account_circle,
      defaultProps: {
        'title': 'Good Morning',
        'name': 'Kalandhar',
        'subtitle': 'Welcome back',
        'showNotification': true,
      },
      defaultStyle: {'backgroundColor': '#0F172A', 'borderRadius': 0},
    ),
    ComponentDefinition(
      type: 'account_card',
      label: 'Account Card',
      category: 'Fintech',
      icon: Icons.credit_card,
      canHaveChildren: true,
      defaultProps: {
        'bankName': 'HDFC Bank',
        'accountType': 'Savings Account',
        'accountNumber': '•••• 4521',
        'balance': '₹ 2,45,800.00',
        'currency': 'INR',
        'holderName': 'Kalandhar S',
      },
      defaultStyle: {'backgroundColor': '#0F172A', 'borderRadius': 16},
    ),
    ComponentDefinition(
      type: 'balance_card',
      label: 'Balance Card',
      category: 'Fintech',
      icon: Icons.account_balance_wallet,
      canHaveChildren: true,
      defaultProps: {
        'total': '₹ 5,42,100',
        'change': '+2.4%',
        'subtitle': 'Total Portfolio',
      },
      defaultStyle: {'borderRadius': 16},
    ),
    ComponentDefinition(
      type: 'transaction_item',
      label: 'Transaction Item',
      category: 'Fintech',
      icon: Icons.receipt_long,
      defaultProps: {
        'title': 'Salary Credit',
        'subtitle': 'HDFC • Today 09:24 AM',
        'amount': '+ ₹ 45,000',
        'icon': 'payments',
        'status': 'success',
      },
      defaultStyle: {'borderRadius': 12},
    ),
    ComponentDefinition(
      type: 'loan_card',
      label: 'Loan Card',
      category: 'Fintech',
      icon: Icons.request_quote,
      canHaveChildren: true,
      defaultProps: {
        'title': 'Personal Loan',
        'amount': '₹ 3,20,000',
        'due': 'Due: 15 Sep • EMI ₹ 12,400',
        'progress': 0.62,
        'progressLabel': '62% paid',
      },
      defaultStyle: {'borderRadius': 16},
    ),
    ComponentDefinition(
      type: 'credit_score',
      label: 'Credit Score',
      category: 'Fintech',
      icon: Icons.score,
      defaultProps: {'score': 782, 'maxScore': 900, 'label': 'Excellent'},
      defaultStyle: {'borderRadius': 16},
    ),
    ComponentDefinition(
      type: 'quick_actions',
      label: 'Quick Actions',
      category: 'Fintech',
      icon: Icons.apps,
      canHaveChildren: true,
      defaultProps: {'title': 'Quick Actions'},
      defaultStyle: {'borderRadius': 12},
    ),
    ComponentDefinition(
      type: 'kyc_banner',
      label: 'KYC Banner',
      category: 'Fintech',
      icon: Icons.verified_user,
      defaultProps: {
        'status': 'pending',
        'title': 'Complete your KYC',
        'subtitle': 'Verify identity to unlock higher limits',
        'buttonText': 'Verify Now',
      },
      defaultStyle: {'borderRadius': 12},
      defaultEvents: {
        'onTap': {'action': 'show_snackbar', 'message': 'KYC pressed'},
      },
    ),
    ComponentDefinition(
      type: 'chart',
      label: 'Chart',
      category: 'Fintech',
      icon: Icons.bar_chart,
      canHaveChildren: true,
      defaultProps: {
        'title': 'Spending Overview',
        'period': 'Last 6 months',
        'values': [40, 65, 45, 80, 55, 70],
      },
      defaultStyle: {'borderRadius': 16},
    ),
    ComponentDefinition(
      type: 'input_field',
      label: 'Input Field',
      category: 'Fintech',
      icon: Icons.input,
      defaultProps: {
        'label': 'Amount',
        'hint': 'Enter amount',
        'value': '',
        'prefix': '₹',
      },
      defaultStyle: {'borderRadius': 10},
    ),
    ComponentDefinition(
      type: 'otp_field',
      label: 'OTP Field',
      category: 'Fintech',
      icon: Icons.password,
      defaultProps: {'label': 'Enter OTP', 'length': 4},
      defaultStyle: {'borderRadius': 10},
    ),
    ComponentDefinition(
      type: 'switch_tile',
      label: 'Switch Tile',
      category: 'Fintech',
      icon: Icons.toggle_on,
      defaultProps: {
        'title': 'Enable Biometric',
        'subtitle': 'Use fingerprint to login',
        'value': true,
      },
      defaultStyle: {'borderRadius': 12},
      defaultEvents: {
        'onChanged': {'action': 'show_snackbar', 'message': 'Toggled'},
      },
    ),
    ComponentDefinition(
      type: 'alert_banner',
      label: 'Alert Banner',
      category: 'Fintech',
      icon: Icons.warning_amber,
      canHaveChildren: true,
      defaultProps: {
        'type': 'info',
        'title': 'Info',
        'message': 'Your transaction is being processed.',
      },
      defaultStyle: {'borderRadius': 10},
    ),
    ComponentDefinition(
      type: 'badge',
      label: 'Badge',
      category: 'Fintech',
      icon: Icons.label,
      defaultProps: {'label': 'Verified', 'variant': 'success'},
      defaultStyle: {'borderRadius': 20},
    ),
  ];

  static ComponentDefinition? byType(String type) {
    try {
      return all.firstWhere((e) => e.type == type);
    } catch (_) {
      return null;
    }
  }

  static Map<String, List<ComponentDefinition>> get grouped {
    final map = <String, List<ComponentDefinition>>{};
    for (final c in all) {
      map.putIfAbsent(c.category, () => []).add(c);
    }
    return map;
  }
}
