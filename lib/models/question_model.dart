class ConceptQuestion {
  final String conceptId;
  final String topic;
  final String formula;
  final QuizItem primary;
  final QuizItem reinforcement;

  ConceptQuestion({
    required this.conceptId,
    required this.topic,
    required this.formula,
    required this.primary,
    required this.reinforcement,
  });
}

class QuizItem {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizItem({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

final List<ConceptQuestion> sampleQuestionBank = [
  ConceptQuestion(
    conceptId: 'phy_kinematics_01',
    topic: 'Kinematics',
    formula: 'v = u + at',
    primary: QuizItem(
      question: 'A car starts from rest (u = 0) with an acceleration of 2 m/s² for 5 seconds. What is its final velocity?',
      options: ['5 m/s', '10 m/s', '15 m/s', '20 m/s'],
      correctIndex: 1,
      explanation: 'Formula: v = u + at\nu = 0, a = 2 m/s², t = 5 s\nv = 0 + (2 * 5) = 10 m/s',
    ),
    reinforcement: QuizItem(
      question: 'A bike accelerates from rest with 3 m/s² for 4 seconds. Calculate final speed:',
      options: ['7 m/s', '10 m/s', '12 m/s', '15 m/s'],
      correctIndex: 2,
      explanation: 'Formula: v = u + at\nv = 0 + (3 * 4) = 12 m/s',
    ),
  ),
  ConceptQuestion(
    conceptId: 'math_algebra_01',
    topic: 'Algebra',
    formula: '(a + b)² = a² + 2ab + b²',
    primary: QuizItem(
      question: 'Expand (x + 3)²',
      options: ['x² + 6x + 9', 'x² + 3x + 9', 'x² + 9', 'x² + 6x + 6'],
      correctIndex: 0,
      explanation: 'Formula: (a + b)² = a² + 2ab + b²\nHere a = x, b = 3\nx² + 2(x)(3) + 3² = x² + 6x + 9',
    ),
    reinforcement: QuizItem(
      question: 'Expand (y + 5)²',
      options: ['y² + 25', 'y² + 10y + 25', 'y² + 5y + 25', 'y² + 10y + 10'],
      correctIndex: 1,
      explanation: 'Formula: (a + b)² = a² + 2ab + b²\ny² + 2(y)(5) + 5² = y² + 10y + 25',
    ),
  ),
];
