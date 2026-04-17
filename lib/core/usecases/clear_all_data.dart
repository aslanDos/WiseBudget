import 'package:wisebuget/features/account/data/model/account_model.dart';
import 'package:wisebuget/features/budget/data/model/budget_model.dart';
import 'package:wisebuget/features/category/data/model/category_model.dart';
import 'package:wisebuget/features/transaction/data/model/transaction_model.dart';
import 'package:wisebuget/objectbox.g.dart';

class ClearAllData {
  final Store _store;

  ClearAllData(this._store);

  Future<void> call() async {
    _store.box<TransactionModel>().removeAll();
    _store.box<AccountModel>().removeAll();
    _store.box<BudgetModel>().removeAll();
    _store.box<CategoryModel>().removeAll();
  }
}
