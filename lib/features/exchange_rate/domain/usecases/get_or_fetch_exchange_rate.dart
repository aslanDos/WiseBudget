import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/exchange_rate/domain/entity/exchange_rate_entity.dart';
import 'package:wisebuget/features/exchange_rate/domain/repository/exchange_rate_repository.dart';

class GetOrFetchExchangeRate
    extends UseCase<ExchangeRateEntity?, GetOrFetchRateParams> {
  GetOrFetchExchangeRate(this.repository);

  final ExchangeRateRepository repository;

  @override
  Future<Either<Failure, ExchangeRateEntity?>> call(
    GetOrFetchRateParams params,
  ) async {
    if (params.from == params.to) {
      return Right(
        ExchangeRateEntity(
          fromCurrency: params.from,
          toCurrency: params.to,
          rate: 1.0,
          date: _dateOnly(params.date),
          fetchedAt: DateTime.now(),
        ),
      );
    }

    final cached = await repository.getRate(
      from: params.from,
      to: params.to,
      date: params.date,
    );

    return cached.fold(
      Left.new,
      (rate) async {
        if (rate != null && !rate.isStale) return Right(rate);
        // Cache miss or stale: fetch from network.
        final fetched = await repository.fetchAndStoreRate(
          from: params.from,
          to: params.to,
          date: params.date,
        );
        // If network fails but we have a stale cached value, use it.
        return fetched.fold(
          (failure) => rate != null ? Right(rate) : Left(failure),
          Right.new,
        );
      },
    );
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

class GetOrFetchRateParams extends Equatable {
  const GetOrFetchRateParams({
    required this.from,
    required this.to,
    required this.date,
  });

  final String from;
  final String to;
  final DateTime date;

  @override
  List<Object?> get props => [from, to, date];
}
