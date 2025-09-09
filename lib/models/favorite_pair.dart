import 'package:flutter/foundation.dart';

@immutable
class FavoritePair {
  final String id;
  final String baseCurrency;
  final String targetCurrency;
  final DateTime createdAt;
  final int sortOrder;

  const FavoritePair({
    required this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.createdAt,
    this.sortOrder = 0,
  });

  FavoritePair copyWith({
    String? id,
    String? baseCurrency,
    String? targetCurrency,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return FavoritePair(
      id: id ?? this.id,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  factory FavoritePair.fromJson(Map<String, dynamic> json) {
    return FavoritePair(
      id: json['id'],
      baseCurrency: json['baseCurrency'],
      targetCurrency: json['targetCurrency'],
      createdAt: DateTime.parse(json['createdAt']),
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoritePair &&
        other.id == id &&
        other.baseCurrency == baseCurrency &&
        other.targetCurrency == targetCurrency;
  }

  @override
  int get hashCode =>
      id.hashCode ^ baseCurrency.hashCode ^ targetCurrency.hashCode;
}
