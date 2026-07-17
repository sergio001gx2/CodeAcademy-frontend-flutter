import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:codeacademy/core/config/app_config.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileBottomSheet(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.profile;
    final firstNameController = TextEditingController(text: user?.firstName);
    final lastNameController = TextEditingController(text: user?.lastName);
    final bioController = TextEditingController(text: user?.bio);
    Uint8List? selectedAvatarBytes;
    String? selectedAvatarPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickAvatar() async {
              try {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 500,
                  maxHeight: 500,
                  imageQuality: 80,
                );
                if (pickedFile != null) {
                  final bytes = await pickedFile.readAsBytes();
                  setSheetState(() {
                    selectedAvatarBytes = bytes;
                    selectedAvatarPath = kIsWeb ? pickedFile.name : pickedFile.path;
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al seleccionar imagen: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Editar Perfil',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Avatar edit selector
                    Center(
                      child: GestureDetector(
                        onTap: pickAvatar,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: AppColors.surfaceLight,
                              backgroundImage: selectedAvatarBytes != null
                                  ? MemoryImage(selectedAvatarBytes!)
                                  : (user?.avatar != null
                                      ? NetworkImage(
                                          user!.avatar!.startsWith('http')
                                              ? user.avatar!
                                              : '${Uri.parse(AppConfig.baseUrl).scheme}://${Uri.parse(AppConfig.baseUrl).host}${user.avatar}')
                                      : null) as ImageProvider?,
                              child: selectedAvatarBytes == null && user?.avatar == null
                                  ? const Icon(Icons.camera_alt_outlined, size: 30, color: AppColors.textSecondary)
                                  : null,
                            ),
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.edit, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First Name
                    TextFormField(
                      controller: firstNameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    TextFormField(
                      controller: lastNameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    TextFormField(
                      controller: bioController,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Biografía (Bio)',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close bottom sheet
                        
                        final success = await authProvider.updateProfile(
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          bio: bioController.text.trim(),
                          avatarPath: selectedAvatarPath,
                          avatarBytes: selectedAvatarBytes,
                        );

                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Perfil actualizado correctamente'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProvider.errorMessage ?? 'Error al actualizar perfil'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('GUARDAR CAMBIOS'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final session = authProvider.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          if (session != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar Perfil',
              onPressed: () => _showEditProfileBottomSheet(context, authProvider),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                backgroundImage: (authProvider.profile?.avatar != null)
                    ? NetworkImage(
                        authProvider.profile!.avatar!.startsWith('http')
                            ? authProvider.profile!.avatar!
                            : '${Uri.parse(AppConfig.baseUrl).scheme}://${Uri.parse(AppConfig.baseUrl).host}${authProvider.profile!.avatar}')
                    : null,
                child: (authProvider.profile?.avatar == null)
                    ? const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            
            // Name / Email
            Text(
              authProvider.profile?.fullName.trim().isNotEmpty == true
                  ? authProvider.profile!.fullName
                  : (session?.email ?? 'correo@ejemplo.com'),
              textAlign: TextAlign.center,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 4),
            if (authProvider.profile?.fullName.trim().isNotEmpty == true) ...[
              Text(
                session?.email ?? '',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],
            if (authProvider.profile?.bio != null && authProvider.profile!.bio!.trim().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  authProvider.profile!.bio!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 20),
            
            // Role Tag
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (session?.isStaff ?? false) 
                      ? AppColors.accent.withAlpha(40) 
                      : (session?.isTeacher ?? false)
                          ? AppColors.primary.withAlpha(40)
                          : AppColors.success.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (session?.isStaff ?? false) 
                        ? AppColors.accent 
                        : (session?.isTeacher ?? false)
                            ? AppColors.primary
                            : AppColors.success,
                  ),
                ),
                child: Text(
                  (session?.isStaff ?? false) 
                      ? 'ADMINISTRADOR' 
                      : (session?.isTeacher ?? false)
                          ? 'DOCENTE'
                          : 'ESTUDIANTE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (session?.isStaff ?? false) 
                        ? AppColors.accent 
                        : (session?.isTeacher ?? false)
                            ? AppColors.primaryLight
                            : AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Navigation Options
            Card(
              child: Column(
                children: [
                  if (authProvider.isStudent) ...[
                    ListTile(
                      leading: const Icon(Icons.school_outlined, color: AppColors.primaryLight),
                      title: const Text('Mis Cursos Inscritos', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/orders'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.favorite_border_rounded, color: AppColors.primaryLight),
                      title: const Text('Mi Lista de Deseos', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/wishlist'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart_outlined, color: AppColors.primaryLight),
                      title: const Text('Carrito de Compras', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/cart'),
                    ),
                  ],
                  
                  // Teacher options
                  if (authProvider.isTeacher && !authProvider.isAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.class_outlined, color: AppColors.primaryLight),
                      title: const Text('Cursos que Imparto (Docente)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/teacher/courses'),
                    ),
                  ],
                  
                  // Admin options
                  if (authProvider.isAdmin) ...[
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent),
                      title: const Text('Panel de Administración (Cursos)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/admin/courses'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.category_outlined, color: AppColors.accent),
                      title: const Text('Panel de Administración (Categorías)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/admin/categories'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.people_outline, color: AppColors.accent),
                      title: const Text('Panel de Administración (Usuarios)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/admin/users'),
                    ),
                    const Divider(height: 1, color: AppColors.surfaceLight),
                    ListTile(
                      leading: const Icon(Icons.receipt_long_outlined, color: AppColors.accent),
                      title: const Text('Auditoría de Matrículas (Admin)', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/admin/orders'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Logout
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada correctamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('CERRAR SESIÓN'),
            ),
          ],
        ),
      ),
    );
  }
}
