import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'providers/expense_provider.dart';
import 'providers/category_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/balance_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/all_expenses_screen.dart';
import 'screens/add_user_screen.dart';
import 'screens/users_screen.dart';
import 'screens/user_setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.mode,
          home: const SplashScreen(),
          routes: {
            '/main': (_) => const MainScreen(),
            '/add': (_) => const AddExpenseScreen(),
            '/income': (_) => const AddIncomeScreen(),
            '/expenses': (_) => const AllExpensesScreen(),
            '/add_user': (_) => const AddUserScreen(),
            '/users': (_) => const UsersScreen(),
            '/user_setup': (_) => const UserSetupScreen(),
          },
        ),
      ),
    );
  }
}
