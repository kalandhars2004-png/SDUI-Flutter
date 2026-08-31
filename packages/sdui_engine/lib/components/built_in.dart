import '../registry/component_registry.dart';
import 'text_renderer.dart';
import 'button_renderer.dart';
import 'layout_renderers.dart';
import 'image_renderer.dart';
import 'card_renderer.dart';
import 'common_renderers.dart';
import 'fintech_renderers.dart';
import 'generic_renderers.dart';

void registerBuiltIns(ComponentRegistry registry) {
  // Core — Layout
  registry.register('text', TextRenderer());
  registry.register('button', ButtonRenderer());
  registry.register('column', ColumnRenderer());
  registry.register('row', RowRenderer());
  registry.register('container', ContainerRenderer());
  registry.register('padding', PaddingRenderer());
  registry.register('center', CenterRenderer());
  registry.register('stack', StackRenderer());
  registry.register('image', ImageRenderer());
  registry.register('card', CardRenderer());
  registry.register('icon', IconRenderer());
  registry.register('divider', DividerRenderer());
  registry.register('list', ListRenderer());
  registry.register('sizedbox', SizedBoxRenderer());
  registry.register('sizedBox', SizedBoxRenderer());
  registry.register('spacer', SizedBoxRenderer());
  registry.register('wrap', WrapRenderer());
  registry.register('align', AlignRenderer());
  registry.register('expanded', ExpandedRenderer());
  registry.register('flexible', FlexibleRenderer());

  // Generic widgets — Initial Widget Support
  registry.register('circleAvatar', CircleAvatarRenderer());
  registry.register('circleavatar', CircleAvatarRenderer());
  registry.register('singleChildScrollView', SingleChildScrollViewRenderer());
  registry.register('singlechildscrollview', SingleChildScrollViewRenderer());
  registry.register('listView', ListViewRenderer());
  registry.register('gridView', GridViewRenderer());
  registry.register('listTile', ListTileRenderer());
  registry.register('elevatedButton', ElevatedButtonRenderer());
  registry.register('textButton', TextButtonRenderer());
  registry.register('iconButton', IconButtonRenderer());
  registry.register('floatingActionButton', FloatingActionButtonRenderer());
  registry.register('textField', TextFieldRenderer());
  registry.register('textfield', TextFieldRenderer());
  registry.register('checkbox', CheckboxRenderer());
  registry.register('dropdownButton', DropdownButtonRenderer());
  registry.register('searchBar', SearchBarRenderer());
  registry.register('bottomNavigationBar', BottomNavigationBarRenderer());
  registry.register('drawer', DrawerRenderer());
  registry.register('circularProgressIndicator', CircularProgressRenderer());
  registry.register('linearProgressIndicator', LinearProgressRenderer());
  // aliases for snackBar etc (placeholder)
  registry.register('circularProgress', CircularProgressRenderer());
  registry.register('linearProgress', LinearProgressRenderer());

  // Fintech — Appzillon style (kept for backward compat)
  registry.register('fintech_header', FintechHeaderRenderer());
  registry.register('account_card', AccountCardRenderer());
  registry.register('balance_card', BalanceHeaderRenderer());
  registry.register('balance_header', BalanceHeaderRenderer());
  registry.register('transaction_item', TransactionItemRenderer());
  registry.register('loan_card', LoanCardRenderer());
  registry.register('credit_score', CreditScoreRenderer());
  registry.register('quick_actions', QuickActionsRenderer());
  registry.register('kyc_banner', KycBannerRenderer());
  registry.register('chart', ChartRenderer());
  registry.register('input_field', InputFieldRenderer());
  registry.register('text_field', InputFieldRenderer());
  registry.register('otp_field', OtpFieldRenderer());
  registry.register('switch_tile', SwitchTileRenderer());
  registry.register('alert_banner', AlertBannerRenderer());
  registry.register('alert', AlertBannerRenderer());
  registry.register('badge', BadgeRenderer());
  registry.register('chip', BadgeRenderer());
}
