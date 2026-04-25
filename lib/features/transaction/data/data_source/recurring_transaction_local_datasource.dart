import 'package:wisebuget/features/transaction/data/model/recurring_transaction_model.dart';

abstract class RecurringTransactionLocalDataSource {
  Future<List<RecurringTransactionModel>> getRecurringTransactions();
  Future<RecurringTransactionModel> createRecurringTransaction(
    RecurringTransactionModel transaction,
  );
  Future<RecurringTransactionModel> updateRecurringTransaction(
    RecurringTransactionModel transaction,
  );
  Future<void> deleteRecurringTransaction(String uuid);
}
