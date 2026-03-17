import 'package:wisebuget/features/budget/data/data_source/budget_local_datasource.dart';
import 'package:wisebuget/features/budget/data/model/budget_model.dart';
import 'package:wisebuget/objectbox.g.dart';

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final Store _store;
  late final Box<BudgetModel> _box;

  BudgetLocalDataSourceImpl(this._store) {
    _box = _store.box<BudgetModel>();
  }

  @override
  Future<List<BudgetModel>> getBudgets() async {
    return _box
        .query()
        .order(BudgetModel_.createdDate, flags: Order.descending)
        .build()
        .find();
  }

  @override
  Future<List<BudgetModel>> getActiveBudgets() async {
    return _box
        .query(BudgetModel_.isArchived.equals(false))
        .order(BudgetModel_.createdDate, flags: Order.descending)
        .build()
        .find();
  }

  @override
  Future<BudgetModel?> getBudgetById(String uuid) async {
    return _box.query(BudgetModel_.uuid.equals(uuid)).build().findFirst();
  }

  @override
  Future<BudgetModel> createBudget(BudgetModel budget) async {
    _box.put(budget);
    return budget;
  }

  @override
  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    // Find existing by UUID to get the ID
    final existing =
        _box.query(BudgetModel_.uuid.equals(budget.uuid)).build().findFirst();

    if (existing != null) {
      budget.id = existing.id;
    }

    _box.put(budget);
    return budget;
  }

  @override
  Future<void> deleteBudget(String uuid) async {
    final existing =
        _box.query(BudgetModel_.uuid.equals(uuid)).build().findFirst();

    if (existing != null) {
      _box.remove(existing.id);
    }
  }
}
