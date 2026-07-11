import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/core/utils/validators.dart';
import 'package:codeacademy/domain/model/course.dart';
import 'package:codeacademy/presentation/providers/teacher_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';

class LessonFormScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final Lesson? lesson; // null = create, non-null = edit

  const LessonFormScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.lesson,
  });

  @override
  State<LessonFormScreen> createState() => _LessonFormScreenState();
}

class _LessonFormScreenState extends State<LessonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _orderController = TextEditingController();
  final _durationController = TextEditingController();

  bool get _isEdit => widget.lesson != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final l = widget.lesson!;
      _titleController.text = l.title;
      _contentController.text = l.content;
      _videoUrlController.text = l.videoUrl ?? '';
      _orderController.text = l.order.toString();
      _durationController.text = l.duration.toString();
    } else {
      // Suggest next order number
      final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
      _orderController.text = (teacherProvider.lessons.length + 1).toString();
      _durationController.text = '30';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    _orderController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final data = {
      'course': widget.courseId,
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      if (_videoUrlController.text.trim().isNotEmpty)
        'video_url': _videoUrlController.text.trim(),
      'order': int.tryParse(_orderController.text) ?? 1,
      'duration': int.tryParse(_durationController.text) ?? 0,
    };

    bool success;
    if (_isEdit) {
      success = await teacherProvider.updateLesson(widget.lesson!.id, data);
    } else {
      success = await teacherProvider.createLesson(data);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? (_isEdit ? 'Lección actualizada' : 'Lección creada con éxito')
            : teacherProvider.errorMessage ?? 'Error al guardar'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ));
      if (success && context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit ? 'Editar Lección' : 'Nueva Lección',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
            Text(
              widget.courseTitle,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: teacherProvider.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order and Duration row
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _orderController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Orden',
                          prefixIcon: Icon(Icons.format_list_numbered, color: AppColors.textMuted),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Requerido';
                          if (int.tryParse(val) == null) return 'Número entero';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Duración (min)',
                          prefixIcon: Icon(Icons.timer_outlined, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Título de la lección',
                    prefixIcon: Icon(Icons.title, color: AppColors.textMuted),
                  ),
                  validator: (val) => Validators.validateRequired(val, 'Título'),
                ),
                const SizedBox(height: 20),

                // Content
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Contenido / Descripción',
                    prefixIcon: Icon(Icons.article_outlined, color: AppColors.textMuted),
                    alignLabelWithHint: true,
                  ),
                  validator: (val) => Validators.validateRequired(val, 'Contenido'),
                ),
                const SizedBox(height: 20),

                // Video URL (optional)
                TextFormField(
                  controller: _videoUrlController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'URL del video (opcional)',
                    prefixIcon: Icon(Icons.play_circle_outline, color: AppColors.textMuted),
                    hintText: 'https://youtube.com/...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isEdit ? 'ACTUALIZAR LECCIÓN' : 'CREAR LECCIÓN',
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
