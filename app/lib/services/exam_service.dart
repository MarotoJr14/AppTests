import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam.dart';
import '../models/topic.dart';
import '../models/user_topic_stats.dart';
import 'question_service.dart';

class ExamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final QuestionService _questionService = QuestionService();

  // ── Create a new real exam ───────────────────────────────────────────────
  /// Returns the created [Exam] or throws [ExamException] if name exists.
  Future<Exam> createExam(String userId, String name) async {
    // 1. Check uniqueness
    final existing = await _db
        .collection('exams')
        .where('userId', isEqualTo: userId)
        .where('name', isEqualTo: name.trim())
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw ExamException('Ya existe un examen con ese nombre.');
    }

    // 2. Build sections by pulling random questions per topic
    final sections = <ExamSection>[];
    for (final entry in Topic.catalogue) {
      final topicId = entry['id'] as String;
      final topicName = entry['name'] as String;
      final count = entry['examQuestionCount'] as int;

      final questions =
          await _questionService.getRandomQuestionsForTopic(topicId, count);

      sections.add(ExamSection(
        topicId: topicId,
        topicName: topicName,
        questionCount: count,
        questions: questions
            .map(ExamQuestionEntry.fromQuestion)
            .toList(),
      ));
    }

    // 3. Write to Firestore
    final docRef = _db.collection('exams').doc();
    final now = DateTime.now();
    final data = {
      'userId': userId,
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
      'totalQuestions': 45,
      'correctCount': null,
      'status': 'in_progress',
      'sections': sections.map((s) => s.toMap()).toList(),
    };
    await docRef.set(data);

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
    // Calculate correct count
    int correct = 0;
    for (final s in exam.sections) {
      for (final q in s.questions) {
        if (q.isCorrect == true) correct++;
      }
    }

    final batch = _db.batch();

    // Update exam document
    final examRef = _db.collection('exams').doc(exam.id);
    batch.update(examRef, {
      'status': 'completed',
      'correctCount': correct,
      'completedAt': FieldValue.serverTimestamp(),
      'sections': exam.sections.map((s) => s.toMap()).toList(),
    });

    // Update userTopicStats per section
    for (final section in exam.sections) {
      int sectionCorrect = 0;
      for (final q in section.questions) {
        if (q.isCorrect == true) sectionCorrect++;
      }
      final statsRef = _db
          .collection('userTopicStats')
          .doc(UserTopicStats.docId(exam.userId, section.topicId));

      batch.set(
        statsRef,
        {
          'userId': exam.userId,
          'topicId': section.topicId,
          'topicName': section.topicName,
          'totalAnswered': FieldValue.increment(section.questions.length),
          'totalCorrect': FieldValue.increment(sectionCorrect),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  // ── Save partial exam progress (answers) ─────────────────────────────────
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

  // ── Update topic stats for free practice (topic or random battery) ───────
  Future<void> updateStatsForPractice({
    required String userId,
    required String topicId,
    required String topicName,
    required int answered,
    required int correct,
  }) async {
    final statsRef = _db
        .collection('userTopicStats')
        .doc(UserTopicStats.docId(userId, topicId));
    await statsRef.set(
      {
        'userId': userId,
        'topicId': topicId,
        'topicName': topicName,
        'totalAnswered': FieldValue.increment(answered),
        'totalCorrect': FieldValue.increment(correct),
      },
      SetOptions(merge: true),
    );
  }
}

class ExamException implements Exception {
  final String message;
  const ExamException(this.message);
  @override
  String toString() => message;
}
