import '../../data/models/category_model.dart';
import '../../data/models/transaction_type.dart';

/// Fixed IDs so these rows line up with the same fixed UUIDs seeded into the
/// `categories` table on Supabase (see the hand-off SQL) — this lets local
/// seeding and remote sync merge into the same rows instead of duplicating.
class DefaultCategories {
  DefaultCategories._();

  static const _defaults = <(String id, String name, String icon, TransactionType type)>[
    ('00000000-0000-4000-8000-000000000001', 'Salary', 'work', TransactionType.income),
    ('00000000-0000-4000-8000-000000000002', 'Business', 'store', TransactionType.income),
    ('00000000-0000-4000-8000-000000000003', 'Gift', 'card_giftcard', TransactionType.income),
    ('00000000-0000-4000-8000-000000000004', 'Other Income', 'attach_money', TransactionType.income),
    ('00000000-0000-4000-8000-000000000005', 'Food', 'restaurant', TransactionType.expense),
    ('00000000-0000-4000-8000-000000000006', 'Transport', 'directions_car', TransactionType.expense),
    ('00000000-0000-4000-8000-000000000007', 'Shopping', 'shopping_bag', TransactionType.expense),
    ('00000000-0000-4000-8000-000000000008', 'Bills', 'receipt_long', TransactionType.expense),
    ('00000000-0000-4000-8000-000000000009', 'Entertainment', 'movie', TransactionType.expense),
    ('00000000-0000-4000-8000-000000000010', 'Health', 'local_hospital', TransactionType.expense),
    ('00000000-0000-4000-8000-000000000011', 'Education', 'school', TransactionType.expense),
    ('00000000-0000-4000-8000-000000000012', 'Other Expense', 'category', TransactionType.expense),
  ];

  static List<CategoryModel> build() {
    final now = DateTime.now();
    return _defaults
        .map(
          (entry) => CategoryModel(
            id: entry.$1,
            userId: null,
            name: entry.$2,
            icon: entry.$3,
            type: entry.$4,
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList();
  }
}
