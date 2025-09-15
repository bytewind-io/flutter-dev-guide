import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TagFilterWidget extends StatelessWidget {
  final List<String> tags;
  final VoidCallback onClearAll;
  
  const TagFilterWidget({
    Key? key,
    required this.tags,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ локализация
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tags.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TagChip(
                    label: l10n.clearAll, // ✅ локализация
                    isSelected: false,
                    onTap: onClearAll,
                    isSpecial: true,
                  ),
                );
              }
              
              final tag = tags[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TagChip(
                  label: tag,
                  isSelected: true,
                  onTap: () {},
                ),
              );
            },
          ),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: l10n.enterTagName, // ✅ локализация
            labelText: l10n.searchByTags, // ✅ локализация
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text(l10n.applyFilter), // ✅ локализация
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSpecial;

  const _TagChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSpecial = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

// Пример файла локализации (app_en.arb):
/*
{
  "clearAll": "Clear all",
  "enterTagName": "Enter tag name", 
  "searchByTags": "Search by tags",
  "applyFilter": "Apply filter"
}
*/

// Пример файла локализации (app_ru.arb):
/*
{
  "clearAll": "Очистить все",
  "enterTagName": "Введите название тега",
  "searchByTags": "Поиск по тегам", 
  "applyFilter": "Применить фильтр"
}
*/
