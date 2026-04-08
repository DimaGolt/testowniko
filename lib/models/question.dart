enum QuestionStatus { unopened, toRepeat, mastered }

class Answer {
  final String text;
  final bool isCorrect;

  Answer({required this.text, required this.isCorrect});
}

class Question {
  final String id;
  final String content;
  final List<Answer> answers;
  final bool isMultipleChoice;
  int repetitionsDone;
  int requiredRepetitions;
  QuestionStatus status;

  Question({
    required this.id,
    required this.content,
    required this.answers,
    this.isMultipleChoice = false,
    this.repetitionsDone = 0,
    this.requiredRepetitions = 2,
    this.status = QuestionStatus.unopened,
  });

  factory Question.fromRawData(int id, String rawContent, List<String> rawAnswers) {
    List<Answer> answers = [];
    bool isMultiple = rawAnswers.where((a) => a.startsWith('*')).length > 1;

    for (var rawAns in rawAnswers) {
      bool correct = rawAns.startsWith('*');
      String text = correct ? rawAns.substring(1).trim() : rawAns.trim();
      // Remove prefix like 'a. ', 'b. ' if exists
      if (text.contains('. ')) {
        text = text.split('. ').sublist(1).join('. ');
      }
      answers.add(Answer(text: text, isCorrect: correct));
    }

    return Question(
      id: id.toString(),
      content: rawContent.trim(),
      answers: answers,
      isMultipleChoice: isMultiple,
    );
  }
}
