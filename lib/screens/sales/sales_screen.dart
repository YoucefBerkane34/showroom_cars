import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/lang/app_lang.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/sale.dart';
import '../../models/vehicle.dart';
import '../../models/client.dart';
import '../../services/sale_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/client_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Sale> _sales = [];
  bool _loading = true;
  String _statusFilter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    _sales = await SaleService.getSales(
        status: _statusFilter == 'all' ? null : _statusFilter,
        search: _searchCtrl.text.trim());
    setState(() => _loading = false);
  }

  String _fmtPrice(double v) {
    final f = NumberFormat('#,###', 'fr_FR');
    return '${f.format(v)} DA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.t('sales')),
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
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: '${AppLang.t('search')} (véhicule, client...)',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _chip('all', AppLang.t('all')),
                    ...(AppConstants.saleStatuses.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _chip(s, AppLang.t(s)),
                    ))),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _sales.isEmpty
                    ? Center(child: Text(AppLang.t('no_data'),
                        style: const TextStyle(color: AppColors.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _sales.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (_, i) => _saleCard(_sales[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    final selected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) { setState(() => _statusFilter = value); _load(); },
      selectedColor: AppColors.primary.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _saleCard(Sale s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Vente #${s.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                StatusBadge(status: s.status),
              ],
            ),
            const Divider(height: 16),
            _row(Icons.directions_car, s.vehicleDisplay ?? '—'),
            const SizedBox(height: 4),
            _row(Icons.person, s.clientDisplay ?? '—'),
            const SizedBox(height: 4),
            _row(Icons.calendar_today, s.saleDate),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _priceBox('Prix total', _fmtPrice(s.totalPrice), AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: _priceBox('Payé', _fmtPrice(s.paidAmount), AppColors.available)),
                const SizedBox(width: 8),
                Expanded(child: _priceBox('Reste', _fmtPrice(s.remainingAmount),
                    s.remainingAmount > 0 ? AppColors.reserved : AppColors.available)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(AppLang.t('edit')),
                  onPressed: () => _openForm(s),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: Text(AppLang.t('delete'), style: const TextStyle(color: Colors.red)),
                  onPressed: () => _delete(s),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
    ],
  );

  Widget _priceBox(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: color)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
      ],
    ),
  );

  void _openForm(Sale? sale) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaleFormSheet(sale: sale),
    );
    if (saved == true) _load();
  }

  void _delete(Sale s) async {
    final ok = await showConfirmDialog(context, 'Supprimer cette vente ?');
    if (ok) { await SaleService.deleteSale(s.id!); _load(); }
  }
}

// =========== FORM ===========
class SaleFormSheet extends StatefulWidget {
  final Sale? sale;
  const SaleFormSheet({super.key, this.sale});
  @override
  State<SaleFormSheet> createState() => _SaleFormSheetState();
}

