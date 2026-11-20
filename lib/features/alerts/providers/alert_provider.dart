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

  // The list stays on screen while these run, so there is no loading state:
  // setting one would swap the whole list for a spinner on every tap.
  Future<void> markRead(String id) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(alertRepositoryProvider);
      await repository.markRead(id);
      return repository.getAll();
    });
  }

  Future<void> markAllRead() async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(alertRepositoryProvider);
      await repository.markAllRead();
      return repository.getAll();
    });
  }
}

@riverpod
List<AlertModel> unreadAlerts(Ref ref) {
  final alerts = ref.watch(alertListProvider).value ?? const [];
  return alerts.where((a) => a.isUnread).toList();
}
