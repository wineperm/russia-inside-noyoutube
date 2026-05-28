#!/bin/bash

# URLs исходных файлов (raw-версии)
MAIN_URL="https://raw.githubusercontent.com/aezakmi8/podkop-allow-domains/main/Russia/inside-raw.lst"
EXCLUDE_URL="https://raw.githubusercontent.com/aezakmi8/podkop-allow-domains/main/Services/youtube.lst"

OUTPUT_FILE="russia-inside-noyoutube.lst"
CHECKSUM_FILE=".last_checksums"

# Функция вычисления MD5-хеша файла
md5_hash() {
    md5sum "$1" | cut -d' ' -f1
}

# Скачиваем текущие версии во временные файлы
TEMP_MAIN=$(mktemp)
TEMP_EXCLUDE=$(mktemp)

echo "Загрузка основного списка..."
curl -fsSL "$MAIN_URL" -o "$TEMP_MAIN" || { echo "Ошибка загрузки основного списка"; exit 1; }
echo "Загрузка списка исключений (YouTube)..."
curl -fsSL "$EXCLUDE_URL" -o "$TEMP_EXCLUDE" || { echo "Ошибка загрузки списка исключений"; exit 1; }

# Хеши новых файлов
NEW_MAIN_HASH=$(md5_hash "$TEMP_MAIN")
NEW_EXCLUDE_HASH=$(md5_hash "$TEMP_EXCLUDE")

# Чтение старых хешей
if [ -f "$CHECKSUM_FILE" ]; then
    read -r OLD_MAIN_HASH OLD_EXCLUDE_HASH < "$CHECKSUM_FILE"
else
    OLD_MAIN_HASH=""
    OLD_EXCLUDE_HASH=""
fi

# Сравнение
if [ "$NEW_MAIN_HASH" = "$OLD_MAIN_HASH" ] && [ "$NEW_EXCLUDE_HASH" = "$OLD_EXCLUDE_HASH" ]; then
    echo "Исходные файлы не изменились. Выход без обновления."
    rm "$TEMP_MAIN" "$TEMP_EXCLUDE"
    exit 0
fi

echo "Обнаружены изменения. Формируем новый фильтрованный список..."

# Удаляем строки, присутствующие в списке исключений (полное совпадение)
grep -vxFf "$TEMP_EXCLUDE" "$TEMP_MAIN" > "$OUTPUT_FILE"

# Проверка на пустоту
if [ ! -s "$OUTPUT_FILE" ]; then
    echo "Предупреждение: итоговый файл пуст. Возможно, основной список пуст или полностью состоит из исключений."
fi

# Сохраняем новые хеши
echo "$NEW_MAIN_HASH $NEW_EXCLUDE_HASH" > "$CHECKSUM_FILE"

# Очистка временных файлов
rm "$TEMP_MAIN" "$TEMP_EXCLUDE"

echo "Готово. Результат сохранён в $OUTPUT_FILE"
