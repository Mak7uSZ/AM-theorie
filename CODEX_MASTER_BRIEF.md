# Codex: Roblox AM Theory Simulator — Master Brief (v0.2)

> Language for communication with the project owner: **Russian**. Player-facing educational content and road rules: **Dutch (Nederlands)**. Technical identifier names and code comments: English.
>
> **Priority:** the owner wants to personally study Dutch AM theory by writing its content, and produce a convincing programming portfolio project. Commercial success is optional. The owner has **never programmed in Roblox Studio**. Lead as an experienced Luau engineer and patient hands-on teacher.

## 0. Your immediate task

**Owner update, 18 November 2026:** The target curriculum now uses eight visible sections: Wetgeving; Voertuigkennis; Gebruik van de weg; Voorrang en voor laten gaan; Bijzondere wegen; Veilig rijden en noodsituaties; Verkeerstekens; Verantwoord rijden. This supersedes the suggested topic grouping below. See `docs/CURRICULUM_REFERENCE_RU.md` for screenshot-derived requirements, future numeric/actor-selection/ordering formats, and `docs/AM_TOPIC_MAP_RU.md` for stable subtopic IDs. Introduce these formats incrementally; their specification does not mean they have been implemented. The owner learns by building the game, about four small subtopics per week.

Do **not** generate the entire project in one giant answer. First explain the Roblox Studio basics the owner needs, then implement the first tested vertical slice outlined in Milestone 1 below. If working inside a local repository, create the files and the repository structure; if no Roblox Studio access, **do not claim the game has been tested in Studio**. Provide exact manual Explorer paths, object types, and Play Mode verification steps. Ask for a screenshot of the Output window if a runtime error occurs. Do not introduce Rojo, GitHub Actions, external plugins, or complicated tooling before the owner can run a basic version; these may be introduced later as optional upgrades.

## 1. Game overview / non-negotiable design

Working title: **Roblox AM Theory Simulator** (NL moped/scooter theory, AM category).

This is **not** a linear slideshow or an always-on car simulator. The primary place is a real, navigable **3D lobby**. A player can freely walk among topic stations, an exam hall, a large leaderboard wall, and an information area. The game combines reading theory, checkpoint exams, cinematic road scenes, and short driving actions.

**Flow:**
1. Main screen GUI: Play, Settings, Progress (minimal functionality initially).
2. Click Play -> spawn inside the 3D lobby; free Roblox avatar movement.
3. Each topic has **two adjacent visible circular pads on the floor**:
   - **Theory Circle**: remain inside for **5 uninterrupted seconds**; visible radial/countdown indicator 5 -> 0; walk off = cancel/reset; on success open a paginated **book** UI, optionally shift camera toward a lectern. The owner personally writes the theory in Dutch. Pages can contain explanations, diagrams and illustrations later.
   - **Training Circle**: after this topic's book has been completed, remain inside for 5 seconds; begin **10 separate cinematic road questions**, each with a separate small scene/camera setup. (A player may replay a completed topic.)
4. Each cinematic training challenge presents an AM-style original question with 2–4 possible answers; then makes the player **physically perform** the relevant action in a simplified riding scenario (e.g., stop before a stop line, wait for tram, continue when safe). The knowledge answer and the road action are graded **separately**; each challenge explains errors.
5. Complete a topic's training to **unlock the next topic**. In the design, 'passing' is configurable; provisional suggestion = at least 8/10 knowledge correct **and** at least 8/10 successful actions. Do not hardcode this threshold as an immutable product rule; ask the owner before finalizing.
6. After the final topic, the **Final Oefenexamen** area becomes accessible. Target 50 original AM-style questions (the exact current format should be independently verified against the official CBR information before release). Show result, accuracy and elapsed time. Only passed, server-verified exams appear on leaderboard.
7. In the lobby, a **huge 3D leaderboard board** displays top passed exam scores: username, correctly answered/total or accuracy, and time. Primary ranking **accuracy first, time second**, so rushing is not rewarded over safety/knowledge. Later maybe a second leaderboard for fastest perfect exam. Until global leaderboard exists, show an explicitly labeled *preview* instead of made-up user scores.
8. The project must be modular: dozens of topics, questions, and scenes must be addable as DATA and reusable scene prefabs, not giant copies of code.

## 2. Functional details

### Main menu
- Clean ScreenGui shown on join, with Play button. While menu open, the avatar can be safely held/spawned in a menu area or controls disabled. Avoid breaking normal multiplayer character spawning.
- Play fades into lobby, unlocks avatar controls and shows topic markers.
- Settings and Progress can start as minimal real UI screens; don't add misleading buttons that do nothing.

