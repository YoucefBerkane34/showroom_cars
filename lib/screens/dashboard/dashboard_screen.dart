import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 3,
          children: [
            _card("Vehicles", "120"),
            _card("Sold", "45"),
            _card("Revenue", "12,500,000 DA"),
            _card("Clients", "80"),
            _card("Installments Late", "7"),
            _card("Profit", "3,200,000 DA"),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String value) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
