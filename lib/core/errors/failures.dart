import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Database operation failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Validation failures (invalid input)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Network / HTTP failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
