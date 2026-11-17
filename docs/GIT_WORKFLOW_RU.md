# Git: работа с разных компьютеров

Git хранит историю исходников. GitHub/GitLab хранит их общую удалённую копию. Roblox хранит опубликованный place отдельно. Прогресс игроков в будущем будет храниться в DataStore — это третья, отдельная система.

## Что уже настроено

- Локальный репозиторий, основная ветка `main`.
- `.gitignore` исключает временные файлы, секреты и локальные Studio places.
- `.gitattributes` согласует окончания строк исходников.
- Три полных исходных файла и инструкции восстановления на чистом Baseplate.
- Подключён `origin`: https://github.com/Mak7uSZ/AM-theorie.git. Для синхронизации выполняйте `push`/`pull`.

## Подключённый GitHub

Репозиторий уже создан: https://github.com/Mak7uSZ/AM-theorie. Следующие команды нужны только для подключения существующей локальной копии, у которой ещё нет origin:

```powershell
git remote add origin https://github.com/Mak7uSZ/AM-theorie.git
git push -u origin main
```

При запросе Git выполните вход в браузере. Не вставляйте пароль или токен в исходники. Если origin уже добавлен, проверьте `git remote -v`; для исправления адреса используйте `git remote set-url origin ...`.

## Второй компьютер

Установите Git и Roblox Studio. В PowerShell:

```powershell
git clone https://github.com/Mak7uSZ/AM-theorie.git AM-TheorieSpel
cd AM-TheorieSpel
```

Затем откройте `docs/STUDIO_SETUP_RU.md`: новый Baseplate и вставка трёх файлов. Все детали текущего прототипа создаются кодом, поэтому игнорируемый `.rbxl` не требуется для восстановления.

## Каждый рабочий сеанс

Перед началом, если нет локальных несохранённых изменений:

```powershell
git switch main
git pull --ff-only
```

После правок и проверки в Studio скопируйте изменённый код обратно в `src`, затем:

```powershell
git status
git diff
git add src docs README.md
git commit -m "Improve lobby prototype"
git push
```

Прежде чем перейти на другой ПК, завершите `push`. На другом ПК выполните `pull`. Не редактируйте одновременно одну и ту же ветку на двух компьютерах. Если pull сообщает о локальных изменениях, сначала сохраните их коммитом; не применяйте `reset --hard` для обхода ошибки.

## Отдельная ветка для задачи (необязательно сначала)

```powershell
git switch -c codex/improve-book
```

После изменений:

```powershell
git add src docs
git commit -m "Improve theory book"
git push -u origin codex/improve-book
```

Для продолжения этой задачи на другом ПК:

```powershell
git fetch origin
git switch codex/improve-book
git pull --ff-only
```

Ветки можно объединять через Pull Request на GitHub. Сейчас CI, Rojo и внешние плагины не нужны.
