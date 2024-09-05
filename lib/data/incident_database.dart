import 'package:app_emel_cm/models/incidente.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class IncidentDatabase {
  Database? _database;

  //temos de criar a bd e concetar-nos a ela por isso tem de ser async
  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'emelIncidente.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE incident( '
          'id TEXT PRIMARY KEY, '
          'parque TEXT NOT NULL, '
          'data TEXT NOT NULL, '
          'gravidade INT NOT NULL, '
          'descricao TEXT NULL '
          ')',
        );
      },
      version: 1,
    );
  }

  Future<List<Incidente>> getIncidentes() async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    List result = await _database!.rawQuery("SELECT * FROM incident");

    return result.map((e) => Incidente.fromDB(e)).toList();
  }

  Future<List<Incidente>> getIncidentesByParque(String parque) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    List result = await _database!.rawQuery("SELECT * FROM incident WHERE parque = '$parque'");

    return result.map((e) => Incidente.fromDB(e)).toList();
  }

  Future<void> insert(Incidente incidente) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    await _database!.insert('incident', incidente.toDb());
  }
}
