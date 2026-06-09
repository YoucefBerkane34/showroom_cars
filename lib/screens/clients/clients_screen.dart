import 'package:flutter/material.dart';
import '../../core/lang/app_lang.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/wilayas.dart';
import '../../models/client.dart';
import '../../services/client_service.dart';
import '../../widgets/confirm_dialog.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Client> _clients = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _clients = await ClientService.getClients(search: _searchCtrl.text.trim());
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.t('clients')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppLang.t('add')),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _load(),
              decoration: InputDecoration(
                hintText: '${AppLang.t('search')} (nom, téléphone, wilaya...)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchCtrl.clear(); _load(); })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _clients.isEmpty
                    ? Center(child: Text(AppLang.t('no_data'),
                        style: const TextStyle(color: AppColors.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _clients.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (_, i) => _clientCard(_clients[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _clientCard(Client c) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.phone != null) Row(
              children: [
                const Icon(Icons.phone, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(c.phone!, style: const TextStyle(fontSize: 12)),
              ],
            ),
            if (c.wilaya != null) Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(c.wilaya!, style: const TextStyle(fontSize: 12)),
              ],
            ),
            if (c.clientType == 'corporate' && c.company != null)
              Row(children: [
                const Icon(Icons.business, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(c.company!, style: const TextStyle(fontSize: 12)),
              ]),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.clientType == 'corporate'
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLang.t(c.clientType),
                style: TextStyle(
                  fontSize: 11,
                  color: c.clientType == 'corporate' ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _openForm(c)),
            IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: () => _delete(c)),
          ],
        ),
        onTap: () => _openForm(c),
      ),
    );
  }

  void _openForm(Client? client) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClientFormSheet(client: client),
    );
    if (saved == true) _load();
  }

  void _delete(Client c) async {
    final ok = await showConfirmDialog(context, 'Supprimer ${c.fullName} ?');
    if (ok) { await ClientService.deleteClient(c.id!); _load(); }
  }
}

// =========== FORM ===========
class ClientFormSheet extends StatefulWidget {
  final Client? client;
  const ClientFormSheet({super.key, this.client});
  @override
  State<ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<ClientFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _clientType = 'individual';
  String? _wilaya;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    if (c != null) {
      _nameCtrl.text = c.fullName;
      _phoneCtrl.text = c.phone ?? '';
      _whatsappCtrl.text = c.whatsapp ?? '';
      _emailCtrl.text = c.email ?? '';
      _addressCtrl.text = c.address ?? '';
      _companyCtrl.text = c.company ?? '';
      _notesCtrl.text = c.notes ?? '';
      _clientType = c.clientType;
      _wilaya = c.wilaya;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    widget.client == null
                        ? '${AppLang.t('add')} ${AppLang.t('clients')}'
                        : '${AppLang.t('edit')} ${AppLang.t('clients')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Type selector
                    Row(
                      children: [
                        Expanded(child: _typeBtn('individual', Icons.person)),
                        const SizedBox(width: 12),
                        Expanded(child: _typeBtn('corporate', Icons.business)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _field(AppLang.t('full_name'), _nameCtrl, required: true),
                    Row(children: [
                      Expanded(child: _field(AppLang.t('phone'), _phoneCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(AppLang.t('whatsapp'), _whatsappCtrl)),
                    ]),
                    _field(AppLang.t('email'), _emailCtrl),
                    _field(AppLang.t('address'), _addressCtrl),
                    DropdownButtonFormField<String>(
                      value: _wilaya,
                      decoration: InputDecoration(labelText: AppLang.t('wilaya')),
                      items: algerianWilayas.map((w) =>
                        DropdownMenuItem(value: w, child: Text(w))).toList(),
                      onChanged: (v) => setState(() => _wilaya = v),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),
                    if (_clientType == 'corporate') ...[
                      _field(AppLang.t('company'), _companyCtrl),
                    ],
                    _field(AppLang.t('notes'), _notesCtrl),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(AppLang.t('save')),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn(String type, IconData icon) {
    final selected = _clientType == type;
    return GestureDetector(
      onTap: () => setState(() => _clientType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(color: selected ? AppColors.primary : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppColors.primary : Colors.grey, size: 18),
            const SizedBox(width: 8),
            Text(AppLang.t(type),
                style: TextStyle(
                    color: selected ? AppColors.primary : Colors.grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label + (required ? ' *' : '')),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? AppLang.t('required_field') : null
            : null,
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final client = Client(
      id: widget.client?.id,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      whatsapp: _whatsappCtrl.text.trim().isEmpty ? null : _whatsappCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      wilaya: _wilaya,
      clientType: _clientType,
      company: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    try {
      if (widget.client == null) {
        await ClientService.addClient(client);
      } else {
        await ClientService.updateClient(client);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLang.t('error_occurred'))));
    }
  }
}
