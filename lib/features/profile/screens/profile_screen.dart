import 'package:flutter/material.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de Usuário
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.accent],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🎙️',
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estudante Fonético',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Nível Intermediário • B2',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Estatísticas Gerais
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Ofensiva',
                      value: '5 Dias',
                      icon: '🔥',
                      color: AppTheme.scoreYellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Palavras',
                      value: '142',
                      icon: '🎯',
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Acurácia',
                      value: '84%',
                      icon: '⚡',
                      color: AppTheme.scoreGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Configurações Fonéticas
              const Text(
                'Preferências de Treino',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              ValueListenableBuilder<PronunciationType>(
                valueListenable:
                    PreferencesService.instance.pronunciationTypeNotifier,
                builder: (context, currentType, _) {
                  final isAportuguesada =
                      currentType == PronunciationType.portugueseGuide;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.surfaceLight.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.translate_rounded,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guia de Pronúncia Ativa',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Alterne entre símbolos IPA e pronúncia aportuguesada',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(
                                  child: Text('IPA Internacional'),
                                ),
                                selected: !isAportuguesada,
                                selectedColor:
                                    AppTheme.primary.withValues(alpha: 0.2),
                                backgroundColor: AppTheme.surfaceLight,
                                labelStyle: TextStyle(
                                  color: !isAportuguesada
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                  fontWeight: !isAportuguesada
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: !isAportuguesada
                                      ? AppTheme.primary
                                      : Colors.transparent,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    PreferencesService.instance
                                        .setPronunciationType(
                                            PronunciationType.standardIpa);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(
                                  child: Text('Aportuguesada'),
                                ),
                                selected: isAportuguesada,
                                selectedColor:
                                    AppTheme.accent.withValues(alpha: 0.25),
                                backgroundColor: AppTheme.surfaceLight,
                                labelStyle: TextStyle(
                                  color: isAportuguesada
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                  fontWeight: isAportuguesada
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: isAportuguesada
                                      ? AppTheme.accent
                                      : Colors.transparent,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    PreferencesService.instance
                                        .setPronunciationType(
                                            PronunciationType.portugueseGuide);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surfaceLight.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(icon, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
