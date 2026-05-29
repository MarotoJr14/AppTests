import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam.dart';
import '../models/topic.dart';
import '../models/user_question_result.dart';
import 'question_service.dart';
import 'stats_service.dart';

class ExamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final QuestionService _questionService = QuestionService();

  // ── Create a new real exam ───────────────────────────────────────────────
  Future<Exam> createExam(String userId, String name) async {
    final existing = await _db
        .collection('exams')
        .where('userId', isEqualTo: userId)
        .where('name', isEqualTo: name.trim())
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw ExamException('Ya existe un examen con ese nombre.');
    }

    final sections = <ExamSection>[];
    for (final entry in Topic.catalogue) {
      final topicId   = entry['id'] as String;
      final topicName = entry['name'] as String;
      final count     = entry['examQuestionCount'] as int;
      final questions = await _questionService.getRandomQuestionsForTopic(topicId, count);
      sections.add(ExamSection(
        topicId: topicId,
        topicName: topicName,
        questionCount: count,
        questions: questions.map(ExamQuestionEntry.fromQuestion).toList(),
      ));
    }

    final docRef = _db.collection('exams').doc();
    final now    = DateTime.now();
    await docRef.set({
      'userId': userId,
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
      'totalQuestions': 45,
      'correctCount': null,
      'status': 'in_progress',
      'sections': sections.map((s) => s.toMap()).toList(),
    });

    return Exam(
      id: docRef.id,
      userId: userId,
      name: name.trim(),
      createdAt: now,
      totalQuestions: 45,
      status: 'in_progress',
      sections: sections,
    );
  }

  // ── Complete an exam ─────────────────────────────────────────────────────
  Future<void> completeExam(Exam exam) async {
    int correct = 0;
    final questionResults = <UserQuestionResult>[];

    for (final s in exam.sections) {
      for (final q in s.questions) {
        if (q.isCorrect == true) correct++;
        if (q.selectedAnswerId != null) {
          questionResults.add(UserQuestionResult(
            userId: exam.userId,
            questionId: q.questionId,
            topicId: s.topicId,
            topicName: s.topicName,
            isCorrect: q.isCorrect == true,
            answeredAt: DateTime.now(),
          ));
        }
      }
    }

    // Update exam document
    final batch = _db.batch();
    final examRef = _db.collection('exams').doc(exam.id);
    batch.update(examRef, {
      'status': 'completed',
      'correctCount': correct,
      'completedAt': FieldValue.serverTimestamp(),
      'sections': exam.sections.map((s) => s.toMap()).toList(),
    });
    await batch.commit();

    // Save per-question results (upsert last answer)
    await StatsService().saveQuestionResults(questionResults);
  }

  // ── Save partial exam progress ────────────────────────────────────────────
  Future<void> saveExamProgress(Exam exam) async {
    await _db.collection('exams').doc(exam.id).update({
      'sections': exam.sections.map((s) => s.toMap()).toList(),
    });
  }

  // ── Get all completed exams for a user ───────────────────────────────────
  Future<List<Exam>> getUserExams(String userId) async {
    final snap = await _db
        .collection('exams')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(Exam.fromFirestore).toList();
  }

  // ── Get a single exam ────────────────────────────────────────────────────
  Future<Exam?> getExam(String examId) async {
    final doc = await _db.collection('exams').doc(examId).get();
    if (!doc.exists) return null;
    return Exam.fromFirestore(doc);
  }
}

class ExamException implements Exception {
  final String message;
  const ExamException(this.message);
  @override
  String toString() => message;
}
