import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/parque.dart';

class ParqueDatabase {
  Database? _database;

  //temos de criar a bd e concetar-nos a ela por isso tem de ser async
  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'emelParque.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE parque( '
          'id TEXT PRIMARY KEY, '
          'nome TEXT NULL, '
          'lotacao_real INT NULL, '
          'lotacao_max INT NULL, '
          'data TEXT NOT NULL, '
          'distancia INT NULL, '
          'latitude TEXT NULL, '
          'longitude TEXT NULL, '
          'tipo_parque TEXT NULL, '
          'estado_parque TEXT NULL '
          ')',
        );
      },
      version: 1,
    );
  }

  Future<List<Parque>> getParques() async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    List result = await _database!.rawQuery("SELECT * FROM parque");

    return result.map((e) => Parque.fromDB(e)).toList();
  }

  Future<Parque> getParque(String id) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    List result = await _database!.rawQuery("SELECT * FROM parque WHERE id = ?", [id]);

    if(result.isNotEmpty) {
      return Parque.fromDB(result.first);
    } else {
      throw Exception('Inexistent parque with id: $id');
    }
  }

  Future<void> insert(Parque parque) async {
    if (_database == null) {
      throw Exception('Forgot to initialize the database');
    }

    await _database!.insert('parque', parque.toDb());
  }
}
