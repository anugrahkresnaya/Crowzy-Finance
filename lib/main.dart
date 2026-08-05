import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/hive_constants.dart';
import 'core/constants/supabase_constants.dart';
import 'core/notifications/notification_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/ui/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<Map>(HiveConstants.categoriesBox);
  await Hive.openBox<Map>(HiveConstants.transactionsBox);
  await Hive.openBox<Map>(HiveConstants.wishlistBox);
  await Hive.openBox<Map>(HiveConstants.alertsBox);
  await Hive.openBox(HiveConstants.syncMetaBox);

  await Supabase.initialize(
    url: SupabaseConstants.url,
    publishableKey: SupabaseConstants.publishableKey,
  );

  final container = ProviderContainer();
  if (!kIsWeb) {
    // flutter_local_notifications has no web implementation; skip there.
    // Non-fatal elsewhere too — the app must still start if init fails.
    try {
      await container.read(notificationServiceProvider).init();
    } catch (_) {}
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crowzy Finance',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
