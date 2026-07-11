import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/core/utils/validators.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/providers/teacher_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';

/// Shared course form for Teacher (creates for themselves) and accessible from admin too
class TeacherCourseFormScreen extends StatefulWidget {
  final int? courseId;
  const TeacherCourseFormScreen({super.key, this.courseId});

  @override
  State<TeacherCourseFormScreen> createState() => _TeacherCourseFormScreenState();
}

class _TeacherCourseFormScreenState extends State<TeacherCourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  bool _isPublished = true;
  bool _isEdit = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.courseId != null;
    Future.microtask(() async {
      if (!mounted) return;final teacher = Provider.of<TeacherProvider>(context, listen: false);
      await teacher.loadCategories();
      if (_isEdit && teacher.myCourses.isNotEmpty) {
        final course = teacher.myCourses.firstWhere(
          (c) => c.id == widget.courseId,
          orElse: () => teacher.myCourses.first,
        );
        _titleController.text = course.title;
        _descriptionController.text = course.description;
        _priceController.text = course.price.toStringAsFixed(2);
        _isPublished = course.isPublished;
        _selectedCategoryId = course.category;
        _selectedSubcategoryId = course.subcategory;
        await teacher.loadSubcategories(categoryId: course.category);
            }
      setState(() => _initialized = true);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, seleccione una categoría'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);

    final courseData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.parse(_priceController.text.trim()).toStringAsFixed(2),
      'category': _selectedCategoryId,
      if (_selectedSubcategoryId != null) 'subcategory': _selectedSubcategoryId,
      'is_published': _isPublished,
      'teacher': authProvider.session?.userId ?? 1,
    };

    bool success;
    if (_isEdit) {
      success = await teacherProvider.updateCourse(widget.courseId!, courseData);
    } else {
      success = await teacherProvider.createCourse(courseData);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? (_isEdit ? 'Curso actualizado con éxito' : 'Curso creado con éxito')
            : teacherProvider.errorMessage ?? 'Error al guardar'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ));
      if (success) {
        // Reload courses and go back
        if (authProvider.session?.userId != null) {
          await teacherProvider.loadMyCourses(authProvider.session!.userId);
        }
        if (mounted) context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          _isEdit ? 'Editar Curso' : 'Nuevo Curso',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : LoadingOverlay(
              isLoading: teacherProvider.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Título del curso',
                          prefixIcon: Icon(Icons.title, color: AppColors.textMuted),
                        ),
                        validator: (val) => Validators.validateRequired(val, 'Título'),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: Icon(Icons.description, color: AppColors.textMuted),
                          alignLabelWithHint: true,
                        ),
                        validator: (val) => Validators.validateRequired(val, 'Descripción'),
                      ),
                      const SizedBox(height: 20),

                      // Price
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Precio (\$)',
                          prefixIcon: Icon(Icons.attach_money, color: AppColors.textMuted),
                          hintText: '0.00',
                        ),
                        validator: Validators.validatePrice,
                      ),
                      const SizedBox(height: 20),

                      // Category
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        dropdownColor: AppColors.surface,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          prefixIcon: Icon(Icons.category, color: AppColors.textMuted),
                        ),
                        items: teacherProvider.categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.name, style: const TextStyle(color: AppColors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) async {
                          setState(() {
                            _selectedCategoryId = val;
                            _selectedSubcategoryId = null;
                          });
                          if (val != null) {
                            await teacherProvider.loadSubcategories(categoryId: val);
                          }
                        },
                        validator: (val) => val == null ? 'Seleccione una categoría' : null,
                      ),
                      const SizedBox(height: 20),

                      // Subcategory (optional, only shown if category is selected and has subcats)
                      if (_selectedCategoryId != null && teacherProvider.subcategories.isNotEmpty) ...[
                        DropdownButtonFormField<int?>(
                          value: _selectedSubcategoryId,
                          dropdownColor: AppColors.surface,
                          decoration: const InputDecoration(
                            labelText: 'Subcategoría (opcional)',
                            prefixIcon: Icon(Icons.subdirectory_arrow_right, color: AppColors.textMuted),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Sin subcategoría', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            ...teacherProvider.subcategories.map((sub) {
                              return DropdownMenuItem<int?>(
                                value: sub.id,
                                child: Text(sub.name, style: const TextStyle(color: AppColors.textPrimary)),
                              );
                            }),
                          ],
                          onChanged: (val) => setState(() => _selectedSubcategoryId = val),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Published switch
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: const Text('Publicar inmediatamente', style: TextStyle(color: AppColors.textPrimary)),
                          subtitle: Text(
                            _isPublished ? 'Visible para estudiantes' : 'Solo visible para ti',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          value: _isPublished,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _isPublished = val),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          _isEdit ? 'ACTUALIZAR CURSO' : 'CREAR CURSO',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
