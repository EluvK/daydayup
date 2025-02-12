import 'package:daydayup/model/course.dart';
import 'package:daydayup/model/db.dart';
import 'package:daydayup/utils/utils.dart';
import 'package:get/get.dart';

class CoursesController extends GetxController {
  final RxList<CourseGroup> courseGroups = <CourseGroup>[].obs;
  final RxList<Course> courses = <Course>[].obs;
  final RxMap<String, List<Lesson>> courseLessons = <String, List<Lesson>>{}.obs;
  final RxMap<String, CourseStatus> courseStatus = <String, CourseStatus>{}.obs;
  final RxMap<DateTime, List<Lesson>> eachDateLessons = <DateTime, List<Lesson>>{}.obs;

  @override
  Future<void> onInit() async {
    courseGroups.value = await DataBase().getCourseGroups();
    courses.value = await DataBase().getCourses();
    for (final course in courses) {
      courseLessons[course.id] = await DataBase().getLessons(course.id);
      courseStatus[course.id] = CourseStatus.fromCourses(course, courseLessons[course.id]!);
    }
    await rebuildEachDateLessons();

    super.onInit();
    _initialized = true;
  }

  bool _initialized = false;
  Future<void> ensureInitialization() async {
    while (!_initialized) {
      await onInit();
    }
    return;
  }

  Future<void> rebuildEachDateLessons() async {
    eachDateLessons.clear();
    var allLessons = await DataBase().getAllLessons();
    for (final lesson in allLessons) {
      var date = regularDateTimeToDate(lesson.startTime);
      // print('regularDateTimeToDate: $date');
      if (eachDateLessons[date] == null) {
        // print('new date: $date');
        eachDateLessons[date] = <Lesson>[];
      }
      if (eachDateLessons[date]!.indexWhere((element) => element.id == lesson.id) == -1) {
        eachDateLessons[date]!.add(lesson);
      }
      // print('add lesson, current length: ${eachDateLessons[date]!.length}');
    }
  }

  // --- course group bill
  Future<void> addCourseGroupBill(CourseGroupBill bill) async {
    await DataBase().upsertCourseGroupBill(bill);
  }

  Future<List<CourseGroupBill>> getCourseGroupBills(String groupId) async {
    return await DataBase().getCourseGroupBills(groupId);
  }

  // --- course group
  CourseGroup getCourseGroup(String id) {
    return courseGroups.firstWhere((courseGroup) => courseGroup.id == id);
  }

  Future<void> upsertCourseGroup(CourseGroup courseGroup) async {
    await DataBase().upsertCourseGroup(courseGroup);

    if (courseGroups.indexWhere((element) => element.id == courseGroup.id) == -1) {
      courseGroups.add(courseGroup);
    } else {
      final index = courseGroups.indexWhere((element) => element.id == courseGroup.id);
      courseGroups[index] = courseGroup;
    }
  }

  Future<void> deleteCourseGroup(String id) async {
    await DataBase().deleteCourseGroup(id);
    // todo remove course group bills and courses in this group.
    courseGroups.removeWhere((element) => element.id == id);
  }

  // --- course
  Course getCourse(String id) {
    return courses.firstWhere((course) => course.id == id);
  }

  Future<void> upsertCourse(Course course, List<Lesson> lessons) async {
    await DataBase().upsertCourse(course);
    await DataBase().upsertLessons(lessons);

    if (courses.indexWhere((element) => element.id == course.id) == -1) {
      courses.add(course);
    } else {
      final index = courses.indexWhere((element) => element.id == course.id);
      courses[index] = course;
    }
    courseLessons[course.id] = lessons;
    courseStatus[course.id] = CourseStatus.fromCourses(course, lessons);
    await rebuildEachDateLessons();
  }

  Future<void> deleteCourse(String id) async {
    await DataBase().deleteCourse(id);
    await DataBase().deleteLessons(id);
    courseLessons.remove(id);
    courseStatus.remove(id);
    courses.removeWhere((element) => element.id == id);
    await rebuildEachDateLessons();
  }

  // lesson
  List<Lesson> getCourseLessons(String courseId) {
    return courseLessons[courseId] ?? [];
  }
}

class CourseStatus {
  // int total;
  int completed;
  int notStarted;
  int canceled;
  int notAttended;

  CourseStatus({
    // required this.total,
    required this.completed,
    required this.notStarted,
    this.canceled = 0,
    this.notAttended = 0,
  });

  factory CourseStatus.fromCourses(Course course, List<Lesson> lessons) {
    // todo! different pattern, not the some.
    return CourseStatus(
      // total: course.timeTable.courseLength,
      completed: lessons.where((lesson) => lesson.status == LessonStatus.finished).length,
      notStarted: lessons.where((lesson) => lesson.status == LessonStatus.notStarted).length,
      canceled: lessons.where((lesson) => lesson.status == LessonStatus.canceled).length,
      notAttended: lessons.where((lesson) => lesson.status == LessonStatus.notAttended).length,
    );
  }
}
