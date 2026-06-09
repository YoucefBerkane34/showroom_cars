import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/lang/app_lang.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/expense.dart';
import '../../models/vehicle.dart';
import '../../services/expense_service.dart';
import '../../services/vehicle_service.dart';
import '../../widgets/confirm_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Expense> _expenses = [];
  bool _loading = true;
  double _total = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    _expenses = await ExpenseService.getExpenses();
    _total = await ExpenseService.getTotalExpenses();
    setState(() => _loading = false);
  }

  String _fmt(double v) => '${NumberFormat('#,###', 'fr_FR').format(v)} DA';

  Color _typeColor(String type) {
    switch (type) {
      case 'repairs': return Colors.red;
      case 'maintenance': return Colors.orange;
      case 'transportation': return Colors.blue;
      case 'cleaning': return Colors.teal;
      case 'registration_fees': return Colors.purple;
      case 'advertising': return Colors.pink;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.t('expenses')),
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
          // Total summary
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total des dépenses',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(_fmt(_total),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                ]),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                    ? Center(child: Text(AppLang.t('no_data'),
                        style: const TextStyle(color: AppColors.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _expenses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (_, i) => _expenseCard(_expenses[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _expenseCard(Expense e) {
    final color = _typeColor(e.expenseType);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long, color: color, size: 22),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(AppLang.t(e.expenseType),
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            Text(_fmt(e.amount),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (e.vehicleDisplay != null)
            Text('🚗 ${e.vehicleDisplay}', style: const TextStyle(fontSize: 12)),
          if (e.description != null)
            Text(e.description!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(e.expenseDate, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _openForm(e)),
          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () => _delete(e)),
        ]),
      ),
    );
  }

  void _openForm(Expense? expense) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseFormSheet(expense: expense),
    );
    if (saved == true) _load();
  }

  void _delete(Expense e) async {
    final ok = await showConfirmDialog(context, 'Supprimer cette dépense ?');
    if (ok) { await ExpenseService.deleteExpense(e.id!); _load(); }
  }
}

// =========== FORM ===========
class ExpenseFormSheet extends StatefulWidget {
  final Expense? expense;
  const ExpenseFormSheet({super.key, this.expense});
  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  List<Vehicle> _vehicles = [];

  int? _vehicleId;
  String _expenseType = 'miscellaneous';
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    final e = widget.expense;
    if (e != null) {
      _vehicleId = e.vehicleId;
      _expenseType = e.expenseType;
      _amountCtrl.text = e.amount.toString();
      _descCtrl.text = e.description ?? '';
      _date = e.expenseDate;
    }
  }

  void _loadVehicles() async {
    final list = await VehicleService.getVehicles();
    setState(() => _vehicles = list);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
                  Text(widget.expense == null ? 'Nouvelle Dépense' : 'Modifier Dépense',
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
                    DropdownButtonFormField<String>(
                      value: _expenseType,
                      decoration: InputDecoration(labelText: AppLang.t('expense_type')),
                      items: AppConstants.expenseTypes.map((t) =>
                          DropdownMenuItem(value: t, child: Text(AppLang.t(t)))).toList(),
                      onChanged: (v) => setState(() => _expenseType = v ?? 'miscellaneous'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: '${AppLang.t('amount')} (DA) *'),
                      validator: (v) => (v == null || v.isEmpty) ? AppLang.t('required_field') : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: _date),
                      decoration: InputDecoration(
                          labelText: 'Date *', suffixIcon: const Icon(Icons.calendar_today)),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(_date) ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _date = DateFormat('yyyy-MM-dd').format(d));
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _vehicleId,
                      decoration: InputDecoration(labelText: 'Véhicule lié (optionnel)'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Aucun')),
                        ..._vehicles.map((v) => DropdownMenuItem(
                            value: v.id,
                            child: Text(v.displayName, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) => setState(() => _vehicleId = v),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: AppLang.t('description')),
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
    setState(() => _saving = true);
    final e = Expense(
      id: widget.expense?.id,
      vehicleId: _vehicleId,
      expenseType: _expenseType,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      expenseDate: _date,
    );
    try {
      if (widget.expense == null) {
        await ExpenseService.addExpense(e);
      } else {
        await ExpenseService.updateExpense(e);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLang.t('error_occurred'))));
    }
  }
}
