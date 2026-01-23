// ✅ ХОРОШО: Растровые иконки с версиями для всех плотностей
//
// Структура assets:
// assets/
//   images/
//     icon_home.png        // 24x24 (1x - базовая версия)
//     icon_profile.png     // 24x24 (1x)
//     icon_settings.png    // 24x24 (1x)
//     2.0x/
//       icon_home.png      // 48x48 (2x - для Retina)
//       icon_profile.png   // 48x48 (2x)
//       icon_settings.png  // 48x48 (2x)
//     3.0x/
//       icon_home.png      // 72x72 (3x - для AMOLED)
//       icon_profile.png   // 72x72 (3x)
//       icon_settings.png  // 72x72 (3x)
//     4.0x/                // Опционально, для экстремально высокой плотности
//       icon_home.png      // 96x96 (4x)
//       icon_profile.png   // 96x96 (4x)
//       icon_settings.png  // 96x96 (4x)

// pubspec.yaml:
// flutter:
//   assets:
//     - assets/images/

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          // ✅ Flutter автоматически выберет правильную версию
          // - На обычном экране: icon_settings.png (24x24)
          // - На Retina: 2.0x/icon_settings.png (48x48)
          // - На AMOLED: 3.0x/icon_settings.png (72x72)
          IconButton(
            icon: Image.asset(
              'assets/images/icon_settings.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Четкое отображение на всех экранах
          Image.asset(
            'assets/images/icon_home.png',
            width: 48,
            height: 48,
          ),
          SizedBox(height: 16),
          // ✅ Идеальное качество на любой плотности экрана
          CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage('assets/images/icon_profile.png'),
          ),
        ],
      ),
    );
  }
}

// ПРЕИМУЩЕСТВА:
// 1. Flutter автоматически выбирает подходящую версию без дополнительного кода
// 2. Иконки всегда отображаются четко на любых экранах
// 3. Оптимальное использование памяти (загружается только нужная версия)
// 4. Профессиональный внешний вид приложения

// ЛУЧШАЯ АЛЬТЕРНАТИВА - Шрифтовые иконки:
//
// Для иконок ОБЯЗАТЕЛЬНО использовать шрифтовые иконки вместо растровых.
// См. правило FL-UI-ICON-IMAGE-FORMAT для подробностей.
//
// Преимущества шрифтовых иконок:
// - Масштабируются бесконечно без потери качества
// - Не требуют версий 2x/3x
// - Малый размер (один шрифтовой файл для всех иконок)
// - Легко менять цвет через параметр color
// - Быстрая отрисовка
//
// import 'package:flutter/material.dart';
//
// Widget build(BuildContext context) {
//   return Icon(
//     Icons.home,  // Material Icons
//     size: 24,
//     color: Colors.blue,
//   );
// }
//
// Для кастомных иконок создайте иконочный шрифт:
// - Используйте FlutterIcon (fluttericon.com) или IcoMoon (icomoon.io)
// - Конвертируйте SVG в TTF шрифт
// - Подключите в pubspec.yaml
//
// ВАЖНО: SVG запрещен для иконок (см. FL-UI-ICON-IMAGE-FORMAT)
// SVG допустим только для изображений в особых случаях.
