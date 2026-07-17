import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/screens/auth/login_screen.dart';
import 'package:codeacademy/presentation/screens/auth/register_screen.dart';
import 'package:codeacademy/presentation/screens/auth/profile_screen.dart';
import 'package:codeacademy/presentation/screens/notification/notification_screen.dart';
import 'package:codeacademy/presentation/screens/catalog/catalog_screen.dart';
import 'package:codeacademy/presentation/screens/catalog/course_detail_screen.dart';
import 'package:codeacademy/presentation/screens/catalog/lesson_screen.dart';
import 'package:codeacademy/presentation/screens/catalog/forum_screen.dart';
import 'package:codeacademy/presentation/screens/catalog/quiz_screen.dart';
import 'package:codeacademy/presentation/screens/catalog/wishlist_screen.dart';
import 'package:codeacademy/presentation/screens/cart/cart_screen.dart';
import 'package:codeacademy/presentation/screens/orders/orders_screen.dart';
import 'package:codeacademy/presentation/screens/admin/admin_courses_screen.dart';
import 'package:codeacademy/presentation/screens/admin/admin_categories_screen.dart';
import 'package:codeacademy/presentation/screens/admin/admin_users_screen.dart';
import 'package:codeacademy/presentation/screens/admin/admin_orders_screen.dart';
import 'package:codeacademy/presentation/screens/admin/course_form_screen.dart';
import 'package:codeacademy/presentation/screens/admin/category_form_screen.dart';
import 'package:codeacademy/presentation/screens/teacher/teacher_courses_screen.dart';
import 'package:codeacademy/presentation/screens/teacher/teacher_course_form_screen.dart';
import 'package:codeacademy/presentation/screens/teacher/teacher_lessons_screen.dart';
import 'package:codeacademy/presentation/screens/teacher/lesson_form_screen.dart';
import 'package:codeacademy/presentation/screens/orders/certificate_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: Provider.of<AuthProvider>(context, listen: false),
      redirect: (ctx, state) {
        final authProvider = Provider.of<AuthProvider>(ctx, listen: false);
        
        final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
        final loggedIn = authProvider.isAuthenticated;
        final isAdmin = authProvider.isAdmin;
        final isTeacher = authProvider.isTeacher;

        final isPrivateRoute = state.matchedLocation.startsWith('/admin') ||
                               state.matchedLocation.startsWith('/teacher') ||
                               state.matchedLocation.startsWith('/orders') ||
                               state.matchedLocation.startsWith('/wishlist') ||
                               state.matchedLocation.startsWith('/lesson') ||
                               state.matchedLocation.startsWith('/certificates') ||
                               state.matchedLocation == '/profile' ||
                               state.matchedLocation == '/notifications';

        // 1. Si no está logueado y va a una ruta privada -> Mandar a Login
        if (!loggedIn && isPrivateRoute) {
          return '/login';
        }

        // 2. Si ya está logueado e intenta ir a login/registro -> Mandar a Home
        if (loggedIn && loggingIn) {
          return '/';
        }

        // 3. Si intenta entrar a admin pero no es Administrador -> Mandar a Home
        if (state.matchedLocation.startsWith('/admin') && !isAdmin) {
          return '/';
        }

        // 4. Si intenta entrar a teacher pero no es Docente ni Admin -> Mandar a Home
        if (state.matchedLocation.startsWith('/teacher') && !isTeacher && !isAdmin) {
          return '/';
        }

        return null;
      },
      routes: [
        // Public routes
        GoRoute(
          path: '/',
          builder: (context, state) => const CatalogScreen(),
        ),
        GoRoute(
          path: '/course/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return CourseDetailScreen(courseId: id);
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Private Student routes
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/wishlist',
          builder: (context, state) => const WishlistScreen(),
        ),
        GoRoute(
          path: '/certificates',
          builder: (context, state) => const CertificateScreen(),
        ),
        GoRoute(
          path: '/course/:id/forum',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final extra = state.extra as Map<String, dynamic>?;
            final title = extra?['title'] as String? ?? 'Curso';
            return ForumScreen(courseId: id, courseTitle: title);
          },
        ),
        GoRoute(
          path: '/course/:id/quiz',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final extra = state.extra as Map<String, dynamic>?;
            final title = extra?['title'] as String? ?? 'Curso';
            return QuizScreen(courseId: id, courseTitle: title);
          },
        ),
        GoRoute(
          path: '/lesson',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final lesson = extra['lesson'] as Lesson;
            final enrollmentId = extra['enrollmentId'] as int;
            return LessonScreen(lesson: lesson, enrollmentId: enrollmentId);
          },
        ),

        // Private Admin routes
        GoRoute(
          path: '/admin/courses',
          builder: (context, state) => const AdminCoursesScreen(),
        ),
        GoRoute(
          path: '/admin/courses/new',
          builder: (context, state) => const CourseFormScreen(),
        ),
        GoRoute(
          path: '/admin/courses/edit/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return CourseFormScreen(courseId: id);
          },
        ),
        GoRoute(
          path: '/admin/categories',
          builder: (context, state) => const AdminCategoriesScreen(),
        ),
        GoRoute(
          path: '/admin/categories/new',
          builder: (context, state) => const CategoryFormScreen(),
        ),
        GoRoute(
          path: '/admin/categories/edit/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return CategoryFormScreen(categoryId: id);
          },
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: '/admin/orders',
          builder: (context, state) => const AdminOrdersScreen(),
        ),

        // Private Teacher routes
        GoRoute(
          path: '/teacher/courses',
          builder: (context, state) => const TeacherCoursesScreen(),
        ),
        GoRoute(
          path: '/teacher/courses/new',
          builder: (context, state) => const TeacherCourseFormScreen(),
        ),
        GoRoute(
          path: '/teacher/courses/edit/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return TeacherCourseFormScreen(courseId: id);
          },
        ),
        GoRoute(
          path: '/teacher/courses/:id/lessons',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final extra = state.extra as Map<String, dynamic>?;
            final title = extra?['courseTitle'] as String? ?? 'Curso';
            return TeacherLessonsScreen(courseId: id, courseTitle: title);
          },
        ),
        GoRoute(
          path: '/teacher/courses/:courseId/lessons/new',
          builder: (context, state) {
            final courseId = int.parse(state.pathParameters['courseId']!);
            final extra = state.extra as Map<String, dynamic>;
            final courseTitle = extra['courseTitle'] as String;
            return LessonFormScreen(courseId: courseId, courseTitle: courseTitle);
          },
        ),
        GoRoute(
          path: '/teacher/courses/:courseId/lessons/edit/:lessonId',
          builder: (context, state) {
            final courseId = int.parse(state.pathParameters['courseId']!);
            final extra = state.extra as Map<String, dynamic>;
            final courseTitle = extra['courseTitle'] as String;
            final lesson = extra['lesson'] as Lesson;
            return LessonFormScreen(courseId: courseId, courseTitle: courseTitle, lesson: lesson);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Página no encontrada: ${state.error}'),
        ),
      ),
    );
  }
}
