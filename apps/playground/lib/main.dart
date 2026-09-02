import 'package:flutter/material.dart';
import 'package:sdui_builder/sdui_builder.dart';
import 'package:sdui_engine/sdui_engine.dart';

import 'services/sdui_graphql_service.dart';
import 'studio/studio_shell.dart';
import 'widgets/custom_components.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlaygroundApp());
}

class PlaygroundApp extends StatefulWidget {
  const PlaygroundApp({super.key});

  @override
  State<PlaygroundApp> createState() => _PlaygroundAppState();
}

class _PlaygroundAppState extends State<PlaygroundApp> {
  late final SduiEngine engine;
  late final BuilderController controller;
  late final SduiGraphqlService gqlService;

  @override
  void initState() {
    super.initState();
    engine = SduiEngine();
    // === APPZILLON PLUGIN (proves extension layer, not hardcoded) ===
    engine.registerPlugin(AppzillonPlugin());
    // === CUSTOM COMPONENT INJECTION (proves host can still inject alongside Appzillon) ===
    engine.registerComponent('custom.customer_card', CustomerCardRenderer());
    engine.registerComponent('profile_card', ProfileCardRenderer());
    engine.registerComponent('product_card', ProductCardRenderer());
    engine.registerComponent('custom_card', ProfileCardRenderer());
    engine.registerAction('open_payment', OpenPaymentAction());
    engine.registerAction('loadScreen', LoadScreenAction());
    engine.registerAction('showTransactionDetail', ShowTransactionDetailAction());
    engine.registerAction('show_transaction_detail', ShowTransactionDetailAction());

    // GraphQL — strictly API level, MySQL behind Java
    gqlService = SduiGraphqlService.create(endpoint: 'http://127.0.0.1:8080/graphql');
    // Provide dataProvider for List's GraphQL fetch (used by new payment_history.json)
    engine.registerDataProvider((String key) async {
      if (key.contains('recentTransactions') || key.contains('TransactionList')) {
        try {
          final list = await gqlService.rawQuery('query { recentTransactions { id description amount type date } }');
          return list;
        } catch (_) {
          return null;
        }
      }
      return null;
    });

    // initial document: demo welcome screen
    final initialDoc = UiDocument(
      version: '1.0',
      root: UiNode(
        type: 'column',
        style: {'gap': 12, 'padding': 16},
        children: [
          UiNode(
            type: 'text',
            props: {'text': 'Welcome to SDUI'},
            style: {'fontSize': 26, 'fontWeight': 'bold', 'color': '#0F172A'},
          ),
          UiNode(
            type: 'text',
            props: {
              'text': 'Build UI visually → Generate JSON → Load JSON → Render natively',
            },
            style: {'fontSize': 13, 'color': '#64748B'},
          ),
          UiNode(type: 'divider', props: {'thickness': 1}),
          UiNode(
            type: 'card',
            style: {'borderRadius': 16, 'padding': 16},
            children: [
              UiNode(
                type: 'text',
                props: {'text': 'Drag components from the left palette'},
                style: {'fontSize': 14, 'fontWeight': 'medium'},
              ),
              UiNode(
                type: 'text',
                props: {
                  'text': 'Try Profile Card (custom injected component) from code',
                },
                style: {'fontSize': 12, 'color': '#64748B'},
              ),
              UiNode(
                type: 'button',
                props: {'text': 'Continue'},
                style: {'borderRadius': 10},
                events: {
                  'onTap': {
                    'action': 'show_snackbar',
                    'message': 'Hello from SDUI!',
                  },
                },
              ),
            ],
          ),
          UiNode(
            type: 'profile_card',
            props: {
              'name': 'Kalandhar S',
              'role': 'SDUI Architect',
              'avatar': 'https://i.pravatar.cc/150?img=11',
            },
            style: {'backgroundColor': '#FFFFFF', 'borderRadius': 16},
          ),
        ],
      ),
    );

    controller = BuilderController(engine: engine, initial: initialDoc);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDUI Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: StudioShell(controller: controller, gqlService: gqlService),
    );
  }
}
