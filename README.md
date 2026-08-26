```markdown
# 🇷🇺 Russia Inside NoYouTube — Rule Set для Podkop / sing-box

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/wineperm/russia-inside-noyoutube/update-filtered-list.yml?label=Auto%20Update&logo=github)](https://github.com/wineperm/russia-inside-noyoutube/actions)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Podkop Compatible](https://img.shields.io/badge/Podkop-✅-green)](https://podkop.app)
[![Update Status](https://github.com/wineperm/russia-inside-noyoutube/actions/workflows/update-filtered-list.yml/badge.svg)](https://github.com/wineperm/russia-inside-noyoutube/actions)

Автоматически обновляемый список доменов российских сервисов **без YouTube**, скомпилированный в формат `.srs` для использования в **Podkop**, **sing-box** и других совместимых прокси-клиентах.

---

## 📋 Описание

Этот репозиторий ежедневно обновляет два основных файла:

| Файл | Формат | Назначение |
|------|--------|------------|
| `russia-inside-noyoutube.lst` | Текстовый список доменов | Читаемый формат, ручная проверка |
| `russia-inside-noyoutube.srs` | Бинарный Rule Set (Protobuf) | ⚡ Оптимальный для sing-box / Podkop |

### 🔗 Источники данных
- **Основной список**: [`itdoginfo/allow-domains`](https://github.com/itdoginfo/allow-domains) — Россия, внутри
- **Исключения**: домены `youtube.com`, `ytimg.com`, `googlevideo.com` и др.

### ✨ Новое: пользовательские списки
Теперь вы можете **постоянно** добавлять или исключать домены из финального правила, не опасаясь, что автоматическое обновление их перезапишет. Для этого в корне репозитория созданы два файла:

- **`custom_deny.lst`** – домены, которые **всегда будут удалены** из финального списка (даже если они есть в источнике).
- **`custom_allow.lst`** – домены, которые **всегда будут добавлены** в финальный список (если их нет в источнике).

Эти файлы обрабатываются **после** загрузки актуальных списков, непосредственно перед компиляцией `.srs`. Таким образом, ваши правки **не теряются** при каждом обновлении.

---

## 🚀 Быстрое подключение в Podkop

### Вариант 1: Бинарный SRS (рекомендуется)
```
https://raw.githubusercontent.com/wineperm/russia-inside-noyoutube/main/russia-inside-noyoutube.srs
```

### Вариант 2: Текстовый список
```
https://raw.githubusercontent.com/wineperm/russia-inside-noyoutube/main/russia-inside-noyoutube.lst
```

### Настройки в Podkop:
1. Перейдите в секцию **Внешние списки доменов**
2. Нажмите **«Добавить список»**
3. Вставьте одну из ссылок выше
4. Тип правила: **Domain Suffix** (по умолчанию)
5. Сохраните и примените конфигурацию

> 💡 **Совет**: Используйте `.srs` — он обрабатывается быстрее и занимает меньше места.

---

## 📁 Структура репозитория

```
📦 russia-inside-noyoutube
├── 📄 README.md                 # Этот файл
├── 📄 .gitignore               # Исключения для git
├── 📁 .github/
│   └── 📁 workflows/
│       └── 📄 update-filtered-list.yml  # GitHub Actions workflow
├── 📁 scripts/
│   └── 📄 filter_and_check.sh  # Скрипт фильтрации доменов
├── 📄 russia-inside-noyoutube.lst   # ✅ Текстовый список (автогенерация)
├── 📄 russia-inside-noyoutube.srs   # ✅ Бинарный SRS (автогенерация)
├── 📄 custom_allow.lst          # ➕ Пользовательские домены для добавления
├── 📄 custom_deny.lst           # ➖ Пользовательские домены для исключения
└── 📄 .last_checksums          # Хеш-суммы для отслеживания изменений
```

---

## ⚙️ Как это работает

### 🔁 Автоматическое обновление
1. **Ежедневно в 03:00 UTC** запускается GitHub Actions
2. Скрипт скачивает актуальные списки с `itdoginfo/allow-domains`
3. Исключает все домены, связанные с YouTube
4. Очищает и нормализует список → сохраняет в `russia-inside-noyoutube.lst`
5. **Применяет пользовательские правила**:
   - Удаляет домены из `custom_deny.lst`
   - Добавляет домены из `custom_allow.lst` (если их нет)
6. Компилирует финальный список в `.srs` через `sing-box rule-set compile`
7. Если есть изменения — пушит в репозиторий и отправляет уведомление в Telegram

### 🔄 Триггеры запуска
```yaml
on:
  schedule:
    - cron: '0 3 * * *'        # Ежедневно в 3:00 UTC
  push:
    branches: [main]
    paths:
      - 'scripts/filter_and_check.sh'
      - 'russia-inside-noyoutube.lst'
      - 'custom_allow.lst'      # ➕ При изменении пользовательских списков
      - 'custom_deny.lst'       # ➖ тоже запускает пересборку SRS
  workflow_dispatch:           # Ручной запуск через интерфейс GitHub