### Lobby
- Compact Roblox-friendly 3D training academy, not a full city.
- Topics arranged in an easily understood progression (pods/stations/road-themed exhibits) with colored labels showing `LOCKED`, `THEORY`, `READY FOR TRAINING`, `PASSED`.
- Each station has two adjacent circular pads (`TheoryPad`, `TrainingPad`), distinct colors and labels. If locked, show clear explanation instead of silently ignoring player.
- The 5-second dwell timer counts while the player is physically on/near the pad **on the server**. It resets when leaving, dying, teleporting, opening another UI, or entering another station. UI shows countdown. Avoid fragile `Touched`-only tracking; server should sample actual character/HRP position or equivalent authoritative zone check.
- Prevent duplicate triggers and conflicting sessions, per-player.
- Countdown on theory circle ends by opening `BookGui`. The book has pages, Back/Next, progress, Close; a `Finish theory` action is enabled after reaching the final page. Reading the book marks the topic as read (not passed). Returning players can reopen it.
- Training circle triggers only after corresponding `theoryRead` state is true; optionally allow review without re-reading.

### Theory book and content policy
- All rule text is authored by the owner **in Dutch**. Codex must supply the **primary official source first**, with article/section and working URL (e.g., RVV 1990 on wetten.overheid.nl, CBR when relevant). The owner paraphrases the rule in their own words; Codex reviews factual accuracy, exceptions, and clarity before flagging content `reviewed`.
- Define data model: `topicId`, `titleNl`, `sourceName`, `sourceUrl`, `article`, `pages` (paragraphs/images placeholders), `reviewStatus` (`draft`/`awaiting_review`/`reviewed`), `questionIds`, `sceneIds`.
- A `draft` page may be shown in developer mode but must be visibly marked as draft; don't silently publish inaccurate guidance.
- Do NOT copy copyrighted CBR questions or third-party practice exam graphics; create original scenarios based on official rules. Never claim the game is officially affiliated with CBR.

### Training mode / scenes
- **10 scenes per topic in the complete design**; each scene is a separate reusable prefabricated environment/room and camera preset, not necessarily a standalone Roblox `Place` or server. Keeping them in the same Roblox experience avoids needless teleport complexity.
- A session loads/activates one scenario at a time, positions scooter/player, switches to Scriptable camera for cutscene, freezes/controls movement when question is shown, then restores driving control after an answer.
- For action checks, use configurable predicates (`stop_before_line`, `yield_until_clear`, `slow_before_zone`, `indicate_then_turn`, etc.) validated by server. v0.1 implement ONLY a reliable simple action `stop_before_line` for the tram scene.
- Make mistakes teachable: show Dutch explanation and option to retry in training, but do not give credit for a retry in strict exam mode.
- During prototype, a simple non-realistic vehicle/controller is fine; don't spend days on realistic physics or city builds.
- Driving speeds must not be presented as real km/h until scale and vehicle dynamics are calibrated. Distinguish simulated studs/s from road speed.

### Topics (suggested order, configurable)
1. Voorrang (including tram, unregulated crossings, traffic lights, yielding, turning)
2. Verkeersborden en verkeerstekens
3. Plaats op de weg en snelheden (bromfiets/snorfiets, inside/outside bebouwde kom)
4. Afslaan, inhalen en bijzondere manoeuvres
5. Verlichting en zicht
6. Defensief rijden en gevaarherkenning
7. Weggebruikers, voetgangers en fietsers
8. Voertuigtechniek en veiligheid
9. Overige AM-regels
10. Herhaling / mixed exam preparation
Topics can be merged/expanded after reviewing official AM syllabus. Do not invent laws.

### End-of-course mock exam
- Unlock after all required topics have `passed` state.
- All questions are original, reviewed and stored in a server-only question bank for answer keys; expose to client only prompt/options (not `correctAnswerIndex`) until graded.
- Exam session maintained by server: questions, current question, time, score, completion, cheat/rate-limit validation. Avoid exposing a client API for setting score or passing topics.
- Leaderboard results: passed exams only; server verifies. Display both correct count/accuracy and elapsed time. Do not rank a fast incorrect exam ahead of a higher-accuracy one.
- Some exam questions can be static images; the training scenes remain separate playable scenes.

