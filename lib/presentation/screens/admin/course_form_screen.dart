import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/core/utils/validators.dart';
import 'package:codeacademy/presentation/providers/admin_provider.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';

class CourseFormScreen extends StatefulWidget {
  final int? courseId;

  const CourseFormScreen({super.key, this.courseId});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  int? _selectedCategoryId;
  int? _selectedTeacherId;
  bool _isPublished = true;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.courseId != null;
    
    Future.microtask(() async {
      if (!mounted) return;final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await adminProvider.loadCategories();
      if (authProvider.isAdmin) {
        await adminProvider.loadUsers();
      }
      
      if (_isEdit) {
        final course = adminProvider.courses.firstWhere((c) => c.id == widget.courseId);
        _titleController.text = course.title;
        _descriptionController.text = course.description;
        _priceController.text = course.price.toString();
        _isPublished = course.isPublished;
        _selectedCategoryId = course.category;
        _selectedTeacherId = course.teacher;
      } else {
        _selectedTeacherId = authProvider.session?.userId;
      }
      setState(() {});
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione una categoría'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    // Construct Django request fields
    final courseData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.parse(_priceController.text.trim()).toStringAsFixed(2),
      'category': _selectedCategoryId,
      'is_published': _isPublished,
      'teacher': _selectedTeacherId ?? authProvider.session?.userId ?? 1,
    };

    bool success;
    if (_isEdit) {
      success = await adminProvider.updateCourse(widget.courseId!, courseData);
    } else {
      success = await adminProvider.createCourse(courseData);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Curso actualizado con éxito' : 'Curso creado con éxito'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.errorMessage ?? 'Ocurrió un error al guardar'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Curso' : 'Nuevo Curso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin/courses');
            }
          },
        ),
      ),
      body: LoadingOverlay(
        isLoading: adminProvider.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título del curso'),
                  validator: (val) => Validators.validateRequired(val, 'Título'),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (val) => Validators.validateRequired(val, 'Descripción'),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Precio (\$)',
                    hintText: '0.00',
                  ),
                  validator: Validators.validatePrice,
                ),
                const SizedBox(height: 20),
                
                // Category Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  dropdownColor: AppColors.surface,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: adminProvider.categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name, style: const TextStyle(color: AppColors.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryId = val;
                    });
                  },
                  validator: (val) => val == null ? 'Seleccione una categoría' : null,
                ),
                const SizedBox(height: 20),

                // Teacher Dropdown (Only visible to Administrators)
                if (authProvider.isAdmin) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedTeacherId,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(labelText: 'Docente (Profesor Asignado)'),
                    items: adminProvider.users.map((u) {
                      return DropdownMenuItem<int>(
                        value: u.id,
                        child: Text(u.fullName, style: const TextStyle(color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedTeacherId = val;
                      });
                    },
                    validator: (val) => val == null ? 'Seleccione un docente' : null,
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Is Published Switch
                SwitchListTile(
                  title: const Text('Publicar inmediatamente', style: TextStyle(color: AppColors.textPrimary)),
                  value: _isPublished,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _isPublished = val;
                    });
                  },
                ),
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('GUARDAR CURSO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
