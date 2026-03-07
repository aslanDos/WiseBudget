import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';

class DeleteAccount extends UseCase<void, DeleteAccountParams> {
  final AccountRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAccountParams params) {
    return repository.deleteAccount(params.uuid);
  }
}

class DeleteAccountParams extends Equatable {
  final String uuid;

  const DeleteAccountParams({required this.uuid});

  @override
  List<Object> get props => [uuid];
}
