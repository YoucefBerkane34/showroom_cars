import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/lang/app_lang.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/wilayas.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});
  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Vehicle> _vehicles = [];
  bool _loading = true;
  String _statusFilter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _vehicles = await VehicleService.getVehicles(
      status: _statusFilter == 'all' ? null : _statusFilter,
      search: _searchCtrl.text.trim(),
    );
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
        title: Text(AppLang.t('vehicles')),
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
          // Filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: '${AppLang.t('search')} (marque, modèle, couleur...)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              _load();
                            })
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('all', AppLang.t('all')),
                      const SizedBox(width: 8),
                      _filterChip('available', AppLang.t('status_available')),
                      const SizedBox(width: 8),
                      _filterChip('reserved', AppLang.t('status_reserved')),
                      const SizedBox(width: 8),
                      _filterChip('sold', AppLang.t('status_sold')),
                      const SizedBox(width: 8),
                      _filterChip('preparation', AppLang.t('status_preparation')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _vehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_outlined,
                                size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(AppLang.t('no_data'),
                                style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _vehicles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (ctx, i) => _vehicleCard(_vehicles[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _statusFilter = value);
        _load();
      },
      selectedColor: AppColors.primary.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _vehicleCard(Vehicle v) {
    return Card(
      child: InkWell(
        onTap: () => _openForm(v),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_rounded,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            v.displayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(status: v.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (v.color != null)
                          _info(Icons.circle, v.color!),
                        if (v.fuelType != null) ...[
                          const SizedBox(width: 10),
                          _info(Icons.local_gas_station, AppLang.t(v.fuelType!)),
                        ],
                        if (v.mileage > 0) ...[
                          const SizedBox(width: 10),
                          _info(Icons.speed,
                              '${NumberFormat('#,###', 'fr_FR').format(v.mileage)} km'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fmtPrice(v.salePrice),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _openForm(v),
                    tooltip: AppLang.t('edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () => _delete(v),
                    tooltip: AppLang.t('delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      );

  void _openForm(Vehicle? vehicle) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VehicleFormSheet(vehicle: vehicle),
    );
    if (saved == true) _load();
  }

  void _delete(Vehicle v) async {
    final ok = await showConfirmDialog(
        context, 'Supprimer ${v.displayName} ?');
    if (ok) {
      await VehicleService.deleteVehicle(v.id!);
      _load();
    }
  }
}

// ============ VEHICLE FORM ============
class VehicleFormSheet extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormSheet({super.key, this.vehicle});

  @override
  State<VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _versionCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _regCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _purchaseDateCtrl = TextEditingController();
  final _purchasePriceCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _minSalePriceCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _fuelType;
  String? _transmission;
  String _status = 'available';

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (v != null) {
      _brandCtrl.text = v.brand;
      _modelCtrl.text = v.model;
      _versionCtrl.text = v.version ?? '';
      _stockCtrl.text = v.stockNumber ?? '';
      _vinCtrl.text = v.vin ?? '';
      _regCtrl.text = v.registration ?? '';
      _yearCtrl.text = v.year?.toString() ?? '';
      _mileageCtrl.text = v.mileage.toString();
      _colorCtrl.text = v.color ?? '';
      _engineCtrl.text = v.engine ?? '';
      _purchaseDateCtrl.text = v.purchaseDate ?? '';
      _purchasePriceCtrl.text = v.purchasePrice.toString();
      _salePriceCtrl.text = v.salePrice.toString();
      _minSalePriceCtrl.text = v.minSalePrice.toString();
      _supplierCtrl.text = v.supplier ?? '';
      _notesCtrl.text = v.notes ?? '';
      _fuelType = v.fuelType;
      _transmission = v.transmission;
      _status = v.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    widget.vehicle == null
                        ? AppLang.t('add') + ' ' + AppLang.t('vehicles')
                        : AppLang.t('edit') + ' ' + AppLang.t('vehicles'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
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
                    _section('Identification'),
                    Row(
                      children: [
                        Expanded(child: _field(AppLang.t('brand'), _brandCtrl, required: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(AppLang.t('model'), _modelCtrl, required: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _field(AppLang.t('version'), _versionCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(AppLang.t('year'), _yearCtrl, numeric: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _field(AppLang.t('stock_number'), _stockCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(AppLang.t('vin'), _vinCtrl)),
                      ],
                    ),
                    _field(AppLang.t('registration'), _regCtrl),
                    const SizedBox(height: 16),
                    _section('Caractéristiques'),
                    Row(
                      children: [
                        Expanded(child: _field(AppLang.t('color'), _colorCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(AppLang.t('mileage'), _mileageCtrl, numeric: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _dropdown(
                            AppLang.t('fuel_type'),
                            _fuelType,
                            AppConstants.fuelTypes
                                .map((e) => DropdownMenuItem(value: e, child: Text(AppLang.t(e))))
                                .toList(),
                            (v) => setState(() => _fuelType = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dropdown(
                            AppLang.t('transmission'),
                            _transmission,
                            AppConstants.transmissions
                                .map((e) => DropdownMenuItem(value: e, child: Text(AppLang.t(e))))
                                .toList(),
                            (v) => setState(() => _transmission = v),
                          ),
                        ),
                      ],
                    ),
                    _field(AppLang.t('engine'), _engineCtrl),
                    const SizedBox(height: 16),
                    _section('Prix & Achat'),
                    Row(
                      children: [
                        Expanded(child: _field(AppLang.t('purchase_price'), _purchasePriceCtrl, numeric: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(AppLang.t('sale_price'), _salePriceCtrl, numeric: true)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _field(AppLang.t('min_sale_price'), _minSalePriceCtrl, numeric: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(AppLang.t('purchase_date'), _purchaseDateCtrl, hint: 'AAAA-MM-JJ')),
                      ],
                    ),
                    _field(AppLang.t('supplier'), _supplierCtrl),
                    const SizedBox(height: 16),
                    _section(AppLang.t('status')),
                    _dropdown(
                      AppLang.t('status'),
                      _status,
                      AppConstants.vehicleStatuses
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(AppLang.t('status_$e') == 'status_$e'
                                  ? e
                                  : AppLang.t('status_$e'))))
                          .toList(),
                      (v) => setState(() => _status = v ?? 'available'),
                    ),
                    const SizedBox(height: 16),
                    _section(AppLang.t('notes')),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: AppLang.t('notes')),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
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

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 14)),
      );

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false, bool numeric = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
        ),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? AppLang.t('required_field') : null
            : null,
      ),
    );
  }

  Widget _dropdown(String label, String? value,
      List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      version: _versionCtrl.text.trim().isEmpty ? null : _versionCtrl.text.trim(),
      stockNumber: _stockCtrl.text.trim().isEmpty ? null : _stockCtrl.text.trim(),
      vin: _vinCtrl.text.trim().isEmpty ? null : _vinCtrl.text.trim(),
      registration: _regCtrl.text.trim().isEmpty ? null : _regCtrl.text.trim(),
      year: int.tryParse(_yearCtrl.text),
      mileage: int.tryParse(_mileageCtrl.text) ?? 0,
      color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
      engine: _engineCtrl.text.trim().isEmpty ? null : _engineCtrl.text.trim(),
      fuelType: _fuelType,
      transmission: _transmission,
      purchaseDate: _purchaseDateCtrl.text.trim().isEmpty ? null : _purchaseDateCtrl.text.trim(),
      purchasePrice: double.tryParse(_purchasePriceCtrl.text) ?? 0,
      salePrice: double.tryParse(_salePriceCtrl.text) ?? 0,
      minSalePrice: double.tryParse(_minSalePriceCtrl.text) ?? 0,
      supplier: _supplierCtrl.text.trim().isEmpty ? null : _supplierCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      status: _status,
    );

    try {
      if (widget.vehicle == null) {
        await VehicleService.addVehicle(vehicle);
      } else {
        await VehicleService.updateVehicle(vehicle);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLang.t('error_occurred'))),
        );
      }
    }
  }
}
