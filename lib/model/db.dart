import 'package:sqflite/sqflite.dart';
import 'course.dart';

class DataBase {
  static Database? _db;

  Future<Database> getDb() async {
    _db ??= await openDatabase(
      'ddu.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            color INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE courses (
            id TEXT PRIMARY KEY,
            name TEXT,
            user TEXT,
            description TEXT,
            pattern TEXT,
            color INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE lessons (
            courseId TEXT,
            id TEXT,
            name TEXT,
            user TEXT,
            startTime TEXT,
            endTime TEXT,
            PRIMARY KEY (courseId, id)
          )
        ''');

        // insert a default user
        await db.execute('''
          INSERT INTO users (id, name, color) VALUES ('default', '我', 0xFF3F3F00)
        ''');
      },
    );

    return _db!;
  }

  // course
  Future<void> insertCourse(Course course) async {
    final db = await getDb();
    await db.insert(
      'courses',
      course.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCourse(Course course) async {
    final db = await getDb();
    await db.update(
      'courses',
      course.toJson(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<void> upsertCourse(Course course) async {
    final db = await getDb();
    await db.insert(
      'courses',
      course.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Course?> getCourse(String id) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Course.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Course>> getCourses() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('courses');

    return List.generate(maps.length, (i) {
      return Course.fromJson(maps[i]);
    });
  }

  Future<void> deleteCourse(String id) async {
    final db = await getDb();
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // user
  // Future<void> insertUser(User user) async {
  //   final db = await getDb();
  //   await db.insert(
  //     'users',
  //     user.toJson(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // Future<void> updateUser(User user) async {
  //   final db = await getDb();
  //   await db.update(
  //     'users',
  //     user.toJson(),
  //     where: 'id = ?',
  //     whereArgs: [user.id],
  //   );
  // }

  Future<void> upsertUser(User user) async {
    final db = await getDb();
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String id) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<List<User>> getUsers() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User.fromJson(maps[i]);
    });
  }

  Future<void> deleteUser(String id) async {
    final db = await getDb();
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // lesson
  Future<void> upsertLesson(Lesson lesson) async {
    final db = await getDb();
    await db.insert(
      'lessons',
      lesson.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertLessons(List<Lesson> lessons) async {
    final db = await getDb();
    final batch = db.batch();
    for (final lesson in lessons) {
      batch.insert(
        'lessons',
        lesson.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateLesson(Lesson lesson) async {
    final db = await getDb();
    await db.update(
      'lessons',
      lesson.toJson(),
      where: 'courseId = ? AND id = ?',
      whereArgs: [lesson.courseId, lesson.id],
    );
  }

  Future<Lesson?> getLesson(String courseId, String id) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'courseId = ? AND id = ?',
      whereArgs: [courseId, id],
    );

    if (maps.isNotEmpty) {
      return Lesson.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Lesson>> getLessons(String courseId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );

    return List.generate(maps.length, (i) {
      return Lesson.fromJson(maps[i]);
    });
  }

  Future<void> deleteLesson(String courseId, String id) async {
    final db = await getDb();
    await db.delete(
      'lessons',
      where: 'courseId = ? AND id = ?',
      whereArgs: [courseId, id],
    );
  }
}
