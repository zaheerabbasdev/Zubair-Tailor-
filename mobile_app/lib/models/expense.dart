class Expense {
  final int? id;
  final String category;
  final double amount;
  final String? notes;
  final DateTime expenseDate;
  final DateTime? createdAt;

  Expense({
    this.id,
    required this.category,
    required this.amount,
    this.notes,
    required this.expenseDate,
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      category: json['category'],
      amount: double.parse(json['amount'].toString()),
      notes: json['notes'],
      expenseDate: DateTime.parse(json['expense_date']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'notes': notes,
      'expense_date': expenseDate.toIso8601String(),
    };
  }

  Expense copyWith({
    int? id,
    String? category,
    double? amount,
    String? notes,
    DateTime? expenseDate,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
