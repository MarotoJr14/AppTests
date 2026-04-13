import 'package:cloud_firestore/cloud_firestore.dart';

class UserTopicStats {
  final String userId;
  final String topicId;
  final String topicName;
  final int totalAnswered;
  final int totalCorrect;

  const UserTopicStats({
    required this.userId,
    required this.topicId,
    required this.topicName,
    required this.totalAnswered,
    required this.totalCorrect,
  });

  double get correctRate =>
      totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

  static String docId(String userId, String topicId) => '${userId}_$topicId';

  factory UserTopicStats.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserTopicStats(
      userId: d['userId'] as String,
      topicId: d['topicId'] as String,
      topicName: d['topicName'] as String,
      totalAnswered: d['totalAnswered'] as int,
      totalCorrect: d['totalCorrect'] as int,
    );
  }

  factory UserTopicStats.empty(String userId, String topicId, String topicName) =>
      UserTopicStats(
        userId: userId,
        topicId: topicId,
        topicName: topicName,
        totalAnswered: 0,
        totalCorrect: 0,
      );

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'topicId': topicId,
    'topicName': topicName,
    'totalAnswered': totalAnswered,
    'totalCorrect': totalCorrect,
  };
}
