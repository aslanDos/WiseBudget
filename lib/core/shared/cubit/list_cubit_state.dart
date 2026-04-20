import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';

abstract class ListCubitState<T> extends Equatable {
  final CubitStatus status;
  final List<T> items;
  final String? errorMessage;

  const ListCubitState({
    this.status = CubitStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, items, errorMessage];
}
