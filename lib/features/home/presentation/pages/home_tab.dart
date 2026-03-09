import 'package:flutter/material.dart';
import 'package:wisebuget/features/home/presentation/widgets/collapsible_calendar.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          // Calendar
          SafeArea(
            bottom: false,
            child: CollapsibleCalendar(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),

          // Transactions for selected date
          Expanded(child: _TransactionsList(selectedDate: _selectedDate)),
        ],
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final DateTime selectedDate;

  const _TransactionsList({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: Replace with actual transactions from TransactionCubit
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.0,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16.0),
          Text(
            'No transactions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            _formatDate(selectedDate),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
