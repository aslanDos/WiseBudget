import 'package:wisebuget/features/exchange_rate/data/model/exchange_rate_model.dart';
import 'package:wisebuget/objectbox.g.dart';

abstract class ExchangeRateLocalDataSource {
  /// Returns the stored rate for [pairKey] on [date], or null.
  Future<ExchangeRateModel?> getRate(String pairKey, DateTime date);

  /// Returns the most recently fetched rate for [pairKey], or null.
  Future<ExchangeRateModel?> getLatestRate(String pairKey);

  Future<void> storeRate(ExchangeRateModel model);
}

class ExchangeRateLocalDataSourceImpl implements ExchangeRateLocalDataSource {
  ExchangeRateLocalDataSourceImpl(Store store)
      : _box = store.box<ExchangeRateModel>();

  final Box<ExchangeRateModel> _box;

  @override
  Future<ExchangeRateModel?> getRate(String pairKey, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final query = _box
        .query(
          ExchangeRateModel_.pairKey.equals(pairKey).and(
                ExchangeRateModel_.date.equals(dateOnly.millisecondsSinceEpoch),
              ),
        )
        .build();
    return query.findFirst();
  }

  @override
  Future<ExchangeRateModel?> getLatestRate(String pairKey) async {
    final query = (_box.query(ExchangeRateModel_.pairKey.equals(pairKey))
          ..order(ExchangeRateModel_.fetchedAt, flags: Order.descending))
        .build();
    return query.findFirst();
  }

  @override
  Future<void> storeRate(ExchangeRateModel model) async {
    // Upsert: replace existing entry for same pair+date.
    final dateOnly = DateTime(model.date.year, model.date.month, model.date.day);
    final existing = await getRate(model.pairKey, dateOnly);
    if (existing != null) {
      model.id = existing.id;
    }
    _box.put(model);
  }
}
