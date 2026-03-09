import 'package:wisebuget/features/transaction/data/data_source/transaction_local_datasource.dart';
import 'package:wisebuget/features/transaction/data/model/transaction_model.dart';
import 'package:wisebuget/objectbox.g.dart';

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Box<TransactionModel> _box;

  TransactionLocalDataSourceImpl(Store store)
      : _box = store.box<TransactionModel>();

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final query = _box.query()
      ..order(TransactionModel_.date, flags: Order.descending);
    return query.build().find();
  }

  @override
  Future<TransactionModel?> getTransactionByUuid(String uuid) async {
    final query = _box.query(TransactionModel_.uuid.equals(uuid)).build();
    return query.findFirst();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByAccountUuid(
    String accountUuid,
  ) async {
    final query = _box.query(TransactionModel_.accountUuid.equals(accountUuid))
      ..order(TransactionModel_.date, flags: Order.descending);
    return query.build().find();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCategoryUuid(
    String categoryUuid,
  ) async {
    final query = _box.query(TransactionModel_.categoryUuid.equals(categoryUuid))
      ..order(TransactionModel_.date, flags: Order.descending);
    return query.build().find();
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    _box.put(transaction);
    return transaction;
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    final existing = await getTransactionByUuid(transaction.uuid);
    if (existing != null) {
      transaction.id = existing.id;
    }
    _box.put(transaction);
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String uuid) async {
    final query = _box.query(TransactionModel_.uuid.equals(uuid)).build();
    final transaction = query.findFirst();
    if (transaction != null) {
      _box.remove(transaction.id);
    }
  }
}
