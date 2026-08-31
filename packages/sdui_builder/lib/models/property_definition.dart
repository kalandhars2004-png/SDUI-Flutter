class PropertyDefinition {
  final String key;
  final String label;
  final String type; // string, number, boolean, enum, color, spacing
  final String group; // props, style, events
  final dynamic defaultValue;
  final List<String>? enumValues;
  const PropertyDefinition({
    required this.key,
    required this.label,
    required this.type,
    required this.group,
    this.defaultValue,
    this.enumValues,
  });
}

class PropertyCatalog {
  static List<PropertyDefinition> forType(String type) {
    final lower = type.toLowerCase();
    final base = lower.startsWith('appzillon.')
        ? lower.substring('appzillon.'.length)
        : lower;
    switch (base) {
      case 'text':
        return const [
          PropertyDefinition(
            key: 'text',
            label: 'Text',
            type: 'string',
            group: 'props',
            defaultValue: 'Hello World',
          ),
          PropertyDefinition(
            key: 'fontSize',
            label: 'Font Size',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
          PropertyDefinition(
            key: 'fontWeight',
            label: 'Weight',
            type: 'enum',
            group: 'style',
            defaultValue: 'normal',
            enumValues: ['normal', 'medium', 'bold', 'w700', 'w800'],
          ),
          PropertyDefinition(
            key: 'color',
            label: 'Color',
            type: 'color',
            group: 'style',
            defaultValue: '#0F172A',
          ),
          PropertyDefinition(
            key: 'textAlign',
            label: 'Align',
            type: 'enum',
            group: 'style',
            defaultValue: 'left',
            enumValues: ['left', 'center', 'right', 'justify'],
          ),
          PropertyDefinition(
            key: 'padding',
            label: 'Padding',
            type: 'number',
            group: 'style',
            defaultValue: 0,
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap Action',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'button':
        return const [
          PropertyDefinition(
            key: 'text',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Button',
          ),
          PropertyDefinition(
            key: 'variant',
            label: 'Variant',
            type: 'enum',
            group: 'props',
            defaultValue: 'elevated',
            enumValues: ['elevated', 'outlined', 'text'],
          ),
          PropertyDefinition(
            key: 'backgroundColor',
            label: 'BG Color',
            type: 'color',
            group: 'style',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 10,
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'container':
        return const [
          PropertyDefinition(
            key: 'width',
            label: 'Width',
            type: 'number',
            group: 'props',
          ),
          PropertyDefinition(
            key: 'height',
            label: 'Height',
            type: 'number',
            group: 'props',
          ),
          PropertyDefinition(
            key: 'color',
            label: 'Background',
            type: 'color',
            group: 'style',
            defaultValue: '#FFFFFF',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
          PropertyDefinition(
            key: 'padding',
            label: 'Padding',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
          PropertyDefinition(
            key: 'margin',
            label: 'Margin',
            type: 'number',
            group: 'style',
          ),
          PropertyDefinition(
            key: 'borderColor',
            label: 'Border Color',
            type: 'color',
            group: 'style',
          ),
        ];
      case 'image':
        return const [
          PropertyDefinition(
            key: 'src',
            label: 'Source URL',
            type: 'string',
            group: 'props',
            defaultValue: 'https://picsum.photos/400/200',
          ),
          PropertyDefinition(
            key: 'height',
            label: 'Height',
            type: 'number',
            group: 'props',
            defaultValue: 160,
          ),
          PropertyDefinition(
            key: 'width',
            label: 'Width',
            type: 'number',
            group: 'props',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
          PropertyDefinition(
            key: 'fit',
            label: 'Fit',
            type: 'enum',
            group: 'props',
            defaultValue: 'cover',
            enumValues: ['cover', 'contain', 'fill'],
          ),
        ];
      case 'icon':
        return const [
          PropertyDefinition(
            key: 'icon',
            label: 'Icon',
            type: 'enum',
            group: 'props',
            defaultValue: 'star',
            enumValues: [
              'star',
              'favorite',
              'home',
              'person',
              'settings',
              'search',
              'add',
              'check',
              'info',
              'warning',
              'shopping_cart',
              'menu',
            ],
          ),
          PropertyDefinition(
            key: 'size',
            label: 'Size',
            type: 'number',
            group: 'props',
            defaultValue: 24,
          ),
          PropertyDefinition(
            key: 'color',
            label: 'Color',
            type: 'color',
            group: 'style',
          ),
        ];
      case 'card':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Card Title',
          ),
          PropertyDefinition(
            key: 'subtitle',
            label: 'Subtitle',
            type: 'string',
            group: 'props',
          ),
          PropertyDefinition(
            key: 'elevation',
            label: 'Elevation',
            type: 'number',
            group: 'style',
            defaultValue: 2,
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
          PropertyDefinition(
            key: 'padding',
            label: 'Padding',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
        ];
      case 'column':
      case 'row':
      case 'list':
        return const [
          PropertyDefinition(
            key: 'gap',
            label: 'Gap',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
          PropertyDefinition(
            key: 'padding',
            label: 'Padding',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
          PropertyDefinition(
            key: 'mainAxisAlignment',
            label: 'Main Axis',
            type: 'enum',
            group: 'props',
            defaultValue: 'start',
            enumValues: [
              'start',
              'center',
              'end',
              'spaceBetween',
              'spaceAround',
              'spaceEvenly',
            ],
          ),
          PropertyDefinition(
            key: 'crossAxisAlignment',
            label: 'Cross Axis',
            type: 'enum',
            group: 'props',
            defaultValue: 'start',
            enumValues: ['start', 'center', 'end', 'stretch'],
          ),
        ];
      case 'divider':
        return const [
          PropertyDefinition(
            key: 'thickness',
            label: 'Thickness',
            type: 'number',
            group: 'props',
            defaultValue: 1,
          ),
          PropertyDefinition(
            key: 'color',
            label: 'Color',
            type: 'color',
            group: 'style',
          ),
        ];
      case 'fintech_header':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Good Morning',
          ),
          PropertyDefinition(
            key: 'name',
            label: 'Name',
            type: 'string',
            group: 'props',
            defaultValue: 'Kalandhar',
          ),
          PropertyDefinition(
            key: 'subtitle',
            label: 'Subtitle',
            type: 'string',
            group: 'props',
            defaultValue: 'Welcome back',
          ),
          PropertyDefinition(
            key: 'showNotification',
            label: 'Show Notification',
            type: 'boolean',
            group: 'props',
            defaultValue: true,
          ),
          PropertyDefinition(
            key: 'backgroundColor',
            label: 'Background',
            type: 'color',
            group: 'style',
            defaultValue: '#0F172A',
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'account_card':
        return const [
          PropertyDefinition(
            key: 'bankName',
            label: 'Bank',
            type: 'string',
            group: 'props',
            defaultValue: 'HDFC Bank',
          ),
          PropertyDefinition(
            key: 'accountType',
            label: 'Account Type',
            type: 'string',
            group: 'props',
            defaultValue: 'Savings Account',
          ),
          PropertyDefinition(
            key: 'accountNumber',
            label: 'Account No',
            type: 'string',
            group: 'props',
            defaultValue: '•••• 4521',
          ),
          PropertyDefinition(
            key: 'balance',
            label: 'Balance',
            type: 'string',
            group: 'props',
            defaultValue: '₹ 2,45,800.00',
          ),
          PropertyDefinition(
            key: 'currency',
            label: 'Currency',
            type: 'string',
            group: 'props',
            defaultValue: 'INR',
          ),
          PropertyDefinition(
            key: 'holderName',
            label: 'Holder',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'backgroundColor',
            label: 'Background',
            type: 'color',
            group: 'style',
            defaultValue: '#0F172A',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'balance_card':
      case 'balance_header':
        return const [
          PropertyDefinition(
            key: 'total',
            label: 'Total',
            type: 'string',
            group: 'props',
            defaultValue: '₹ 5,42,100',
          ),
          PropertyDefinition(
            key: 'change',
            label: 'Change',
            type: 'string',
            group: 'props',
            defaultValue: '+2.4%',
          ),
          PropertyDefinition(
            key: 'subtitle',
            label: 'Subtitle',
            type: 'string',
            group: 'props',
            defaultValue: 'Total Portfolio',
          ),
          PropertyDefinition(
            key: 'backgroundColor',
            label: 'Background',
            type: 'color',
            group: 'style',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
        ];
      case 'transaction_item':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Salary Credit',
          ),
          PropertyDefinition(
            key: 'subtitle',
            label: 'Subtitle',
            type: 'string',
            group: 'props',
            defaultValue: 'HDFC • Today',
          ),
          PropertyDefinition(
            key: 'amount',
            label: 'Amount',
            type: 'string',
            group: 'props',
            defaultValue: '+ ₹ 45,000',
          ),
          PropertyDefinition(
            key: 'icon',
            label: 'Icon',
            type: 'enum',
            group: 'props',
            defaultValue: 'payments',
            enumValues: [
              'payments',
              'shopping',
              'food',
              'fuel',
              'transfer',
              'bill',
              'atm',
            ],
          ),
          PropertyDefinition(
            key: 'status',
            label: 'Status',
            type: 'enum',
            group: 'props',
            defaultValue: 'success',
            enumValues: ['success', 'pending', 'failed', ''],
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'loan_card':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Personal Loan',
          ),
          PropertyDefinition(
            key: 'amount',
            label: 'Amount',
            type: 'string',
            group: 'props',
            defaultValue: '₹ 3,20,000',
          ),
          PropertyDefinition(
            key: 'due',
            label: 'Due',
            type: 'string',
            group: 'props',
            defaultValue: 'Due: 15 Sep • EMI ₹ 12,400',
          ),
          PropertyDefinition(
            key: 'progress',
            label: 'Progress (0-1)',
            type: 'number',
            group: 'props',
            defaultValue: 0.62,
          ),
          PropertyDefinition(
            key: 'progressLabel',
            label: 'Progress Label',
            type: 'string',
            group: 'props',
            defaultValue: '62% paid',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'credit_score':
        return const [
          PropertyDefinition(
            key: 'score',
            label: 'Score',
            type: 'number',
            group: 'props',
            defaultValue: 782,
          ),
          PropertyDefinition(
            key: 'maxScore',
            label: 'Max',
            type: 'number',
            group: 'props',
            defaultValue: 900,
          ),
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Excellent',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
        ];
      case 'quick_actions':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Quick Actions',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
        ];
      case 'kyc_banner':
        return const [
          PropertyDefinition(
            key: 'status',
            label: 'Status',
            type: 'enum',
            group: 'props',
            defaultValue: 'pending',
            enumValues: ['pending', 'verified', 'rejected'],
          ),
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Complete your KYC',
          ),
          PropertyDefinition(
            key: 'subtitle',
            label: 'Subtitle',
            type: 'string',
            group: 'props',
            defaultValue: 'Verify identity',
          ),
          PropertyDefinition(
            key: 'buttonText',
            label: 'Button',
            type: 'string',
            group: 'props',
            defaultValue: 'Verify Now',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'chart':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Spending Overview',
          ),
          PropertyDefinition(
            key: 'period',
            label: 'Period',
            type: 'string',
            group: 'props',
            defaultValue: 'Last 6 months',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
        ];
      case 'input_field':
      case 'text_field':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Amount',
          ),
          PropertyDefinition(
            key: 'hint',
            label: 'Hint',
            type: 'string',
            group: 'props',
            defaultValue: 'Enter amount',
          ),
          PropertyDefinition(
            key: 'value',
            label: 'Value',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'prefix',
            label: 'Prefix',
            type: 'string',
            group: 'props',
            defaultValue: '₹',
          ),
          PropertyDefinition(
            key: 'error',
            label: 'Error',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 10,
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'otp_field':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Enter OTP',
          ),
          PropertyDefinition(
            key: 'length',
            label: 'Length',
            type: 'number',
            group: 'props',
            defaultValue: 4,
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 10,
          ),
        ];
      case 'switch_tile':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Enable Biometric',
          ),
          PropertyDefinition(
            key: 'subtitle',
            label: 'Subtitle',
            type: 'string',
            group: 'props',
            defaultValue: 'Use fingerprint to login',
          ),
          PropertyDefinition(
            key: 'value',
            label: 'Value',
            type: 'boolean',
            group: 'props',
            defaultValue: true,
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
          PropertyDefinition(
            key: 'onChanged',
            label: 'On Changed',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'alert_banner':
      case 'alert':
        return const [
          PropertyDefinition(
            key: 'type',
            label: 'Type',
            type: 'enum',
            group: 'props',
            defaultValue: 'info',
            enumValues: ['info', 'warning', 'success', 'error'],
          ),
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'message',
            label: 'Message',
            type: 'string',
            group: 'props',
            defaultValue: 'Your transaction is being processed.',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 10,
          ),
        ];
      case 'badge':
      case 'chip':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Verified',
          ),
          PropertyDefinition(
            key: 'variant',
            label: 'Variant',
            type: 'enum',
            group: 'props',
            defaultValue: 'success',
            enumValues: ['success', 'warning', 'neutral', 'primary'],
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 20,
          ),
        ];
      // ── Appzillon specific (namespace stripped) ──
      case 'header':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Header',
          ),
          PropertyDefinition(
            key: 'subtitle',
            label: 'Subtitle',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'backgroundColor',
            label: 'Background',
            type: 'color',
            group: 'style',
            defaultValue: '#0F172A',
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'sidebar':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Menu',
          ),
          PropertyDefinition(
            key: 'width',
            label: 'Width',
            type: 'number',
            group: 'props',
            defaultValue: 220,
          ),
          PropertyDefinition(
            key: 'backgroundColor',
            label: 'Background',
            type: 'color',
            group: 'style',
            defaultValue: '#1E293B',
          ),
        ];
      case 'footer':
        return const [
          PropertyDefinition(
            key: 'text',
            label: 'Text',
            type: 'string',
            group: 'props',
            defaultValue: '© 2026 Appzillon',
          ),
          PropertyDefinition(
            key: 'backgroundColor',
            label: 'Background',
            type: 'color',
            group: 'style',
            defaultValue: '#F1F5F9',
          ),
        ];
      case 'modal':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Modal',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 16,
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'dialog':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Dialog',
          ),
          PropertyDefinition(
            key: 'message',
            label: 'Message',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'popover':
        return const [
          PropertyDefinition(
            key: 'text',
            label: 'Text',
            type: 'string',
            group: 'props',
            defaultValue: 'PopOver',
          ),
        ];
      case 'simple_panel':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Panel',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
        ];
      case 'tab':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Tab',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 8,
          ),
        ];
      case 'accordion':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Accordion',
          ),
        ];
      case 'carousel':
        return const [
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
        ];
      case 'collapsible':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Collapsible',
          ),
          PropertyDefinition(
            key: 'collapsed',
            label: 'Collapsed',
            type: 'boolean',
            group: 'props',
            defaultValue: false,
          ),
        ];
      case 'panel_section':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Section',
          ),
        ];
      case 'chart':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Chart',
          ),
          PropertyDefinition(
            key: 'values',
            label: 'Values',
            type: 'string',
            group: 'props',
            defaultValue: '30,60,45',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
        ];
      case 'breadcrumb':
        return const [
          PropertyDefinition(
            key: 'items',
            label: 'Items',
            type: 'string',
            group: 'props',
            defaultValue: 'Home, Category',
          ),
        ];
      case 'form':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Form',
          ),
          PropertyDefinition(
            key: 'borderRadius',
            label: 'Radius',
            type: 'number',
            group: 'style',
            defaultValue: 12,
          ),
        ];
      case 'gauge':
        return const [
          PropertyDefinition(
            key: 'value',
            label: 'Value (0-1)',
            type: 'number',
            group: 'props',
            defaultValue: 0.65,
          ),
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: '65%',
          ),
        ];
      case 'menu':
        return const [
          PropertyDefinition(
            key: 'items',
            label: 'Items',
            type: 'string',
            group: 'props',
            defaultValue: 'Item 1, Item 2',
          ),
        ];
      case 'navbar':
        return const [
          PropertyDefinition(
            key: 'title',
            label: 'Title',
            type: 'string',
            group: 'props',
            defaultValue: 'Navbar',
          ),
          PropertyDefinition(
            key: 'backgroundColor',
            label: 'Background',
            type: 'color',
            group: 'style',
            defaultValue: '#0F172A',
          ),
        ];
      case 'table':
        return const [
          PropertyDefinition(
            key: 'headers',
            label: 'Headers',
            type: 'string',
            group: 'props',
            defaultValue: 'Col 1, Col 2',
          ),
          PropertyDefinition(
            key: 'rows',
            label: 'Rows',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
        ];
      case 'bullets':
        return const [
          PropertyDefinition(
            key: 'items',
            label: 'Items',
            type: 'string',
            group: 'props',
            defaultValue: 'Bullet 1, Bullet 2',
          ),
        ];
      case 'card_number':
        return const [
          PropertyDefinition(
            key: 'number',
            label: 'Number',
            type: 'string',
            group: 'props',
            defaultValue: '4111 1111 1111 1111',
          ),
        ];
      case 'check':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Check',
          ),
          PropertyDefinition(
            key: 'value',
            label: 'Checked',
            type: 'boolean',
            group: 'props',
            defaultValue: false,
          ),
          PropertyDefinition(
            key: 'onChanged',
            label: 'On Changed',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'check_group':
        return const [
          PropertyDefinition(
            key: 'items',
            label: 'Items',
            type: 'string',
            group: 'props',
            defaultValue: 'Option A, Option B',
          ),
        ];
      case 'dropdown':
      case 'dropdown_list':
        return const [
          PropertyDefinition(
            key: 'hint',
            label: 'Hint',
            type: 'string',
            group: 'props',
            defaultValue: 'Select',
          ),
          PropertyDefinition(
            key: 'items',
            label: 'Items',
            type: 'string',
            group: 'props',
            defaultValue: 'Option 1, Option 2',
          ),
          PropertyDefinition(
            key: 'value',
            label: 'Value',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'onChanged',
            label: 'On Changed',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'external_link':
        return const [
          PropertyDefinition(
            key: 'text',
            label: 'Text',
            type: 'string',
            group: 'props',
            defaultValue: 'External Link',
          ),
          PropertyDefinition(
            key: 'url',
            label: 'URL',
            type: 'string',
            group: 'props',
            defaultValue: 'https://example.com',
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'file':
        return const [
          PropertyDefinition(
            key: 'name',
            label: 'Name',
            type: 'string',
            group: 'props',
            defaultValue: 'document.pdf',
          ),
          PropertyDefinition(
            key: 'size',
            label: 'Size',
            type: 'string',
            group: 'props',
            defaultValue: '2.4 MB',
          ),
        ];
      case 'hyperlink':
        return const [
          PropertyDefinition(
            key: 'text',
            label: 'Text',
            type: 'string',
            group: 'props',
            defaultValue: 'Hyperlink',
          ),
          PropertyDefinition(
            key: 'url',
            label: 'URL',
            type: 'string',
            group: 'props',
            defaultValue: 'https://example.com',
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'input':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Input',
          ),
          PropertyDefinition(
            key: 'hint',
            label: 'Hint',
            type: 'string',
            group: 'props',
            defaultValue: 'Enter value',
          ),
          PropertyDefinition(
            key: 'value',
            label: 'Value',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'required',
            label: 'Required',
            type: 'boolean',
            group: 'props',
            defaultValue: false,
          ),
          PropertyDefinition(
            key: 'onChanged',
            label: 'On Changed',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'input_with_button':
        return const [
          PropertyDefinition(
            key: 'hint',
            label: 'Hint',
            type: 'string',
            group: 'props',
            defaultValue: 'Enter value',
          ),
          PropertyDefinition(
            key: 'buttonText',
            label: 'Button',
            type: 'string',
            group: 'props',
            defaultValue: 'Go',
          ),
          PropertyDefinition(
            key: 'onTap',
            label: 'On Tap',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'label':
        return const [
          PropertyDefinition(
            key: 'text',
            label: 'Text',
            type: 'string',
            group: 'props',
            defaultValue: 'Label',
          ),
          PropertyDefinition(
            key: 'color',
            label: 'Color',
            type: 'color',
            group: 'style',
            defaultValue: '#0F172A',
          ),
        ];
      case 'progress_bar':
        return const [
          PropertyDefinition(
            key: 'value',
            label: 'Value (0-1)',
            type: 'number',
            group: 'props',
            defaultValue: 0.5,
          ),
        ];
      case 'progress_steps':
        return const [
          PropertyDefinition(
            key: 'steps',
            label: 'Steps',
            type: 'string',
            group: 'props',
            defaultValue: 'Step 1, Step 2',
          ),
          PropertyDefinition(
            key: 'current',
            label: 'Current',
            type: 'number',
            group: 'props',
            defaultValue: 1,
          ),
        ];
      case 'radio':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Radio',
          ),
          PropertyDefinition(
            key: 'value',
            label: 'Selected',
            type: 'boolean',
            group: 'props',
            defaultValue: false,
          ),
          PropertyDefinition(
            key: 'onChanged',
            label: 'On Changed',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'separator':
        return const [
          PropertyDefinition(
            key: 'thickness',
            label: 'Thickness',
            type: 'number',
            group: 'props',
            defaultValue: 1,
          ),
          PropertyDefinition(
            key: 'color',
            label: 'Color',
            type: 'color',
            group: 'style',
          ),
        ];
      case 'slider':
        return const [
          PropertyDefinition(
            key: 'value',
            label: 'Value',
            type: 'number',
            group: 'props',
            defaultValue: 0.5,
          ),
          PropertyDefinition(
            key: 'min',
            label: 'Min',
            type: 'number',
            group: 'props',
            defaultValue: 0,
          ),
          PropertyDefinition(
            key: 'max',
            label: 'Max',
            type: 'number',
            group: 'props',
            defaultValue: 1,
          ),
          PropertyDefinition(
            key: 'onChanged',
            label: 'On Changed',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'sort_code':
        return const [
          PropertyDefinition(
            key: 'code',
            label: 'Code',
            type: 'string',
            group: 'props',
            defaultValue: '12-34-56',
          ),
        ];
      case 'sort_code_list':
        return const [
          PropertyDefinition(
            key: 'items',
            label: 'Items',
            type: 'string',
            group: 'props',
            defaultValue: '12-34-56',
          ),
        ];
      case 'stepper':
        return const [
          PropertyDefinition(
            key: 'value',
            label: 'Value',
            type: 'number',
            group: 'props',
            defaultValue: 1,
          ),
          PropertyDefinition(
            key: 'onChanged',
            label: 'On Changed',
            type: 'action',
            group: 'events',
          ),
        ];
      case 'tags':
        return const [
          PropertyDefinition(
            key: 'items',
            label: 'Tags',
            type: 'string',
            group: 'props',
            defaultValue: 'Tag 1, Tag 2',
          ),
        ];
      case 'textarea':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'hint',
            label: 'Hint',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
          PropertyDefinition(
            key: 'value',
            label: 'Value',
            type: 'string',
            group: 'props',
            defaultValue: '',
          ),
        ];
      case 'toggle':
        return const [
          PropertyDefinition(
            key: 'label',
            label: 'Label',
            type: 'string',
            group: 'props',
            defaultValue: 'Toggle',
          ),
          PropertyDefinition(
            key: 'value',
            label: 'Value',
            type: 'boolean',
            group: 'props',
            defaultValue: false,
          ),
          PropertyDefinition(
            key: 'onChanged',
            label: 'On Changed',
            type: 'action',
            group: 'events',
          ),
        ];
      default:
        return const [
          PropertyDefinition(
            key: 'padding',
            label: 'Padding',
            type: 'number',
            group: 'style',
          ),
          PropertyDefinition(
            key: 'color',
            label: 'Color',
            type: 'color',
            group: 'style',
          ),
        ];
    }
  }
}
