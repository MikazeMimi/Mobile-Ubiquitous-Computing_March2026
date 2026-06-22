//=====1. Import Packages=========================================================
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//=====2. Database connection sessions============================================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campuspulse.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //=====3. Functions to create Tables inside DB====================================
  Future _createDB(Database db, int version) async {
    //-----create table user--------------------------------------------------------
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        studentId TEXT UNIQUE NOT NULL CHECK(length(studentId) = 11),
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'User',
        status TEXT NOT NULL DEFAULT 'Valid',
        phone TEXT,
        course TEXT,
        semester TEXT
      )
    ''');

    //-----Create table booking--------------------------------------------------------
    await db.execute('''
      CREATE TABLE booking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        date TEXT,
        time TEXT,
        place TEXT,
        status TEXT NOT NULL DEFAULT 'Pending',
        FOREIGN KEY (userId) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');

    //-----Insert default admin---------------------------------------------------------
    await db.insert('user', {
      'username': 'admin',
      'studentId': '52224224168', // ✅ valid 11-digit ID
      'email': 'admin@example.com',
      'password': '12345',
      'role': 'Admin',
      'status': 'Valid',
      'phone': '',
      'course': '',
      'semester': ''
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  //=====4. USER FUNCTIONS========================================================================
  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('user', row);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('user');
  }

  Future<int> updateUserRole(int id, String role) async {
    final db = await instance.database;
    return await db.update('user', {'role': role}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update('user', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserProfile(int id, Map<String, dynamic> fields) async {
    final db = await instance.database;
    return await db.update('user', fields, where: 'id = ?', whereArgs: [id]);
  }

  //=====5. BOOKING FUNCTIONS=====================================================================
  Future<int> insertBooking(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('booking', row);
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final db = await instance.database;
    return await db.query('booking', orderBy: 'id DESC');
  }

  Future<int> updateBookingStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update('booking', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBooking(int id) async {
    final db = await instance.database;
    return await db.delete('booking', where: 'id = ?', whereArgs: [id]);
  }
}