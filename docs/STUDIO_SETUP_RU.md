# Установка: сначала маленькая проверка, затем прототип

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

Это первая проверка окружения. Следующий раздел устанавливает ровно три рабочих файла.

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

## 3. Установите три файла

1. Остановите Play. Удалите стандартный `SpawnLocation` из Workspace, чтобы не было второго места появления. **Baseplate оставьте.** Не удаляйте Camera или Terrain.
2. Выберите **Workspace**. В Properties найдите **StreamingEnabled** и установите `false`: для этого малого прототипа отдельные сцены должны быть загружены целиком. Меняйте в режиме редактирования.
3. **ReplicatedStorage → ⊕ → ModuleScript**. Назовите **точно `TopicContent`**. Откройте файл `src/ReplicatedStorage/TopicContent.lua` в текстовом редакторе, скопируйте **всё** и замените всё содержимое ModuleScript.
4. **ServerScriptService → ⊕ → Script**. Назовите **`Boot`**. Замените всё содержимое кодом из `src/ServerScriptService/Boot.server.lua`. Оставьте обычный серверный режим выполнения по умолчанию. Скрипт не должен быть отключён.
5. Раскройте **StarterPlayer → StarterPlayerScripts → ⊕ → LocalScript**. Назовите **`ClientController`**. Замените всё содержимое кодом из `src/StarterPlayerScripts/ClientController.client.lua`.
6. Сохраните проект. Суффиксы `.server.lua` и `.client.lua` — соглашение для файлов на диске; в Explorer используйте имена из таблицы ниже.

```text
ReplicatedStorage
  TopicContent                 ModuleScript
ServerScriptService
  Boot                         Script
StarterPlayer
  StarterPlayerScripts
    ClientController           LocalScript
```

Вручную создавать RemoteEvent, круги, ScreenGui, трамвай или кнопки **не нужно**. Сервер создаёт `ReplicatedStorage/PrototypeEvent` и `Workspace/AMPrototype`, клиент — `PlayerGui/AMPrototypeGui` во время Play. Не добавляйте вторую копию Boot.

## 4. Первый проход

1. Нажмите F5. В Output ожидаются `[AM Theory] Server ready` и `[AM Theory] Client ready`; на экране — меню.
2. Нажмите **Spelen**. Идите к синему кругу. Постойте около двух секунд, выйдите: таймер сбросится. Вернитесь и дождитесь полных пяти секунд.
3. Книга открывается один раз. **Volgende** — следующая страница, **Vorige** — предыдущая, **Sluiten** — закрыть без завершения. На третьей странице нажмите **Theorie afronden**.
4. Встаньте на соседний оранжевый круг на пять секунд. Появится трёхсекундный пролёт камеры, затем вопрос с тремя вариантами. Выберите вариант и нажмите **Start de actie**.
5. Держите **W / ↑** или экранную кнопку **Vooruit**. Блок едет к белой линии. Отпустите заранее: блок тормозит, а не останавливается мгновенно. Можно коротко нажимать W для приближения. Нужно остановить центр блока в жёлтой зоне и оставаться неподвижно секунду. Затем **Terug naar lobby**.

Здесь проверяется только остановка перед линией. Правила уступания трамваю и продолжение движения после его проезда ещё не оцениваются.

## 5. Где менять компоненты

- `TopicContent`: страницы вашей будущей нидерландской теории. Сейчас там только явно помеченные заглушки.
- `Boot`: создание 3D-мира, серверные стадии `menu → lobby → book → cinematic → question → answered → action → result`, таймеры и результаты. Константа `DWELL = 5` задаёт время круга. Ключ ответа не передаётся клиенту до выбора.
- `ClientController`: кнопки, страницы, обратная связь, камера и отправка команд движения. Интерфейс не имеет команды «выдать баллы».

После правок на диске повторно скопируйте **полный изменённый файл** в соответствующий объект Studio. После правок в Studio скопируйте полный текст обратно в файл репозитория **до коммита**. Автоматической синхронизации пока нет.

## 6. Если не заработало

- Откройте Output, включите сообщения Client и Server, снимите фильтр по тексту. Красная строка показывает скрипт и номер строки; щелчок по ней открывает код. [Документация Output](https://create.roblox.com/docs/studio/output).
- `Infinite yield ... TopicContent`: проверьте имя, расположение и тип ModuleScript.
- Нет меню: проверьте, что `ClientController` — именно **LocalScript** в **StarterPlayerScripts**, а не в StarterCharacterScripts.
- Нет мира / нет PrototypeEvent: сначала исправьте первую красную серверную ошибку в Boot.
- Сцена пустая: убедитесь, что StreamingEnabled выключен, и нет второго Boot.
- После Stop построенные объекты исчезли: это нормально, они создаются заново при Play.
- При ошибке пришлите скриншот **Output с первой красной строкой** и дерево трёх скриптов в Explorer.

Сверка API: [RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent), [граница клиент/сервер](https://create.roblox.com/docs/scripting/security/client-server-boundary), [RunService](https://create.roblox.com/docs/reference/engine/classes/RunService), [Explorer](https://create.roblox.com/docs/studio/explorer). Код пока не запускался в Studio.
