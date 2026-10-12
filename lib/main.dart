import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VocalisApp());
}

class VocalisApp extends StatelessWidget {
  const VocalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocalis • Treino Fonético',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
