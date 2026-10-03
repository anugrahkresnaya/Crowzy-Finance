import 'package:flutter/material.dart' show DateTimeRange;

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

/// Narrows [transactions] for the Activity list.
///
/// A [dateRange] wins over [month]. A non-blank [query] searches every month
/// (matching the note or the category name), so a search is never limited to
/// the month on screen; an explicit [dateRange] still applies.
List<TransactionModel> filterTransactions(
  List<TransactionModel> transactions, {
  DateTime? month,
  DateTimeRange? dateRange,
  String? categoryId,
  TransactionType? type,
  String query = '',
  Map<String, String> categoryNames = const {},
}) {
  final needle = query.trim().toLowerCase();

  return transactions.where((t) {
    if (dateRange != null) {
      // Through the end of the last day, not just its first instant.
      final end = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day + 1);
      if (t.date.isBefore(dateRange.start) || !t.date.isBefore(end)) return false;
    } else if (needle.isEmpty && month != null && !DateFormatter.isSameMonth(t.date, month)) {
      return false;
    }

    if (categoryId != null && t.categoryId != categoryId) return false;
    if (type != null && t.type != type) return false;

    if (needle.isNotEmpty) {
      final note = t.note?.toLowerCase() ?? '';
      final category = categoryNames[t.categoryId]?.toLowerCase() ?? '';
      if (!note.contains(needle) && !category.contains(needle)) return false;
    }
    return true;
  }).toList();
}

/// Transactions that fall on the same calendar day, with their net result.
class DayGroup {
  const DayGroup({required this.day, required this.transactions, required this.net});

  final DateTime day;
  final List<TransactionModel> transactions;

  /// Income minus expenses for the day.
  final double net;
}

/// Groups consecutive transactions that share a calendar day, keeping the
/// order given. Meant for date-sorted lists.
List<DayGroup> groupByDay(List<TransactionModel> transactions) {
  final groups = <DayGroup>[];
  var currentDay = DateTime(0);
  var items = <TransactionModel>[];
  var net = 0.0;

  void flush() {
    if (items.isEmpty) return;
    groups.add(DayGroup(day: currentDay, transactions: items, net: net));
  }

  for (final transaction in transactions) {
    if (items.isEmpty || !DateFormatter.isSameDay(transaction.date, currentDay)) {
      flush();
      currentDay = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      items = [];
      net = 0;
    }
    items.add(transaction);
    net += transaction.type == TransactionType.income ? transaction.amount : -transaction.amount;
  }
  flush();

  return groups;
}
