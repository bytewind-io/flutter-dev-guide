#!/usr/bin/env python3
"""
Скрипт для проверки Dart кода на соответствие правилам архитектуры.
Запускается как pre-commit hook.
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import List, Dict, Any, Tuple


class RuleChecker:
    def __init__(self, rules_file: str = "docs/mappings/rules_map.json"):
        self.rules_file = rules_file
        self.rules = self._load_rules()
        
    def _load_rules(self) -> List[Dict[str, Any]]:
        """Загружает правила из JSON файла."""
        try:
            with open(self.rules_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"❌ Файл правил не найден: {self.rules_file}")
            return []
        except json.JSONDecodeError:
            print(f"❌ Ошибка парсинга JSON в файле: {self.rules_file}")
            return []
    
    def get_staged_dart_files(self) -> List[str]:
        """Получает список staged Dart файлов."""
        try:
            import subprocess
            result = subprocess.run(
                ["git", "diff", "--cached", "--name-only", "--diff-filter=ACM"],
                capture_output=True, text=True, check=True
            )
            files = result.stdout.strip().split('\n')
            return [f for f in files if f.endswith('.dart') and f.strip()]
        except subprocess.CalledProcessError:
            print("❌ Ошибка при получении staged файлов")
            return []
    
    def check_rule(self, rule: Dict[str, Any], file_path: str) -> List[str]:
        """Проверяет файл на соответствие конкретному правилу."""
        violations = []
        rule_id = rule.get('id', '')
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"⚠️  Не удалось прочитать файл {file_path}: {e}")
            return violations
        
        # Проверка правила ARCH-DS-NO-DIRECT-ACCESS
        if rule_id == "ARCH-DS-NO-DIRECT-ACCESS":
            violations.extend(self._check_no_direct_access(content, file_path))
        
        # Проверка правила ARCH-IMPORT-ABSTRACTION
        elif rule_id == "ARCH-IMPORT-ABSTRACTION":
            violations.extend(self._check_import_abstraction(content, file_path))
        
        # Проверка правила ARCH-REPO-STATELESS
        elif rule_id == "ARCH-REPO-STATELESS":
            violations.extend(self._check_repo_stateless(content, file_path))
        
        return violations
    
    def _check_no_direct_access(self, content: str, file_path: str) -> List[str]:
        """Проверяет правило ARCH-DS-NO-DIRECT-ACCESS."""
        violations = []
        
        # Паттерны для прямого доступа к источникам данных
        patterns = [
            (r'import.*firebase', 'Прямой импорт Firebase'),
            (r'import.*sqflite', 'Прямой импорт SQLite'),
            (r'import.*http', 'Прямой импорт HTTP'),
            (r'FirebaseFirestore\.instance', 'Прямое использование Firebase'),
            (r'DatabaseHelper\(\)', 'Прямое использование SQLite'),
            (r'http\.get\(', 'Прямой HTTP запрос'),
            (r'http\.post\(', 'Прямой HTTP запрос'),
        ]
        
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            for pattern, description in patterns:
                if re.search(pattern, line, re.IGNORECASE):
                    violations.append(f"  Строка {i}: {description}")
        
        return violations
    
    def _check_import_abstraction(self, content: str, file_path: str) -> List[str]:
        """Проверяет правило ARCH-IMPORT-ABSTRACTION."""
        violations = []
        
        # Проверяем импорты конкретных реализаций
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            if 'import' in line and any(keyword in line.lower() for keyword in ['repository', 'service', 'datasource']):
                if not any(abstract in line.lower() for abstract in ['_i.dart', 'interface', 'abstract']):
                    if not line.strip().startswith('//'):
                        violations.append(f"  Строка {i}: Импорт конкретной реализации вместо интерфейса")
        
        return violations
    
    def _check_repo_stateless(self, content: str, file_path: str) -> List[str]:
        """Проверяет правило ARCH-REPO-STATELESS."""
        violations = []
        
        # Проверяем наличие методов init/setup в репозиториях
        if 'class' in content and 'Repository' in content:
            lines = content.split('\n')
            for i, line in enumerate(lines, 1):
                if re.search(r'void\s+init|void\s+setup|Future<void>\s+init|Future<void>\s+setup', line):
                    violations.append(f"  Строка {i}: Репозиторий содержит метод init/setup")
        
        return violations
    
    def run_checks(self) -> bool:
        """Запускает все проверки и возвращает результат."""
        print("🔍 Проверка правил архитектуры...")
        
        dart_files = self.get_staged_dart_files()
        if not dart_files:
            print("✅ Нет staged Dart файлов для проверки")
            return True
        
        print(f"📁 Найдено {len(dart_files)} Dart файлов для проверки")
        
        all_violations = []
        
        for file_path in dart_files:
            print(f"\n📄 Проверяю файл: {file_path}")
            file_violations = []
            
            for rule in self.rules:
                rule_violations = self.check_rule(rule, file_path)
                if rule_violations:
                    file_violations.append(f"  {rule['title']}:")
                    file_violations.extend(rule_violations)
            
            if file_violations:
                all_violations.append(f"\n❌ {file_path}:")
                all_violations.extend(file_violations)
            else:
                print(f"  ✅ Файл соответствует всем правилам")
        
        if all_violations:
            print("\n" + "="*60)
            print("❌ НАРУШЕНИЯ ПРАВИЛ АРХИТЕКТУРЫ:")
            print("="*60)
            for violation in all_violations:
                print(violation)
            print("\n💡 Рекомендации по исправлению:")
            print("   - Создайте интерфейсы для репозиториев")
            print("   - Используйте dependency injection")
            print("   - Избегайте прямого доступа к источникам данных")
            return False
        else:
            print("\n🎉 Все файлы соответствуют правилам архитектуры!")
            return True


def main():
    """Основная функция."""
    checker = RuleChecker()
    success = checker.run_checks()
    
    if not success:
        print("\n❌ Коммит отклонен из-за нарушений правил архитектуры")
        sys.exit(1)
    
    print("\n✅ Проверка завершена успешно")
    sys.exit(0)


if __name__ == "__main__":
    main()
