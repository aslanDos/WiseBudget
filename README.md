# WiseBudget

A personal finance management app built with Flutter. Track transactions, manage multiple accounts, categorize spending, and gain insights into your financial habits.

## Features

- **Multi-Account Management** - Track balances across multiple accounts
- **Transaction Tracking** - Record income, expenses, and transfers
- **Categories** - Organize transactions with customizable categories and colors
- **Analytics** - Visualize spending patterns and financial insights
- **Offline-First** - All data stored locally using ObjectBox

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **BLoC/Cubit** - State management
- **ObjectBox** - Local NoSQL database
- **GoRouter** - Navigation
- **GetIt** - Dependency injection
- **Clean Architecture** - Feature-based modular structure

## Getting Started

### Prerequisites

- Flutter SDK 3.10.7+
- Dart 3.10.7+

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/wisebuget.git
cd wisebuget

# Install dependencies
flutter pub get

# Generate ObjectBox models
dart run build_runner build

# Run the app
flutter run
```

## Architecture

Each feature follows Clean Architecture:

- **Presentation** - Cubits, Pages, Widgets
- **Domain** - Entities, Repositories (abstract), Use Cases
- **Data** - Models, Data Sources, Repositories (implementation)

## License

MIT License
