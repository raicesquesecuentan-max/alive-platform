import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class OfflineDatabase {
  static const String _dbName = 'alive_voice.db';
  static const int _dbVersion = 1;
  static Database? _database;
  final Logger _logger = Logger();

  // Nombres de tablas
  static const String tableVoiceQueries = 'voice_queries';
  static const String tableAudioGuides = 'audio_guides';
  static const String tableLocations = 'locations';
  static const String tableSyncQueue = 'sync_queue';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _dbName);
      _logger.i('Inicializando base de datos en: $path');

      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      _logger.e('Error inicializando base de datos: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Tabla de consultas de voz
      await db.execute('''
        CREATE TABLE $tableVoiceQueries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL,
          response TEXT NOT NULL,
          language TEXT DEFAULT 'es',
          timestamp INTEGER NOT NULL,
          isSynced INTEGER DEFAULT 0
        )
      ''');

      // Tabla de audioguías offline
      await db.execute('''
        CREATE TABLE $tableAudioGuides (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          audioPath TEXT NOT NULL,
          language TEXT DEFAULT 'es',
          duration INTEGER,
          downloaded INTEGER DEFAULT 0,
          fileSize INTEGER
        )
      ''');

      // Tabla de ubicaciones
      await db.execute('''
        CREATE TABLE $tableLocations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          latitude REAL,
          longitude REAL,
          description TEXT,
          audioGuideId INTEGER,
          visited INTEGER DEFAULT 0,
          visitedAt INTEGER,
          FOREIGN KEY (audioGuideId) REFERENCES $tableAudioGuides (id)
        )
      ''');

      // Tabla de cola de sincronización
      await db.execute('''
        CREATE TABLE $tableSyncQueue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          operation TEXT NOT NULL,
          tableName TEXT NOT NULL,
          data TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          synced INTEGER DEFAULT 0
        )
      ''');

      _logger.i('Tablas creadas exitosamente');
    } catch (e) {
      _logger.e('Error creando tablas: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('Actualizando base de datos de v$oldVersion a v$newVersion');
  }

  // ===== OPERACIONES DE CONSULTAS DE VOZ =====
  Future<int> insertVoiceQuery({
    required String query,
    required String response,
    required String language,
  }) async {
    try {
      Database db = await database;
      int id = await db.insert(
        tableVoiceQueries,
        {
          'query': query,
          'response': response,
          'language': language,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isSynced': 0,
        },
      );
      _logger.i('Consulta de voz guardada: $id');
      
      // Agregar a cola de sincronización
      await _addToSyncQueue('INSERT', tableVoiceQueries, {'id': id});
      
      return id;
    } catch (e) {
      _logger.e('Error insertando consulta de voz: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getVoiceQueries({
    int limit = 50,
    String? language,
  }) async {
    try {
      Database db = await database;
      String query = 'SELECT * FROM $tableVoiceQueries ORDER BY timestamp DESC LIMIT $limit';
      
      List<Map<String, dynamic>> result;
      if (language != null) {
        result = await db.query(
          tableVoiceQueries,
          where: 'language = ?',
          whereArgs: [language],
          orderBy: 'timestamp DESC',
          limit: limit,
        );
      } else {
        result = await db.rawQuery(query);
      }
      
      return result;
    } catch (e) {
      _logger.e('Error obteniendo consultas de voz: $e');
      return [];
    }
  }

  // ===== OPERACIONES DE AUDIOGUÍAS =====
  Future<int> insertAudioGuide({
    required String title,
    required String audioPath,
    required String language,
    String? description,
    int? duration,
    int? fileSize,
  }) async {
    try {
      Database db = await database;
      int id = await db.insert(
        tableAudioGuides,
        {
          'title': title,
          'description': description,
          'audioPath': audioPath,
          'language': language,
          'duration': duration,
          'fileSize': fileSize,
          'downloaded': 1,
        },
      );
      _logger.i('Audioguía guardada: $id');
      
      await _addToSyncQueue('INSERT', tableAudioGuides, {'id': id});
      
      return id;
    } catch (e) {
      _logger.e('Error insertando audioguía: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDownloadedAudioGuides({
    String? language,
  }) async {
    try {
      Database db = await database;
      
      List<Map<String, dynamic>> result;
      if (language != null) {
        result = await db.query(
          tableAudioGuides,
          where: 'downloaded = 1 AND language = ?',
          whereArgs: [language],
        );
      } else {
        result = await db.query(
          tableAudioGuides,
          where: 'downloaded = 1',
        );
      }
      
      return result;
    } catch (e) {
      _logger.e('Error obteniendo audioguías descargadas: $e');
      return [];
    }
  }

  // ===== OPERACIONES DE UBICACIONES =====
  Future<int> insertLocation({
    required String name,
    double? latitude,
    double? longitude,
    String? description,
    int? audioGuideId,
  }) async {
    try {
      Database db = await database;
      int id = await db.insert(
        tableLocations,
        {
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
          'description': description,
          'audioGuideId': audioGuideId,
          'visited': 0,
        },
      );
      _logger.i('Ubicación guardada: $id');
      
      await _addToSyncQueue('INSERT', tableLocations, {'id': id});
      
      return id;
    } catch (e) {
      _logger.e('Error insertando ubicación: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyLocations({
    required double latitude,
    required double longitude,
    double radiusKm = 1.0,
  }) async {
    try {
      Database db = await database;
      // Fórmula de Haversine simplificada
      String query = '''
        SELECT *, 
               (6371 * ACOS(COS(RADIANS(?)) * COS(RADIANS(latitude)) * 
               COS(RADIANS(longitude) - RADIANS(?)) + 
               SIN(RADIANS(?)) * SIN(RADIANS(latitude)))) AS distance
        FROM $tableLocations
        HAVING distance < ?
        ORDER BY distance
      ''';
      
      List<Map<String, dynamic>> result = await db.rawQuery(
        query,
        [latitude, longitude, latitude, radiusKm],
      );
      
      return result;
    } catch (e) {
      _logger.e('Error obteniendo ubicaciones cercanas: $e');
      return [];
    }
  }

  Future<void> markLocationAsVisited(int locationId) async {
    try {
      Database db = await database;
      await db.update(
        tableLocations,
        {
          'visited': 1,
          'visitedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [locationId],
      );
      
      await _addToSyncQueue('UPDATE', tableLocations, {'id': locationId});
      
      _logger.i('Ubicación marcada como visitada: $locationId');
    } catch (e) {
      _logger.e('Error marcando ubicación como visitada: $e');
      rethrow;
    }
  }

  // ===== OPERACIONES DE SINCRONIZACIÓN =====
  Future<void> _addToSyncQueue(
    String operation,
    String tableName,
    Map<String, dynamic> data,
  ) async {
    try {
      Database db = await database;
      await db.insert(
        tableSyncQueue,
        {
          'operation': operation,
          'tableName': tableName,
          'data': data.toString(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'synced': 0,
        },
      );
    } catch (e) {
      _logger.w('Error agregando a cola de sincronización: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    try {
      Database db = await database;
      return await db.query(
        tableSyncQueue,
        where: 'synced = 0',
        orderBy: 'timestamp ASC',
      );
    } catch (e) {
      _logger.e('Error obteniendo operaciones pendientes: $e');
      return [];
    }
  }

  Future<void> markAsSynced(int syncId) async {
    try {
      Database db = await database;
      await db.update(
        tableSyncQueue,
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [syncId],
      );
    } catch (e) {
      _logger.e('Error marcando como sincronizado: $e');
      rethrow;
    }
  }

  // ===== MANTENIMIENTO =====
  Future<void> clearOldData({int daysOld = 30}) async {
    try {
      Database db = await database;
      int timestamp = DateTime.now()
          .subtract(Duration(days: daysOld))
          .millisecondsSinceEpoch;
      
      await db.delete(
        tableVoiceQueries,
        where: 'timestamp < ?',
        whereArgs: [timestamp],
      );
      
      _logger.i('Datos antiguos eliminados');
    } catch (e) {
      _logger.e('Error limpiando datos antiguos: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
