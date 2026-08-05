import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/passive_insight.dart';
import '../../auth/providers/auth_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../utils/passive_insight_context_builder.dart';
import 'ai_analyzer_provider.dart';

part 'passive_insight_provider.g.dart';

const _cacheKeyPrefix = 'passive_insight_';

@riverpod
PassiveInsightContext passiveInsightContext(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  final categories = ref.watch(categoryListProvider).value ?? const [];
  return buildPassiveInsightContext(transactions: transactions, categories: categories);
}

@riverpod
class PassiveInsightController extends _$PassiveInsightController {
  @override
  Future<PassiveInsight?> build() async {
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) return null;

    final context = ref.watch(passiveInsightContextProvider);
    final box = ref.watch(syncMetaBoxProvider);
    final cacheKey = '$_cacheKeyPrefix$userId';
    final today = DateFormatter.day(DateTime.now());

    final cachedRaw = box.get(cacheKey) as String?;
    if (cachedRaw != null) {
      try {
        final cached = Map<String, dynamic>.from(jsonDecode(cachedRaw) as Map);
        if (cached['date'] == today && cached['fingerprint'] == context.fingerprint) {
          return PassiveInsight.fromJson(Map<String, dynamic>.from(cached['insight'] as Map));
        }
      } catch (_) {
        // Corrupt cache entry — fall through and regenerate.
      }
    }

    try {
      final insight =
          await ref.read(aiAnalyzerRepositoryProvider).getPassiveInsight(context.payload);
      await box.put(
        cacheKey,
        jsonEncode({
          'date': today,
          'fingerprint': context.fingerprint,
          'insight': insight.toJson(),
        }),
      );
      return insight;
    } catch (_) {
      // Non-critical nice-to-have — Home must not break if this fails.
      return null;
    }
  }
}
