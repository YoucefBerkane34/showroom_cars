import 'package:flutter/material.dart';
import '../../core/lang/app_lang.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/wilayas.dart';
import '../../models/supplier.dart';
import '../../services/supplier_service.dart';
import '../../widgets/confirm_dialog.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});
  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  List<Supplier> _suppliers = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    _suppliers = await SupplierService.getSuppliers(search: _searchCtrl.text.trim());
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.t('suppliers')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppLang.t('add')),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppColors.primary),
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
                hintText: '${AppLang.t('search')}...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear),
                        onPressed: () { _searchCtrl.clear(); _load(); })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _suppliers.isEmpty
                    ? Center(child: Text(AppLang.t('no_data'),
                        style: const TextStyle(color: AppColors.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _suppliers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (_, i) => _supplierCard(_suppliers[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _supplierCard(Supplier s) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 22),
        ),
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (s.phone != null) Row(children: [
            const Icon(Icons.phone, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(s.phone!, style: const TextStyle(fontSize: 12)),
          ]),
          if (s.wilaya != null) Row(children: [
            const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(s.wilaya!, style: const TextStyle(fontSize: 12)),
          ]),
          if (s.email != null) Row(children: [
            const Icon(Icons.email, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(s.email!, style: const TextStyle(fontSize: 12)),
          ]),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _openForm(s)),
          IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () => _delete(s)),
        ]),
        onTap: () => _openForm(s),
      ),
    );
  }

  void _openForm(Supplier? s) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SupplierFormSheet(supplier: s),
    );
    if (saved == true) _load();
  }

  void _delete(Supplier s) async {
    final ok = await showConfirmDialog(context, 'Supprimer ${s.name} ?');
    if (ok) { await SupplierService.deleteSupplier(s.id!); _load(); }
  }
}

// =========== FORM ===========
class SupplierFormSheet extends StatefulWidget {
  final Supplier? supplier;
  const SupplierFormSheet({super.key, this.supplier});
  @override
  State<SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends State<SupplierFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _wilaya;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    if (s != null) {
      _nameCtrl.text = s.name;
      _phoneCtrl.text = s.phone ?? '';
      _emailCtrl.text = s.email ?? '';
      _addressCtrl.text = s.address ?? '';
      _notesCtrl.text = s.notes ?? '';
      _wilaya = s.wilaya;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(widget.supplier == null ? 'Nouveau Fournisseur' : 'Modifier Fournisseur',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    _field(AppLang.t('full_name'), _nameCtrl, required: true),
                    Row(children: [
                      Expanded(child: _field(AppLang.t('phone'), _phoneCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(AppLang.t('email'), _emailCtrl)),
                    ]),
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
    final s = Supplier(
      id: widget.supplier?.id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      wilaya: _wilaya,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    try {
      if (widget.supplier == null) {
        await SupplierService.addSupplier(s);
      } else {
        await SupplierService.updateSupplier(s);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLang.t('error_occurred'))));
    }
  }
}
