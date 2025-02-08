import 'package:daydayup/model/course.dart';
import 'package:daydayup/model/db.dart';
import 'package:get/get.dart';

class CoursesController extends GetxController {
  final RxList<Course> courses = <Course>[].obs;
  final RxMap<String, List<Lesson>> courseLessons = <String, List<Lesson>>{}.obs;
  final RxMap<String, CourseStatus> courseStatus = <String, CourseStatus>{}.obs;

  @override
  void onInit() async {
    courses.value = await DataBase().getCourses();
    for (final course in courses) {
      courseLessons[course.id] = await DataBase().getLessons(course.id);
      courseStatus[course.id] = CourseStatus.fromCourses(course, courseLessons[course.id]!);
    }

    super.onInit();
  }

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
  }

  // lesson
  List<Lesson> getCourseLessons(String courseId) {
    return courseLessons[courseId]!;
  }
}

class CourseStatus {
  int total;
  int completed;
  int notStarted;
  int canceled;
  int notAttended;

  CourseStatus({
    required this.total,
    required this.completed,
    required this.notStarted,
    this.canceled = 0,
    this.notAttended = 0,
  });

  factory CourseStatus.fromCourses(Course course, List<Lesson> lessons) {
    return CourseStatus(
      total: course.pattern.courseLength,
      completed: lessons.where((lesson) => lesson.status == LessonStatus.finished).length,
      notStarted: lessons.where((lesson) => lesson.status == LessonStatus.notStarted).length,
      canceled: lessons.where((lesson) => lesson.status == LessonStatus.skipped).length,
      notAttended: lessons.where((lesson) => lesson.status == LessonStatus.notAttended).length,
    );
  }
}
