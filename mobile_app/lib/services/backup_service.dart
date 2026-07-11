import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';

class BackupService {
  static const _kFolderIdKey = 'drive_backup_folder_id';
  static const _kLastBackupAtKey = 'last_backup_at';
  static const _folderName = 'Zubair Tailors Backups';
  static const _retentionCount = 10;
  static const _folderMimeType = 'application/vnd.google-apps.folder';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  bool get isSignedIn => _googleSignIn.currentUser != null;

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signInSilently() => _googleSignIn.signInSilently();

  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  Future<void> signOut() => _googleSignIn.signOut();

  Future<DateTime?> lastBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_kLastBackupAtKey);
    return iso == null ? null : DateTime.tryParse(iso);
  }

  Future<void> _setLastBackupAt(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastBackupAtKey, time.toIso8601String());
  }

  Future<void> backupNow() async {
    final api = await _driveApi();
    final snapshot = await _snapshotDatabase();
    try {
      final folderId = await _getOrCreateFolderId(api);
      final name = 'backup_${_timestamp()}.db';
      final length = await snapshot.length();
      await api.files.create(
        drive.File()
          ..name = name
          ..parents = [folderId],
        uploadMedia: drive.Media(snapshot.openRead(), length),
      );
      await _setLastBackupAt(DateTime.now());
      await _enforceRetention(api, folderId);
    } finally {
      if (await snapshot.exists()) await snapshot.delete();
    }
  }

  Future<List<drive.File>> listBackups() async {
    final api = await _driveApi();
    final folderId = await _getOrCreateFolderId(api);
    final result = await api.files.list(
      q: "'$folderId' in parents and trashed = false",
      orderBy: 'createdTime desc',
      $fields: 'files(id, name, createdTime)',
    );
    return result.files ?? [];
  }

  Future<void> restoreFrom(String fileId) async {
    final api = await _driveApi();
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final tempDir = await getTemporaryDirectory();
    final tempPath = join(tempDir.path, 'restore_download.db');
    final tempFile = File(tempPath);
    final sink = tempFile.openWrite();
    await media.stream.pipe(sink);
    await sink.close();

    await DatabaseHelper.instance.close();
    final livePath = await DatabaseHelper.instance.databasePath;
    for (final suffix in ['-wal', '-shm']) {
      final sideFile = File('$livePath$suffix');
      if (await sideFile.exists()) await sideFile.delete();
    }
    await tempFile.copy(livePath);
    await tempFile.delete();
  }

  Future<drive.DriveApi> _driveApi() async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (account == null) {
      throw StateError('Not signed in to Google');
    }
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw StateError('Failed to obtain an authenticated Google client');
    }
    return drive.DriveApi(client);
  }

  Future<File> _snapshotDatabase() async {
    final db = await DatabaseHelper.instance.database;
    final tempDir = await getTemporaryDirectory();
    final tempPath = join(tempDir.path, 'backup_snapshot.db');
    final tempFile = File(tempPath);
    if (await tempFile.exists()) await tempFile.delete();
    await db.execute("VACUUM INTO '$tempPath'");
    return tempFile;
  }

  Future<String> _getOrCreateFolderId(drive.DriveApi api) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedId = prefs.getString(_kFolderIdKey);

    if (cachedId != null) {
      try {
        final file = await api.files.get(cachedId, $fields: 'id, trashed') as drive.File;
        if (file.trashed != true) return cachedId;
      } catch (_) {
        // Cached folder no longer exists or is inaccessible; fall through and re-resolve.
      }
    }

    final search = await api.files.list(
      q: "mimeType = '$_folderMimeType' and name = '$_folderName' and trashed = false",
      $fields: 'files(id, name)',
    );
    final existing = search.files;
    if (existing != null && existing.isNotEmpty) {
      final id = existing.first.id!;
      await prefs.setString(_kFolderIdKey, id);
      return id;
    }

    final created = await api.files.create(
      drive.File()
        ..name = _folderName
        ..mimeType = _folderMimeType,
    );
    final id = created.id!;
    await prefs.setString(_kFolderIdKey, id);
    return id;
  }

  Future<void> _enforceRetention(drive.DriveApi api, String folderId) async {
    final result = await api.files.list(
      q: "'$folderId' in parents and trashed = false",
      orderBy: 'createdTime desc',
      $fields: 'files(id, name, createdTime)',
    );
    final files = result.files ?? [];
    if (files.length <= _retentionCount) return;
    for (final file in files.skip(_retentionCount)) {
      if (file.id != null) {
        await api.files.delete(file.id!);
      }
    }
  }

  String _timestamp() {
    final now = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${pad(now.month)}-${pad(now.day)}T'
        '${pad(now.hour)}-${pad(now.minute)}-${pad(now.second)}';
  }
}
