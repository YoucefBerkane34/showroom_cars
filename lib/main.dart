import 'package:flutter/material.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/vehicles/vehicles_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/sales/sales_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Showroom Cars',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final pages = [
    DashboardScreen(),
    VehiclesScreen(),
    ClientsScreen(),
    SalesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_car), label: "Vehicles"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clients"),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: "Sales"),
        ],
      ),
    );
  }
}
