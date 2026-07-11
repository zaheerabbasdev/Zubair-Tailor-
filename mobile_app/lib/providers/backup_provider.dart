import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../services/backup_service.dart';

class BackupProvider extends ChangeNotifier {
  final BackupService _service = BackupService();

  bool isSignedIn = false;
  String? accountEmail;
  DateTime? lastBackupAt;
  bool isBusy = false;
  String? errorMessage;

  Future<void> init() async {
    final account = await _service.signInSilently();
    isSignedIn = account != null;
    accountEmail = account?.email;
    lastBackupAt = await _service.lastBackupAt();
    notifyListeners();
  }

  Future<void> signIn() async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      final account = await _service.signIn();
      isSignedIn = account != null;
      accountEmail = account?.email;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    isSignedIn = false;
    accountEmail = null;
    notifyListeners();
  }

  Future<void> backupNow() async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.backupNow();
      lastBackupAt = await _service.lastBackupAt();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<List<drive.File>> listBackups() => _service.listBackups();

  Future<void> restoreFrom(String fileId) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.restoreFrom(fileId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  /// Backs up on every app open (while signed in), keeping Drive in sync
  /// with whatever local changes have been made since the app was last used.
  Future<void> autoBackupOnOpen() async {
    if (isBusy) return;

    final account = await _service.signInSilently();
    if (account == null) return;

    await backupNow();
  }

  /// Fire-and-forget backup triggered right after a customer/measurement/order
  /// is created, updated, or deleted, so Drive stays in sync with in-app
  /// changes as they happen rather than only when the app is reopened.
  /// Silent by design: a transient network hiccup here shouldn't interrupt
  /// the user's current action with an error dialog.
  void syncInBackground() {
    if (isBusy || !isSignedIn) return;
    backupNow();
  }
}
