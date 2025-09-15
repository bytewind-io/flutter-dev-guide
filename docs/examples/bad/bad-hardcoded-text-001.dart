import 'package:flutter/material.dart';

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
                    label: 'Очистить все', // ❌ хардкод кириллицы
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
            hintText: 'Введите название тега', // ❌ хардкод кириллицы
            labelText: 'Поиск по тегам', // ❌ хардкод кириллицы
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text('Применить фильтр'), // ❌ хардкод кириллицы
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
