import 'package:flutter/material.dart';
import '../../core/lang/app_lang.dart';
import '../../core/theme/colors.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) onLangChanged;
  const SettingsScreen({super.key, required this.onLangChanged});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLang = AppLang.lang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(AppLang.t('language')),
          Card(
            child: Column(
              children: [
                _langTile('fr', '🇫🇷  Français'),
                const Divider(height: 1, indent: 56),
                _langTile('ar', '🇩🇿  العربية'),
                const Divider(height: 1, indent: 56),
                _langTile('en', '🇬🇧  English'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _section('À propos'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.directions_car, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text('Showroom Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  const SizedBox(height: 8),
                  const Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary)),
                  const Text('Marché Algérien — Gestion de concessionnaire automobile',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 12),
                  const Divider(),
                  _infoRow('Base de données', 'SQLite locale'),
                  _infoRow('Langues', 'Français, Arabe, Anglais'),
                  _infoRow('Devise', 'Dinar Algérien (DA)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold,
        color: AppColors.primary, fontSize: 13)),
  );

  Widget _langTile(String code, String label) {
    final selected = _currentLang == code;
    return ListTile(
      leading: Text(label.split(' ').first, style: const TextStyle(fontSize: 22)),
      title: Text(label.substring(label.indexOf(' ') + 1)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () {
        setState(() => _currentLang = code);
        AppLang.setLang(code);
        widget.onLangChanged(code);
      },
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    ),
  );
}
