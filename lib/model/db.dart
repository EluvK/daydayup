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
            name TEXT NOT NULL,
            color INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE courses (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            groupId TEXT,
            user TEXT NOT NULL,
            description TEXT NOT NULL,
            timeTable TEXT NOT NULL,
            pattern TEXT NOT NULL,
            color INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE lessons (
            courseId TEXT NOT NULL,
            id TEXT NOT NULL,
            name TEXT NOT NULL,
            user TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            originalEndTime TEXT NOT NULL,
            status INTEGER NOT NULL,
            PRIMARY KEY (courseId, id)
          )
        ''');
        await db.execute('''
          CREATE TABLE course_group (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            billIds TEXT NOT NULL,
            restAmount REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE course_group_bill (
            id TEXT PRIMARY KEY,
            groupId TEXT NOT NULL,
            description TEXT NOT NULL,
            time TEXT NOT NULL,
            amount REAL NOT NULL
          )
        ''');

        // insert a default user
        await db.execute('''
          INSERT INTO users (id, name, color) VALUES ('default', '默认用户', 0xFF3F3F00)
        ''');
      },
    );

    return _db!;
  }

  // course group bill
  Future<void> upsertCourseGroupBill(CourseGroupBill courseGroupBill) async {
    final db = await getDb();
    await db.insert(
      'course_group_bill',
      courseGroupBill.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CourseGroupBill>> getCourseGroupBills(String groupId) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'course_group_bill',
      where: 'groupId = ?',
      whereArgs: [groupId],
    );

    return List.generate(maps.length, (i) {
      return CourseGroupBill.fromJson(maps[i]);
    });
  }

  Future<void> deleteCourseGroupBill(String id) async {
    final db = await getDb();
    await db.delete(
      'course_group_bill',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // course group
  Future<void> upsertCourseGroup(CourseGroup courseGroup) async {
    final db = await getDb();
    await db.insert(
      'course_group',
      courseGroup.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CourseGroup?> getCourseGroup(String id) async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'course_group',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CourseGroup.fromJson(maps.first);
    }
    return null;
  }

  Future<List<CourseGroup>> getCourseGroups() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('course_group');

    return List.generate(maps.length, (i) {
      return CourseGroup.fromJson(maps[i]);
    });
  }

  Future<void> deleteCourseGroup(String id) async {
    final db = await getDb();
    await db.delete(
      'course_group',
      where: 'id = ?',
      whereArgs: [id],
    );
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
  Future<void> replaceCourseLessons(String courseId, List<Lesson> lessons) async {
    final db = await getDb();
    await db.transaction((txn) async {
      await txn.delete(
        'lessons',
        where: 'courseId = ?',
        whereArgs: [courseId],
      );
      for (final lesson in lessons) {
        await txn.insert(
          'lessons',
          lesson.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> upsertLesson(Lesson lesson) async {
    final db = await getDb();
    await db.insert(
      'lessons',
      lesson.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Future<void> upsertLessons(List<Lesson> lessons) async {
  //   final db = await getDb();
  //   final batch = db.batch();
  //   for (final lesson in lessons) {
  //     batch.insert(
  //       'lessons',
  //       lesson.toJson(),
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //   }
  //   await batch.commit(noResult: true);
  // }

  // Future<void> updateLesson(Lesson lesson) async {
  //   final db = await getDb();
  //   await db.update(
  //     'lessons',
  //     lesson.toJson(),
  //     where: 'courseId = ? AND id = ?',
  //     whereArgs: [lesson.courseId, lesson.id],
  //   );
  // }

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

    var result = List.generate(maps.length, (i) => Lesson.fromJson(maps[i]));
    result.sort((a, b) => a.startTime.compareTo(b.startTime));
    return result;
  }

  Future<List<Lesson>> getAllLessons() async {
    final db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query('lessons');

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

  Future<void> deleteLessons(String courseId) async {
    final db = await getDb();
    await db.delete(
      'lessons',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
  }
}
