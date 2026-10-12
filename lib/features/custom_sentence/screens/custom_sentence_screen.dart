import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomSentenceScreen extends StatefulWidget {
  const CustomSentenceScreen({super.key});

  @override
  State<CustomSentenceScreen> createState() => _CustomSentenceScreenState();
}

class _CustomSentenceScreenState extends State<CustomSentenceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinar Minha Frase'),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );
  }
}