```

---

## 🛠️ Развёртывание своей копии

### 1. Форкните репозиторий
Нажмите **Fork** в правом верхнем углу GitHub.

### 2. Настройте секреты (для Telegram-уведомлений)
Перейдите в **Settings → Secrets and variables → Actions** и добавьте:

| Secret | Описание |
|--------|----------|
| `TELEGRAM_BOT_TOKEN` | Токен бота от [@BotFather](https://t.me/BotFather) |
| `TELEGRAM_CHAT_ID` | ID чата для уведомлений (узнать через [@getidsbot](https://t.me/getidsbot)) |

> ⚠️ Уведомления в Telegram — опционально. Если не настроите, воркфлоу будет работать без них.

### 3. Настройте пользовательские списки (по желанию)
- Добавьте нужные домены в `custom_deny.lst` (по одному на строку) для постоянного исключения.
- Добавьте нужные домены в `custom_allow.lst` для постоянного добавления.
- Эти файлы можно изменять в любое время — после пуша сразу пересобирается SRS.

### 4. Запустите первое обновление вручную
1. Перейдите во вкладку **Actions**
2. Выберите воркфлоу **Update filtered Russia list**
3. Нажмите **Run workflow** → **Run workflow**

### 5. Готово! 🎉
Файлы `.lst` и `.srs` появятся в репозитории после успешного выполнения.

---

## 🔧 Локальное тестирование

```bash
# 1. Клонируйте репозиторий
git clone https://github.com/wineperm/russia-inside-noyoutube.git
cd russia-inside-noyoutube

# 2. Сделайте скрипт исполняемым
chmod +x scripts/filter_and_check.sh

# 3. Запустите фильтрацию (получите свежий .lst)
./scripts/filter_and_check.sh

# 4. Проверьте результат
head -10 russia-inside-noyoutube.lst
cat custom_deny.lst custom_allow.lst

# 5. (Опционально) Протестируйте компиляцию SRS локально с применением custom-правил
# Создайте финальный список (повторите логику из workflow)
cp russia-inside-noyoutube.lst final.lst
# Удалите домены из custom_deny.lst
while IFS= read -r deny; do sed -i "/^$deny$/d" final.lst; done < custom_deny.lst
# Добавьте домены из custom_allow.lst
while IFS= read -r allow; do grep -qxF "$allow" final.lst || echo "$allow" >> final.lst; done < custom_allow.lst
# Скомпилируйте SRS
echo '{"version": 3, "rules": [{"domain_suffix": [' > rules.json
sed 's/^/"/; s/$/"/' final.lst | paste -sd ',' >> rules.json
echo ']}]}' >> rules.json
docker run --rm -v "$(pwd):/data" ghcr.io/sagernet/sing-box:latest \
  rule-set compile --output /data/test.srs /data/rules.json
rm rules.json final.lst test.srs
```

---

## ❓ FAQ

### Почему файл `.srs` выглядит как "кракозябры"?
Это **нормально**. Файлы `.srs` используют бинарный формат Protobuf для максимальной производительности. Не пытайтесь читать их в текстовом редакторе — используйте `.lst` для просмотра содержимого.

### Как добавить свои исключения или домены **постоянно**?
Отредактируйте файлы `custom_deny.lst` (для исключения) или `custom_allow.lst` (для добавления) в корне репозитория. Каждый домен с новой строки. После пуша этих файлов автоматически пересоберётся `.srs` с применёнными правками. При следующих обновлениях ваши правки сохранятся.

### Почему я вижу домен в `.lst`, но его нет в `.srs`?
Это нормально, если вы добавили его в `custom_deny.lst`. Файл `.lst` содержит исходный список из источников, а `.srs` — финальный после применения пользовательских правил. Для проверки содержимого `.srs` используйте `sing-box rule-set dump`.

### Можно ли исключить другие сервисы (кроме YouTube)?
Да! Добавьте домены в `custom_deny.lst`. Если вы хотите исключить их навсегда, просто оставьте их там. Если хотите временно — можете убрать из файла, и при следующем обновлении они вернутся (если есть в источнике).

### Почему не обновляется список?
1. Проверьте вкладку **Actions** — нет ли ошибок в логах
2. Убедитесь, что исходные списки `itdoginfo` изменились (скрипт сравнивает MD5-хеши)
3. Проверьте, что файлы не добавлены в `.gitignore`

### Можно ли использовать в других клиентах?
- ✅ **Podkop** — полная поддержка `.srs` и `.lst`
- ✅ **sing-box** — нативная поддержка `.srs`
- ✅ **Clash Meta / Mihomo** — поддержка через `rule-providers`
- ⚠️ **Qv2ray / V2Ray** — только текстовый `.lst`, требуется конвертация

---

## 🤝 Вклад в проект

Предложения по улучшению приветствуются! 🙌

1. Создайте форк репозитория
2. Создайте ветку для вашей фичи: `git checkout -b feature/amazing-feature`
3. Внесите изменения и закоммитьте: `git commit -m 'Add: amazing feature'`
4. Отправьте в свой форк: `git push origin feature/amazing-feature`
5. Откройте **Pull Request**

---

## 📜 Лицензия

Проект распространяется под лицензией **MIT**. См. файл [LICENSE](LICENSE) для деталей.

Исходные данные взяты из репозитория [`itdoginfo/allow-domains`](https://github.com/itdoginfo/allow-domains) (лицензия автора).

---

## ⚠️ Отказ от ответственности

> Этот проект предоставляется «как есть», без каких-либо гарантий. Автор не несёт ответственности за возможные проблемы при использовании списков.

---

## 📬 Контакты

- 🐛 [Сообщить об ошибке](https://github.com/wineperm/russia-inside-noyoutube/issues)
- 💡 [Предложить улучшение](https://github.com/wineperm/russia-inside-noyoutube/discussions)

---

> ⭐ **Понравился проект?** Поставьте звезду — это помогает другим найти репозиторий!

```yaml
# Если этот репозиторий оказался полезным — поделитесь ссылкой с друзьями! 🙏
```
```

---

Теперь ваш README полностью отражает новую функциональность с пользовательскими списками. Вы можете скопировать этот текст и заменить им существующий файл в репозитории.
