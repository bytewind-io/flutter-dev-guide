// ❌ ПЛОХО: Неправильное использование форматов иконок и изображений
// + использование магических строк вместо констант

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BadIconImageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bad Example'),
        actions: [
          // ❌ ОШИБКА 1: SVG файл (.asset) используется как иконка
          // ❌ ОШИБКА 2: Если SVG нужен - используйте .string(), а не .asset()
          // Проблема: медленная отрисовка, большой размер файла, зависимость
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/settings.svg', // Плохо - файл
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),

          // ❌ ОШИБКА: PNG иконка вместо шрифтовой
          // Проблема: не масштабируется, требует версии 2x/3x
          IconButton(
            icon: Image.asset(
              'assets/icons/search.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),

          // ❌ ОШИБКА: JPG иконка
          // Проблема: низкое качество, нет прозрачности
          IconButton(
            icon: Image.asset(
              'assets/icons/notification.jpg',
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ❌ ОШИБКА 1: PNG для изображения (должен быть WebP)
            // ❌ ОШИБКА 2: Магическая строка вместо константы
            // Проблема: большой размер файла (~200KB вместо ~60KB) + риск опечатки
            Image.asset(
              'assets/images/banner.png', // Хардкод пути
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),

            SizedBox(height: 16),

            // ❌ ОШИБКА: SVG для изображения без обоснования
            // Если SVG нужен для динамического изменения цвета - добавьте комментарий
            SvgPicture.asset(
              'assets/images/logo.svg',
              width: 120,
              height: 120,
            ),

            SizedBox(height: 16),

            // ❌ ОШИБКА: Растровые иконки без версий для разных плотностей
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // assets/icons/home.png (только 1x версия)
                Image.asset('assets/icons/home.png', width: 24, height: 24),
                Image.asset('assets/icons/profile.png', width: 24, height: 24),
                Image.asset('assets/icons/settings.png', width: 24, height: 24),
              ],
            ),

            SizedBox(height: 16),

            // ❌ ОШИБКА: Цветная иконка в PNG
            // Проблема: большой размер, нет версий 2x/3x
            Row(
              children: [
                Image.asset(
                  'assets/icons/colored_star.png',
                  width: 32,
                  height: 32,
                ),
                Text('Premium Badge'),
              ],
            ),

            SizedBox(height: 16),

            // ❌ ОШИБКА: Использование SVG для простых иконок навигации
            BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset('assets/icons/nav_home.svg'),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset('assets/icons/nav_search.svg'),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset('assets/icons/nav_profile.svg'),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // ❌ ОШИБКА: Растровая иконка в FAB
        child: Image.asset('assets/icons/add.png'),
        onPressed: () {},
      ),
    );
  }
}

// ❌ ОШИБКА: Неправильная структура assets
// Текущая структура:
// assets/
//   icons/
//     home.png              // Только 1x, нет 2x/3x
//     profile.png           // Только 1x, нет 2x/3x
//     settings.svg          // SVG для иконок запрещен
//     colored_star.png      // PNG вместо WebP
//   images/
//     banner.png            // PNG вместо WebP
//     logo.svg              // SVG без обоснования

class BadListTileExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      // ❌ ОШИБКА: PNG иконка в leading
      leading: Image.asset('assets/icons/folder.png', width: 24, height: 24),
      title: Text('Documents'),
      // ❌ ОШИБКА: SVG иконка в trailing
      trailing: SvgPicture.asset('assets/icons/arrow.svg', width: 16, height: 16),
    );
  }
}

// ПОСЛЕДСТВИЯ ЭТИХ ОШИБОК:
// 1. Медленная отрисовка UI из-за SVG парсинга
// 2. Большой размер APK/IPA из-за PNG
// 3. Размытые иконки на Retina/AMOLED экранах
// 4. Невозможность легко менять цвет иконок
// 5. Зависимость от flutter_svg пакета
// 6. Повышенное использование памяти
// 7. Плохая производительность при множественном использовании
// 8. Сложность поддержки темной темы
// 9. Магические строки - риск опечаток, нет автодополнения
// 10. Сложность рефакторинга путей к ассетам
