import 'package:flutter/material.dart';
import '../../models/sale.dart';
import '../../services/sale_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Sale> sales = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    sales = await SaleService.getSales();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sales")),
      body: ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, i) {
          final s = sales[i];

          return ListTile(
            title: Text("Sale #${s.id ?? 0}"),
            subtitle: Text("Paid: ${s.paidAmount} DA"),
            trailing: Text("${s.remainingAmount} DA"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddSaleDialog(onSave: load),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddSaleDialog extends StatefulWidget {
  final Function onSave;

  const AddSaleDialog({super.key, required this.onSave});

  @override
  State<AddSaleDialog> createState() => _AddSaleDialogState();
}

class _AddSaleDialogState extends State<AddSaleDialog> {
  final price = TextEditingController();
  final paid = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Sale"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: price,
            decoration: const InputDecoration(labelText: "Price"),
          ),
          TextField(
            controller: paid,
            decoration: const InputDecoration(labelText: "Paid"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            double p = double.parse(price.text);
            double paidAmount = double.parse(paid.text);

            await SaleService.addSale(
              Sale(
                vehicleId: 1,
                clientId: 1,
                price: p,
                paidAmount: paidAmount,
                remainingAmount: p - paidAmount,
                date: DateTime.now().toString(),
              ),
            );

            widget.onSave();
            Navigator.pop(context);
          },
          child: const Text("Save"),
        )
      ],
    );
  }
}
