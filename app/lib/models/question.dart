import 'package:cloud_firestore/cloud_firestore.dart';

class Answer {
  final String id;   // "a" | "b" | "c" | "d"
  final String text;

  const Answer({required this.id, required this.text});

  factory Answer.fromMap(Map<String, dynamic> m) =>
      Answer(id: m['id'] as String, text: m['text'] as String);

  Map<String, dynamic> toMap() => {'id': id, 'text': text};
}

class Question {
  final String id;
  final String topicId;
  final String topicName;
  final String statement;
  final List<Answer> answers;
  final String correctAnswerId;

  const Question({
    required this.id,
    required this.topicId,
    required this.topicName,
    required this.statement,
    required this.answers,
    required this.correctAnswerId,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      topicId: d['topicId'] as String,
      topicName: d['topicName'] as String? ?? '',
      statement: d['statement'] as String,
      answers: (d['answers'] as List)
          .map((a) => Answer.fromMap(a as Map<String, dynamic>))
          .toList(),
      correctAnswerId: d['correctAnswerId'] as String,
    );
  }

  factory Question.fromMap(Map<String, dynamic> d, String id) {
    return Question(
      id: id,
      topicId: d['topicId'] as String,
      topicName: d['topicName'] as String? ?? '',
      statement: d['statement'] as String,
      answers: (d['answers'] as List)
          .map((a) => Answer.fromMap(a as Map<String, dynamic>))
          .toList(),
      correctAnswerId: d['correctAnswerId'] as String,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'topicId': topicId,
    'topicName': topicName,
    'statement': statement,
    'answers': answers.map((a) => a.toMap()).toList(),
    'correctAnswerId': correctAnswerId,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
