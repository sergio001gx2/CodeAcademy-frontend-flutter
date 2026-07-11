import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/domain/model/category.dart';
import 'package:codeacademy/domain/model/subcategory.dart';
import 'package:codeacademy/domain/model/quiz.dart';
import 'package:codeacademy/domain/model/forum.dart';

abstract class CatalogRepository {
  // Course CRUD
  Future<List<Course>> getCourses({String? search, int? categoryId, int? teacherId});
  Future<Course> getCourseById(int id);
  Future<Course> createCourse(Map<String, dynamic> courseData);
  Future<Course> updateCourse(int id, Map<String, dynamic> courseData);
  Future<void> deleteCourse(int id);

  // Category CRUD
  Future<List<Category>> getCategories({String? search});
  Future<Category> getCategoryById(int id);
  Future<Category> createCategory(String name, String slug);
  Future<Category> updateCategory(int id, String name, String slug);
  Future<void> deleteCategory(int id);

  // Subcategory
  Future<List<Subcategory>> getSubcategories({int? categoryId});
  Future<Subcategory> createSubcategory(String name, String slug, int categoryId);

  // Lesson CRUD
  Future<List<Lesson>> getLessons(int courseId);
  Future<Lesson> createLesson(Map<String, dynamic> data);
  Future<Lesson> updateLesson(int id, Map<String, dynamic> data);
  Future<void> deleteLesson(int id);

  // Course Tags
  Future<List<String>> getCourseTags(int courseId);
  Future<void> addCourseTag(int courseId, String tag);

  // Forum endpoints
  Future<List<DiscussionForum>> getForums({int? courseId});
  Future<DiscussionForum> createForum(int courseId, String title, String description);
  Future<List<ForumPost>> getForumPosts(int forumId);
  Future<ForumPost> createForumPost(int forumId, String title, String content);
  Future<List<ForumComment>> getForumComments(int postId);
  Future<ForumComment> createForumComment(int postId, String content);

  // Quiz endpoints
  Future<List<Quiz>> getQuizzes({int? courseId});
  Future<List<Question>> getQuestions(int quizId);
  Future<Quiz> createQuiz(Map<String, dynamic> data);
  Future<Question> createQuestion(Map<String, dynamic> data);
  Future<Answer> createAnswer(Map<String, dynamic> data);
}
