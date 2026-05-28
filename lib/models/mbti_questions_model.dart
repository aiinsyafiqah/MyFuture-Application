class Question {
  final String id;
  final String text;
  final String dimension; // 'EI', 'SN', 'TF', 'JP'
  final int direction;    // 1 or -1

  Question({
    required this.id,
    required this.text,
    required this.dimension,
    required this.direction,
  });

  // Factory to create a Question from a Map (JSON)
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      dimension: map['dimension'] ?? '',
      direction: map['direction']?.toInt() ?? 0,
    );
  }
}