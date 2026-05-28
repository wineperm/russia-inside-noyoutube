# 🇷🇺 Russia inside domain list (without YouTube)

[![GitHub Actions status](https://github.com/wineperm/russia-inside-noyoutube/actions/workflows/update-filtered-list.yml/badge.svg)](https://github.com/wineperm/russia-inside-noyoutube/actions/workflows/update-filtered-list.yml)
[![Last commit](https://img.shields.io/github/last-commit/wineperm/russia-inside-noyoutube)](https://github.com/wineperm/russia-inside-noyoutube/commits/main)

**Автоматически обновляемый список разрешённых доменов для России, очищенный от всех доменов YouTube и связанных с ним сервисов.**

Этот репозиторий предоставляет готовый к использованию файл `russia-inside-noyoutube.lst`, который всегда содержит актуальную версию списка `Russia/inside-raw.lst` из [podkop-allow-domains](https://github.com/aezakmi8/podkop-allow-domains) **без** строк, перечисленных в `Services/youtube.lst`.

## 🎯 Цель

Исходные списки ([aezakmi8/podkop-allow-domains](https://github.com/aezakmi8/podkop-allow-domains)) часто обновляются. Вручную удалять домены YouTube из основного списка неудобно. Мы автоматизировали процесс:

- каждые 15 минут проверяются изменения в исходных файлах (по MD5‑хешам);
- если данные изменились — формируется новый отфильтрованный список;
- результат коммитится обратно в репозиторий;
- при успешном обновлении отправляется уведомление в Telegram.

Так вы всегда имеете свежий список **без YouTube** с минимальной задержкой.

## 📥 Использование

Прямая ссылка на итоговый файл (для использования в прокси, блокировщиках, DNS‑фильтрах и т.д.):

https://raw.githubusercontent.com/wineperm/russia-inside-noyoutube/main/russia-inside-noyoutube.lst


Можете также просматривать файл прямо в репозитории: [russia-inside-noyoutube.lst](russia-inside-noyoutube.lst).

## ⚙️ Как это работает (внутреннее устройство)

- **Исходные данные**  
  `MAIN_LIST` = `https://raw.githubusercontent.com/aezakmi8/podkop-allow-domains/main/Russia/inside-raw.lst`  
  `EXCLUDE_LIST` = `https://raw.githubusercontent.com/aezakmi8/podkop-allow-domains/main/Services/youtube.lst`

- **Механизм**  
  - GitHub Actions запускается по расписанию (`cron: '*/15 * * * *'`) или вручную.
  - Скрипт `scripts/filter_and_check.sh` скачивает оба списка, вычисляет MD5 и сравнивает с предыдущими значениями (хранятся в `.last_checksums`).
  - Если хеши совпадают — процесс завершается без коммита.
  - Если хеши различаются — из основного списка удаляются строки, присутствующие в списке исключений (команда `grep -vxFf`), результат записывается в `russia-inside-noyoutube.lst`, обновляется `.last_checksums`, изменения пушатся в репозиторий.
  - После успешного пуша отправляется уведомление в Telegram (через `curl` без сторонних действий).

## 🧪 Локальный запуск (для отладки)

Если вы хотите вручную обновить список у себя на компьютере:

```bash
git clone https://github.com/wineperm/russia-inside-noyoutube.git
cd russia-inside-noyoutube
chmod +x scripts/filter_and_check.sh
./scripts/filter_and_check.sh
