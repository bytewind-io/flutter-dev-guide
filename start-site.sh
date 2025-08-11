#!/bin/bash

# Скрипт для запуска сайта Flutter/Dart Standards

echo "🚀 Запуск сайта Flutter/Dart Standards..."

# Проверяем, установлен ли MkDocs
if ! command -v /Users/vk/Library/Python/3.9/bin/mkdocs &> /dev/null; then
    echo "❌ MkDocs не найден. Устанавливаем..."
    pip3 install mkdocs-material
fi

# Останавливаем предыдущие процессы MkDocs
echo "🛑 Останавливаем предыдущие процессы..."
pkill -f mkdocs 2>/dev/null

# Собираем сайт
echo "🔨 Собираем сайт..."
/Users/vk/Library/Python/3.9/bin/mkdocs build

# Запускаем сервер
echo "🌐 Запускаем сервер на http://localhost:8000"
echo "📁 Раздел шаблонов: http://localhost:8000/templates-docs/"
echo "⏹️  Для остановки нажмите Ctrl+C"

/Users/vk/Library/Python/3.9/bin/mkdocs serve --dev-addr=127.0.0.1:8000

