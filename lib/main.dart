import 'package:flutter/material.dart';
import 'core/lang/app_lang.dart';
import 'core/theme/app_theme.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/vehicles/vehicles_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/sales/sales_screen.dart';
import 'screens/reservations/reservations_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/suppliers/suppliers_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/app_sidebar.dart';

void main() {
  runApp(const ShowroomApp());
}

class ShowroomApp extends StatefulWidget {
  const ShowroomApp({super.key});

  @override
  State<ShowroomApp> createState() => _ShowroomAppState();
}

class _ShowroomAppState extends State<ShowroomApp> {
  String _lang = 'fr';

  void _onLangChanged(String lang) {
    setState(() => _lang = lang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Showroom Manager',
      theme: AppTheme.light,
      // RTL support for Arabic
      builder: (context, child) {
        return Directionality(
          textDirection:
              _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: MainNavigation(onLangChanged: _onLangChanged),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final Function(String) onLangChanged;
  const MainNavigation({super.key, required this.onLangChanged});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        const DashboardScreen(),
        const VehiclesScreen(),
        const ClientsScreen(),
        const SalesScreen(),
        const ReservationsScreen(),
        const ExpensesScreen(),
        const SuppliersScreen(),
        SettingsScreen(onLangChanged: (lang) {
          widget.onLangChanged(lang);
          setState(() {});
        }),
      ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      // Desktop/tablet: sidebar layout
      return Scaffold(
        body: Row(
          children: [
            AppSidebar(
              selectedIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
            ),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      );
    }

    // Mobile: bottom nav
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 4 : _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: AppLang.t('dashboard')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car_rounded),
              label: AppLang.t('vehicles')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.people_rounded),
              label: AppLang.t('clients')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_rounded),
              label: AppLang.t('sales')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.more_horiz_rounded),
              label: 'Plus'),
        ],
      ),
    );
  }
}
