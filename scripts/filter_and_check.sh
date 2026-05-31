#!/bin/bash
set -e  # выход при любой ошибке

# URL исходных файлов (репозиторий itdoginfo)
MAIN_URL="https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/inside-raw.lst"
EXCLUDE_URL="https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Services/youtube.lst"

OUTPUT_LST="russia-inside-noyoutube.lst"
CHECKSUM_FILE=".last_checksums"

# Функция MD5 (кроссплатформенная)
md5_hash() {
    if command -v md5sum &> /dev/null; then
        md5sum "$1" | cut -d' ' -f1
    elif command -v md5 &> /dev/null; then
        md5 -q "$1"
    else
        echo "Ошибка: не найден md5sum или md5" >&2
        exit 1
    fi
}

# Временные файлы
TEMP_MAIN=$(mktemp)
TEMP_EXCLUDE=$(mktemp)

# Обработчик выхода для очистки
cleanup() {
    rm -f "$TEMP_MAIN" "$TEMP_EXCLUDE"
}
trap cleanup EXIT

echo "📥 Загрузка основного списка..."
if ! curl -fsSL "$MAIN_URL" -o "$TEMP_MAIN"; then
    echo "❌ Ошибка загрузки основного списка" >&2
    exit 1
fi

echo "📥 Загрузка списка исключений (YouTube)..."
if ! curl -fsSL "$EXCLUDE_URL" -o "$TEMP_EXCLUDE"; then
    echo "❌ Ошибка загрузки списка исключений" >&2
    exit 1
fi

# Вычисляем хеши
NEW_MAIN_HASH=$(md5_hash "$TEMP_MAIN")
NEW_EXCLUDE_HASH=$(md5_hash "$TEMP_EXCLUDE")

# Читаем старые хеши, если файл существует
if [ -f "$CHECKSUM_FILE" ]; then
    read -r OLD_MAIN_HASH OLD_EXCLUDE_HASH < "$CHECKSUM_FILE" || { OLD_MAIN_HASH=""; OLD_EXCLUDE_HASH=""; }
else
    OLD_MAIN_HASH=""
    OLD_EXCLUDE_HASH=""
fi

# Если ничего не изменилось — выходим
if [ "$NEW_MAIN_HASH" = "$OLD_MAIN_HASH" ] && [ "$NEW_EXCLUDE_HASH" = "$OLD_EXCLUDE_HASH" ]; then
    echo "✅ Исходные файлы не изменились. Выход."
    exit 0
fi

echo "🔄 Обнаружены изменения. Формируем новый список..."

# Фильтрация: исключаем домены YouTube из основного списка
# -v: инвертировать матч, -x: точное совпадение строки, -f: паттерны из файла
grep -vxFf "$TEMP_EXCLUDE" "$TEMP_MAIN" > "$OUTPUT_LST" || true

# Проверка результата
if [ ! -s "$OUTPUT_LST" ]; then
    echo "⚠️  Предупреждение: итоговый файл пуст!" >&2
else
    LINE_COUNT=$(wc -l < "$OUTPUT_LST")
    echo "✅ Список сохранён в $OUTPUT_LST ($LINE_COUNT доменов)"
fi

# Сохраняем новые хеши
echo "$NEW_MAIN_HASH $NEW_EXCLUDE_HASH" > "$CHECKSUM_FILE"

echo "🎉 Готово!"
