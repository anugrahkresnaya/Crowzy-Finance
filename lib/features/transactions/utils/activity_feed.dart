import 'package:flutter/material.dart' show DateTimeRange;

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/models/transfer_model.dart';

/// One line of the Activity list: a transaction, or a transfer between
/// accounts. A transfer is not income or expense, so it never counts towards a
/// day's total.
sealed class ActivityEntry {
  const ActivityEntry();

  String get id;
  DateTime get date;
  double get amount;
}

final class TransactionEntry extends ActivityEntry {
  const TransactionEntry(this.transaction);

  final TransactionModel transaction;

  @override
  String get id => transaction.id;

  @override
  DateTime get date => transaction.date;

  @override
  double get amount => transaction.amount;
}

final class TransferEntry extends ActivityEntry {
  const TransferEntry(this.transfer);

  final TransferModel transfer;

  @override
  String get id => transfer.id;

  @override
  DateTime get date => transfer.date;

  @override
  double get amount => transfer.amount;
}

/// Newest first. When two entries share a moment, a transfer comes before the
/// transactions, so a transfer sits above its own fee.
int compareNewestFirst(ActivityEntry a, ActivityEntry b) {
  final byDate = b.date.compareTo(a.date);
  if (byDate != 0) return byDate;
  if (a is TransferEntry && b is! TransferEntry) return -1;
  if (a is! TransferEntry && b is TransferEntry) return 1;
  return 0;
}

/// Transactions and transfers as one list, newest first.
List<ActivityEntry> mergeActivity(
  Iterable<TransactionModel> transactions,
  Iterable<TransferModel> transfers,
) {
  return [
    for (final transaction in transactions) TransactionEntry(transaction),
    for (final transfer in transfers) TransferEntry(transfer),
  ]..sort(compareNewestFirst);
}

/// What the type chips above the list show.
enum ActivityFilter {
  all('All'),
  expense('Expenses'),
  income('Income'),
  transfers('Transfers');

  const ActivityFilter(this.label);

  final String label;
}

/// Narrows [entries] for the Activity list.
///
/// A [dateRange] wins over [month]. A non-blank [query] searches every month
/// (matching the note, the category name, or for a transfer either account's
/// name), so a search is never limited to the month on screen; an explicit
/// [dateRange] still applies. Choosing a [categoryId] leaves transfers out,
/// since they have no category.
List<ActivityEntry> filterActivity(
  List<ActivityEntry> entries, {
  DateTime? month,
  DateTimeRange? dateRange,
  String? categoryId,
  ActivityFilter filter = ActivityFilter.all,
  String query = '',
  Map<String, String> categoryNames = const {},
  Map<String, String> accountNames = const {},
}) {
  final needle = query.trim().toLowerCase();

  bool matches(String? text) => text != null && text.toLowerCase().contains(needle);

  return entries.where((entry) {
    if (dateRange != null) {
      // Through the end of the last day, not just its first instant.
      final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day + 1);
      if (entry.date.isBefore(dateRange.start) || !entry.date.isBefore(end)) return false;
    } else if (needle.isEmpty && month != null && !DateFormatter.isSameMonth(entry.date, month)) {
      return false;
    }

    switch (entry) {
      case TransactionEntry(:final transaction):
        if (filter == ActivityFilter.transfers) return false;
        if (filter == ActivityFilter.expense && transaction.type != TransactionType.expense) {
          return false;
        }
        if (filter == ActivityFilter.income && transaction.type != TransactionType.income) {
          return false;
        }
        if (categoryId != null && transaction.categoryId != categoryId) return false;
        if (needle.isNotEmpty &&
            !matches(transaction.note) &&
            !matches(categoryNames[transaction.categoryId])) {
          return false;
        }
      case TransferEntry(:final transfer):
        if (filter == ActivityFilter.expense || filter == ActivityFilter.income) return false;
        if (categoryId != null) return false;
        if (needle.isNotEmpty &&
            !matches(transfer.note) &&
            !matches(accountNames[transfer.fromAccountId]) &&
            !matches(accountNames[transfer.toAccountId]) &&
            !matches('transfer')) {
          return false;
        }
    }
    return true;
  }).toList();
}

/// Entries that fall on the same calendar day.
class ActivityDay {
  const ActivityDay({required this.day, required this.entries, required this.net});

  final DateTime day;
  final List<ActivityEntry> entries;

  /// Income minus expenses for the day. Transfers are left out.
  final double net;

  /// Whether anything that counts as money in or out happened that day. A day
  /// with only transfers has no total to show.
  bool get hasTotal => entries.any((e) => e is TransactionEntry);
}

/// Groups consecutive entries that share a calendar day, keeping the order
/// given. Meant for date-sorted lists.
List<ActivityDay> groupActivityByDay(List<ActivityEntry> entries) {
  final days = <ActivityDay>[];
  var currentDay = DateTime(0);
  var items = <ActivityEntry>[];
  var net = 0.0;

  void flush() {
    if (items.isEmpty) return;
    days.add(ActivityDay(day: currentDay, entries: items, net: net));
  }

  for (final entry in entries) {
    if (items.isEmpty || !DateFormatter.isSameDay(entry.date, currentDay)) {
      flush();
      currentDay = DateTime(entry.date.year, entry.date.month, entry.date.day);
      items = [];
      net = 0;
    }
    items.add(entry);
    if (entry is TransactionEntry) {
      net += entry.transaction.type == TransactionType.income
          ? entry.amount
          : -entry.amount;
    }
  }
  flush();

  return days;
}
