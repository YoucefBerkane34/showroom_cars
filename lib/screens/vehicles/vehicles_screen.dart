import 'package:flutter/material.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';

class VehiclesScreen extends StatefulWidget {
  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Vehicle> vehicles = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    vehicles = await VehicleService.getVehicles();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehicles")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddVehicleDialog(onSave: loadData),
          );
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final v = vehicles[index];
          return ListTile(
            title: Text("${v.brand} ${v.model}"),
            subtitle: Text(v.color),
            trailing: Text("${v.price} DA"),
          );
        },
      ),
    );
  }
}

class AddVehicleDialog extends StatefulWidget {
  final Function onSave;

  AddVehicleDialog({required this.onSave});

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final brand = TextEditingController();
  final model = TextEditingController();
  final color = TextEditingController();
  final price = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Vehicle"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: brand),
          TextField(controller: model),
          TextField(controller: color),
          TextField(controller: price),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await VehicleService.addVehicle(
              Vehicle(
                brand: brand.text,
                model: model.text,
                color: color.text,
                price: double.parse(price.text),
              ),
            );

            widget.onSave();
            Navigator.pop(context);
          },
          child: Text("Save"),
        )
      ],
    );
  }
}
