import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mirrors main.dart: fonts must resolve from bundled assets, never the network.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('dark theme uses the brass-on-green palette', () {
    final theme = AppTheme.dark;
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, AppColors.brass);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.surface, AppColors.surface);
  });

  testWidgets('every themed text style resolves from bundled fonts', (tester) async {
    final theme = AppTheme.dark;
    final t = theme.textTheme;
    final styles = <String, TextStyle?>{
      'headlineMedium': t.headlineMedium,
      'titleLarge': t.titleLarge,
      'titleMedium': t.titleMedium,
      'titleSmall': t.titleSmall,
      'bodyMedium': t.bodyMedium,
      'bodySmall': t.bodySmall,
      'labelLarge': t.labelLarge,
      'bold body': t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      'semibold body': t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: ListView(
            children: [
              for (final e in styles.entries) Text('Rp 12.480.000 ${e.key}', style: e.value),
              FilledButton(onPressed: () {}, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  test('serif is used for titles and sans for body text', () {
    final t = AppTheme.dark.textTheme;
    expect(t.titleLarge?.fontFamily, contains('CormorantGaramond'));
    expect(t.titleMedium?.fontFamily, contains('CormorantGaramond'));
    expect(t.bodyMedium?.fontFamily, contains('HankenGrotesk'));
    expect(t.labelLarge?.fontFamily, contains('HankenGrotesk'));
  });
}
