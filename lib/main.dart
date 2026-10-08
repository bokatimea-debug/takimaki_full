import 'screens/work_notifications_screen.dart';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/device_workflow.dart';
import 'services/local_marketplace_store.dart';
import 'utils/work_schedule.dart';
import 'screens/calendar_connection_screen.dart';
import 'screens/work_calendar_screen.dart';
import 'screens/problem_tickets_screen.dart';
import 'screens/onboarding.dart';
import 'screens/settings_notifications_screen.dart';
import 'screens/provider_offer_reply_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_login_screen.dart';
import 'screens/role_select_screen.dart';

import 'screens/customer_profile_screen.dart';
import 'screens/customer_edit_profile_screen.dart';
import 'screens/customer_search_screen.dart';
import 'screens/customer_orders_screen.dart';
import 'screens/customer_messages_screen.dart';

import 'screens/offers_screen.dart';
import 'screens/chat_screens.dart';

import 'screens/provider_profile_screen.dart';
import 'screens/provider_edit_profile_screen.dart';
import 'screens/provider_services_screen.dart';
import 'screens/provider_add_service_screen.dart';
import 'screens/provider_requests_screen.dart';
import 'screens/provider_messages_screen.dart';
import 'screens/provider_all_orders_screen.dart';

import 'screens/map_picker_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/subscription_screen.dart';
import 'theme.dart';
import 'widgets/branded_background.dart';

void main() {
  runApp(const TakimakiApp());
}

class TakimakiApp extends StatefulWidget {
  const TakimakiApp({super.key});

  @override
  State<TakimakiApp> createState() => _TakimakiAppState();
}

class _TakimakiAppState extends State<TakimakiApp> with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DeviceWorkflow.channel.setMethodCallHandler((call) async {
      if (call.method == 'openWork') await _openNotification();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _openNotification());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeviceWorkflow.channel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _openNotification();
  }

  Future<void> _openNotification() async {
    if (_opening) return;
    _opening = true;
    try {
      final launch = await DeviceWorkflow.channel
          .invokeMapMethod<String, dynamic>('launchWork');
      if (launch == null) return;
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool('session_active') ?? false)) return;
      final role = launch['role'] == 'provider' ? 'provider' : 'customer';
      final works = role == 'provider'
          ? await LocalMarketplaceStore.providerOrders()
          : await LocalMarketplaceStore.customerOrders();
      final work = works
          .where((w) => WorkSchedule.id(w) == launch['id'])
          .firstOrNull;
      if (mounted && work != null)
        _navigator.currentState?.pushNamed(
          '/order/details',
          arguments: {...work, 'view_role': role},
        );
    } on MissingPluginException {
      // Unsupported platform.
    } on PlatformException {
      // The app remains usable if Android cannot deliver the launch payload.
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'Takimaki',
      debugShowCheckedModeBanner: false,
      theme: takimakiTheme(),
      builder: (context, child) =>
          BrandedBackground(child: child ?? const SizedBox.shrink()),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('hu'), Locale('en')],
      locale: const Locale('hu'),
      home: const SplashLoginScreen(),
      routes: <String, WidgetBuilder>{
        '/work_notifications': (_) => const WorkNotificationsScreen(),
        '/calendar_connection': (_) => const CalendarConnectionScreen(),
        '/calendar': (_) => const WorkCalendarScreen(),
        '/problem_tickets': (_) => const ProblemTicketsScreen(),
        '/role': (_) => const RoleSelectScreen(),
        '/provider/setup': (_) => const OnboardingScreen(),
        '/provider/edit': (_) => const ProviderEditProfileScreen(),
        '/provider/offer_reply': (_) => const ProviderOfferReplyScreen(),
        '/settings/notifications': (_) => const SettingsNotificationsScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/subscriptions': (_) => const SubscriptionScreen(),
        '/order/details': (_) => const OrderDetailsScreen(),
        '/role_select': (_) => const RoleSelectScreen(),
        '/customer/profile': (_) => const CustomerProfileScreen(),
        '/customer/edit_profile': (_) => const CustomerEditProfileScreen(),
        '/customer/search': (_) => const CustomerSearchScreen(),
        '/customer/orders': (_) => const CustomerOrdersScreen(),
        '/customer/messages': (_) => const CustomerMessagesScreen(),
        '/offers': (_) => const OffersScreen(),
        '/chat': (_) => const ChatListScreen(),
        '/provider/profile': (_) => const ProviderProfileScreen(),
        '/provider/edit_profile': (_) => const ProviderEditProfileScreen(),
        '/provider/services': (_) => const ProviderServicesScreen(),
        '/provider/add_service': (_) => const ProviderAddServiceScreen(),
        '/provider/requests': (_) => const ProviderRequestsScreen(),
        '/provider/messages': (_) => const ProviderMessagesScreen(),
        '/provider/all_orders': (_) => const ProviderAllOrdersScreen(),
        '/map_picker': (_) => const MapPickerScreen(),
      },
    );
  }
}
