import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/providers/catalog_provider.dart';
import 'package:codeacademy/presentation/providers/cart_provider.dart';
import 'package:codeacademy/presentation/providers/order_provider.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _reviewCommentController = TextEditingController();
  int _reviewRating = 5;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;Provider.of<CatalogProvider>(context, listen: false).loadCourseById(widget.courseId);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Provider.of<OrderProvider>(context, listen: false).loadOrders();
        Provider.of<OrderProvider>(context, listen: false).loadWishlist();
      }
      Provider.of<OrderProvider>(context, listen: false).loadReviews(widget.courseId);
    });
  }

  @override
  void dispose() {
    _reviewCommentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final comment = _reviewCommentController.text.trim();
    if (comment.isEmpty) return;

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final success = await orderProvider.submitReview(
      courseId: widget.courseId,
      rating: _reviewRating,
      comment: comment,
    );

    if (success && mounted) {
      _reviewCommentController.clear();
      _reviewRating = 5;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reseña publicada con éxito!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final course = catalogProvider.selectedCourse;
    final isTeacherOfCourse = course != null && authProvider.isTeacher && course.teacher == authProvider.session?.userId;
    final isEnrolled = course != null && orderProvider.isEnrolled(course.id);
    final showEnrolledFeatures = isEnrolled || isTeacherOfCourse || authProvider.isAdmin;
    final isInWishlist = course != null && orderProvider.isInWishlist(course.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(course?.title ?? 'Detalle del Curso'),
        actions: [
          if (authProvider.isAuthenticated && course != null)
            IconButton(
              icon: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: isInWishlist ? AppColors.error : AppColors.textSecondary,
              ),
              onPressed: () async {
                if (isInWishlist) {
                  await orderProvider.removeFromWishlist(course.id);
                } else {
                  await orderProvider.addToWishlist(course.id);
                }
              },
            ),
        ],
      ),
      body: catalogProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : catalogProvider.errorMessage != null
              ? Center(
                  child: Text(
                    catalogProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                )
              : course == null
                  ? const Center(
                      child: Text('Curso no encontrado'),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Banner
                          Container(
                            height: 200,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: course.image != null
                                ? Image.network(
                                    course.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                  )
                                : _buildPlaceholder(),
                          ),
                          
                          // Details
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 // Category & Subcategory chips
                                 Row(
                                   children: [
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                       decoration: BoxDecoration(
                                         color: AppColors.surface,
                                         borderRadius: BorderRadius.circular(8),
                                         border: Border.all(color: AppColors.surfaceLight),
                                       ),
                                       child: Text(
                                         course.categoryName,
                                         style: const TextStyle(
                                           color: AppColors.textSecondary,
                                           fontWeight: FontWeight.bold,
                                           fontSize: 12,
                                         ),
                                       ),
                                     ),
                                     if (course.subcategory != null) ...[
                                       const SizedBox(width: 8),
                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                         decoration: BoxDecoration(
                                           color: AppColors.primary.withValues(alpha: 0.15),
                                           borderRadius: BorderRadius.circular(8),
                                           border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                         ),
                                         child: const Text(
                                           'Subcategoría',
                                           style: TextStyle(
                                             color: AppColors.primary,
                                             fontWeight: FontWeight.bold,
                                             fontSize: 12,
                                           ),
                                         ),
                                       ),
                                     ],
                                   ],
                                 ),
                                 const SizedBox(height: 16),
                                
                                // Title
                                Text(course.title, style: AppTextStyles.h1),
                                const SizedBox(height: 12),
                                
                                // Price
                                Text(
                                  course.price == 0.0 ? 'GRATIS' : '\$${course.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                 const Divider(height: 40, color: AppColors.surfaceLight),
                                 
                                 // Teacher Quick Controls
                                 if (isTeacherOfCourse || authProvider.isAdmin) ...[
                                   Row(
                                     children: [
                                       Expanded(
                                         child: ElevatedButton.icon(
                                           icon: const Icon(Icons.edit),
                                           label: const Text('EDITAR CURSO'),
                                           onPressed: () => context.push('/teacher/courses/edit/${course.id}'),
                                           style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white),
                                         ),
                                       ),
                                       const SizedBox(width: 12),
                                       Expanded(
                                         child: ElevatedButton.icon(
                                           icon: const Icon(Icons.list_alt),
                                           label: const Text('LECCIONES'),
                                           onPressed: () => context.push('/teacher/courses/${course.id}/lessons', extra: {'courseTitle': course.title}),
                                           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                         ),
                                       ),
                                     ],
                                   ),
                                   const Divider(height: 40, color: AppColors.surfaceLight),
                                 ],
                                 
                                 // Description
                                 const Text('Descripción del Curso', style: AppTextStyles.h3),
                                 const SizedBox(height: 10),
                                 Text(course.description, style: AppTextStyles.body),
                                 
                                 const Divider(height: 40, color: AppColors.surfaceLight),
                                
                                // Conditional Section: Enrolled Student/Teacher Features
                                if (showEnrolledFeatures) ...[
                                  _buildEnrolledControls(context, orderProvider, course),
                                  const Divider(height: 40, color: AppColors.surfaceLight),
                                ] else ...[
                                  // Not enrolled: show CTA
                                  _buildActionBtn(context, authProvider, cartProvider, orderProvider, course),
                                  const Divider(height: 40, color: AppColors.surfaceLight),
                                ],

                                // Reviews Section
                                _buildReviewsSection(authProvider, orderProvider),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildEnrolledControls(BuildContext context, OrderProvider orderProvider, Course course) {
    final enrollmentId = orderProvider.getEnrollmentIdForCourse(course.id);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Interactive Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.forum_outlined),
                label: const Text('FORO'),
                onPressed: () => context.push('/course/${course.id}/forum', extra: {'title': course.title}),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.primaryLight),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('EXÁMENES'),
                onPressed: () => context.push('/course/${course.id}/quiz', extra: {'title': course.title}),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Lessons List
        const Text('Lecciones del Curso', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        if (course.lessons.isEmpty)
          const Text('No hay lecciones registradas en este curso.', style: TextStyle(color: AppColors.textSecondary))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: course.lessons.length,
            itemBuilder: (context, index) {
              final lesson = course.lessons[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(lesson.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  subtitle: Text('Duración: ${lesson.duration} min', style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.play_circle_outline, color: AppColors.primaryLight),
                  onTap: () {
                    context.push(
                      '/lesson',
                      extra: {
                        'lesson': lesson,
                        'enrollmentId': enrollmentId ?? 0,
                      },
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildReviewsSection(AuthProvider authProvider, OrderProvider orderProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Reseñas de Estudiantes', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        
        // Write Review Form
        if (authProvider.isAuthenticated) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Deja tu opinión', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Calificación: ', style: TextStyle(color: AppColors.textSecondary)),
                      DropdownButton<int>(
                        value: _reviewRating,
                        dropdownColor: AppColors.surface,
                        items: [5, 4, 3, 2, 1].map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text('$r estrellas', style: const TextStyle(color: AppColors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _reviewRating = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: _reviewCommentController,
                    decoration: const InputDecoration(hintText: 'Escribe tu comentario aquí...'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submitReview,
                    child: const Text('PUBLICAR RESEÑA'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Reviews List
        if (orderProvider.reviews.isEmpty)
          const Text('Aún no hay reseñas para este curso.', style: TextStyle(color: AppColors.textSecondary))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderProvider.reviews.length,
            itemBuilder: (context, index) {
              final review = orderProvider.reviews[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review.studentEmail ?? 'Estudiante',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: i < review.rating ? AppColors.accent : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (review.comment != null && review.comment!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(review.comment!, style: const TextStyle(color: AppColors.textPrimary)),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    AuthProvider authProvider,
    CartProvider cartProvider,
    OrderProvider orderProvider,
    Course course,
  ) {
    if (!authProvider.isAuthenticated) {
      return ElevatedButton(
        onPressed: () => context.push('/login'),
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
        child: const Text('INICIAR SESIÓN PARA INSCRIBIRSE'),
      );
    }

    final inCart = cartProvider.isInCart(course);
    return ElevatedButton(
      onPressed: () {
        if (inCart) {
          cartProvider.removeFromCart(course);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removido del carrito'), backgroundColor: AppColors.info),
          );
        } else {
          cartProvider.addToCart(course);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agregado al carrito de compras'), backgroundColor: AppColors.success),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: inCart ? AppColors.error : AppColors.primary,
      ),
      child: Text(inCart ? 'REMOVER DEL CARRITO' : 'AGREGAR AL CARRITO'),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_rounded, size: 60, color: Colors.white),
          SizedBox(height: 8),
          Text(
            'CodeAcademy',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
