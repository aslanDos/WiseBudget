import 'package:wisebuget/features/transaction/data/model/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel?> getTransactionByUuid(String uuid);
  Future<List<TransactionModel>> getTransactionsByAccountUuid(String accountUuid);
  Future<List<TransactionModel>> getTransactionsByCategoryUuid(String categoryUuid);
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String uuid);
}
