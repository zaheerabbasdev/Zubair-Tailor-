import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async => _db ??= await _initDb();

  Future<String> get databasePath async =>
      join(await getDatabasesPath(), 'zubair_tailors.db');

  Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) await db.close();
  }

  Future<Database> _initDb() async {
    final path = await databasePath;
    return openDatabase(
      path,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            unique_id  TEXT    NOT NULL UNIQUE,
            name       TEXT    NOT NULL,
            phone      TEXT    NOT NULL,
            address    TEXT,
            notes      TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_customers_phone ON customers(phone)');

        await db.execute('''
          CREATE TABLE measurements (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id     INTEGER NOT NULL,
            shirt_length    TEXT,
            shirt_width     TEXT,
            shoulder        TEXT,
            sleeve          TEXT,
            collar          TEXT,
            ban_type        TEXT,
            chest           TEXT,
            ghera           TEXT,
            pancha          TEXT,
            shalwar_length  TEXT,
            daman_type      TEXT,
            front_pocket    INTEGER NOT NULL DEFAULT 0,
            pocket_type     TEXT,
            sleeve_type     TEXT,
            cuff            INTEGER NOT NULL DEFAULT 0,
            shalwar_pocket  INTEGER NOT NULL DEFAULT 0,
            ring_button     INTEGER NOT NULL DEFAULT 0,
            double_silai    INTEGER NOT NULL DEFAULT 0,
            chamak_tar      INTEGER NOT NULL DEFAULT 0,
            sada_patti      INTEGER NOT NULL DEFAULT 0,
            design_button   INTEGER NOT NULL DEFAULT 0,
            notes           TEXT,
            created_at      TEXT NOT NULL,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('CREATE INDEX idx_measurements_customer_id ON measurements(customer_id)');

        await db.execute('''
          CREATE TABLE orders (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id     INTEGER NOT NULL,
            measurement_id  INTEGER NOT NULL,
            clothing_type   TEXT NOT NULL,
            price           REAL NOT NULL,
            amount_paid     REAL NOT NULL DEFAULT 0,
            priority        INTEGER NOT NULL DEFAULT 0,
            delivery_date   TEXT,
            status          TEXT NOT NULL DEFAULT 'Pending',
            notes           TEXT,
            image_url       TEXT,
            created_at      TEXT NOT NULL,
            FOREIGN KEY (customer_id)    REFERENCES customers(id)    ON DELETE CASCADE,
            FOREIGN KEY (measurement_id) REFERENCES measurements(id) ON DELETE RESTRICT
          )
        ''');
        await db.execute('CREATE INDEX idx_orders_customer_id ON orders(customer_id)');
        await db.execute('CREATE INDEX idx_orders_status ON orders(status)');

        await db.execute('''
          CREATE TABLE expenses (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            category      TEXT    NOT NULL,
            amount        REAL    NOT NULL,
            notes         TEXT,
            expense_date  TEXT    NOT NULL,
            created_at    TEXT    NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE orders ADD COLUMN amount_paid REAL NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE orders ADD COLUMN priority INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE customers ADD COLUMN notes TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE expenses (
              id            INTEGER PRIMARY KEY AUTOINCREMENT,
              category      TEXT    NOT NULL,
              amount        REAL    NOT NULL,
              notes         TEXT,
              expense_date  TEXT    NOT NULL,
              created_at    TEXT    NOT NULL
            )
          ''');
        }
      },
    );
  }
}
