import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/core/utils/validators.dart';
import 'package:codeacademy/presentation/providers/admin_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';

class CategoryFormScreen extends StatefulWidget {
  final int? categoryId;

  const CategoryFormScreen({super.key, this.categoryId});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.categoryId != null;

    if (_isEdit) {
      Future.microtask(() {
      if (!mounted) return;final adminProvider = Provider.of<AdminProvider>(context, listen: false);
        final cat = adminProvider.categories.firstWhere((c) => c.id == widget.categoryId);
        _nameController.text = cat.name;
        _slugController.text = cat.slug;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  // Auto-generate slug from name
  void _onNameChanged(String val) {
    if (!_isEdit) {
      final slug = val
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // remove special chars
          .replaceAll(RegExp(r'\s+'), '-'); // replace spaces with hyphens
      _slugController.text = slug;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    final name = _nameController.text.trim();
    final slug = _slugController.text.trim().toLowerCase();

    bool success;
    if (_isEdit) {
      success = await adminProvider.updateCategory(widget.categoryId!, name, slug);
    } else {
      success = await adminProvider.createCategory(name, slug);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Categoría actualizada con éxito' : 'Categoría creada con éxito'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Categoría' : 'Nueva Categoría'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin/categories');
            }
          },
        ),
      ),
      body: LoadingOverlay(
        isLoading: adminProvider.isLoading,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre de la categoría'),
                  onChanged: _onNameChanged,
                  validator: (val) => Validators.validateRequired(val, 'Nombre'),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _slugController,
                  decoration: const InputDecoration(
                    labelText: 'Slug',
                    hintText: 'ejemplo-de-slug',
                  ),
                  validator: (val) {
                    final req = Validators.validateRequired(val, 'Slug');
                    if (req != null) return req;
                    
                    final slugRegExp = RegExp(r'^[-a-z0-9_]+$');
                    if (!slugRegExp.hasMatch(val!)) {
                      return 'El slug solo puede contener letras minúsculas, números, guiones y guiones bajos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('GUARDAR CATEGORÍA'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
