import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../services/client_service.dart';

class ClientsScreen extends StatefulWidget {
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> clients = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    clients = await ClientService.getClients();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clients")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddClientDialog(onSave: loadData),
          );
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final c = clients[index];
          return ListTile(
            title: Text(c.name),
            subtitle: Text(c.phone),
            trailing: Text(c.address),
          );
        },
      ),
    );
  }
}

class AddClientDialog extends StatefulWidget {
  final Function onSave;

  AddClientDialog({required this.onSave});

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Client"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: name),
          TextField(controller: phone),
          TextField(controller: address),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await ClientService.addClient(
              Client(
                name: name.text,
                phone: phone.text,
                address: address.text,
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
