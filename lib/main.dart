import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'controllers/app_controller.dart';
import 'controllers/orders_controller.dart';
import 'controllers/quotations_controller.dart';
import 'core/config/app_config.dart';
import 'repositories/demo_order_repository.dart';
import 'repositories/demo_quotation_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/quotation_repository.dart';
import 'repositories/supabase_order_repository.dart';
import 'repositories/supabase_quotation_repository.dart';
import 'services/image_service.dart';
import 'services/location_service.dart';
import 'services/preferences_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final config = AppConfig.fromEnvironment();
  if (!config.demoMode) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
    );
  }

  final preferences = PreferencesService();
  final appController = AppController(config: config, preferences: preferences);
  await appController.initialize();

  final QuotationRepository quotationRepo = config.demoMode
      ? DemoQuotationRepository()
      : SupabaseQuotationRepository(Supabase.instance.client);

  final OrderRepository orderRepo = config.demoMode
      ? DemoOrderRepository()
      : SupabaseOrderRepository(Supabase.instance.client);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appController),
        Provider<QuotationRepository>.value(value: quotationRepo),
        Provider<OrderRepository>.value(value: orderRepo),
        ChangeNotifierProvider(create: (_) => QuotationsController(quotationRepo)),
        ChangeNotifierProvider(create: (_) => OrdersController(orderRepo)),
        Provider(create: (_) => LocationService()),
        Provider(create: (_) => WeatherService()),
        Provider(create: (_) => ImageService()),
      ],
      child: const UrbanSignsApp(),
    ),
  );
}
