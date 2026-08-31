import '../sdui.dart';
import 'appzillon_renderers.dart';

class AppzillonPlugin implements SduiPlugin {
  @override
  String get name => 'Appzillon';
  @override
  String get version => '1.0';

  void _reg(SduiEngine engine, String appzillonType, String globalType, renderer) {
    engine.componentRegistry.register(appzillonType, renderer);
    engine.componentRegistry.register(globalType, renderer);
  }

  @override
  void register(SduiEngine engine) {
    final r = engine.componentRegistry;
    // PAGE
    _reg(engine, 'appzillon.header', 'header', AppzillonHeaderRenderer());
    _reg(engine, 'appzillon.sidebar', 'sidebar', AppzillonSidebarRenderer());
    _reg(engine, 'appzillon.footer', 'footer', AppzillonFooterRenderer());
    // POPUP
    _reg(engine, 'appzillon.modal', 'modal', AppzillonModalRenderer());
    _reg(engine, 'appzillon.dialog', 'dialog', AppzillonDialogRenderer());
    _reg(engine, 'appzillon.popover', 'popover', AppzillonPopOverRenderer());
    // LAYOUT
    _reg(engine, 'appzillon.row', 'row', AppzillonRowRenderer());
    _reg(engine, 'appzillon.column', 'column', AppzillonColumnRenderer());
    // PANELS
    _reg(engine, 'appzillon.simple_panel', 'simple_panel', AppzillonSimplePanelRenderer());
    _reg(engine, 'appzillon.tab', 'tab', AppzillonTabRenderer());
    _reg(engine, 'appzillon.accordion', 'accordion', AppzillonAccordionRenderer());
    _reg(engine, 'appzillon.carousel', 'carousel', AppzillonCarouselRenderer());
    _reg(engine, 'appzillon.collapsible', 'collapsible', AppzillonCollapsibleRenderer());
    _reg(engine, 'appzillon.panel_section', 'panel_section', AppzillonPanelSectionRenderer());
    // CONTAINERS
    _reg(engine, 'appzillon.breadcrumb', 'breadcrumb', AppzillonBreadcrumbRenderer());
    _reg(engine, 'appzillon.chart', 'chart', AppzillonChartRenderer());
    _reg(engine, 'appzillon.form', 'form', AppzillonFormRenderer());
    _reg(engine, 'appzillon.gauge', 'gauge', AppzillonGaugeRenderer());
    _reg(engine, 'appzillon.list', 'list', AppzillonListRenderer());
    _reg(engine, 'appzillon.menu', 'menu', AppzillonMenuRenderer());
    _reg(engine, 'appzillon.navbar', 'navbar', AppzillonNavbarRenderer());
    _reg(engine, 'appzillon.table', 'table', AppzillonTableRenderer());
    // ELEMENTS
    _reg(engine, 'appzillon.badge', 'badge', AppzillonBadgeRenderer());
    _reg(engine, 'appzillon.bullets', 'bullets', AppzillonBulletsRenderer());
    _reg(engine, 'appzillon.button', 'button', AppzillonButtonRenderer());
    _reg(engine, 'appzillon.card_number', 'card_number', AppzillonCardNumberRenderer());
    _reg(engine, 'appzillon.check', 'check', AppzillonCheckRenderer());
    _reg(engine, 'appzillon.check_group', 'check_group', AppzillonCheckGroupRenderer());
    _reg(engine, 'appzillon.dropdown', 'dropdown', AppzillonDropdownRenderer());
    _reg(engine, 'appzillon.dropdown_list', 'dropdown_list', AppzillonDropdownListRenderer());
    _reg(engine, 'appzillon.external_link', 'external_link', AppzillonExternalLinkRenderer());
    _reg(engine, 'appzillon.file', 'file', AppzillonFileRenderer());
    _reg(engine, 'appzillon.hyperlink', 'hyperlink', AppzillonHyperlinkRenderer());
    _reg(engine, 'appzillon.icon', 'icon', AppzillonIconRenderer());
    _reg(engine, 'appzillon.image', 'image', AppzillonImageRenderer());
    _reg(engine, 'appzillon.input', 'input', AppzillonInputRenderer());
    _reg(engine, 'appzillon.input_with_button', 'input_with_button', AppzillonInputWithButtonRenderer());
    _reg(engine, 'appzillon.label', 'label', AppzillonLabelRenderer());
    _reg(engine, 'appzillon.progress_bar', 'progress_bar', AppzillonProgressBarRenderer());
    _reg(engine, 'appzillon.progress_steps', 'progress_steps', AppzillonProgressStepsRenderer());
    _reg(engine, 'appzillon.radio', 'radio', AppzillonRadioRenderer());
    _reg(engine, 'appzillon.separator', 'separator', AppzillonSeparatorRenderer());
    _reg(engine, 'appzillon.slider', 'slider', AppzillonSliderRenderer());
    _reg(engine, 'appzillon.sort_code', 'sort_code', AppzillonSortCodeRenderer());
    _reg(engine, 'appzillon.sort_code_list', 'sort_code_list', AppzillonSortCodeListRenderer());
    _reg(engine, 'appzillon.stepper', 'stepper', AppzillonStepperRenderer());
    _reg(engine, 'appzillon.tags', 'tags', AppzillonTagsRenderer());
    _reg(engine, 'appzillon.text', 'text', AppzillonTextRenderer());
    _reg(engine, 'appzillon.textarea', 'textarea', AppzillonTextareaRenderer());
    _reg(engine, 'appzillon.toggle', 'toggle', AppzillonToggleRenderer());
    // extra alias for gauge_element
    r.register('appzillon.gauge_element', AppzillonGaugeRenderer());
    r.register('gauge_element', AppzillonGaugeRenderer());
  }
}
