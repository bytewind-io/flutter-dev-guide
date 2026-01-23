// ❌ ПЛОХО: Только одна версия растровой иконки
//
// Структура assets:
// assets/
//   images/
//     icon_home.png        // 24x24 - только базовая версия
//     icon_profile.png     // 24x24 - только базовая версия
//     icon_settings.png    // 24x24 - только базовая версия

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
          // ❌ На Retina/AMOLED экранах иконка будет размытой
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
          // ❌ Иконка без версий для высокой плотности
          Image.asset(
            'assets/images/icon_home.png',
            width: 48,
            height: 48,
          ),
          SizedBox(height: 16),
          // ❌ Будет выглядеть пикселизированной на современных экранах
          CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage('assets/images/icon_profile.png'),
          ),
        ],
      ),
    );
  }
}

// ПРОБЛЕМА:
// - Flutter будет масштабировать единственную версию 24x24 для всех экранов
// - На экранах 2x (iPhone Retina) Flutter растянет 24x24 до 48x48 → размытие
// - На экранах 3x (AMOLED) Flutter растянет 24x24 до 72x72 → сильное размытие
// - Пользователи увидят нечеткие, пикселизированные иконки
