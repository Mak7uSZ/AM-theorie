# AGENTS.md — Instructions for coding agents

Read [CODEX_MASTER_BRIEF.md](CODEX_MASTER_BRIEF.md) first. That document is the source of truth for the Roblox AM Theory Simulator.

- Talk to the owner in Russian; educational text is authored by the owner in Dutch.
- Owner is a Roblox Studio beginner. Teach in small increments, with exact Explorer paths and Play Mode tests.
- Roblox Studio project is **lobby first**: menu -> 3D walkable lobby -> two pads per topic (theory + training), each with a continuous 5-second dwell -> book -> 10 cutscene-and-action questions -> topic unlock -> final mock exam -> large 3D leaderboard.
- Never treat client-supplied scores, unlocks or completion flags as authoritative. Keep answer keys on server; validate remote requests.
- Do not implement all milestones at once. First ship the one-topic, one-scene vertical slice and prove its acceptance tests.
- All actual road-rule text is written by the owner, checked with official Dutch legal/CBR references before marking reviewed. Do not invent or copy official CBR question text.
- Do not claim a script has run in Roblox Studio without real testing.
- Prior three-script ZIP concept from earlier chat is superseded by current requirements.
- Owner update (2026-11-17): training now uses a side overview, a manually controlled first-person approach, a question triggered near the junction, then an automatic first-person consequence for each answer (yield and continue / drive through / rush with staged collision). Grade the decision only; never award manual driving credit for an autopilot demonstration. See docs/LESSON_03_RU.md. This overrides the earlier manual stop-zone exercise for the current prototype.
- Owner priority (2026-11-17, clarified): learn AM theory BY BUILDING the game, not through a separate study course. Nine project categories are broad sections; aim for four SMALL SUBTOPICS per week, not four entire sections. Use docs/AM_TOPIC_MAP_RU.md (provisional 73-subtopic map; official CBR coverage not yet audited) and docs/AM_STUDY_PLAN_RU.md. Each cycle is source → owner-authored Dutch text → fact-check → in-game page/question/illustration or scene → play and explain errors. Exam is not booked. Next block is verkeersborden B1/B2/B6/B7; include cornering forces, speed, grip and stability later. Flying-avatar polish is explicitly deferred.
