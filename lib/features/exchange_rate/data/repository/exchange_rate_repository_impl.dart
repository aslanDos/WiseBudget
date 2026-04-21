import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/exchange_rate/data/data_source/exchange_rate_local_datasource.dart';
import 'package:wisebuget/features/exchange_rate/data/data_source/exchange_rate_remote_datasource.dart';
import 'package:wisebuget/features/exchange_rate/data/model/exchange_rate_model.dart';
import 'package:wisebuget/features/exchange_rate/domain/entity/exchange_rate_entity.dart';
import 'package:wisebuget/features/exchange_rate/domain/repository/exchange_rate_repository.dart';

final _log = Logger('ExchangeRateRepository');

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  ExchangeRateRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final ExchangeRateLocalDataSource localDataSource;
  final ExchangeRateRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, ExchangeRateEntity?>> getRate({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    try {
      final pairKey = '${from}_$to';
      final dateOnly = DateTime(date.year, date.month, date.day);

      ExchangeRateModel? model = await localDataSource.getRate(pairKey, dateOnly);
      // Fall back to the most recent stored rate for this pair.
      model ??= await localDataSource.getLatestRate(pairKey);

      return Right(model?.toEntity());
    } catch (e) {
      _log.warning('Failed to read cached rate $from→$to: $e');
      return Left(DatabaseFailure('Failed to read cached rate: $e'));
    }
  }

  @override
  Future<Either<Failure, ExchangeRateEntity>> fetchAndStoreRate({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    try {
      final model = await remoteDataSource.fetchRate(from, to, date);
      await localDataSource.storeRate(model);
      _log.fine('Fetched and stored rate $from→$to: ${model.rate}');
      return Right(model.toEntity());
    } catch (e) {
      _log.warning('Failed to fetch rate $from→$to: $e');
      return Left(NetworkFailure('Failed to fetch exchange rate: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> storeRate(ExchangeRateEntity rate) async {
    try {
      await localDataSource.storeRate(ExchangeRateModel.fromEntity(rate));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to store rate: $e'));
    }
  }
}
