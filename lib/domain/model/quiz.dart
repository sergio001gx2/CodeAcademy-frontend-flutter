class Quiz {
  final int id;
  final String title;
  final String? description;
  final int course;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.course,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      course: json['course'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'course': course,
      };
}

class Question {
  final int id;
  final String text;
  final int order;
  final int quiz;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.text,
    required this.order,
    required this.quiz,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final list = json['answers'] as List? ?? [];
    return Question(
      id: json['id'] as int,
      text: json['text'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      quiz: json['quiz'] as int,
      answers: list.map((a) => Answer.fromJson(a)).toList(),
    );
  }
}

class Answer {
  final int id;
  final String text;
  final bool isCorrect;
  final int question;

  Answer({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.question,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as int,
      text: json['text'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      question: json['question'] as int,
    );
  }
}

class QuizAttempt {
  final int id;
  final int student;
  final String? studentEmail;
  final int quiz;
  final double score;
  final bool passed;
  final DateTime startedAt;
  final DateTime? completedAt;

  QuizAttempt({
    required this.id,
    required this.student,
    this.studentEmail,
    required this.quiz,
    required this.score,
    required this.passed,
    required this.startedAt,
    this.completedAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as int,
      student: json['student'] as int? ?? 0,
      studentEmail: json['student_email'] as String?,
      quiz: json['quiz'] as int,
      score: double.tryParse(json['score']?.toString() ?? '0.0') ?? 0.0,
      passed: json['passed'] as bool? ?? false,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }
}
