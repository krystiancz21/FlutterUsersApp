import 'package:path/path.dart' as Path;
import '../models/person_model.dart';
import 'package:sqflite/sqflite.dart';

class PersonDatabase {
  static const dbVersion = 1;
  static const dbFileName = 'person_database.db';
  static const personTableName = 'person';
  static const idColumn = 'id';
  static const nameAndSurnameColumn = 'nameAndSurname';
  static const cityColumn = 'city';
  static const phoneNumberColumn = 'phoneNumber';
  static const imageUrlColumn = 'imageUrl';
  static const imageBytesColumn = 'imageBytes';
  static get createDbSql => 'CREATE TABLE IF NOT EXISTS $personTableName'
      '($idColumn INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      '$nameAndSurnameColumn TEXT,'
      '$cityColumn TEXT,'
      '$phoneNumberColumn TEXT,'
      '$imageUrlColumn TEXT,'
      '$imageBytesColumn BLOB)';

  static Future<Database> openPersonDatabase() async {
    return openDatabase(
      Path.join(await getDatabasesPath(), dbFileName),
      onCreate: (db, version) {
        return db.execute(createDbSql);
      },
      version: dbVersion,
    );
  }

  static Future<int> insertPerson(Person person) async {
    final personDatabase = await openPersonDatabase();
    final newItemId = await personDatabase.insert(
      personTableName,
      person.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return newItemId;
  }

  static Future<int> updatePerson(Person person) async {
    final personDatabase = await openPersonDatabase();
    final updatedItem = await personDatabase.update(
      personTableName,
      person.toJsonId(),
      where: '$idColumn = ?',
      whereArgs: [person.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return updatedItem;
  }

  static Future<void> deletePerson(Person person) async {
    final personDatabase = await openPersonDatabase();
    await personDatabase.delete(
      personTableName,
      where: '$idColumn = ?',
      whereArgs: [person.id],
    );
  }

  static Future<List<Person>> getPersons() async {
    final personDatabase = await openPersonDatabase();
    final List<Map<String, dynamic>> personMapList =
      await personDatabase.query(personTableName);

    if (personMapList.isNotEmpty) {
      // return List.generate(personMapList.length, (index) => Person.fromDb(personMapList[index]));
      return List.generate(personMapList.length, (index) => Person.fromJson(personMapList[index]));
    }

    return [];
  }

  static Future<List<Person>> getPersonsFromDb() async {
    final personDatabase = await openPersonDatabase();
    final List<Map<String, dynamic>> personMapList =
    await personDatabase.query(personTableName);

    if (personMapList.isNotEmpty) {
      return List.generate(personMapList.length, (index) => Person.fromDb(personMapList[index]));
    }

    return [];
  }

  static Future<void> clearDatabase() async {
    final database = await openPersonDatabase();
    await database.delete(personTableName);
  }

}
