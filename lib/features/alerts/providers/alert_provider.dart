import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/hive_constants.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../data/models/alert_model.dart';
import '../repository/alert_repository.dart';

part 'alert_provider.g.dart';

@riverpod
Box<Map> alertsBox(Ref ref) => Hive.box<Map>(HiveConstants.alertsBox);

@riverpod
AlertRepository alertRepository(Ref ref) {
  return AlertRepository(ref.watch(alertsBoxProvider), ref.watch(supabaseClientProvider));
}

@riverpod
class AlertList extends _$AlertList {
  @override
  Future<List<AlertModel>> build() async {
    return ref.watch(alertRepositoryProvider).getAll();
  }

  Future<void> markRead(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(alertRepositoryProvider);
      await repository.markRead(id);
      return repository.getAll();
    });
  }
}

@riverpod
List<AlertModel> unreadAlerts(Ref ref) {
  final alerts = ref.watch(alertListProvider).value ?? const [];
  return alerts.where((a) => a.isUnread).toList();
}
