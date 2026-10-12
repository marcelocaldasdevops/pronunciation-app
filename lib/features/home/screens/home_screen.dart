import 'package:flutter/material.dart';
import '../../../core/navigation/app_navigation_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pronunciation_type_selector.dart';
import '../../practice/screens/practice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocalis • Treino Fonético'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            tooltip: 'Tabela IPA',
            onPressed: () {
              AppNavigationScaffold.switchTab(context, 3);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de Streak e Metas Diárias
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.scoreYellow.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.scoreYellow),
                      ),
                      child: const Center(
                        child: Text('🔥', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '5 Dias Seguidos!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Meta de hoje: 3 de 5 lições concluídas',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircularProgressIndicator(
                      value: 0.6,
                      backgroundColor: AppTheme.surfaceLight,
                      color: AppTheme.primary,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Seletor de Tipo de Pronúncia
              const PronunciationTypeSelector(),

              const SizedBox(height: 20),

              // Botão Principal: Praticar Agora
              InkWell(
                onTap: () {
                  AppNavigationScaffold.switchTab(context, 2);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mic, color: Colors.white, size: 36),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Iniciar Prática Rápida',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Avalie sua pronúncia fonema a fonema',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Botão Secundário: Treinar Minha Frase
              InkWell(
                onTap: () {
                  AppNavigationScaffold.switchTab(context, 1);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Treinar Minha Frase',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Digite ou cole sua frase para análise instantânea',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Módulos de Domínio Fonético',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              _buildModuleCard(
                context,
                title: 'O Som do TH (/θ/ e /ð/)',
                subtitle: 'Aprenda o posicionamento correto da língua para "think" vs "this"',
                icon: '👅',
                progress: 0.85,
              ),
              _buildModuleCard(
                context,
                title: 'Vogais Mínimas: /iː/ vs /ɪ/',
                subtitle: 'Nunca mais confunda "sheep" e "ship", ou "beach" e "bitch"',
                icon: '🎯',
                progress: 0.60,
              ),
              _buildModuleCard(
                context,
                title: 'O Schwa Secreto (/ə/)',
                subtitle: 'O som mais frequente da língua inglesa que dá ritmo nativo',
                icon: '⚡',
                progress: 0.40,
              ),
              _buildModuleCard(
                context,
                title: 'Consoantes Fricativas: /v/ vs /w/',
                subtitle: 'Domine a distinção entre "vine" e "wine" com feedback imediato',
                icon: '🌊',
                progress: 0.10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.surfaceLight,
                  color: AppTheme.primary,
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PracticeScreen()),
          );
        },
      ),
    ),
  );
}
}
