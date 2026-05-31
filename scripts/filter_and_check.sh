#!/bin/bash

# URL исходных файлов (репозиторий itdoginfo)
MAIN_URL="https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/inside-raw.lst"
EXCLUDE_URL="https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Services/youtube.lst"

OUTPUT_LST="russia-inside-noyoutube.lst"
CHECKSUM_FILE=".last_checksums"

# Функция MD5
md5_hash() {
    md5sum "$1" | cut -d' ' -f1
}

# Временные файлы
TEMP_MAIN=$(mktemp)
TEMP_EXCLUDE=$(mktemp)

echo "Загрузка основного списка..."
curl -fsSL "$MAIN_URL" -o "$TEMP_MAIN" || { echo "Ошибка загрузки основного списка"; exit 1; }
echo "Загрузка списка исключений (YouTube)..."
curl -fsSL "$EXCLUDE_URL" -o "$TEMP_EXCLUDE" || { echo "Ошибка загрузки списка исключений"; exit 1; }

NEW_MAIN_HASH=$(md5_hash "$TEMP_MAIN")
NEW_EXCLUDE_HASH=$(md5_hash "$TEMP_EXCLUDE")

if [ -f "$CHECKSUM_FILE" ]; then
    read -r OLD_MAIN_HASH OLD_EXCLUDE_HASH < "$CHECKSUM_FILE"
else
    OLD_MAIN_HASH=""
    OLD_EXCLUDE_HASH=""
fi

if [ "$NEW_MAIN_HASH" = "$OLD_MAIN_HASH" ] && [ "$NEW_EXCLUDE_HASH" = "$OLD_EXCLUDE_HASH" ]; then
    echo "Исходные файлы не изменились. Выход."
    rm "$TEMP_MAIN" "$TEMP_EXCLUDE"
    exit 0
fi

echo "Обнаружены изменения. Формируем новый список..."

grep -vxFf "$TEMP_EXCLUDE" "$TEMP_MAIN" > "$OUTPUT_LST"

if [ ! -s "$OUTPUT_LST" ]; then
    echo "Предупреждение: итоговый файл пуст."
fi

echo "$NEW_MAIN_HASH $NEW_EXCLUDE_HASH" > "$CHECKSUM_FILE"

rm "$TEMP_MAIN" "$TEMP_EXCLUDE"

echo "Список сохранён в $OUTPUT_LST"
