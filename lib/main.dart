import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const TestownikoApp(),
    ),
  );
}

class TestownikoApp extends StatelessWidget {
  const TestownikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return MaterialApp(
          title: 'Testowniko',
          debugShowCheckedModeBanner: false,
          themeMode: quizProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/quiz': (context) => const QuizScreen(),
            '/result': (context) => const ResultScreen(),
          },
        );
      },
    );
  }
}
