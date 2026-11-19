# Установка текущего прототипа в Roblox Studio

Если в Studio уже установлен прототип, переходите к шагу 3 в разделе установки. На новом компьютере начните с Baseplate.

## 1. Milestone 0: первый запуск за минуту после установки Studio

1. Установите Roblox Studio с https://create.roblox.com/ и войдите в свой аккаунт. [Официальная инструкция](https://create.roblox.com/docs/studio/setup).
2. Создайте новый проект по шаблону **Baseplate**.
3. В меню **Window** откройте **Explorer**, **Properties**, **Output**. В некоторых раскладках эти команды также доступны на вкладках Home/View. Explorer показывает дерево объектов, Properties — настройки выбранного объекта, Output — сообщения и ошибки.
4. Через **File → Download a Copy** сохраните проект как `studio/AMTheoryPrototype.rbxl` внутри папки репозитория. Именно этот пункт показан в вашей версии Studio; в других версиях он может называться Save to File / Save to File As.
5. В Explorer наведите мышь на **Workspace**, нажмите **⊕**, найдите **Part**. В Properties включите **Anchored** — деталь не будет падать. После этой пробы удалите именно созданную вами деталь.
6. Наведите мышь на **ServerScriptService → ⊕ → Script**. Назовите его `HelloStudio`. Откройте двойным щелчком, замените весь текст:

```lua
print("AM Theory: первый запуск работает")
```

7. Нажмите **Play / F5**. Должны появиться персонаж и строка `AM Theory: первый запуск работает` в Output. Для перемещения используйте WASD, для приближения камеры — колесо мыши.
8. Нажмите **Stop**. Удалите `ServerScriptService/HelloStudio`. Не редактируйте исходники во время Play: такие изменения могут исчезнуть после Stop.

После этой проверки установите игровые скрипты и модули тем.

## 2. Что означают объекты

| Объект | Назначение |
| --- | --- |
| Workspace | Видимые 3D-объекты мира |
| ReplicatedStorage | Общие данные, доступные и клиенту, и серверу |
| ServerScriptService | Серверная логика; правильные ответы остаются здесь |
| StarterPlayerScripts | Скрипты интерфейса и камеры, запускаемые у каждого игрока |
| Script | Код, который в нашем размещении выполняется сервером |
| LocalScript | Код на компьютере конкретного игрока |
| ModuleScript | Данные или функции, возвращаемые через `require()` |
| RemoteEvent | Канал запросов между клиентом и сервером; запрос нужно проверять на сервере |

## 3. Установите скрипты и модули тем

1. Остановите Play. Удалите стандартный `SpawnLocation` из Workspace, чтобы не было второго места появления. **Baseplate оставьте.** Не удаляйте Camera или Terrain.
2. Выберите **Workspace**. В Properties найдите **StreamingEnabled** и установите `false`: для этого малого прототипа отдельные сцены должны быть загружены целиком. Меняйте в режиме редактирования.
3. В режиме **Stop** создайте две папки через **⊕ → Folder**. В **ReplicatedStorage** назовите папку `Theory`, в **ServerScriptService** — `Training`.
4. В каждой папке через **⊕ → ModuleScript** создайте `voorrang` и `verkeerstekens`. Используйте строчные имена. Замените стандартный текст каждого модуля содержимым соответствующего файла из таблицы.
5. Обновите `TopicContent`, `Boot` и `ClientController` по таблице. На чистом Baseplate создайте эти объекты через **⊕**, выбрав их тип. В уже настроенном place откройте существующие объекты и полностью замените их код.
6. Сохраните place. Нажмите **F5** после установки всех семи файлов.

