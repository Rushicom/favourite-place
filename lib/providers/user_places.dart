import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:favourite_places/models/place.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath(); // get the path for database
  final db = await sql.openDatabase(
    // this is the open the database
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)'); // we create a table and also a column
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifire extends StateNotifier<List<Place>> {
  UserPlacesNotifire() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
   final places = data.map(
      (row) => Place(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(row['image'] as String),
        location: PlaceLocation(
            latitude: row['lat'] as double,
            longitude: row['lng'] as double,
            address: row['address'] as String),
      ),
    ).toList();
    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image
        .path); // this must becouse copy is required the string and targeted files
    final copiedImage = await image.copy('${appDir.path}/$fileName');
    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    final db = await _getDatabase();
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
    state = [
      newPlace,
      ...state
    ]; // ... spread oprator used for my old state element into this new list
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifire, List<Place>>(
  (ref) => UserPlacesNotifire(),
);
