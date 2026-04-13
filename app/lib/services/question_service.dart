import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';

class QuestionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _rng = Random();

  // ── Get all questions for a topic ────────────────────────────────────────
  Future<List<Question>> getQuestionsByTopic(String topicId) async {
    final snap = await _db
        .collection('questions')
        .where('topicId', isEqualTo: topicId)
        .get();
    return snap.docs.map(Question.fromFirestore).toList();
  }

  // ── Get N random questions for a topic ──────────────────────────────────
  Future<List<Question>> getRandomQuestionsForTopic(
    String topicId,
    int count,
  ) async {
    final all = await getQuestionsByTopic(topicId);
    if (all.isEmpty) return [];
    all.shuffle(_rng);
    return all.take(count).toList();
  }

  // ── Get random questions across all topics ───────────────────────────────
  Future<List<Question>> getRandomQuestions({int count = 20}) async {
    final snap = await _db.collection('questions').get();
    final all = snap.docs.map(Question.fromFirestore).toList();
    all.shuffle(_rng);
    return all.take(count).toList();
  }

  // ── Shuffle answers (client-side) ────────────────────────────────────────
  List<Answer> shuffleAnswers(List<Answer> answers) {
    final list = List<Answer>.from(answers);
    list.shuffle(_rng);
    return list;
  }
}
