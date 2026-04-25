import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../services/file_parser_service.dart';
import '../services/storage_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final StorageService _storageService = StorageService();
  List<String> _recentFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final settings = await _storageService.loadSettings();
    final recent = await _storageService.getRecentFilesNames();
    
    if (mounted) {
      context.read<QuizProvider>().updateSettings(
        settings['targetReps'],
        settings['maxExtraReps'],
        settings['isDarkMode'],
        maxActive: settings['maxActiveQuestions'] ?? 8,
        shuffleAnswers: settings['shuffleAnswers'] ?? true,
      );
      setState(() {
        _recentFiles = recent;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final content = utf8.decode(result.files.single.bytes!);
      final questions = FileParserService.parseRawText(content);
      
      if (questions.isNotEmpty) {
        if (mounted) {
          final fileName = result.files.single.name;
          await _storageService.saveFileContent(fileName, content);
          context.read<QuizProvider>().loadQuestions(questions);
          Navigator.pushNamed(context, '/quiz');
          _loadInitialData(); // Refresh list
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nie znaleziono pytań w pliku.')),
          );
        }
      }
    }
  }

  Future<void> _loadRecentFile(String fileName) async {
    final content = await _storageService.getFileContent(fileName);
    if (content != null) {
      final questions = FileParserService.parseRawText(content);
      if (questions.isNotEmpty && mounted) {
        context.read<QuizProvider>().loadQuestions(questions);
        Navigator.pushNamed(context, '/quiz');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Testowniko',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  if (_recentFiles.isNotEmpty) ...[
                    Text('Ostatnie testy:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._recentFiles.map((file) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(file),
                        onTap: () => _loadRecentFile(file),
                      ),
                    )),
                    const SizedBox(height: 24),
                    const Text('LUB', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                  ],

                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('ZAŁADUJ NOWY TEST'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 48),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  Text('Ustawienia nauki:', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  
                  _buildSettingRow(
                    'Powtórzenia do opanowania:',
                    quizProvider.targetReps,
                    (val) => _updateSettings(target: val.round()),
                    min: 1, max: 10,
                  ),
                  
                  _buildSettingRow(
                    'Max powtórzeń po błędzie:',
                    quizProvider.maxExtraReps,
                    (val) => _updateSettings(maxExtra: val.round()),
                    min: 1, max: 10,
                  ),

                  _buildSettingRow(
                    'Wielkość aktywnej puli pytań:',
                    quizProvider.maxActiveQuestions,
                    (val) => _updateSettings(maxActive: val.round()),
                    min: 1, max: 50,
                  ),

                  SwitchListTile(
                    title: const Text('Losowa kolejność odpowiedzi'),
                    subtitle: const Text('Odpowiedzi będą tasowane przy każdym pytaniu'),
                    value: quizProvider.shuffleAnswers,
                    onChanged: (val) => _updateSettings(shuffleAnswers: val),
                  ),

                  SwitchListTile(
                    title: const Text('Tryb ciemny'),
                    value: quizProvider.isDarkMode,
                    onChanged: (val) => _updateSettings(dark: val),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, int value, ValueChanged<double> onChanged, {double min = 1, double max = 10}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label $value'),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _updateSettings({int? target, int? maxExtra, bool? dark, int? maxActive, bool? shuffleAnswers}) {
    final quiz = context.read<QuizProvider>();
    final newTarget = target ?? quiz.targetReps;
    final newMaxExtra = maxExtra ?? quiz.maxExtraReps;
    final newDark = dark ?? quiz.isDarkMode;
    final newMaxActive = maxActive ?? quiz.maxActiveQuestions;
    final newShuffle = shuffleAnswers ?? quiz.shuffleAnswers;

    quiz.updateSettings(newTarget, newMaxExtra, newDark, maxActive: newMaxActive, shuffleAnswers: newShuffle);
    _storageService.saveSettings(
      targetReps: newTarget,
      maxExtraReps: newMaxExtra,
      maxActive: newMaxActive,
      isDarkMode: newDark,
      shuffleAnswers: newShuffle,
    );
  }
}
