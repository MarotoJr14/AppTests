import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

// ── ExamQuestionEntry ─────────────────────────────────────────────────────
// Snapshot of a question inside an exam (embedded, not a reference)
class ExamQuestionEntry {
  final String questionId;
  final String statement;
  final List<Answer> answers;       // stored in fixed order
  final String correctAnswerId;
  String? selectedAnswerId;         // filled as user answers
  bool? isCorrect;

  ExamQuestionEntry({
    required this.questionId,
    required this.statement,
    required this.answers,
    required this.correctAnswerId,
    this.selectedAnswerId,
    this.isCorrect,
  });

  factory ExamQuestionEntry.fromQuestion(Question q) => ExamQuestionEntry(
    questionId: q.id,
    statement: q.statement,
    answers: q.answers,
    correctAnswerId: q.correctAnswerId,
  );

  factory ExamQuestionEntry.fromMap(Map<String, dynamic> m) => ExamQuestionEntry(
    questionId: m['questionId'] as String,
    statement: m['statement'] as String,
    answers: (m['answers'] as List)
        .map((a) => Answer.fromMap(a as Map<String, dynamic>))
        .toList(),
    correctAnswerId: m['correctAnswerId'] as String,
    selectedAnswerId: m['selectedAnswerId'] as String?,
    isCorrect: m['isCorrect'] as bool?,
  );

  Map<String, dynamic> toMap() => {
    'questionId': questionId,
    'statement': statement,
    'answers': answers.map((a) => a.toMap()).toList(),
    'correctAnswerId': correctAnswerId,
    'selectedAnswerId': selectedAnswerId,
    'isCorrect': isCorrect,
  };
}

// ── ExamSection ───────────────────────────────────────────────────────────
class ExamSection {
  final String topicId;
  final String topicName;
  final int questionCount;
  final List<ExamQuestionEntry> questions;

  const ExamSection({
    required this.topicId,
    required this.topicName,
    required this.questionCount,
    required this.questions,
  });

  factory ExamSection.fromMap(Map<String, dynamic> m) => ExamSection(
    topicId: m['topicId'] as String,
    topicName: m['topicName'] as String,
    questionCount: m['questionCount'] as int,
    questions: (m['questions'] as List)
        .map((q) => ExamQuestionEntry.fromMap(q as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'topicId': topicId,
    'topicName': topicName,
    'questionCount': questionCount,
    'questions': questions.map((q) => q.toMap()).toList(),
  };
}

// ── Exam ──────────────────────────────────────────────────────────────────
class Exam {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int totalQuestions;
  final int? correctCount;
  final String status;           // "in_progress" | "completed"
  final List<ExamSection> sections;

  const Exam({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    this.completedAt,
    required this.totalQuestions,
    this.correctCount,
    required this.status,
    required this.sections,
  });

  factory Exam.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Exam(
      id: doc.id,
      userId: d['userId'] as String,
      name: d['name'] as String,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      completedAt: d['completedAt'] != null
          ? (d['completedAt'] as Timestamp).toDate()
          : null,
      totalQuestions: d['totalQuestions'] as int,
      correctCount: d['correctCount'] as int?,
      status: d['status'] as String,
      sections: (d['sections'] as List)
          .map((s) => ExamSection.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Flat list of all questions across sections (for review mode)
  List<ExamQuestionEntry> get allQuestions =>
      sections.expand((s) => s.questions).toList();
}
