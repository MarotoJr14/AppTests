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

  // ── Get all questions (all topics) ───────────────────────────────────────
  Future<List<Question>> getAllQuestions() async {
    final snap = await _db.collection('questions').get();
    return snap.docs.map(Question.fromFirestore).toList();
  }

  // ── Get questions for a topic, unanswered first, then answered ───────────
  /// Mejora 2: show unanswered questions first; if all answered, show all.
  /// Battery ends only when the user taps "Terminar".
  Future<List<Question>> getBatteryForTopic(
      String topicId,
      Set<String> answeredIds,
      ) async {
    final all = await getQuestionsByTopic(topicId);
    if (all.isEmpty) return [];

    final unanswered = all.where((q) => !answeredIds.contains(q.id)).toList()
      ..shuffle(_rng);
    final answered   = all.where((q) =>  answeredIds.contains(q.id)).toList()
      ..shuffle(_rng);

    // Unanswered first, then already-answered ones
    return [...unanswered, ...answered];
  }

  // ── Get questions for random battery, unanswered first ───────────────────
  Future<List<Question>> getBatteryRandom(Set<String> answeredIds) async {
    final all = await getAllQuestions();
    if (all.isEmpty) return [];

    final unanswered = all.where((q) => !answeredIds.contains(q.id)).toList()
      ..shuffle(_rng);
    final answered   = all.where((q) =>  answeredIds.contains(q.id)).toList()
      ..shuffle(_rng);

    return [...unanswered, ...answered];
  }

  // ── Get N random questions for a topic (used by real exam) ───────────────
  Future<List<Question>> getRandomQuestionsForTopic(
      String topicId,
      int count,
      ) async {
    final all = await getQuestionsByTopic(topicId);
    if (all.isEmpty) return [];
    all.shuffle(_rng);
    return all.take(count).toList();
  }

  // ── Get total question counts per topic ───────────────────────────────────
  Future<Map<String, int>> getTopicQuestionCounts() async {
    final all = await getAllQuestions();
    final counts = <String, int>{};
    for (final q in all) {
      counts[q.topicId] = (counts[q.topicId] ?? 0) + 1;
    }
    return counts;
  }

  // ── Shuffle answers (client-side) ────────────────────────────────────────
  List<Answer> shuffleAnswers(List<Answer> answers) {
    final list = List<Answer>.from(answers);
    list.shuffle(_rng);
    return list;
  }
}
