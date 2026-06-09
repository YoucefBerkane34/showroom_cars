import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/lang/app_lang.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const AppSidebar(
      {super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dashboard_rounded, 'dashboard'),
      (Icons.directions_car_rounded, 'vehicles'),
      (Icons.people_rounded, 'clients'),
      (Icons.receipt_long_rounded, 'sales'),
      (Icons.bookmark_rounded, 'reservations'),
      (Icons.attach_money_rounded, 'expenses'),
      (Icons.local_shipping_rounded, 'suppliers'),
      (Icons.settings_rounded, 'settings'),
    ];

    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_car,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text('Showroom\nManager',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3)),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final (icon, key) = items[i];
                final selected = selectedIndex == i;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onTap(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(color: Colors.white24)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(icon,
                                color: selected
                                    ? Colors.white
                                    : Colors.white60,
                                size: 20),
                            const SizedBox(width: 12),
                            Text(
                              AppLang.t(key),
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('v1.0.0 — Algeria Market',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
