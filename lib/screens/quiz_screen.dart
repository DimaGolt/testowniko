import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to refresh the UI every second to show updated elapsed time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<QuizProvider>(
          builder: (context, quiz, child) {
            final duration = quiz.elapsedTime;
            String twoDigits(int n) => n.toString().padLeft(2, "0");
            String minutes = twoDigits(duration.inMinutes.remainder(60));
            String seconds = twoDigits(duration.inSeconds.remainder(60));
            return Text('Testowniko ($minutes:$seconds)');
          },
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quiz, child) {
          final question = quiz.currentQuestion;

          if (question == null) {
            // Quiz finished
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/result');
            });
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStats(quiz),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.content,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            ...List.generate(question.answers.length, (index) {
                              return _buildAnswerTile(context, quiz, question, index);
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(context, quiz, question),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(QuizProvider quiz) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem('Opanowane', quiz.masteredCount, Colors.green),
        _statItem('Nieotwarte', quiz.unopenedCount, Colors.blue),
        _statItem('Do powtórki', quiz.toRepeatCount, Colors.orange),
      ],
    );
  }

  Widget _statItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAnswerTile(BuildContext context, QuizProvider quiz, Question question, int index) {
    final answer = question.answers[index];
    final isSelected = quiz.selectedAnswerIndices.contains(index);
    final isAnswered = quiz.isAnswered;

    Color? tileColor;
    if (isAnswered) {
      if (answer.isCorrect) {
        tileColor = isSelected ? Colors.green.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.15);
      } else if (isSelected) {
        tileColor = Colors.red.withValues(alpha: 0.3);
      }
    }

    BorderSide borderSide = BorderSide(
      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
      width: isSelected ? 2 : 1,
    );

    if (isAnswered) {
      if (answer.isCorrect) {
        borderSide = const BorderSide(color: Colors.green, width: 2);
      } else if (isSelected) {
        borderSide = const BorderSide(color: Colors.red, width: 2);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: isAnswered ? null : () => quiz.selectAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.fromBorderSide(borderSide),
          ),
          child: Row(
            children: [
              if (question.isMultipleChoice)
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: _getIconColor(isAnswered, isSelected, answer.isCorrect, context),
                )
              else
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: _getIconColor(isAnswered, isSelected, answer.isCorrect, context),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  answer.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isAnswered && !answer.isCorrect && !isSelected ? Colors.grey : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconColor(bool isAnswered, bool isSelected, bool isCorrect, BuildContext context) {
    if (isAnswered) {
      if (isCorrect) return Colors.green;
      if (isSelected) return Colors.red;
      return Colors.grey;
    }
    return isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;
  }

  Widget _buildActionButtons(BuildContext context, QuizProvider quiz, Question question) {
    if (quiz.isAnswered) {
      return ElevatedButton(
        onPressed: () => quiz.goToNext(),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
        child: const Text('NASTĘPNE PYTANIE'),
      );
    }

    if (question.isMultipleChoice) {
      return ElevatedButton(
        onPressed: quiz.selectedAnswerIndices.isEmpty ? null : () => quiz.validateAnswer(),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
        child: const Text('ZATWIERDŹ'),
      );
    }

    return const SizedBox.shrink();
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wyjść z quizu?'),
        content: const Text('Twój postęp w tej sesji zostanie utracony.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANULUJ')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit quiz
            },
            child: const Text('WYJDŹ'),
          ),
        ],
      ),
    );
  }
}
