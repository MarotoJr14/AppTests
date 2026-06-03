import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_question_result.dart';
import '../models/user_topic_stats.dart';
import '../models/topic.dart';

class StatsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Save last answer for a question (upsert) ─────────────────────────────
  Future<void> saveQuestionResult({
    required String userId,
    required String questionId,
    required String topicId,
    required String topicName,
    required bool isCorrect,
    String? selectedAnswerId,
  }) async {
    final ref = _db
        .collection('userQuestionResults')
        .doc(UserQuestionResult.docId(userId, questionId));
    await ref.set(
      UserQuestionResult(
        userId: userId,
        questionId: questionId,
        topicId: topicId,
        topicName: topicName,
        isCorrect: isCorrect,
        selectedAnswerId: selectedAnswerId,
        answeredAt: DateTime.now(),
      ).toFirestore(),
      // Always overwrite — we only keep the last answer
    );
  }

  // ── Save multiple results in a batch ─────────────────────────────────────
  Future<void> saveQuestionResults(List<UserQuestionResult> results) async {
    if (results.isEmpty) return;
    // Firestore batch max = 500 writes; split if needed
    const chunkSize = 400;
    for (int i = 0; i < results.length; i += chunkSize) {
      final chunk = results.sublist(
          i, i + chunkSize > results.length ? results.length : i + chunkSize);
      final batch = _db.batch();
      for (final r in chunk) {
        final ref = _db
            .collection('userQuestionResults')
            .doc(UserQuestionResult.docId(r.userId, r.questionId));
        batch.set(ref, r.toFirestore());
      }
      await batch.commit();
    }
  }

  // ── Get all question results for a user ──────────────────────────────────
  Future<Map<String, UserQuestionResult>> getUserQuestionResults(
      String userId) async {
    final snap = await _db
        .collection('userQuestionResults')
        .where('userId', isEqualTo: userId)
        .get();
    return {
      for (final doc in snap.docs)
        (doc.data()['questionId'] as String):
        UserQuestionResult.fromFirestore(doc)
    };
  }

  Future<List<UserQuestionResult>> getWrongQuestionResults(
      String userId) async {
    final snap = await _db
        .collection('userQuestionResults')
        .where('userId', isEqualTo: userId)
        .where('isCorrect', isEqualTo: false)
        .get();
    return snap.docs.map(UserQuestionResult.fromFirestore).toList();
  }

  Future<List<UserQuestionResult>> getWrongQuestionResultsByTopic(
      String userId, String topicId) async {
    final snap = await _db
        .collection('userQuestionResults')
        .where('userId', isEqualTo: userId)
        .where('topicId', isEqualTo: topicId)
        .where('isCorrect', isEqualTo: false)
        .get();
    return snap.docs.map(UserQuestionResult.fromFirestore).toList();
  }

  // ── Get answered question IDs for a specific topic ───────────────────────
  Future<Set<String>> getAnsweredQuestionIds(
      String userId, String topicId) async {
    final snap = await _db
        .collection('userQuestionResults')
        .where('userId', isEqualTo: userId)
        .where('topicId', isEqualTo: topicId)
        .get();
    return snap.docs
        .map((d) => d.data()['questionId'] as String)
        .toSet();
  }

  // ── Get all answered question IDs (any topic) ────────────────────────────
  Future<Set<String>> getAllAnsweredQuestionIds(String userId) async {
    final snap = await _db
        .collection('userQuestionResults')
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs
        .map((d) => d.data()['questionId'] as String)
        .toSet();
  }

  // ── Compute topic stats from question results ─────────────────────────────
  /// [topicQuestionCounts] maps topicId → total questions in DB for that topic.
  Future<List<UserTopicStats>> getUserTopicStats(
      String userId,
      Map<String, int> topicQuestionCounts,
      ) async {
    final allResults = await getUserQuestionResults(userId);

    // Group results by topicId
    final Map<String, List<UserQuestionResult>> byTopic = {};
    for (final r in allResults.values) {
      byTopic.putIfAbsent(r.topicId, () => []).add(r);
    }

    return Topic.catalogue.map((entry) {
      final topicId   = entry['id'] as String;
      final topicName = entry['name'] as String;
      final results   = byTopic[topicId] ?? [];
      final correct   = results.where((r) => r.isCorrect).length;
      final total     = topicQuestionCounts[topicId] ?? 0;

      return UserTopicStats(
        userId: userId,
        topicId: topicId,
        topicName: topicName,
        totalQuestions: total,
        answeredUnique: results.length,
        correctUnique: correct,
      );
    }).toList();
  }
}
