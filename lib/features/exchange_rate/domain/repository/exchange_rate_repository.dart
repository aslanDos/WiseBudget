import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/exchange_rate/domain/entity/exchange_rate_entity.dart';

abstract class ExchangeRateRepository {
  /// Returns the cached rate for the given pair and date.
  /// Falls back to the most recent stored rate for the pair if exact date is missing.
  Future<Either<Failure, ExchangeRateEntity?>> getRate({
    required String from,
    required String to,
    required DateTime date,
  });

  /// Fetches the rate from the network and persists it locally.
  Future<Either<Failure, ExchangeRateEntity>> fetchAndStoreRate({
    required String from,
    required String to,
    required DateTime date,
  });

  /// Stores a rate locally (used after a successful remote fetch).
  Future<Either<Failure, void>> storeRate(ExchangeRateEntity rate);
}