class _SaleFormSheetState extends State<SaleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _loadingVehicles = true;
  bool _loadingClients = true;

  List<Vehicle> _vehicles = [];
  List<Client> _clients = [];

  int? _vehicleId;
  int? _clientId;
  final _priceCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _paymentMethod = 'cash';
  String _status = 'draft';
  String _saleDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
    final s = widget.sale;
    if (s != null) {
      _vehicleId = s.vehicleId;
      _clientId = s.clientId;
      _priceCtrl.text = s.totalPrice.toString();
      _paidCtrl.text = s.paidAmount.toString();
      _notesCtrl.text = s.notes ?? '';
      _paymentMethod = s.paymentMethod;
      _status = s.status;
      _saleDate = s.saleDate;
    }
  }

  void _loadDropdowns() async {
    final vList = await VehicleService.getVehicles(status: 'available');
    final cList = await ClientService.getClients();
    // If editing, add the current vehicle even if not available
    if (widget.sale != null && _vehicleId != null) {
      final exists = vList.any((v) => v.id == _vehicleId);
      if (!exists) {
        final current = await VehicleService.getVehicle(_vehicleId!);
        if (current != null) vList.insert(0, current);
      }
    }
    setState(() {
      _vehicles = vList;
      _clients = cList;
      _loadingVehicles = false;
      _loadingClients = false;
    });
  }

  double get _remaining {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final paid = double.tryParse(_paidCtrl.text) ?? 0;
    return price - paid;
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
                  Text(widget.sale == null ? 'Nouvelle Vente' : 'Modifier Vente',
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
                    // Vehicle
                    _loadingVehicles
                        ? const LinearProgressIndicator()
                        : DropdownButtonFormField<int>(
                            value: _vehicleId,
                            decoration: InputDecoration(
                                labelText: '${AppLang.t('select_vehicle')} *'),
                            items: _vehicles.map((v) => DropdownMenuItem(
                              value: v.id,
                              child: Text(v.displayName, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (v) => setState(() => _vehicleId = v),
                            validator: (v) => v == null ? AppLang.t('required_field') : null,
                            isExpanded: true,
                          ),
                    const SizedBox(height: 12),
                    // Client
                    _loadingClients
                        ? const LinearProgressIndicator()
                        : DropdownButtonFormField<int>(
                            value: _clientId,
                            decoration: InputDecoration(
                                labelText: '${AppLang.t('select_client')} *'),
                            items: _clients.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text('${c.fullName}${c.phone != null ? " • ${c.phone}" : ""}',
                                  overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (v) => setState(() => _clientId = v),
                            validator: (v) => v == null ? AppLang.t('required_field') : null,
                            isExpanded: true,
                          ),
                    const SizedBox(height: 12),
                    // Date
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: '${AppLang.t('sale_date')} *',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(text: _saleDate),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(_saleDate) ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _saleDate = DateFormat('yyyy-MM-dd').format(d));
                      },
                    ),
                    const SizedBox(height: 12),
                    // Prices
                    Row(children: [
                      Expanded(child: TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: '${AppLang.t('total_price')} (DA) *'),
                        onChanged: (_) => setState(() {}),
                        validator: (v) => (v == null || v.isEmpty) ? AppLang.t('required_field') : null,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(
                        controller: _paidCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: '${AppLang.t('paid_amount')} (DA)'),
                        onChanged: (_) => setState(() {}),
                      )),
                    ]),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _remaining > 0
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(_remaining > 0 ? Icons.pending_actions : Icons.check_circle,
                              size: 16,
                              color: _remaining > 0 ? Colors.orange : Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '${AppLang.t('remaining')}: ${NumberFormat('#,###', 'fr_FR').format(_remaining)} DA',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _remaining > 0 ? Colors.orange : Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Payment method
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: InputDecoration(labelText: AppLang.t('payment_method')),
                      items: AppConstants.paymentMethods.map((m) =>
                          DropdownMenuItem(value: m, child: Text(AppLang.t(m)))).toList(),
                      onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
                    ),
                    const SizedBox(height: 12),
                    // Status
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(labelText: AppLang.t('sale_status')),
                      items: AppConstants.saleStatuses.map((s) =>
                          DropdownMenuItem(value: s, child: Text(AppLang.t(s)))).toList(),
                      onChanged: (v) => setState(() => _status = v ?? 'draft'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: AppLang.t('notes')),
                    ),
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

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vehicleId == null || _clientId == null) return;
    setState(() => _saving = true);

    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final paid = double.tryParse(_paidCtrl.text) ?? 0;

    final sale = Sale(
      id: widget.sale?.id,
      vehicleId: _vehicleId!,
      clientId: _clientId!,
      saleDate: _saleDate,
      totalPrice: price,
      paidAmount: paid,
      remainingAmount: price - paid,
      paymentMethod: _paymentMethod,
      status: _status,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      if (widget.sale == null) {
        await SaleService.addSale(sale);
        // Mark vehicle as sold if confirmed/completed
        if (_status == 'confirmed' || _status == 'completed') {
          await VehicleService.updateStatus(_vehicleId!, 'sold');
        }
      } else {
        await SaleService.updateSale(sale);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLang.t('error_occurred'))));
    }
  }
}
