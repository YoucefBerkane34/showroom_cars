import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static Future<void> createBackup() async {
    final dir = await getApplicationDocumentsDirectory();

    final dbPath = "${dir.path}/showroom.db";
    final backupPath = "${dir.path}/backup_showroom.db";

    final file = File(dbPath);

    if (await file.exists()) {
      await file.copy(backupPath);
    }
  }

  static Future<void> restoreBackup() async {
    final dir = await getApplicationDocumentsDirectory();

    final dbPath = "${dir.path}/showroom.db";
    final backupPath = "${dir.path}/backup_showroom.db";

    final backup = File(backupPath);

    if (await backup.exists()) {
      await backup.copy(dbPath);
    }
  }
}
