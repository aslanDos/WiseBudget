import 'package:wisebuget/features/account/data/data_source/account_local_datasource.dart';
import 'package:wisebuget/features/account/data/model/account_model.dart';
import 'package:wisebuget/objectbox.g.dart';

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final Box<AccountModel> _box;

  AccountLocalDataSourceImpl(Store store) : _box = store.box<AccountModel>();

  @override
  Future<List<AccountModel>> getAccounts() async {
    final query = _box.query()..order(AccountModel_.sortOrder);
    return query.build().find();
  }

  @override
  Future<AccountModel?> getAccountByUuid(String uuid) async {
    final query = _box.query(AccountModel_.uuid.equals(uuid)).build();
    return query.findFirst();
  }

  @override
  Future<AccountModel> createAccount(AccountModel account) async {
    if (account.sortOrder == -1) {
      final count = _box.count();
      account.sortOrder = count;
    }
    _box.put(account);
    return account;
  }

  @override
  Future<AccountModel> updateAccount(AccountModel account) async {
    final existing = await getAccountByUuid(account.uuid);
    if (existing != null) {
      account.id = existing.id;
    }
    _box.put(account);
    return account;
  }

  @override
  Future<void> deleteAccount(String uuid) async {
    final query = _box.query(AccountModel_.uuid.equals(uuid)).build();
    final account = query.findFirst();
    if (account != null) {
      _box.remove(account.id);
    }
  }
}
