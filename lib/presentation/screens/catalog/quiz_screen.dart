import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeacademy/domain/model/quiz.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/providers/catalog_provider.dart';
import 'package:codeacademy/presentation/providers/order_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class QuizScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const QuizScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Quiz? _selectedQuiz;
  QuizAttempt? _currentAttempt;
  
  // Mapping Question ID -> Selected Answer ID
  final Map<int, int> _selectedAnswers = {};
  
  bool _quizFinished = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
      catalogProvider.loadQuizzes(widget.courseId);
      // Load course details to ensure selectedCourse is available for teacher validation
      catalogProvider.loadCourseById(widget.courseId);
    });
  }

  void _startQuiz(Quiz quiz) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);

    final started = await orderProvider.startQuizAttempt(quiz.id);
    if (started && mounted) {
      _selectedQuiz = quiz;
      _currentAttempt = orderProvider.activeAttempt;
      _selectedAnswers.clear();
      _quizFinished = false;
      
      // Load questions for the quiz
      await catalogProvider.loadQuestions(quiz.id);
      setState(() {});
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Error al iniciar el cuestionario'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _viewQuizResults(Quiz quiz) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    setState(() {
      _selectedQuiz = quiz;
      _quizFinished = true; // Use this flag to show results for teacher
    });
    
    await orderProvider.loadQuizAttempts(quiz.id);
  }

  void _submitQuiz() async {
    final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (_selectedAnswers.length < catalogProvider.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, responda todas las preguntas antes de enviar.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_currentAttempt == null) return;

    // Calculate score locally for immediate UX feedback
    int correct = 0;
    for (final q in catalogProvider.questions) {
      final selectedAnsId = _selectedAnswers[q.id];
      if (selectedAnsId != null) {
        final answer = q.answers.firstWhere((a) => a.id == selectedAnsId);
        if (answer.isCorrect) {
          correct++;
        }
      }
    }

    final success = await orderProvider.submitQuizAnswers(_currentAttempt!.id, _selectedAnswers);
    if (success && mounted) {
      setState(() {
        _quizFinished = true;
        _correctCount = correct;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Error al enviar cuestionario'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showCreateQuizDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final questionController = TextEditingController();
    final optAController = TextEditingController();
    final optBController = TextEditingController();
    final optCController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Crear Nueva Evaluación', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Título del Cuestionario'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 20),
                  const Text('Pregunta de la Evaluación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: questionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Texto de la Pregunta'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: optAController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Opción Correcta'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: optBController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Opción Incorrecta 1'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: optCController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Opción Incorrecta 2'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
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
                
                final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
                Navigator.pop(dialogContext); // Close dialog
                
                final success = await catalogProvider.createQuizFull(
                  courseId: widget.courseId,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  questionText: questionController.text.trim(),
                  optionA: optAController.text.trim(),
                  optionB: optBController.text.trim(),
                  optionC: optCController.text.trim(),
                );
                
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Cuestionario creado con éxito!'), backgroundColor: AppColors.success),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(catalogProvider.errorMessage ?? 'Error al crear cuestionario'), backgroundColor: AppColors.error),
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
  }

  @override
  Widget build(BuildContext context) {
    final catalogProvider = Provider.of<CatalogProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final course = catalogProvider.selectedCourse;
    final isTeacherOfCourse = course != null && authProvider.isTeacher && course.teacher == authProvider.session?.userId;
    final showCreateQuizButton = isTeacherOfCourse || authProvider.isAdmin;

    final isLoading = catalogProvider.isLoading || orderProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedQuiz != null ? _selectedQuiz!.title : 'Evaluaciones'),
        leading: _selectedQuiz != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedQuiz = null;
                    _currentAttempt = null;
                    _quizFinished = false;
                  });
                },
              )
            : null,
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: _selectedQuiz == null
            ? _buildQuizList(catalogProvider, authProvider)
            : _quizFinished
                ? (isTeacherOfCourse || authProvider.isAdmin) 
                    ? _buildTeacherResultsView(orderProvider) 
                    : _buildResultsView(catalogProvider)
                : _buildQuestionsView(catalogProvider),
      ),
      floatingActionButton: (_selectedQuiz == null && showCreateQuizButton)
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateQuizDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('NUEVO EXAMEN'),
            )
          : null,
    );
  }

  Widget _buildQuizList(CatalogProvider catalogProvider, AuthProvider authProvider) {
    if (catalogProvider.quizzes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No hay evaluaciones registradas para este curso.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final course = catalogProvider.selectedCourse;
    final isTeacherOfCourse = course != null && authProvider.isTeacher && course.teacher == authProvider.session?.userId;
    final canViewResults = isTeacherOfCourse || authProvider.isAdmin;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: catalogProvider.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = catalogProvider.quizzes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: AppTextStyles.h3,
                ),
                if (quiz.description != null && quiz.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    quiz.description!,
                    style: AppTextStyles.caption,
                  ),
                ],
                const Divider(height: 24, color: AppColors.surfaceLight),
                ElevatedButton(
                  onPressed: () {
                    if (canViewResults) {
                      _viewQuizResults(quiz);
                    } else {
                      _startQuiz(quiz);
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                  child: Text(canViewResults ? 'VER RESULTADOS DE ESTUDIANTES' : 'INICIAR EVALUACIÓN'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionsView(CatalogProvider catalogProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: catalogProvider.questions.length,
            itemBuilder: (context, qIndex) {
              final question = catalogProvider.questions[qIndex];
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pregunta ${qIndex + 1}: ${question.text}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      ...question.answers.map((answer) {
                        final isSelected = _selectedAnswers[question.id] == answer.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected ? AppColors.primary.withAlpha(20) : Colors.transparent,
                          ),
                          child: RadioListTile<int>(
                            title: Text(answer.text, style: const TextStyle(color: AppColors.textPrimary)),
                            value: answer.id,
                            groupValue: _selectedAnswers[question.id],
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                if (val != null) {
                                  _selectedAnswers[question.id] = val;
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: _submitQuiz,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('ENVIAR EVALUACIÓN'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(CatalogProvider catalogProvider) {
    final total = catalogProvider.questions.length;
    final percentage = total > 0 ? (_correctCount / total) * 100 : 0.0;
    final passed = percentage >= 70.0; // standard passing score limit

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed ? Icons.emoji_events_rounded : Icons.cancel_rounded,
              size: 100,
              color: passed ? AppColors.success : AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              passed ? '¡Felicitaciones! Has aprobado' : 'No has aprobado la evaluación',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Respuestas Correctas: $_correctCount de $total (${percentage.toStringAsFixed(1)}%)',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedQuiz = null;
                  _currentAttempt = null;
                  _quizFinished = false;
                });
              },
              child: const Text('VOLVER A EVALUACIONES'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherResultsView(OrderProvider orderProvider) {
    if (orderProvider.quizAttempts.isEmpty) {
      return const Center(
        child: Text(
          'Ningún estudiante ha tomado esta evaluación aún.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderProvider.quizAttempts.length,
      itemBuilder: (context, index) {
        final attempt = orderProvider.quizAttempts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              attempt.passed ? Icons.check_circle : Icons.cancel,
              color: attempt.passed ? AppColors.success : AppColors.error,
              size: 32,
            ),
            title: Text('Estudiante: ${attempt.studentEmail ?? attempt.student}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text('Puntuación: ${attempt.score}%\nRealizado el: ${attempt.startedAt.day}/${attempt.startedAt.month}/${attempt.startedAt.year}'),
            trailing: Text(
              attempt.passed ? 'Aprobado' : 'Reprobado',
              style: TextStyle(
                color: attempt.passed ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
