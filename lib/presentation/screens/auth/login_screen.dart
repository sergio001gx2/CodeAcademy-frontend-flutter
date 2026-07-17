import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/core/utils/validators.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido, ${authProvider.session?.email}!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Error de autenticación'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showRecoveryDialog() {
    final emailController = TextEditingController();
    final codeController = TextEditingController();
    final passwordController = TextEditingController();
    
    final step1FormKey = GlobalKey<FormState>();
    final step2FormKey = GlobalKey<FormState>();
    
    int currentStep = 1;
    bool isRequesting = false;
    String userEmail = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (currentStep == 1) {
              // STEP 1: Enter Email
              return AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text(
                  'Recuperar Contraseña',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: step1FormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Ingrese el correo electrónico de su cuenta para enviarle un código de verificación.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: isRequesting
                    ? [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      ]
                    : [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'CANCELAR',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (!step1FormKey.currentState!.validate()) return;

                            setStateDialog(() {
                              isRequesting = true;
                            });

                            // Simulate sending email
                            await Future.delayed(const Duration(seconds: 1));

                            userEmail = emailController.text.trim();
                            
                            setStateDialog(() {
                              isRequesting = false;
                              currentStep = 2;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Código de verificación enviado a su correo.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          child: const Text('ENVIAR'),
                        ),
                      ],
              );
            } else {
              // STEP 2: Enter Code and New Password
              return AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text(
                  'Confirmar Restablecimiento',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: step2FormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Se ha enviado un código a $userEmail. Ingrese el código y su nueva contraseña.',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: codeController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Código de verificación',
                            prefixIcon: Icon(Icons.security_rounded),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Requerido';
                            if (val.trim() != '842915') {
                              return 'Código de verificación incorrecto';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Nueva contraseña',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: Validators.validatePassword,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: isRequesting
                    ? [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      ]
                    : [
                        TextButton(
                          onPressed: () {
                            setStateDialog(() {
                              currentStep = 1;
                            });
                          },
                          child: const Text(
                            'ATRÁS',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (!step2FormKey.currentState!.validate()) return;

                            setStateDialog(() {
                              isRequesting = true;
                            });

                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final success = await authProvider.confirmRecoveryNotification(
                              userEmail,
                              passwordController.text,
                            );

                            if (context.mounted) {
                              Navigator.pop(dialogContext); // Close dialog
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Contraseña restablecida con éxito! Inicie sesión.'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error al guardar la nueva contraseña.'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('RESTABLECER'),
                        ),
                      ],
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authProvider.status == AuthStatus.loading,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Header
                  const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CodeAcademy',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión para continuar aprendiendo',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 40),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                          ),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('INGRESAR'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _showRecoveryDialog,
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Register redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
