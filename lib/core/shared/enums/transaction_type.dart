enum TransactionType {
  transfer("transfer"),
  income("income"),
  expense("expense");

  final String value;

  const TransactionType(this.value);
}
