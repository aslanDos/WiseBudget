import 'package:wisebuget/features/transaction/data/data_source/recurring_transaction_local_datasource.dart';
import 'package:wisebuget/features/transaction/data/model/recurring_transaction_model.dart';
import 'package:wisebuget/objectbox.g.dart';

class RecurringTransactionLocalDataSourceImpl
    implements RecurringTransactionLocalDataSource {
  final Box<RecurringTransactionModel> _box;

  RecurringTransactionLocalDataSourceImpl(Store store)
    : _box = store.box<RecurringTransactionModel>();

  @override
  Future<List<RecurringTransactionModel>> getRecurringTransactions() async {
    final query = _box.query()..order(RecurringTransactionModel_.startDate);
    return query.build().find();
  }

  @override
  Future<RecurringTransactionModel> createRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    _box.put(transaction);
    return transaction;
  }

  @override
  Future<RecurringTransactionModel> updateRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    _box.put(transaction);
    return transaction;
  }

  @override
  Future<void> deleteRecurringTransaction(String uuid) async {
    final query = _box
        .query(RecurringTransactionModel_.uuid.equals(uuid))
        .build();
    final model = query.findFirst();
    if (model != null) {
      _box.remove(model.id);
    }
  }
}
