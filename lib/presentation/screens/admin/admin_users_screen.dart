import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeacademy/presentation/providers/admin_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;Provider.of<AdminProvider>(context, listen: false).loadUsers();
    });
  }

  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    bool isTeacher = false;
    bool isStudent = true;
    bool isAdmin = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Crear Nuevo Usuario', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: 'Contraseña'),
                        obscureText: true,
                        validator: (val) => val == null || val.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameController,
                              decoration: const InputDecoration(labelText: 'Nombre'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: const InputDecoration(labelText: 'Apellido'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Roles del Usuario:', style: TextStyle(fontWeight: FontWeight.bold)),
                      CheckboxListTile(
                        title: const Text('Estudiante'),
                        value: isStudent,
                        onChanged: (val) => setStateDialog(() => isStudent = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Docente'),
                        value: isTeacher,
                        onChanged: (val) => setStateDialog(() => isTeacher = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Administrador'),
                        value: isAdmin,
                        onChanged: (val) => setStateDialog(() => isAdmin = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('CANCELAR'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                    Navigator.pop(dialogContext); // Cierra el modal
                    
                    final success = await adminProvider.createUser({
                      'email': emailController.text.trim(),
                      'password': passwordController.text,
                      'first_name': firstNameController.text.trim(),
                      'last_name': lastNameController.text.trim(),
                      'is_student': isStudent,
                      'is_teacher': isTeacher,
                      'is_staff': isAdmin,
                    });
                    
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario creado correctamente'), backgroundColor: AppColors.success),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(adminProvider.errorMessage ?? 'Error al crear usuario'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  child: const Text('CREAR'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Usuarios'),
      ),
      body: LoadingOverlay(
        isLoading: adminProvider.isLoading,
        child: adminProvider.users.isEmpty
            ? const Center(
                child: Text('No hay usuarios registrados o no tiene permisos'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: adminProvider.users.length,
                itemBuilder: (context, index) {
                  final user = adminProvider.users[index];
                  
                  // Role Text
                  String roles = '';
                  if (user.isTeacher) roles += 'Docente ';
                  if (user.isStudent) roles += 'Estudiante';
                  roles = roles.trim().replaceAll(' ', ' / ');
                  if (roles.isEmpty) roles = 'Usuario General';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        'Email: ${user.email}\nRoles: $roles',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('NUEVO USUARIO'),
      ),
    );
  }
}
