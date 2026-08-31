import 'package:flutter/material.dart';

import 'component_definition.dart';
import 'property_definition.dart';

/// Centralized Appzillon catalogue — builder derives categories dynamically.
/// Namespace * prevents collisions with custom components.
class AppzillonComponentCatalog {
  static List<ComponentDefinition> get all => [
    // PAGE — Header, Sidebar, Footer
    ComponentDefinition(
      type: 'header',
      label: 'Header',
      category: 'Page',
      icon: Icons.web_asset,
      defaultProps: {'title': 'Header', 'subtitle': 'Welcome'},
      defaultStyle: {'backgroundColor': '#0F172A'},
      properties: PropertyCatalog.forType('header'),
    ),
    ComponentDefinition(
      type: 'sidebar',
      label: 'Sidebar',
      category: 'Page',
      icon: Icons.view_sidebar,
      defaultProps: {'title': 'Menu'},
      canHaveChildren: true,
      properties: PropertyCatalog.forType('sidebar'),
    ),
    ComponentDefinition(
      type: 'footer',
      label: 'Footer',
      category: 'Page',
      icon: Icons.horizontal_rule,
      defaultProps: {'text': '© 2026 Appzillon'},
      defaultStyle: {'backgroundColor': '#F1F5F9'},
      properties: PropertyCatalog.forType('footer'),
    ),

    // POPUP — Modal, Dialog, PopOver
    ComponentDefinition(
      type: 'modal',
      label: 'Modal',
      category: 'Popup',
      icon: Icons.open_in_new,
      defaultProps: {'title': 'Modal'},
      canHaveChildren: true,
      defaultStyle: {'borderRadius': 16},
      properties: PropertyCatalog.forType('modal'),
    ),
    ComponentDefinition(
      type: 'dialog',
      label: 'Dialog',
      category: 'Popup',
      icon: Icons.chat_bubble_outline,
      defaultProps: {'title': 'Dialog', 'message': 'Dialog message'},
      canHaveChildren: true,
      properties: PropertyCatalog.forType('dialog'),
    ),
    ComponentDefinition(
      type: 'popover',
      label: 'PopOver',
      category: 'Popup',
      icon: Icons.chat_bubble,
      defaultProps: {'text': 'PopOver'},
      properties: PropertyCatalog.forType('popover'),
    ),

    // LAYOUT — Row, Column
    ComponentDefinition(
      type: 'row',
      label: 'Row',
      category: 'Layout',
      icon: Icons.view_week,
      canHaveChildren: true,
      defaultStyle: {'gap': 12, 'padding': 8},
      properties: PropertyCatalog.forType('row'),
    ),
    ComponentDefinition(
      type: 'column',
      label: 'Column',
      category: 'Layout',
      icon: Icons.view_column,
      canHaveChildren: true,
      defaultStyle: {'gap': 12, 'padding': 12},
      properties: PropertyCatalog.forType('column'),
    ),

    // PANELS — Simple Panel, Tab, Accordion, Carousel, Collapsible, Panel Section
    ComponentDefinition(
      type: 'simple_panel',
      label: 'Simple Panel',
      category: 'Panels',
      icon: Icons.dashboard_customize,
      canHaveChildren: true,
      defaultProps: {'title': 'Panel'},
      defaultStyle: {'borderRadius': 12},
      properties: PropertyCatalog.forType('simple_panel'),
    ),
    ComponentDefinition(
      type: 'tab',
      label: 'Tab',
      category: 'Panels',
      icon: Icons.tab,
      canHaveChildren: true,
      defaultProps: {'label': 'Tab'},
      properties: PropertyCatalog.forType('tab'),
    ),
    ComponentDefinition(
      type: 'accordion',
      label: 'Accordion',
      category: 'Panels',
      icon: Icons.expand,
      canHaveChildren: true,
      defaultProps: {'title': 'Accordion'},
      properties: PropertyCatalog.forType('accordion'),
    ),
    ComponentDefinition(
      type: 'carousel',
      label: 'Carousel',
      category: 'Panels',
      icon: Icons.view_carousel,
      canHaveChildren: true,
      defaultProps: {},
      properties: PropertyCatalog.forType('carousel'),
    ),
    ComponentDefinition(
      type: 'collapsible',
      label: 'Collapsible',
      category: 'Panels',
      icon: Icons.unfold_more,
      canHaveChildren: true,
      defaultProps: {'title': 'Collapsible', 'collapsed': false},
      properties: PropertyCatalog.forType('collapsible'),
    ),
    ComponentDefinition(
      type: 'panel_section',
      label: 'Panel Section',
      category: 'Panels',
      icon: Icons.segment,
      canHaveChildren: true,
      defaultProps: {'title': 'Section'},
      properties: PropertyCatalog.forType('panel_section'),
    ),

    // CONTAINERS — Breadcrumb, Chart, Form, Gauge, List, Menu, Navbar, Table
    ComponentDefinition(
      type: 'breadcrumb',
      label: 'Breadcrumb',
      category: 'Containers',
      icon: Icons.link,
      canHaveChildren: true,
      defaultProps: {
        'items': ['Home', 'Category', 'Current'],
      },
      properties: PropertyCatalog.forType('breadcrumb'),
    ),
    ComponentDefinition(
      type: 'chart',
      label: 'Chart',
      category: 'Containers',
      icon: Icons.bar_chart,
      canHaveChildren: true,
      defaultProps: {
        'title': 'Chart',
        'values': [30, 60, 45],
      },
      defaultStyle: {'borderRadius': 12},
      properties: PropertyCatalog.forType('chart'),
    ),
    ComponentDefinition(
      type: 'form',
      label: 'Form',
      category: 'Containers',
      icon: Icons.description,
      canHaveChildren: true,
      defaultProps: {'title': 'Form'},
      defaultStyle: {'borderRadius': 12},
      properties: PropertyCatalog.forType('form'),
    ),
    ComponentDefinition(
      type: 'gauge',
      label: 'Gauge',
      category: 'Containers',
      icon: Icons.speed,
      canHaveChildren: true,
      defaultProps: {'value': 0.65, 'label': '65%'},
      properties: PropertyCatalog.forType('gauge'),
    ),
    ComponentDefinition(
      type: 'list',
      label: 'List',
      category: 'Containers',
      icon: Icons.list,
      canHaveChildren: true,
      defaultProps: {},
      defaultStyle: {'gap': 8},
      properties: PropertyCatalog.forType('list'),
    ),
    ComponentDefinition(
      type: 'menu',
      label: 'Menu',
      category: 'Containers',
      icon: Icons.menu,
      canHaveChildren: true,
      defaultProps: {
        'items': ['Item 1', 'Item 2'],
      },
      properties: PropertyCatalog.forType('menu'),
    ),
    ComponentDefinition(
      type: 'navbar',
      label: 'Navbar',
      category: 'Containers',
      icon: Icons.navigation,
      canHaveChildren: true,
      defaultProps: {'title': 'Navbar'},
      properties: PropertyCatalog.forType('navbar'),
    ),
    ComponentDefinition(
      type: 'table',
      label: 'Table',
      category: 'Containers',
      icon: Icons.table_chart,
      canHaveChildren: true,
      defaultProps: {
        'headers': ['Col 1', 'Col 2'],
        'rows': [
          ['Cell 1', 'Cell 2'],
        ],
      },
      properties: PropertyCatalog.forType('table'),
    ),

    // ELEMENTS — 28 items
    ComponentDefinition(
      type: 'badge',
      label: 'Badge',
      category: 'Elements',
      icon: Icons.label,
      defaultProps: {'label': 'Badge', 'variant': 'primary'},
      properties: PropertyCatalog.forType('badge'),
    ),
    ComponentDefinition(
      type: 'bullets',
      label: 'Bullets',
      category: 'Elements',
      icon: Icons.format_list_bulleted,
      defaultProps: {
        'items': ['Bullet 1', 'Bullet 2'],
      },
      properties: PropertyCatalog.forType('bullets'),
    ),
    ComponentDefinition(
      type: 'button',
      label: 'Button',
      category: 'Elements',
      icon: Icons.smart_button,
      defaultProps: {'text': 'Button', 'enabled': true},
      defaultStyle: {'borderRadius': 8},
      defaultEvents: {
        'onTap': {'action': 'show_snackbar', 'message': 'Tapped'},
      },
      properties: PropertyCatalog.forType('button'),
    ),
    ComponentDefinition(
      type: 'card_number',
      label: 'CardNumber',
      category: 'Elements',
      icon: Icons.credit_card,
      defaultProps: {'number': '4111 1111 1111 1111'},
      properties: PropertyCatalog.forType('card_number'),
    ),
    ComponentDefinition(
      type: 'check',
      label: 'Check',
      category: 'Elements',
      icon: Icons.check_box,
      defaultProps: {'label': 'Check', 'value': false},
      defaultEvents: {
        'onChanged': {'action': 'show_snackbar', 'message': 'Checked'},
      },
      properties: PropertyCatalog.forType('check'),
    ),
    ComponentDefinition(
      type: 'check_group',
      label: 'Check Group',
      category: 'Elements',
      icon: Icons.checklist,
      canHaveChildren: true,
      defaultProps: {
        'items': ['Option A', 'Option B'],
      },
      properties: PropertyCatalog.forType('check_group'),
    ),
    ComponentDefinition(
      type: 'dropdown',
      label: 'Dropdown',
      category: 'Elements',
      icon: Icons.arrow_drop_down_circle,
      defaultProps: {
        'hint': 'Select',
        'items': ['Option 1', 'Option 2'],
      },
      properties: PropertyCatalog.forType('dropdown'),
    ),
    ComponentDefinition(
      type: 'dropdown_list',
      label: 'Dropdown List',
      category: 'Elements',
      icon: Icons.list_alt,
      defaultProps: {'hint': 'Select'},
      properties: PropertyCatalog.forType('dropdown_list'),
    ),
    ComponentDefinition(
      type: 'external_link',
      label: 'External Link',
      category: 'Elements',
      icon: Icons.open_in_new,
      defaultProps: {'text': 'External Link', 'url': 'https://example.com'},
      defaultEvents: {
        'onTap': {'action': 'open_url'},
      },
      properties: PropertyCatalog.forType('external_link'),
    ),
    ComponentDefinition(
      type: 'file',
      label: 'File',
      category: 'Elements',
      icon: Icons.insert_drive_file,
      defaultProps: {'name': 'document.pdf', 'size': '2.4 MB'},
      properties: PropertyCatalog.forType('file'),
    ),
    ComponentDefinition(
      type: 'gauge_element',
      label: 'Gauge',
      category: 'Elements',
      icon: Icons.speed,
      defaultProps: {'value': 0.65},
      properties: PropertyCatalog.forType('gauge'),
    ),
    ComponentDefinition(
      type: 'hyperlink',
      label: 'Hyperlink',
      category: 'Elements',
      icon: Icons.link,
      defaultProps: {'text': 'Hyperlink', 'url': 'https://example.com'},
      defaultEvents: {
        'onTap': {'action': 'open_url'},
      },
      properties: PropertyCatalog.forType('hyperlink'),
    ),
    ComponentDefinition(
      type: 'icon',
      label: 'Icon',
      category: 'Elements',
      icon: Icons.star,
      defaultProps: {'icon': 'star', 'size': 24},
      defaultStyle: {'color': '#0F172A'},
      properties: PropertyCatalog.forType('icon'),
    ),
    ComponentDefinition(
      type: 'image',
      label: 'Image',
      category: 'Elements',
      icon: Icons.image,
      defaultProps: {'src': 'https://picsum.photos/400/200', 'height': 160},
      defaultStyle: {'borderRadius': 8},
      properties: PropertyCatalog.forType('image'),
    ),
    ComponentDefinition(
      type: 'input',
      label: 'Input',
      category: 'Elements',
      icon: Icons.input,
      defaultProps: {'label': 'Input', 'hint': 'Enter value', 'value': ''},
      defaultStyle: {'borderRadius': 8},
      properties: PropertyCatalog.forType('input'),
    ),
    ComponentDefinition(
      type: 'input_with_button',
      label: 'Input with Button',
      category: 'Elements',
      icon: Icons.input_outlined,
      defaultProps: {'hint': 'Enter value', 'buttonText': 'Go'},
      properties: PropertyCatalog.forType('input_with_button'),
    ),
    ComponentDefinition(
      type: 'label',
      label: 'Label',
      category: 'Elements',
      icon: Icons.label_outline,
      defaultProps: {'text': 'Label'},
      properties: PropertyCatalog.forType('label'),
    ),
    ComponentDefinition(
      type: 'progress_bar',
      label: 'Progress Bar',
      category: 'Elements',
      icon: Icons.linear_scale,
      defaultProps: {'value': 0.5},
      properties: PropertyCatalog.forType('progress_bar'),
    ),
    ComponentDefinition(
      type: 'progress_steps',
      label: 'Progress Steps',
      category: 'Elements',
      icon: Icons.timeline,
      defaultProps: {
        'steps': ['Step 1', 'Step 2', 'Step 3'],
        'current': 1,
      },
      properties: PropertyCatalog.forType('progress_steps'),
    ),
    ComponentDefinition(
      type: 'radio',
      label: 'Radio',
      category: 'Elements',
      icon: Icons.radio_button_checked,
      defaultProps: {'label': 'Radio', 'value': false},
      properties: PropertyCatalog.forType('radio'),
    ),
    ComponentDefinition(
      type: 'separator',
      label: 'Separator',
      category: 'Elements',
      icon: Icons.horizontal_rule,
      defaultProps: {'thickness': 1},
      properties: PropertyCatalog.forType('separator'),
    ),
    ComponentDefinition(
      type: 'slider',
      label: 'Slider',
      category: 'Elements',
      icon: Icons.tune,
      defaultProps: {'value': 0.5, 'min': 0, 'max': 1},
      defaultEvents: {
        'onChanged': {'action': 'show_snackbar', 'message': 'Slider'},
      },
      properties: PropertyCatalog.forType('slider'),
    ),
    ComponentDefinition(
      type: 'sort_code',
      label: 'SortCode',
      category: 'Elements',
      icon: Icons.numbers,
      defaultProps: {'code': '12-34-56'},
      properties: PropertyCatalog.forType('sort_code'),
    ),
    ComponentDefinition(
      type: 'sort_code_list',
      label: 'SortCode List',
      category: 'Elements',
      icon: Icons.view_list,
      canHaveChildren: true,
      defaultProps: {
        'items': ['12-34-56'],
      },
      properties: PropertyCatalog.forType('sort_code_list'),
    ),
    ComponentDefinition(
      type: 'stepper',
      label: 'Stepper',
      category: 'Elements',
      icon: Icons.unfold_more,
      defaultProps: {'value': 1},
      defaultEvents: {
        'onChanged': {'action': 'show_snackbar'},
      },
      properties: PropertyCatalog.forType('stepper'),
    ),
    ComponentDefinition(
      type: 'tags',
      label: 'Tags',
      category: 'Elements',
      icon: Icons.tag,
      defaultProps: {
        'items': ['Tag 1', 'Tag 2'],
      },
      properties: PropertyCatalog.forType('tags'),
    ),
    ComponentDefinition(
      type: 'text',
      label: 'Text',
      category: 'Elements',
      icon: Icons.text_fields,
      defaultProps: {'text': 'Text'},
      defaultStyle: {'fontSize': 14, 'color': '#0F172A'},
      properties: PropertyCatalog.forType('text'),
    ),
    ComponentDefinition(
      type: 'textarea',
      label: 'Textarea',
      category: 'Elements',
      icon: Icons.notes,
      defaultProps: {'label': '', 'hint': '', 'value': ''},
      properties: PropertyCatalog.forType('textarea'),
    ),
    ComponentDefinition(
      type: 'toggle',
      label: 'Toggle',
      category: 'Elements',
      icon: Icons.toggle_on,
      defaultProps: {'label': 'Toggle', 'value': false},
      defaultEvents: {
        'onChanged': {'action': 'show_snackbar'},
      },
      properties: PropertyCatalog.forType('toggle'),
    ),
  ];

  static ComponentDefinition? byType(String type) {
    try {
      return all.firstWhere((e) => e.type.toLowerCase() == type.toLowerCase());
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
