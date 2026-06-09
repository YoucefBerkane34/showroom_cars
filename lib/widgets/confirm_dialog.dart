import 'package:flutter/material.dart';
import '../core/lang/app_lang.dart';

Future<bool> showConfirmDialog(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppLang.t('confirm')),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLang.t('cancel'))),
        ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLang.t('confirm'))),
      ],
    ),
  );
  return result ?? false;
}