### Persistence, leaderboard and multiplayer
- Per-player persistent state: `topics[topicId]={theoryRead, trainingPassed, bestKnowledge, bestAction, bestTime}`, `highestUnlockedTopic`, and `bestPassedExam`.
- For first demo: clearly labeled session-only/local storage, then implement DataStoreService later; use `pcall`, retries/backoff, `UpdateAsync` where suitable, avoid writes each second. Server owns all authoritative state.
- Global leaderboard: OrderedDataStore for sortable numeric composite score or separate accuracy/time stores, with a robust scheme that preserves desired ordering, plus mapping for display details. Test tie-breaks and data consistency before public release.
- Server-side trust boundary: validate all RemoteEvents, check pad proximity and interaction phase server-side, cooldown events, disallow sending fake scores or marking progress completed.
- Each player has independent scene/training state. In multiplayer, separate scenario instances/locations or otherwise isolate so two players don't interfere.

### Monetization (not in MVP)
- This project is primarily for studying and portfolio, **not** a retention-maximizing monetization funnel.
- If the game proves useful: consider **Paid Access** around 25–30 Robux and TikTok short clips demonstrating tricky AM situations. Roblox currently documents paid access pricing of 25–1000 Robux: https://create.roblox.com/docs/production/monetization/paid-access-robux. Reverify rules before release.
- No pay-to-pass, no random loot, no gamified gambling; do not spend implementation time on monetization now.

## 3. Architecture (suggested Roblox Explorer structure)

```text
ReplicatedStorage/
  Shared/
    TopicMetadata            (ModuleScript; public metadata only)
    GameConstants            (ModuleScript)
  Remotes/
    LobbyEvent               (RemoteEvent)
    BookEvent                (RemoteEvent)
    TrainingEvent            (RemoteEvent)
    ProgressEvent            (RemoteEvent)
ServerScriptService/
  Boot.server.lua            (Script)
  Services/
    PlayerProgressService    (ModuleScript)
    ZoneDwellService         (ModuleScript)
    TopicService             (ModuleScript)
    TrainingSessionService   (ModuleScript)
    ExamService              (ModuleScript; later)
    LeaderboardService       (ModuleScript; later)
  Data/
    TopicContent             (ModuleScript; official sources and owner-written theory)
    QuestionAnswerKey        (ModuleScript; server-only answer keys)
StarterPlayer/
  StarterPlayerScripts/
    ClientController.client.lua (LocalScript)
    Controllers/
      MenuController         (ModuleScript)
      LobbyController        (ModuleScript)
      BookController         (ModuleScript)
      CutsceneController     (ModuleScript)
      TrainingController     (ModuleScript)
StarterGui/
  [ScreenGuis or programmatic UI]
ServerStorage/
  ScenarioTemplates/
    TramCrossing01           (Model; later)
Workspace/
  Lobby/
    SpawnLocation
    LeaderboardWall
    TopicStations/
      Voorrang/
        TheoryPad
        TrainingPad
    ExamArea
  ActiveScenarioAreas/       (private/isolated areas later)
```

**Important:** This is the **target structure**, not a requirement to implement every service at once. For the first slice, fewer clean modules are preferable to dozens of empty files. Existing earlier 3-script ZIP from prior iteration was a prototype concept and is **superseded by this updated lobby-first specification**. Codex may reuse ideas, but must verify and adapt; do not assume that ZIP is already imported or functional.

## 4. Development roadmap with acceptance tests

### Milestone 0 — onboarding and scaffold
- Explain to new Roblox Studio user: create `Baseplate`, save as `.rbxl`, reveal `Explorer`, `Properties`, `Output`, insert `Part`, `Script`, `LocalScript`, `ModuleScript`, use `Play (F5)` and `Stop`.
- Supply exact names and paths; include a 60-second success test: player spawns in simple world, `print` appears in Output.
- If writing repository files outside Studio, explicitly explain they will not magically appear in Studio; start with manual copying. Rojo can be discussed later.

### Milestone 1 — first end-to-end vertical slice (IMPLEMENT FIRST)
- Main menu with working `Play` button.
- Simple small 3D lobby with one `Voorrang` topic station and two neighboring circles, different labels/colors.
- A server-validated, **uninterrupted 5-second dwell timer** on the theory circle, resets immediately on exit.
- Book GUI with **2–3 short placeholder pages**, Dutch text clearly marked `[CONCEPT — OWNER TO WRITE]`; Back/Next/Finish/Close. Finishing marks theory read **in session only**.
- Training circle only available after the player finishes the book; same 5-second countdown.
- After training trigger: **one tram crossing cutscene** with an original Dutch placeholder question, 3 answers, safe server-side answer validation; a simple action-check (stop before line) and feedback; then return to lobby.
- One simple leaderboard wall with title `Oefenexamen Leaderboard — Coming Later` and honest placeholder; **do not invent scores**.
- Provide a numbered manual Studio installation guide with exact Explorer objects and file locations; explain how to read Output errors.

