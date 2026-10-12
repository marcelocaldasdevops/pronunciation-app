import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class IpaPhonemeItem {
  final String ipa;
  final String exampleWord;
  final String category;
  final String description;

  const IpaPhonemeItem({
    required this.ipa,
    required this.exampleWord,
    required this.category,
    required this.description,
  });
}

class IpaChartScreen extends StatefulWidget {
  const IpaChartScreen({super.key});

  @override
  State<IpaChartScreen> createState() => _IpaChartScreenState();
}

class _IpaChartScreenState extends State<IpaChartScreen> {
  String _selectedCategory = 'Todos';

  static const List<IpaPhonemeItem> _allPhonemes = [
    // Vogais Puras (Monophthongs)
    IpaPhonemeItem(ipa: 'iː', exampleWord: 'Sheep', category: 'Vogais', description: 'Vogal longa fechada. Sorria e projete a língua para a frente.'),
    IpaPhonemeItem(ipa: 'ɪ', exampleWord: 'Ship', category: 'Vogais', description: 'Vogal curta relaxada entre o "i" e o "e".'),
    IpaPhonemeItem(ipa: 'ʊ', exampleWord: 'Good', category: 'Vogais', description: 'Vogal curta recuada, lábios arredondados sem tensão.'),
    IpaPhonemeItem(ipa: 'uː', exampleWord: 'Shoot', category: 'Vogais', description: 'Vogal longa fechada, lábios bem arredondados em bico.'),
    IpaPhonemeItem(ipa: 'e', exampleWord: 'Bed', category: 'Vogais', description: 'Vogal frontal semiaberta.'),
    IpaPhonemeItem(ipa: 'ə', exampleWord: 'Teacher', category: 'Vogais', description: 'Schwa: som mais comum do inglês. Totalmente neutro e relaxado.'),
    IpaPhonemeItem(ipa: 'ɜː', exampleWord: 'Bird', category: 'Vogais', description: 'Vogal central longa, comum antes do som "r".'),
    IpaPhonemeItem(ipa: 'ɔː', exampleWord: 'Door', category: 'Vogais', description: 'Vogal longa posterior arredondada.'),
    IpaPhonemeItem(ipa: 'æ', exampleWord: 'Cat', category: 'Vogais', description: 'Vogal aberta frontal. Abra bem o maxilar inferior.'),
    IpaPhonemeItem(ipa: 'ʌ', exampleWord: 'Up', category: 'Vogais', description: 'Vogal curta central aberta rápida.'),
    IpaPhonemeItem(ipa: 'ɑː', exampleWord: 'Far', category: 'Vogais', description: 'Vogal longa aberta profunda.'),
    IpaPhonemeItem(ipa: 'ɒ', exampleWord: 'On', category: 'Vogais', description: 'Vogal curta posterior aberta.'),

    // Ditongos (Diphthongs)
    IpaPhonemeItem(ipa: 'eɪ', exampleWord: 'Train', category: 'Ditongos', description: 'Transição suave de /e/ para /ɪ/.'),
    IpaPhonemeItem(ipa: 'aɪ', exampleWord: 'Time', category: 'Ditongos', description: 'Transição de /a/ para /ɪ/.'),
    IpaPhonemeItem(ipa: 'ɔɪ', exampleWord: 'Boy', category: 'Ditongos', description: 'Transição de /ɔ/ para /ɪ/.'),
    IpaPhonemeItem(ipa: 'aʊ', exampleWord: 'House', category: 'Ditongos', description: 'Transição de /a/ para /ʊ/.'),
    IpaPhonemeItem(ipa: 'oʊ', exampleWord: 'Go', category: 'Ditongos', description: 'Transição de /o/ para /ʊ/.'),
    IpaPhonemeItem(ipa: 'ɪə', exampleWord: 'Near', category: 'Ditongos', description: 'Transição de /ɪ/ para schwa /ə/.'),
    IpaPhonemeItem(ipa: 'eə', exampleWord: 'Hair', category: 'Ditongos', description: 'Transição de /e/ para schwa /ə/.'),
    IpaPhonemeItem(ipa: 'ʊə', exampleWord: 'Pure', category: 'Ditongos', description: 'Transição de /ʊ/ para schwa /ə/.'),

    // Consoantes (Consonants)
    IpaPhonemeItem(ipa: 'p', exampleWord: 'Pen', category: 'Consoantes', description: 'Plosiva bilabial surda com sopro de ar.'),
    IpaPhonemeItem(ipa: 'b', exampleWord: 'Bad', category: 'Consoantes', description: 'Plosiva bilabial sonora com vibração de voz.'),
    IpaPhonemeItem(ipa: 't', exampleWord: 'Tea', category: 'Consoantes', description: 'Plosiva alveolar surda com estalo de língua.'),
    IpaPhonemeItem(ipa: 'd', exampleWord: 'Did', category: 'Consoantes', description: 'Plosiva alveolar sonora.'),
    IpaPhonemeItem(ipa: 'tʃ', exampleWord: 'Chair', category: 'Consoantes', description: 'Africada palatoalveolar surda ("tch").'),
    IpaPhonemeItem(ipa: 'dʒ', exampleWord: 'Job', category: 'Consoantes', description: 'Africada palatoalveolar sonora ("dj").'),
    IpaPhonemeItem(ipa: 'k', exampleWord: 'Cat', category: 'Consoantes', description: 'Plosiva velar surda.'),
    IpaPhonemeItem(ipa: 'ɡ', exampleWord: 'Get', category: 'Consoantes', description: 'Plosiva velar sonora.'),
    IpaPhonemeItem(ipa: 'f', exampleWord: 'Fall', category: 'Consoantes', description: 'Fricativa labiodental surda.'),
    IpaPhonemeItem(ipa: 'v', exampleWord: 'Voice', category: 'Consoantes', description: 'Fricativa labiodental sonora com dentes no lábio.'),
    IpaPhonemeItem(ipa: 'θ', exampleWord: 'Think', category: 'Consoantes', description: 'Fricativa dental surda: ponta da língua entre os dentes soprando ar.'),
    IpaPhonemeItem(ipa: 'ð', exampleWord: 'This', category: 'Consoantes', description: 'Fricativa dental sonora: ponta da língua entre os dentes vibrando a voz.'),
    IpaPhonemeItem(ipa: 's', exampleWord: 'See', category: 'Consoantes', description: 'Fricativa alveolar surda.'),
    IpaPhonemeItem(ipa: 'z', exampleWord: 'Zoo', category: 'Consoantes', description: 'Fricativa alveolar sonora.'),
    IpaPhonemeItem(ipa: 'ʃ', exampleWord: 'She', category: 'Consoantes', description: 'Fricativa postalveolar surda ("sh").'),
    IpaPhonemeItem(ipa: 'ʒ', exampleWord: 'Vision', category: 'Consoantes', description: 'Fricativa postalveolar sonora ("j" suave).'),
    IpaPhonemeItem(ipa: 'm', exampleWord: 'Man', category: 'Consoantes', description: 'Nasal bilabial.'),
    IpaPhonemeItem(ipa: 'n', exampleWord: 'No', category: 'Consoantes', description: 'Nasal alveolar.'),
    IpaPhonemeItem(ipa: 'ŋ', exampleWord: 'Sing', category: 'Consoantes', description: 'Nasal velar: ar liberado pelo nariz sem soltar a língua.'),
    IpaPhonemeItem(ipa: 'h', exampleWord: 'Hat', category: 'Consoantes', description: 'Fricativa glotal suave.'),
    IpaPhonemeItem(ipa: 'l', exampleWord: 'Leg', category: 'Consoantes', description: 'Aproximante lateral com língua firme na gengiva superior.'),
    IpaPhonemeItem(ipa: 'r', exampleWord: 'Red', category: 'Consoantes', description: 'Aproximante alveolar sem tocar o palato.'),
    IpaPhonemeItem(ipa: 'w', exampleWord: 'Wet', category: 'Consoantes', description: 'Aproximante labiovelar.'),
    IpaPhonemeItem(ipa: 'j', exampleWord: 'Yes', category: 'Consoantes', description: 'Aproximante palatal.'),
  ];

  List<IpaPhonemeItem> get _filteredPhonemes {
    if (_selectedCategory == 'Todos') return _allPhonemes;
    return _allPhonemes.where((p) => p.category == _selectedCategory).toList();
  }

  void _showPhonemeDetails(IpaPhonemeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary),
                    ),
                    child: Text(
                      '/${item.ipa}/',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.exampleWord,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item.category,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Como Articular:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: const TextStyle(fontSize: 15, height: 1.4, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.check),
                  label: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['Todos', 'Vogais', 'Ditongos', 'Consoantes'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabela Fonética IPA (44 Sons)'),
      ),
      body: Column(
        children: [
          // Filtros por categoria
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.surfaceLight,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Grid dos fonemas
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 130,
                childAspectRatio: 0.95,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredPhonemes.length,
              itemBuilder: (context, idx) {
                final p = _filteredPhonemes[idx];
                return InkWell(
                  onTap: () => _showPhonemeDetails(p),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceLight),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '/${p.ipa}/',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.exampleWord,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
