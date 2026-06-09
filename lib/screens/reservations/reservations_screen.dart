import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/lang/app_lang.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/reservation.dart';
import '../../models/vehicle.dart';
import '../../models/client.dart';
import '../../services/reservation_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/client_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});
  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _loading = true;
  String _statusFilter = 'all';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    _reservations = await ReservationService.getReservations(
        status: _statusFilter == 'all' ? null : _statusFilter);
    setState(() => _loading = false);
  }

  String _fmtPrice(double v) => '${NumberFormat('#,###', 'fr_FR').format(v)} DA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.t('reservations')),
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _chip('all', AppLang.t('all')),
                ...(AppConstants.reservationStatuses.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _chip(s, AppLang.t(s)),
                ))),
              ]),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _reservations.isEmpty
                    ? Center(child: Text(AppLang.t('no_data'),
                        style: const TextStyle(color: AppColors.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _reservations.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (_, i) => _reservCard(_reservations[i]),
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
    );
  }

  Widget _reservCard(Reservation r) {
    final expired = r.isExpired && r.status == 'active';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.bookmark, color: AppColors.reserved, size: 20),
              const SizedBox(width: 8),
              Text('Réservation #${r.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              if (expired)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('EXPIRÉE', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              StatusBadge(status: r.status),
            ]),
            const Divider(height: 16),
            _row(Icons.directions_car, r.vehicleDisplay ?? '—'),
            const SizedBox(height: 4),
            _row(Icons.person, r.clientDisplay ?? '—'),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: _row(Icons.calendar_today, 'Réservé: ${r.reservationDate}')),
              if (r.expiryDate != null)
                Expanded(child: _row(Icons.event_busy, 'Expire: ${r.expiryDate}')),
            ]),
            if (r.deposit > 0) ...[
              const SizedBox(height: 4),
              _row(Icons.payments, 'Acompte: ${_fmtPrice(r.deposit)}'),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (r.status == 'active') ...[
                  TextButton.icon(
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: const Text('→ Vente', style: TextStyle(fontSize: 12)),
                    onPressed: () => _convertToSale(r),
                  ),
                  const SizedBox(width: 4),
                ],
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(AppLang.t('edit')),
                  onPressed: () => _openForm(r),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: Text(AppLang.t('delete'), style: const TextStyle(color: Colors.red)),
                  onPressed: () => _delete(r),
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

  void _convertToSale(Reservation r) async {
    final ok = await showConfirmDialog(context,
        'Convertir cette réservation en vente ?');
    if (ok) {
      await ReservationService.updateStatus(r.id!, 'converted');
      await VehicleService.updateStatus(r.vehicleId, 'available');
      _load();
    }
  }

  void _openForm(Reservation? r) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationFormSheet(reservation: r),
    );
    if (saved == true) _load();
  }

  void _delete(Reservation r) async {
    final ok = await showConfirmDialog(context, 'Supprimer cette réservation ?');
    if (ok) {
      await ReservationService.deleteReservation(r.id!);
      await VehicleService.updateStatus(r.vehicleId, 'available');
      _load();
    }
  }
}

// =========== FORM ===========
class ReservationFormSheet extends StatefulWidget {
  final Reservation? reservation;
  const ReservationFormSheet({super.key, this.reservation});
  @override
  State<ReservationFormSheet> createState() => _ReservationFormSheetState();
}

class _ReservationFormSheetState extends State<ReservationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  List<Vehicle> _vehicles = [];
  List<Client> _clients = [];

  int? _vehicleId;
  int? _clientId;
  final _depositCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _status = 'active';
  String _reservDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? _expiryDate;

  @override
  void initState() {
    super.initState();
    _loadDropdowns();
    final r = widget.reservation;
    if (r != null) {
      _vehicleId = r.vehicleId;
      _clientId = r.clientId;
      _depositCtrl.text = r.deposit.toString();
      _notesCtrl.text = r.notes ?? '';
      _status = r.status;
      _reservDate = r.reservationDate;
      _expiryDate = r.expiryDate;
    }
  }

  void _loadDropdowns() async {
    final vList = await VehicleService.getVehicles(status: 'available');
    final cList = await ClientService.getClients();
    if (widget.reservation != null && _vehicleId != null) {
      final exists = vList.any((v) => v.id == _vehicleId);
      if (!exists) {
        final current = await VehicleService.getVehicle(_vehicleId!);
        if (current != null) vList.insert(0, current);
      }
    }
    setState(() { _vehicles = vList; _clients = cList; });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
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
                  Text(widget.reservation == null ? 'Nouvelle Réservation' : 'Modifier Réservation',
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
                    DropdownButtonFormField<int>(
                      value: _vehicleId,
                      decoration: InputDecoration(labelText: '${AppLang.t('select_vehicle')} *'),
                      items: _vehicles.map((v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(v.displayName, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _vehicleId = v),
                      validator: (v) => v == null ? AppLang.t('required_field') : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _clientId,
                      decoration: InputDecoration(labelText: '${AppLang.t('select_client')} *'),
                      items: _clients.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.fullName, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _clientId = v),
                      validator: (v) => v == null ? AppLang.t('required_field') : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _datePicker('Date réservation', _reservDate,
                          (d) => setState(() => _reservDate = d))),
                      const SizedBox(width: 12),
                      Expanded(child: _datePicker("Date d'expiration", _expiryDate ?? '',
                          (d) => setState(() => _expiryDate = d))),
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _depositCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: '${AppLang.t('deposit')} (DA)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(labelText: AppLang.t('reservation_status')),
                      items: AppConstants.reservationStatuses.map((s) =>
                          DropdownMenuItem(value: s, child: Text(AppLang.t(s)))).toList(),
                      onChanged: (v) => setState(() => _status = v ?? 'active'),
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

  Widget _datePicker(String label, String value, Function(String) onChanged) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
          labelText: label, suffixIcon: const Icon(Icons.calendar_today)),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(value) ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (d != null) onChanged(DateFormat('yyyy-MM-dd').format(d));
      },
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final r = Reservation(
      id: widget.reservation?.id,
      vehicleId: _vehicleId!,
      clientId: _clientId!,
      reservationDate: _reservDate,
      expiryDate: _expiryDate,
      deposit: double.tryParse(_depositCtrl.text) ?? 0,
      status: _status,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    try {
      if (widget.reservation == null) {
        await ReservationService.addReservation(r);
        await VehicleService.updateStatus(_vehicleId!, 'reserved');
      } else {
        await ReservationService.updateReservation(r);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLang.t('error_occurred'))));
    }
  }
}