**Milestone 1 is complete only if:**
1. Join -> menu -> Play -> freely walk in lobby.
2. Leave TheoryPad at 3 sec -> timer visibly resets, no book.
3. Stand 5 sec -> paginated book opens once.
4. TrainingPad before theory finished -> doesn't start; tells user why.
5. Finish book -> TrainingPad available.
6. Stand on training pad 5 sec -> single cutscene/question.
7. Correct and incorrect answers both show suitable feedback; no answer key leaked in advance.
8. Action stage checks a real stop before line and leads to a result.
9. Returns to lobby cleanly; no stuck camera/input/UI.
10. Two players can join without corrupting each other's session state, or MVP explicitly disallows simultaneous training until isolation is implemented and flags this as a limitation.

### Milestone 2 — first full Voorrang topic
- Owner writes and reviews full Dutch theory; validated sources.
- 10 original varied question/scene definitions; share prefab architecture.
- Pass/fail threshold configurable. State progression, replay, errors explained.

### Milestone 3 — modular multi-topic course
- Add next topics as data; progression lock/unlock with visually clear stations.
- Save/load progress with DataStoreService, robust failure handling.

### Milestone 4 — final mock exam + leaderboard
- Locked exam hall, 50-question configurable mock exam, server-side scoring.
- Big 3D board with correct, passed results, accuracy/time and proper ranking. Persist across sessions.

### Milestone 5 — polish and launch
- Camera and vehicle polish, art, onboarding, sound, mobile controls, accessibility, multiplayer robustness, anti-cheat tests.
- Only after validating content consider Paid Access and TikTok promotion.

## 5. Rules for Codex collaboration with owner

1. Speak Russian to owner. In-game academic content Dutch. No long English-only instruction dumps.
2. User has never programmed in Roblox Studio; explain each new concept when first used: Explorer, Workspace, ReplicatedStorage, ServerScriptService, StarterGui, Script vs LocalScript, RemoteEvent.
3. Teach through small verifiable increments; **do not write 1000 lines before the first Play Mode check**. Prefer 1–3 files per round and finish with a simple test.
4. If code changes, specify exactly which existing Script to replace and give COMPLETE revised content, not ambiguous code fragments.
5. For every task: show (a) goal, (b) what to click in Studio, (c) code or generated file, (d) what expected result looks like, (e) how to debug it, (f) how it connects to later steps.
6. Ask only for essential clarifications; use sensible defaults otherwise. Example: pass score of 8/10 is **proposed**, not confirmed.
7. Verify current Roblox API against official Creator Hub when using nontrivial APIs. Do not invent Studio functionality or assert simulator tested unless actually tested.
8. If the owner's Dutch rule text is submitted for review, **fact-check against official RVV 1990 or appropriate Dutch official source**; flag exceptions and uncertainties. User retains authorship of theory text.
9. Avoid third-party copyrighted exam question banks, pirated assets, leaked questions, official affiliation claims, and misleading final exam guarantees.
10. Avoid external dependencies without prior justification. Minimize `while true` loops, event leaks, client-trusted state, unbounded DataStore writes, and bad camera state restoration.
11. When delivering a change, give a quick note of what is functional, what is placeholder, and what is not yet implemented.

## 6. Suggested first response from Codex

- Confirm understanding: menu -> freely traversable 3D lobby -> two adjacent 5-sec circles per topic -> book -> 10 road cutscenes -> next topic -> final exam -> big leaderboard.
- State first target = Milestone 0 + Milestone 1, not the full game.
- Give exact click-by-click beginner setup: install/open Roblox Studio, Baseplate, Explorer/Properties/Output, project saving.
- Start building playable menu/lobby/pads as the first runnable small step. Do **not** claim previous ZIP has been imported automatically.
- At end provide explicit 3–5 action checklist to run in Play Mode.

## 7. Source links to maintain and check

- RVV 1990 (Dutch road rules): https://wetten.overheid.nl/BWBR0004825/
- Roblox beginner onboarding: https://create.roblox.com/docs/tutorials/curriculums/coding/get-started
- Roblox Explorer: https://create.roblox.com/docs/studio/explorer
- Roblox Output: https://create.roblox.com/docs/studio/output
- Roblox RemoteEvent: https://create.roblox.com/docs/reference/engine/classes/RemoteEvent
- Roblox client/server security: https://create.roblox.com/docs/scripting/security/client-server-boundary
- Roblox data stores: https://create.roblox.com/docs/cloud-services/data-stores
- Roblox paid access: https://create.roblox.com/docs/production/monetization/paid-access-robux

**Project ownership principle:** User writes/learns all the theory; Codex builds the systems while explaining how they work, and reviews factual content only after user supplies it. Start small, prove it works, expand.
