import '../models/question.dart';

class FileParserService {
  static List<Question> parseRawText(String content) {
    List<Question> questions = [];
    List<String> lines = content.split('\n');
    
    String? currentQuestionText;
    List<String> currentAnswers = [];
    int questionId = 1;

    for (var line in lines) {
      String trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        if (currentQuestionText != null && currentAnswers.isNotEmpty) {
          questions.add(Question.fromRawData(questionId++, currentQuestionText, currentAnswers));
          currentQuestionText = null;
          currentAnswers = [];
        }
        continue;
      }

      // Check if line starts with a number (Question)
      if (RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
        if (currentQuestionText != null && currentAnswers.isNotEmpty) {
          questions.add(Question.fromRawData(questionId++, currentQuestionText, currentAnswers));
          currentAnswers = [];
        }
        // Extract question text after "1. "
        currentQuestionText = trimmedLine.replaceFirst(RegExp(r'^\d+\.\s*'), '');
      } else if (currentQuestionText != null) {
        // It's an answer line
        currentAnswers.add(trimmedLine);
      }
    }

    // Add last question if exists
    if (currentQuestionText != null && currentAnswers.isNotEmpty) {
      questions.add(Question.fromRawData(questionId++, currentQuestionText, currentAnswers));
    }

    return questions;
  }
}
