import 'package:wisebuget/features/account/data/model/account_model.dart';

abstract class AccountLocalDataSource {
  Future<List<AccountModel>> getAccounts();
  Future<AccountModel?> getAccountByUuid(String uuid);
  Future<AccountModel> createAccount(AccountModel account);
  Future<AccountModel> updateAccount(AccountModel account);
  Future<void> deleteAccount(String uuid);
}