| Путь в Explorer | Тип | Файл из Git |
| --- | --- | --- |
| ReplicatedStorage → Theory → voorrang | ModuleScript | [Теория Voorrang](../src/ReplicatedStorage/Theory/voorrang.lua) |
| ReplicatedStorage → Theory → verkeerstekens | ModuleScript | [Теория Verkeerstekens](../src/ReplicatedStorage/Theory/verkeerstekens.lua) |
| ServerScriptService → Training → voorrang | ModuleScript | [Тренировка Voorrang](../src/ServerScriptService/Training/voorrang.lua) |
| ServerScriptService → Training → verkeerstekens | ModuleScript | [Тренировка Verkeerstekens](../src/ServerScriptService/Training/verkeerstekens.lua) |
| ReplicatedStorage → TopicContent | ModuleScript | [TopicContent.lua](../src/ReplicatedStorage/TopicContent.lua) |
| ServerScriptService → Boot | Script | [Boot.server.lua](../src/ServerScriptService/Boot.server.lua) |
| StarterPlayer → StarterPlayerScripts → ClientController | LocalScript | [ClientController.client.lua](../src/StarterPlayerScripts/ClientController.client.lua) |

```text
ReplicatedStorage
  TopicContent                 ModuleScript
  Theory                       Folder
    voorrang                   ModuleScript
    verkeerstekens             ModuleScript
ServerScriptService
  Boot                         Script
  Training                     Folder
    voorrang                   ModuleScript
    verkeerstekens             ModuleScript
StarterPlayer
  StarterPlayerScripts
    ClientController           LocalScript
```

Вручную создавать RemoteEvent, круги, ScreenGui, трамвай или кнопки **не нужно**. Сервер создаёт `ReplicatedStorage/PrototypeEvent` и `Workspace/AMPrototype`, клиент — `PlayerGui/AMPrototypeGui` во время Play. Не добавляйте вторую копию Boot.

## 4. Первый проход

1. Нажмите F5. В Output ожидаются `[AM Theory] Server ready` и `[AM Theory] Client ready`; на экране — меню.
2. Нажмите **Spelen**. Идите к синему кругу. Постойте около двух секунд, выйдите: таймер сбросится. Вернитесь и дождитесь полных пяти секунд.
3. Откройте все шесть страниц **Voorrang** через **Volgende**. На последней нажмите **Theorie afronden**.
4. Постойте 5 секунд на оранжевом круге. После обзора сцены держите **W / ↑** до появления вопроса. Выберите ответ, дождитесь последствий решения, затем нажмите **Terug naar lobby**.
5. Постойте 5 секунд на фиолетовом круге, пролистайте книгу до **Einde Zone 30** и нажмите **Theorie afronden**. Постойте 5 секунд на зелёном круге. Карточки о скорости начинаются с 11-го задания.

## 5. Где менять компоненты

- `Theory`: в модуле нужной темы есть `pages` с нидерландским текстом, иллюстрациями и источником. Для правки B1–B7 откройте только `Theory → verkeerstekens`.
- `Training`: в модуле с тем же именем находятся задания, параметры сцен или карточек и правильные ответы. Они доступны серверу.
- `TopicContent` задаёт порядок станций и собирает учебные модули. `Boot` создаёт лобби, проверяет таймеры и ответы. `ClientController` показывает интерфейс, управляет камерой и передаёт запросы серверу.

После правок на диске повторно скопируйте **полный изменённый файл** в соответствующий объект Studio. После правок в Studio скопируйте полный текст обратно в файл репозитория **до коммита**. Автоматической синхронизации пока нет.

## 6. Если не заработало

- Откройте Output, включите сообщения Client и Server, снимите фильтр по тексту. Красная строка показывает скрипт и номер строки; щелчок по ней открывает код. [Документация Output](https://create.roblox.com/docs/studio/output).
- `Infinite yield`: проверьте указанные в сообщении имя и расположение объекта по таблице установки.
- Нет меню: проверьте, что `ClientController` — именно **LocalScript** в **StarterPlayerScripts**, а не в StarterCharacterScripts.
- Нет мира / нет PrototypeEvent: сначала исправьте первую красную серверную ошибку в Boot.
- Сцена пустая: убедитесь, что StreamingEnabled выключен, и нет второго Boot.
- После Stop построенные объекты исчезли: это нормально, они создаются заново при Play.
- При ошибке пришлите скриншот **Output с первой красной строкой** и дерево Explorer.

[RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) · [Граница клиент/сервер](https://create.roblox.com/docs/scripting/security/client-server-boundary) · [Explorer](https://create.roblox.com/docs/studio/explorer).
