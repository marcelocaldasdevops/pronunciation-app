import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/custom_sentence/screens/custom_sentence_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/ipa_chart/screens/ipa_chart_screen.dart';
import '../../features/practice/screens/practice_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../theme/app_theme.dart';

class AppNavigationScaffold extends StatefulWidget {
  final int initialIndex;

  const AppNavigationScaffold({
    super.key,
    this.initialIndex = 0,
  });

  static _AppNavigationScaffoldState? _findState(BuildContext context) {
    return context.findAncestorStateOfType<_AppNavigationScaffoldState>();
  }

  /// Permite trocar de aba programaticamente de qualquer tela filha
  static void switchTab(BuildContext context, int index) {
    final state = _findState(context);
    if (state != null) {
      state.setIndex(index);
    }
  }

  @override
  State<AppNavigationScaffold> createState() => _AppNavigationScaffoldState();
}

class _AppNavigationScaffoldState extends State<AppNavigationScaffold> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    CustomSentenceScreen(),
    PracticeScreen(),
    IpaChartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    if (index >= 0 && index < _screens.length && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Row(
          children: [
            _buildDesktopRail(),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppTheme.surfaceLight.withValues(alpha: 0.6),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildMobileBottomBar(),
    );
  }

  /// Barra de navegação inferior mobile idêntica ao componente TWNZS do design
  Widget _buildMobileBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.surfaceLight.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMobileNavItem(
                index: 0,
                icon: Icons.school_outlined,
                activeIcon: Icons.school_rounded,
                label: 'Treino',
              ),
              _buildMobileNavItem(
                index: 1,
                icon: Icons.edit_note_rounded,
                activeIcon: Icons.edit_note_rounded,
                label: 'Minha Frase',
              ),
              _buildMobileNavItem(
                index: 2,
                icon: Icons.mic_none_rounded,
                activeIcon: Icons.mic_rounded,
                label: 'Prática',
              ),
              _buildMobileNavItem(
                index: 3,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Tabela IPA',
              ),
              _buildMobileNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setIndex(index),
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menu lateral responsivo para Desktop / Tablet com logo e glow
  Widget _buildDesktopRail() {
    return Container(
      width: 240,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Marca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.graphic_eq_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VOCALIS',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Treino Fonético',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Itens de Navegação Desktop
          _buildDesktopNavItem(
            index: 0,
            icon: Icons.school_outlined,
            activeIcon: Icons.school_rounded,
            label: 'Treino',
          ),
          const SizedBox(height: 8),
          _buildDesktopNavItem(
            index: 1,
            icon: Icons.edit_note_rounded,
            activeIcon: Icons.edit_note_rounded,
            label: 'Minha Frase',
          ),
          const SizedBox(height: 8),
          _buildDesktopNavItem(
            index: 2,
            icon: Icons.mic_none_rounded,
            activeIcon: Icons.mic_rounded,
            label: 'Prática Guiada',
          ),
          const SizedBox(height: 8),
          _buildDesktopNavItem(
            index: 3,
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'Tabela IPA',
          ),
          const SizedBox(height: 8),
          _buildDesktopNavItem(
            index: 4,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Meu Perfil',
          ),

          const Spacer(),

          // Badge de status no rodapé do menu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.surfaceLight,
              ),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5 Dias Seguidos',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Meta: 3/5 lições',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setIndex(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
