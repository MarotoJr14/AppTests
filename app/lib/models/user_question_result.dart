import 'package:cloud_firestore/cloud_firestore.dart';

/// Stores the LAST answer the user gave to a specific question.
/// Document ID: '{userId}_{questionId}'
/// This replaces cumulative counters for topic stats.
class UserQuestionResult {
  final String userId;
  final String questionId;
  final String topicId;
  final String topicName;
  final bool isCorrect;
  final DateTime answeredAt;

  const UserQuestionResult({
    required this.userId,
    required this.questionId,
    required this.topicId,
    required this.topicName,
    required this.isCorrect,
    required this.answeredAt,
  });

  static String docId(String userId, String questionId) =>
      '${userId}_$questionId';

  factory UserQuestionResult.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserQuestionResult(
      userId: d['userId'] as String,
      questionId: d['questionId'] as String,
      topicId: d['topicId'] as String,
      topicName: d['topicName'] as String,
      isCorrect: d['isCorrect'] as bool,
      answeredAt: (d['answeredAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'questionId': questionId,
    'topicId': topicId,
    'topicName': topicName,
    'isCorrect': isCorrect,
    'answeredAt': FieldValue.serverTimestamp(),
  };
}
