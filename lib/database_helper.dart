import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'card_organizer.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Folders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        await db.execute('''
          CREATE TABLE Cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            suit TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            folderId INTEGER,
            FOREIGN KEY (folderId) REFERENCES Folders(id)
          )
        ''');
        await _prepopulateFolders(db);
        await _prepopulateCards(db);
      },
    );
  }

  Future<void> _prepopulateFolders(Database db) async {
    List<Map<String, dynamic>> folders = [
      {'name': 'Hearts'},
      {'name': 'Spades'},
      {'name': 'Diamonds'},
      {'name': 'Clubs'},
    ];
    for (var folder in folders) {
      await db.insert('Folders', folder);
    }
  }

  Future<void> _prepopulateCards(Database db) async {
    List<Map<String, dynamic>> cards = [
      {'name': 'Ace of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://example.com/ace_of_hearts.png', 'folderId': 1},
      {'name': '2 of Hearts', 'suit': 'Hearts', 'imageUrl': 'https://example.com/2_of_hearts.png', 'folderId': 1},
      // Add more cards here
    ];
    for (var card in cards) {
      await db.insert('Cards', card);
    }
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await database;
    return await db.query('Folders');
  }

  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    final db = await database;
    return await db.query('Cards', where: 'folderId = ?', whereArgs: [folderId]);
  }

  Future<void> addFolder(String name) async {
    final db = await database;
    await db.insert('Folders', {'name': name});
  }

  Future<void> addCard(String name, String suit, String imageUrl, int folderId) async {
    final db = await database;
    await db.insert('Cards', {'name': name, 'suit': suit, 'imageUrl': imageUrl, 'folderId': folderId});
  }

  Future<void> deleteFolder(int id) async {
    final db = await database;
    await db.delete('Folders', where: 'id = ?', whereArgs: [id]);
    await db.delete('Cards', where: 'folderId = ?', whereArgs: [id]);
  }

  Future<void> deleteCard(int id) async {
    final db = await database;
    await db.delete('Cards', where: 'id = ?', whereArgs: [id]);
  }
}
