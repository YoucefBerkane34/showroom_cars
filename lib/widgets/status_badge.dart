import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/lang/app_lang.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'available':
        return AppColors.available;
      case 'reserved':
        return AppColors.reserved;
      case 'sold':
        return AppColors.sold;
      case 'preparation':
        return AppColors.preparation;
      case 'active':
        return AppColors.available;
      case 'expired':
        return Colors.red;
      case 'converted':
        return AppColors.sold;
      case 'draft':
        return Colors.grey;
      case 'confirmed':
        return AppColors.reserved;
      case 'completed':
        return AppColors.available;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (status) {
      case 'available': return AppLang.t('status_available');
      case 'reserved': return AppLang.t('status_reserved');
      case 'sold': return AppLang.t('status_sold');
      case 'preparation': return AppLang.t('status_preparation');
      case 'active': return AppLang.t('active');
      case 'expired': return AppLang.t('expired');
      case 'converted': return AppLang.t('converted');
      case 'draft': return AppLang.t('draft');
      case 'confirmed': return AppLang.t('confirmed');
      case 'completed': return AppLang.t('completed');
      case 'cancelled': return AppLang.t('cancelled');
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
            color: _color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
