// ✅ ХОРОШО: Правильное использование форматов иконок и изображений

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoodIconImageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Good Example'),
        actions: [
          // ✅ Шрифтовая иконка из Material Icons
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),

          // ✅ Шрифтовая иконка из Material Icons
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),

          // ✅ Шрифтовая иконка из Material Icons
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ WebP для изображения
            // Размер: ~60KB (вместо ~200KB PNG)
            Image.asset(
              'assets/images/banner.webp',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),

            SizedBox(height: 16),

            // ✅ SVG для изображения с обоснованием
            // Используется SVG для динамического изменения цвета логотипа
            // в зависимости от темы приложения
            SvgPicture.asset(
              'assets/images/logo.svg',
              width: 120,
              height: 120,
              colorFilter: ColorFilter.mode(
                Theme.of(context).primaryColor,
                BlendMode.srcIn,
              ),
            ),

            SizedBox(height: 16),

            // ✅ Шрифтовые иконки Material Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.home, size: 24),
                Icon(Icons.person, size: 24),
                Icon(Icons.settings, size: 24),
              ],
            ),

            SizedBox(height: 16),

            // ✅ Цветная иконка в WebP с версиями для разных плотностей
            Row(
              children: [
                Image.asset(
                  'assets/icons/colored_star.webp',
                  width: 32,
                  height: 32,
                ),
                // Структура:
                // assets/icons/colored_star.webp (1x: 32x32)
                // assets/icons/2.0x/colored_star.webp (2x: 64x64)
                // assets/icons/3.0x/colored_star.webp (3x: 96x96)
                Text('Premium Badge'),
              ],
            ),

            SizedBox(height: 16),

            // ✅ Кастомная иконка из шрифтового набора
            Icon(CustomIcons.customStar, size: 32, color: Colors.amber),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // ✅ Шрифтовые иконки для навигации
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // ✅ Шрифтовая иконка в FAB
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

// ✅ Правильная структура assets
// assets/
//   icons/
//     colored_star.webp           // 1x (32x32)
//     2.0x/
//       colored_star.webp         // 2x (64x64)
//     3.0x/
//       colored_star.webp         // 3x (96x96)
//   images/
//     banner.webp                 // WebP для изображений
//     logo.svg                    // SVG с обоснованием (динамический цвет)
//   fonts/
//     CustomIcons.ttf             // Кастомный иконочный шрифт

// ✅ Кастомный иконочный шрифт (pubspec.yaml)
// flutter:
//   fonts:
//     - family: CustomIcons
//       fonts:
//         - asset: assets/fonts/CustomIcons.ttf

// ✅ Определение кастомных иконок
class CustomIcons {
  CustomIcons._();

  static const String _fontFamily = 'CustomIcons';

  static const IconData customStar = IconData(0xe900, fontFamily: _fontFamily);
  static const IconData customHeart = IconData(0xe901, fontFamily: _fontFamily);
  static const IconData customBookmark = IconData(0xe902, fontFamily: _fontFamily);
  static const IconData customShare = IconData(0xe903, fontFamily: _fontFamily);
}

class GoodListTileExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      // ✅ Шрифтовая иконка в leading
      leading: Icon(Icons.folder, size: 24),
      title: Text('Documents'),
      // ✅ Шрифтовая иконка в trailing
      trailing: Icon(Icons.chevron_right, size: 16),
    );
  }
}

// ✅ Использование кастомных шрифтовых иконок
class CustomIconExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(CustomIcons.customStar),
          color: Colors.amber,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(CustomIcons.customHeart),
          color: Colors.red,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(CustomIcons.customBookmark),
          color: Colors.blue,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(CustomIcons.customShare),
          color: Colors.green,
          onPressed: () {},
        ),
      ],
    );
  }
}

// ✅ Цветная иконка с версиями для разных плотностей
class ColorfulIconExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Цветная иконка бейджа в WebP
          Image.asset(
            'assets/icons/premium_badge.webp',
            width: 48,
            height: 48,
          ),
          SizedBox(height: 8),
          Text('Premium User'),
        ],
      ),
    );
  }
}

// ✅ Динамическое изменение цвета SVG (допустимый случай)
class DynamicSvgExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/themed_illustration.svg',
      // Обоснование: SVG используется для динамического изменения цвета
      // элементов иллюстрации в зависимости от темы приложения
      colorFilter: ColorFilter.mode(
        Theme.of(context).primaryColor,
        BlendMode.srcIn,
      ),
      width: 200,
      height: 200,
    );
  }
}

// ✅ Фотография в JPEG (допустимо для фото)
class PhotoExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/photo.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 300,
    );
  }
}

// ПРЕИМУЩЕСТВА ЭТОГО ПОДХОДА:
// 1. Быстрая отрисовка (шрифтовые иконки)
// 2. Малый размер APK/IPA (WebP + шрифты)
// 3. Четкое отображение на всех экранах (шрифты + версии 2x/3x)
// 4. Легкое изменение цвета иконок (color параметр)
// 5. Нет лишних зависимостей
// 6. Низкое использование памяти
// 7. Отличная производительность
// 8. Простая поддержка темной темы
// 9. Единообразный стиль иконок
// 10. Быстрая загрузка приложения

// СОЗДАНИЕ КАСТОМНОГО ШРИФТА:
// 1. Подготовьте SVG иконки
// 2. Используйте FlutterIcon (fluttericon.com) или IcoMoon (icomoon.io)
// 3. Загрузите SVG и сгенерируйте TTF шрифт
// 4. Добавьте шрифт в pubspec.yaml
// 5. Используйте IconData с кодами из генератора

// КОНВЕРТАЦИЯ В WebP:
// brew install webp
// cwebp -q 80 input.png -o output.webp
//
// Или используйте онлайн: https://squoosh.app/
