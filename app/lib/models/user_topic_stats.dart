/// Computed stats for a topic, derived from UserQuestionResult records.
/// Not stored in Firestore — calculated client-side from userQuestionResults.
class UserTopicStats {
  final String userId;
  final String topicId;
  final String topicName;
  final int totalQuestions;   // total questions in DB for this topic
  final int answeredUnique;   // unique questions answered at least once
  final int correctUnique;    // unique questions whose LAST answer was correct

  const UserTopicStats({
    required this.userId,
    required this.topicId,
    required this.topicName,
    required this.totalQuestions,
    required this.answeredUnique,
    required this.correctUnique,
  });

  /// Rate based on unique questions: correct last answers / total questions in DB
  double get correctRate =>
      totalQuestions == 0 ? 0 : correctUnique / totalQuestions;

  factory UserTopicStats.empty(String userId, String topicId, String topicName) =>
      UserTopicStats(
        userId: userId,
        topicId: topicId,
        topicName: topicName,
        totalQuestions: 0,
        answeredUnique: 0,
        correctUnique: 0,
      );

  static String docId(String userId, String topicId) => '${userId}_$topicId';
}
