import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/lang/app_lang.dart';
import '../../core/theme/colors.dart';
import '../../services/vehicle_service.dart';
import '../../services/client_service.dart';
import '../../services/sale_service.dart';
import '../../services/expense_service.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  Map<String, int> _vehicleCounts = {};
  int _totalVehicles = 0;
  int _totalClients = 0;
  Map<String, double> _monthlyStats = {};
  double _totalRevenue = 0;
  double _totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        VehicleService.getStatusCounts(),
        VehicleService.getTotalCount(),
        ClientService.getTotalCount(),
        SaleService.getMonthlyStats(),
        SaleService.getTotalRevenue(),
        ExpenseService.getTotalExpenses(),
      ]);
      setState(() {
        _vehicleCounts = results[0] as Map<String, int>;
        _totalVehicles = results[1] as int;
        _totalClients = results[2] as int;
        _monthlyStats = results[3] as Map<String, double>;
        _totalRevenue = results[4] as double;
        _totalExpenses = results[5] as double;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _fmt(double v) {
    final f = NumberFormat('#,###', 'fr_FR');
    return '${f.format(v)} ${AppLang.t('currency')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profit = _totalRevenue - _totalExpenses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLang.t('dashboard')),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Actualiser'),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Inventory
              _sectionTitle(AppLang.t('vehicles')),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: _cols(context),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: AppLang.t('total_vehicles'),
                    value: '$_totalVehicles',
                    icon: Icons.directions_car_rounded,
                    color: AppColors.primary,
                  ),
                  StatCard(
                    title: AppLang.t('available'),
                    value: '${_vehicleCounts['available'] ?? 0}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.available,
                  ),
                  StatCard(
                    title: AppLang.t('reserved'),
                    value: '${_vehicleCounts['reserved'] ?? 0}',
                    icon: Icons.bookmark_rounded,
                    color: AppColors.reserved,
                  ),
                  StatCard(
                    title: AppLang.t('sold'),
                    value: '${_vehicleCounts['sold'] ?? 0}',
                    icon: Icons.done_all_rounded,
                    color: AppColors.sold,
                  ),
                  StatCard(
                    title: AppLang.t('in_preparation'),
                    value: '${_vehicleCounts['preparation'] ?? 0}',
                    icon: Icons.build_rounded,
                    color: AppColors.preparation,
                  ),
                  StatCard(
                    title: AppLang.t('clients'),
                    value: '$_totalClients',
                    icon: Icons.people_rounded,
                    color: const Color(0xFF00796B),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section: Finances
              _sectionTitle(AppLang.t('sales') + ' & Finances'),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: _cols(context),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: AppLang.t('monthly_sales'),
                    value: '${(_monthlyStats['count'] ?? 0).toInt()}',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.primary,
                    subtitle: 'Ce mois',
                  ),
                  StatCard(
                    title: AppLang.t('monthly_revenue'),
                    value: _fmt(_monthlyStats['revenue'] ?? 0),
                    icon: Icons.account_balance_rounded,
                    color: AppColors.available,
                    subtitle: 'Ce mois',
                  ),
                  StatCard(
                    title: AppLang.t('total_revenue'),
                    value: _fmt(_totalRevenue),
                    icon: Icons.monetization_on_rounded,
                    color: const Color(0xFF1565C0),
                  ),
                  StatCard(
                    title: AppLang.t('expenses'),
                    value: _fmt(_totalExpenses),
                    icon: Icons.receipt_rounded,
                    color: AppColors.reserved,
                  ),
                  StatCard(
                    title: AppLang.t('total_profit'),
                    value: _fmt(profit),
                    icon: Icons.emoji_events_rounded,
                    color: profit >= 0 ? AppColors.available : Colors.red,
                  ),
                  StatCard(
                    title: 'Reste à encaisser',
                    value: _fmt(_monthlyStats['pending'] ?? 0),
                    icon: Icons.pending_actions_rounded,
                    color: Colors.orange,
                    subtitle: 'Ce mois',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _cols(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1000) return 4;
    if (w > 700) return 3;
    return 2;
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary),
      );
}
