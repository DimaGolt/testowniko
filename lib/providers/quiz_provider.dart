import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';

class QuizProvider with ChangeNotifier {
  List<Question> _allQuestions = [];
  int _currentIndex = -1;
  final Stopwatch _stopwatch = Stopwatch();
  final Random _random = Random();

  // Settings
  int _targetReps = 2;
  int _maxExtraReps = 4;
  int _maxActiveQuestions = 8;
  bool _isDarkMode = false;
  bool _shuffleAnswers = true;

  // State for current question
  List<int> _selectedAnswerIndices = [];
  bool _isAnswered = false;

  List<Question> get allQuestions => _allQuestions;
  int get currentIndex => _currentIndex;
  Question? get currentQuestion => (_currentIndex >= 0 && _currentIndex < _allQuestions.length) 
      ? _allQuestions[_currentIndex] : null;

  int get masteredCount => _allQuestions.where((q) => q.status == QuestionStatus.mastered).length;
  int get unopenedCount => _allQuestions.where((q) => q.status == QuestionStatus.unopened).length;
  int get toRepeatCount => _allQuestions.where((q) => q.status == QuestionStatus.toRepeat).length;

  bool get isDarkMode => _isDarkMode;
  bool get shuffleAnswers => _shuffleAnswers;
  int get targetReps => _targetReps;
  int get maxExtraReps => _maxExtraReps;
  int get maxActiveQuestions => _maxActiveQuestions;
  bool get isAnswered => _isAnswered;
  List<int> get selectedAnswerIndices => _selectedAnswerIndices;

  Duration get elapsedTime => _stopwatch.elapsed;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void loadQuestions(List<Question> questions) {
    _allQuestions = List.from(questions)..shuffle(_random);
    for (var q in _allQuestions) {
      q.requiredRepetitions = _targetReps;
      q.repetitionsDone = 0;
      q.status = QuestionStatus.unopened;
    }
    _currentIndex = -1;
    _stopwatch.reset();
    _stopwatch.start();
    _pickNextQuestion();
  }

  void updateSettings(int target, int maxExtra, bool dark, {int? maxActive, bool? shuffleAnswers}) {
    _targetReps = target;
    _maxExtraReps = maxExtra;
    _isDarkMode = dark;
    if (maxActive != null) _maxActiveQuestions = maxActive;
    if (shuffleAnswers != null) _shuffleAnswers = shuffleAnswers;
    notifyListeners();
  }

  void _pickNextQuestion() {
    int oldIndex = _currentIndex;
    _isAnswered = false;
    _selectedAnswerIndices = [];

    // 1. Get current "to repeat" questions
    List<Question> toRepeat = _allQuestions.where((q) => q.status == QuestionStatus.toRepeat).toList();
    
    // 2. Determine pool from which to pick
    List<Question> currentWorkingPool = List.from(toRepeat);
    
    // 3. If pool is smaller than maxActive, fill it with unopened questions
    if (currentWorkingPool.length < _maxActiveQuestions) {
      List<Question> unopened = _allQuestions.where((q) => q.status == QuestionStatus.unopened).toList();
      // Unopened are already shuffled from loadQuestions, but let's be safe or just take first ones
      int needed = _maxActiveQuestions - currentWorkingPool.length;
      currentWorkingPool.addAll(unopened.take(needed));
    }
    
    if (currentWorkingPool.isEmpty) {
      // Check if there are ANY non-mastered questions left (should be covered above, but for safety)
      List<Question> nonMastered = _allQuestions.where((q) => q.status != QuestionStatus.mastered).toList();
      if (nonMastered.isEmpty) {
        _currentIndex = -1;
        _stopwatch.stop();
        notifyListeners();
        return;
      }
      currentWorkingPool = nonMastered;
    }

    // 4. Try not to show the same question twice in a row if there's choice
    if (currentWorkingPool.length > 1 && oldIndex != -1) {
      currentWorkingPool.removeWhere((q) => _allQuestions.indexOf(q) == oldIndex);
    }
    
    // 5. Pick random from the pool
    currentWorkingPool.shuffle(_random);
    Question next = currentWorkingPool.first;
    _currentIndex = _allQuestions.indexOf(next);

    // Shuffle answer order so user learns content, not position
    if (_shuffleAnswers) next.answers.shuffle(_random);

    notifyListeners();
  }

  void selectAnswer(int index) {
    if (_isAnswered) return;

    final q = currentQuestion;
    if (q == null) return;

    if (q.isMultipleChoice) {
      if (_selectedAnswerIndices.contains(index)) {
        _selectedAnswerIndices.remove(index);
      } else {
        _selectedAnswerIndices.add(index);
      }
    } else {
      _selectedAnswerIndices = [index];
      validateAnswer();
    }
    notifyListeners();
  }

  void validateAnswer() {
    if (_isAnswered || currentQuestion == null) return;
    _isAnswered = true;

    final q = currentQuestion!;
    
    bool isCorrect = true;
    List<int> correctIndices = [];
    for (int i = 0; i < q.answers.length; i++) {
      if (q.answers[i].isCorrect) correctIndices.add(i);
    }

    if (_selectedAnswerIndices.length != correctIndices.length) {
      isCorrect = false;
    } else {
      for (var idx in _selectedAnswerIndices) {
        if (!q.answers[idx].isCorrect) {
          isCorrect = false;
          break;
        }
      }
    }

    if (isCorrect) {
      q.repetitionsDone++;
      if (q.repetitionsDone >= q.requiredRepetitions) {
        q.status = QuestionStatus.mastered;
      } else {
        q.status = QuestionStatus.toRepeat;
      }
    } else {
      q.status = QuestionStatus.toRepeat;
      if (q.requiredRepetitions < _maxExtraReps) {
        q.requiredRepetitions++;
      }
    }

    notifyListeners();
  }

  void goToNext() {
    _pickNextQuestion();
  }

  void stopQuiz() {
    _stopwatch.stop();
  }
}
