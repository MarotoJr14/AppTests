import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_topic_stats.dart';
import '../models/topic.dart';

class StatsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Get stats for all topics for a user ──────────────────────────────────
  /// Returns a list aligned to Topic.catalogue order.
  /// Topics with no data get an empty stats object.
  Future<List<UserTopicStats>> getUserTopicStats(String userId) async {
    final snap = await _db
        .collection('userTopicStats')
        .where('userId', isEqualTo: userId)
        .get();

    final map = {
      for (final doc in snap.docs)
        (doc.data()['topicId'] as String): UserTopicStats.fromFirestore(doc)
    };

    return Topic.catalogue.map((entry) {
      final topicId = entry['id'] as String;
      final topicName = entry['name'] as String;
      return map[topicId] ??
          UserTopicStats.empty(userId, topicId, topicName);
    }).toList();
  }
}
