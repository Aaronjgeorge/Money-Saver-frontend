import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:price_checker/screens/home_screen.dart';
import 'package:price_checker/screens/account_screen.dart';
import 'package:price_checker/screens/expenses_screen.dart';
import 'package:price_checker/providers/navigation_provider.dart';
import 'package:price_checker/providers/expenses_provider.dart';

class TabScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider.state).state;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomePage(),
          ExpensesScreen(),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

// bottom_nav_bar.dart

class BottomNavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('BottomNavBar is building');
    final currentIndex = ref.watch(currentIndexProvider.state).state;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        print("BottomNavBar onTap - Current index: $index");
        ref.watch(currentIndexProvider.state).state = index;

        // Add refresh call for the "Expenses" tab
        if (index == 1) {
          ref.refresh(expensesProvider);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Expenses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Account',
        ),
      ],
    );
  }
}
