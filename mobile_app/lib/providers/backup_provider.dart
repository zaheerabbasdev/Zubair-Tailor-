import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../services/backup_service.dart';

enum BackupOperation { none, signingIn, backingUp, listingBackups, restoring }

class BackupProvider extends ChangeNotifier {
  final BackupService _service = BackupService();

  bool isSignedIn = false;
  String? accountEmail;
  DateTime? lastBackupAt;
  BackupOperation operation = BackupOperation.none;
  String? errorMessage;

  bool get isBusy => operation != BackupOperation.none;

  Future<void> init() async {
    final account = await _service.signInSilently();
    isSignedIn = account != null;
    accountEmail = account?.email;
    lastBackupAt = await _service.lastBackupAt();
    notifyListeners();
  }

  Future<void> signIn() async {
    operation = BackupOperation.signingIn;
    errorMessage = null;
    notifyListeners();
    try {
      final account = await _service.signIn();
      isSignedIn = account != null;
      accountEmail = account?.email;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      operation = BackupOperation.none;
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
    operation = BackupOperation.backingUp;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.backupNow();
      lastBackupAt = await _service.lastBackupAt();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      operation = BackupOperation.none;
      notifyListeners();
    }
  }

  Future<List<drive.File>> listBackups() async {
    operation = BackupOperation.listingBackups;
    notifyListeners();
    try {
      return await _service.listBackups();
    } finally {
      operation = BackupOperation.none;
      notifyListeners();
    }
  }

  Future<void> restoreFrom(String fileId) async {
    operation = BackupOperation.restoring;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.restoreFrom(fileId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      operation = BackupOperation.none;
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
