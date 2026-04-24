import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/account/data/model/account_model.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/services/balance_service.dart';
import 'package:wisebuget/features/transaction/data/model/transaction_model.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_effects_gateway.dart';
import 'package:wisebuget/objectbox.g.dart';

class ObjectBoxTransactionEffectsGateway implements TransactionEffectsGateway {
  final Store _store;
  final BalanceService _balanceService;

  ObjectBoxTransactionEffectsGateway(
    this._store, {
    BalanceService balanceService = const BalanceService(),
  }) : _balanceService = balanceService;

  Box<AccountModel> get _accountBox => _store.box<AccountModel>();
  Box<TransactionModel> get _transactionBox => _store.box<TransactionModel>();

  @override
  Future<Either<Failure, TransactionEntity>> createTransactionWithEffects(
    TransactionEntity transaction,
  ) async {
    try {
      final created = _store.runInTransaction(TxMode.write, () {
        final model = TransactionModel.fromEntity(transaction);
        _transactionBox.put(model);
        _applyBalanceChanges(
          _balanceService.calculateAllBalanceChanges(model.toEntity()),
        );
        return model.toEntity();
      });
      return Right(created);
    } catch (error) {
      return Left(
        DatabaseFailure('Failed to create transaction with effects: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransactionWithEffects(
    TransactionEntity transaction,
  ) async {
    try {
      final updated = _store.runInTransaction(TxMode.write, () {
        final existing = _findTransactionByUuid(transaction.uuid);
        if (existing == null) {
          throw NotFoundFailure('Transaction not found: ${transaction.uuid}');
        }

        final updatedModel = TransactionModel.fromEntity(
          transaction,
          id: existing.id,
        );
        _transactionBox.put(updatedModel);
        _applyBalanceChanges(
          _balanceService.calculateEditChanges(
            existing.toEntity(),
            updatedModel.toEntity(),
          ),
        );
        return updatedModel.toEntity();
      });
      return Right(updated);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (error) {
      return Left(
        DatabaseFailure('Failed to update transaction with effects: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransactionWithEffects(
    String uuid,
  ) async {
    try {
      _store.runInTransaction(TxMode.write, () {
        final existing = _findTransactionByUuid(uuid);
        if (existing == null) {
          throw NotFoundFailure('Transaction not found: $uuid');
        }

        _transactionBox.remove(existing.id);
        _applyBalanceChanges(
          _balanceService.calculateAllBalanceChanges(
            existing.toEntity(),
            reverse: true,
          ),
        );
      });
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (error) {
      return Left(
        DatabaseFailure('Failed to delete transaction with effects: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, List<AccountEntity>>> recalculateAccountBalances(
    List<TransactionEntity> transactions,
  ) async {
    try {
      final updatedAccounts = _store.runInTransaction(TxMode.write, () {
        final query = _accountBox.query()..order(AccountModel_.sortOrder);
        final accountModels = query.build().find();

        final recalculated = accountModels.map((account) {
          final balance = _balanceService.calculateTotalBalance(
            transactions,
            account.uuid,
            0.0,
          );
          return AccountModel.fromEntity(
            account.toEntity().copyWith(balance: balance),
            id: account.id,
          );
        }).toList();

        for (final account in recalculated) {
          _accountBox.put(account);
        }

        return recalculated.map((account) => account.toEntity()).toList();
      });

      return Right(updatedAccounts);
    } catch (error) {
      return Left(
        DatabaseFailure('Failed to recalculate account balances: $error'),
      );
    }
  }

  void _applyBalanceChanges(Map<String, double> changes) {
    for (final entry in changes.entries) {
      final account = _findAccountByUuid(entry.key);
      if (account == null) {
        throw NotFoundFailure('Account not found: ${entry.key}');
      }
      account.balance += entry.value;
      _accountBox.put(account);
    }
  }

  AccountModel? _findAccountByUuid(String uuid) {
    final query = _accountBox.query(AccountModel_.uuid.equals(uuid)).build();
    return query.findFirst();
  }

  TransactionModel? _findTransactionByUuid(String uuid) {
    final query = _transactionBox
        .query(TransactionModel_.uuid.equals(uuid))
        .build();
    return query.findFirst();
  }
}
