-- Script: ServerScriptService > Boot
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Content = require(ReplicatedStorage:WaitForChild("TopicContent"))

local remote = Instance.new("RemoteEvent")
remote.Name = "PrototypeEvent"
remote.Parent = ReplicatedStorage
local world = Instance.new("Folder")
world.Name = "AMPrototype"
world.Parent = workspace
local sessions = {}
local DWELL = 5
local DEBUG_LOGS = true
-- Server-only original questions. Public metadata contains IDs, never keys.
local scenarios = {
	{
		id = "cyclist_right_01", titleNl = "Fietser van rechts", actorKind = "bicycle", startX = 30, laneZ = -9.5,
		prompt = "Je nadert op je bromfiets een gelijkwaardig kruispunt van twee verharde wegen. Een fietser komt van rechts en rijdt rechtdoor. Er zijn geen voorrangstekens of werkende verkeerslichten. Aan wie verleen je voorrang?",
		options = { "Aan niemand: een bromfiets gaat vóór een fiets.", "Aan de fietser die van rechts komt.", "Alleen aan auto's van rechts." },
		correct = 2, explanationNl = "De fietser is een bestuurder die voor jou van rechts komt. Je verleent de fietser voorrang.",
	},
	{
		id = "unpaved_01", titleNl = "Van onverhard naar verhard", actorKind = "car", startX = -30, laneZ = -3.5, unpaved = true,
		prompt = "Je rijdt op een onverharde weg naar een kruispunt. Van links komt een auto op de verharde weg. Er zijn geen voorrangstekens of werkende verkeerslichten. Wat doe je?",
		options = { "Ik verleen de auto op de verharde weg voorrang.", "Ik rijd eerst, omdat de auto van links komt.", "Ik rijd eerst, omdat ik op een bromfiets rijd." },
		correct = 1, explanationNl = "Bestuurders op een onverharde weg verlenen voorrang aan bestuurders op een verharde weg, ook als die van links komen.",
	},
	{
		id = "tram_demo_01", titleNl = "Tram van links", actorKind = "tram", startX = -30, laneZ = -6.5,
		prompt = "Je nadert een kruispunt zonder voorrangsregeling, werkende verkeerslichten of verkeersregelaar. Een tram komt van links. Wat doe je?",
		options = { "Ik rijd eerst, omdat de tram van links komt.", "Ik rijd eerst, omdat de tram groter is.", "Ik verleen de tram voorrang." },
		correct = 3, explanationNl = "Bij deze ongeregelde kruising verleen je de tram voorrang, ook als de tram van links komt. Dit betekent niet dat een tram in iedere situatie voorrang heeft.",
	},
}
local function trace(player, event, details)
	if not DEBUG_LOGS then return end
	local s = sessions[player]
	print(string.format("[AM Theory][Server][%s:%d][phase=%s][session=%s][question=%s] %s %s",
		player.Name, player.UserId, s and s.phase or "none", s and s.token or 0,
		s and s.definition and s.definition.id or "none", event, details or ""))
end
local function part(parent, name, size, position, color)
	local p = Instance.new("Part")
	p.Name, p.Size, p.Position = name, size, position
	p.Anchored, p.Color = true, color
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function label(p, text)
	local gui = Instance.new("BillboardGui")
	-- Scale components are world studs: signs shrink with distance.
	gui.Size, gui.StudsOffset = UDim2.fromScale(9, 2.4), Vector3.new(0, 3, 0)
	gui.AlwaysOnTop, gui.MaxDistance = false, 55
	gui.Parent = p
	local t = Instance.new("TextLabel")
	t.Size, t.BackgroundTransparency = UDim2.fromScale(1, 1), 0.15
	t.BackgroundColor3, t.TextColor3 = Color3.fromRGB(22, 28, 43), Color3.new(1, 1, 1)
	t.TextScaled, t.TextWrapped, t.Text = true, true, text
	local limit = Instance.new("UITextSizeConstraint")
	limit.MinTextSize, limit.MaxTextSize, limit.Parent = 8, 18, t
	t.Parent = gui
end
part(world, "LobbyFloor", Vector3.new(80, 1, 70), Vector3.new(0, 0, 0), Color3.fromRGB(64, 79, 91))
local spawn = Instance.new("SpawnLocation")
spawn.Name, spawn.Size, spawn.Position = "LobbySpawn", Vector3.new(8, 1, 8), Vector3.new(0, 1, 20)
spawn.Anchored, spawn.Neutral, spawn.Duration = true, true, 0
spawn.Parent = world
local pads = {}
for _, definition in ipairs({
	{ "Theory", -7, Color3.fromRGB(45, 155, 220), "Voorrang | THEORIE\nBlijf 5 seconden staan" },
	{ "Training", 7, Color3.fromRGB(240, 145, 45), "Voorrang | TRAINING\nRond eerst het boek af" },
}) do
	local p = part(world, definition[1] .. "Pad", Vector3.new(0.4, 10, 10), Vector3.new(definition[2], 0.8, 0), definition[3])
	p.Shape, p.Orientation = Enum.PartType.Cylinder, Vector3.new(0, 0, 90)
	label(p, definition[4])
	pads[definition[1]] = p
end
local wall = part(world, "LeaderboardWall", Vector3.new(30, 9, 1), Vector3.new(0, 5, -26), Color3.fromRGB(28, 38, 58))
local wallGui = Instance.new("SurfaceGui")
wallGui.Face, wallGui.CanvasSize = Enum.NormalId.Back, Vector2.new(900, 270)
wallGui.Parent = wall
local wallText = Instance.new("TextLabel")
wallText.Size, wallText.BackgroundTransparency = UDim2.fromScale(1, 1), 1
wallText.TextColor3, wallText.TextSize = Color3.new(1, 1, 1), 30
wallText.TextWrapped = true
wallText.Text = "Oefenexamen Leaderboard\nComing Later\nPreview: nog geen scores"
wallText.Parent = wallGui

local function send(player, kind, data)
	local s = sessions[player]
	if kind == "Countdown" then
		local marker = data.active and data.seconds or "reset"
		if s and marker ~= s.lastCountdown then
			trace(player, "Countdown", "pad=" .. tostring(s.pad) .. " value=" .. tostring(marker))
			s.lastCountdown = marker
		end
	else
		local details = ""
		if kind == "Book" then details = string.format("page=%d/%d", data.page, data.total)
		elseif kind == "Question" then details = "options=" .. #data.options
		elseif kind == "AnswerFeedback" then details = "correct=" .. tostring(data.correct)
		elseif kind == "Result" then
			details = string.format("knowledge=%s action=%s reason=%s", tostring(data.knowledge), tostring(data.action), data.reason)
		elseif kind == "Lobby" then details = "theoryRead=" .. tostring(data.theoryRead)
		elseif kind == "Notice" then details = data end
		trace(player, "Send:" .. kind, details)
	end
	remote:FireClient(player, kind, data)
end
local function sendBook(player, s)
	local page = Content.pages[s.page]
	send(player, "Book", {
		page = s.page, total = #Content.pages, titleNl = page.titleNl, text = page.text,
		imageKey = page.imageKey, captionNl = page.captionNl, reviewStatus = Content.reviewStatus,
	})
end
local function characterParts(player)
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end
local function clearDwell(player, s)
	if s.pad then send(player, "Countdown", { seconds = 0, active = false }) end
	s.pad, s.dwell, s.previous = nil, 0, nil
end
local function clearScene(s)
	if s.scene then s.scene:Destroy() end
	s.scene, s.block, s.actor, s.origin = nil, nil, nil, nil
	s.slot, s.throttle, s.speed = nil, 0, 0
end
local function moveCharacter(player, position, frozen)
	local root, humanoid = characterParts(player)
	if root and humanoid then
		root.Anchored = frozen
		root.AssemblyLinearVelocity = Vector3.zero
		root.CFrame = CFrame.new(position)
		humanoid.WalkSpeed = 16
	end
end
local function lobby(player, s)
	clearDwell(player, s)
	clearScene(s)
	s.definition, s.sceneIndex, s.results = nil, nil, nil
	s.phase = "lobby"
	moveCharacter(player, Vector3.new(0, 5, 19), false)
	send(player, "Lobby", { theoryRead = s.theoryRead })
end
local function result(player, s, passed, reason)
	trace(player, "ActionOutcome", string.format("z=%.2f speed=%.2f elapsed=%.2f", s.block.Position.Z - s.origin.Z, s.speed, s.actionTime))
	s.phase, s.throttle = "result", 0
	s.results[s.sceneIndex] = { knowledge = s.knowledge, action = passed }
	local knowledgeCount, actionCount = 0, 0
	for _, score in pairs(s.results) do
		if score.knowledge then knowledgeCount += 1 end
		if score.action then actionCount += 1 end
	end
	send(player, "Result", {
		knowledge = s.knowledge, action = passed, reason = reason, titleNl = s.definition.titleNl,
		index = s.sceneIndex, total = #scenarios, knowledgeCount = knowledgeCount, actionCount = actionCount,
	})
end
local function createActor(parent, definition, origin)
	local model = Instance.new("Model")
	model.Name, model.Parent = definition.actorKind, parent
	local color = definition.actorKind == "tram" and Color3.fromRGB(245, 195, 40) or Color3.fromRGB(210, 70, 60)
	local size = definition.actorKind == "tram" and Vector3.new(14, 6, 5) or Vector3.new(7, 2, 3.5)
	if definition.actorKind == "bicycle" then size = Vector3.new(4.5, 0.35, 0.5) end
	local height = definition.actorKind == "tram" and 4 or 2.5
	local pivot = origin + Vector3.new(0, height, 0)
	local body = part(model, "Body", size, pivot, color)
	model.PrimaryPart = body
	if definition.actorKind == "bicycle" then
		for _, x in ipairs({ -1.7, 1.7 }) do
			local wheel = part(model, "Wheel", Vector3.new(0.25, 2.2, 2.2), pivot + Vector3.new(x, -0.7, 0), Color3.fromRGB(24, 28, 32))
			wheel.Shape, wheel.Orientation = Enum.PartType.Cylinder, Vector3.new(0, 90, 0)
		end
		part(model, "Rider", Vector3.new(1, 1.6, 0.8), pivot + Vector3.new(0, 1.1, 0), Color3.fromRGB(230, 160, 45))
		local head = part(model, "Helmet", Vector3.new(1.1, 1.1, 1.1), pivot + Vector3.new(0, 2.5, 0), Color3.fromRGB(235, 235, 230))
		head.Shape = Enum.PartType.Ball
	elseif definition.actorKind == "car" then
		part(model, "Cabin", Vector3.new(3.5, 1.4, 3), pivot + Vector3.new(0, 1.5, 0), Color3.fromRGB(130, 190, 215))
		for _, x in ipairs({ -2.2, 2.2 }) do
			for _, z in ipairs({ -1.8, 1.8 }) do
				local wheel = part(model, "Wheel", Vector3.new(0.35, 1.4, 1.4), pivot + Vector3.new(x, -1, z), Color3.fromRGB(25, 25, 28))
				wheel.Shape, wheel.Orientation = Enum.PartType.Cylinder, Vector3.new(0, 90, 0)
			end
		end
		for _, z in ipairs({ -1, 1 }) do
			part(model, "Headlight", Vector3.new(0.1, 0.5, 0.7), pivot + Vector3.new(3.55, 0, z), Color3.fromRGB(250, 235, 150))
		end
	else
		for _, x in ipairs({ -4, 0, 4 }) do
			part(model, "Window", Vector3.new(2.6, 2.1, 0.1), pivot + Vector3.new(x, 0.7, 2.55), Color3.fromRGB(65, 115, 145))
		end
	end
	return model, height
end
local function positionActor(s, x)
	s.actor:PivotTo(CFrame.new(s.origin + Vector3.new(x, s.actorHeight, s.definition.laneZ)))
end
local function beginScene(player, s, index)
	clearDwell(player, s)
	clearScene(s)
	s.sceneIndex = index or 1
	s.definition = scenarios[s.sceneIndex]
	s.results = s.results or {}
	s.knowledge = false
	local occupied = {}
	for _, other in pairs(sessions) do if other.slot then occupied[other.slot] = true end end
	local slot = 1
	while occupied[slot] do slot += 1 end
	s.slot = slot
	s.token += 1
	s.phase, s.sceneTime = "cinematic", 0
	s.origin = Vector3.new(slot * 160, 0, 200)
	s.scene = Instance.new("Folder")
	s.scene.Name, s.scene.Parent = s.definition.id .. "_" .. player.UserId, world
	local o = s.origin
	part(s.scene, "Ground", Vector3.new(85, 1, 85), o, Color3.fromRGB(65, 85, 65))
	local roadColor = s.definition.unpaved and Color3.fromRGB(160, 125, 80) or Color3.fromRGB(45, 45, 50)
	part(s.scene, "ApproachRoad", Vector3.new(14, 0.2, 80), o + Vector3.new(0, 0.6, 0), roadColor)
	part(s.scene, "CrossingRoad", Vector3.new(80, 0.2, 14), o + Vector3.new(0, 0.75, -6.5), Color3.fromRGB(45, 45, 50))
	local target = part(s.scene, "PracticeStopZone", Vector3.new(6, 0.1, 6), o + Vector3.new(3.5, 0.8, 6), Color3.fromRGB(190, 155, 35))
	target.Transparency = 0.3
	label(target, "OEFENVAK\nGeen verplicht stopteken")
	if s.definition.actorKind == "tram" then
		for _, z in ipairs({ -5, -8 }) do
			part(s.scene, "Rail", Vector3.new(75, 0.2, 0.3), o + Vector3.new(0, 0.9, z), Color3.fromRGB(190, 190, 190))
		end
	end
	s.actor, s.actorHeight = createActor(s.scene, s.definition, o)
	positionActor(s, s.definition.startX)
	s.block = part(s.scene, "PracticeBlock", Vector3.new(3, 2, 4), o + Vector3.new(3.5, 2, 24), Color3.fromRGB(40, 180, 210))
	moveCharacter(player, o + Vector3.new(18, 5, 20), true)
	send(player, "Cinematic", { origin = o, token = s.token, titleNl = s.definition.titleNl, index = s.sceneIndex, total = #scenarios })
end

local function setupPlayer(player)
	if sessions[player] then return end
	local s = { phase = "menu", started = false, theoryRead = false, token = 0, lastRemote = 0, dwell = 0 }
	sessions[player] = s
	trace(player, "Join")
	player.RespawnLocation = spawn
	local function spawned(character)
		clearDwell(player, s)
		clearScene(s)
		s.definition, s.sceneIndex, s.results = nil, nil, nil
		s.phase = s.started and "lobby" or "menu"
		local root = character:WaitForChild("HumanoidRootPart", 10)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not root or not humanoid or player.Character ~= character or sessions[player] ~= s then return end
		moveCharacter(player, Vector3.new(0, 5, 19), not s.started)
		humanoid.Died:Connect(function()
			if player.Character ~= character then return end
			clearDwell(player, s)
			clearScene(s)
			s.phase = "dead"
			send(player, "Reset")
		end)
		send(player, s.started and "Lobby" or "Menu", { theoryRead = s.theoryRead })
	end
	player.CharacterAdded:Connect(spawned)
	if player.Character then task.spawn(spawned, player.Character) end
end
Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerRemoving:Connect(function(player)
	local s = sessions[player]
	trace(player, "Leave", "scene cleaned up; session-only progress discarded")
	if s then clearScene(s) end
	sessions[player] = nil
end)

remote.OnServerEvent:Connect(function(player, command, value, token)
	local s = sessions[player]
	if not s or type(command) ~= "string" then return end
	local now = os.clock()
	if now - s.lastRemote < 0.06 then return end
	s.lastRemote = now
	local root, humanoid = characterParts(player)
	if not root or not humanoid or humanoid.Health <= 0 then return end
	if command ~= "Drive" then
		local scalar = type(value) == "number" or type(value) == "boolean"
		trace(player, "Request:" .. command, "value=" .. (scalar and tostring(value) or type(value)))
	end
	if command == "Sync" then
		if s.phase == "menu" then send(player, "Menu")
		elseif s.phase == "lobby" then send(player, "Lobby", { theoryRead = s.theoryRead }) end
	elseif command == "Play" and s.phase == "menu" then
		s.started = true
		lobby(player, s)
	elseif command == "Overlay" and (s.phase == "lobby" or s.phase == "overlay") and type(value) == "boolean" then
		clearDwell(player, s)
		s.phase = value and "overlay" or "lobby"
		root.Anchored = value
	elseif command == "BookClose" and s.phase == "book" then
		lobby(player, s)
	elseif command == "Page" and s.phase == "book" and (value == 1 or value == -1) then
		s.page = math.clamp(s.page + value, 1, #Content.pages)
		sendBook(player, s)
	elseif command == "Finish" and s.phase == "book" and s.page == #Content.pages then
		s.theoryRead = true
		lobby(player, s)
	elseif command == "Answer" and s.phase == "question" and token == s.token then
		local options = s.definition.options
		if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > #options then
			trace(player, "Reject:Answer", "invalid option index")
			return
		end
		s.knowledge, s.phase = value == s.definition.correct, "answered"
		send(player, "AnswerFeedback", { correct = s.knowledge,
			text = s.definition.explanationNl })
	elseif command == "BeginAction" and s.phase == "answered" and token == s.token then
		s.phase, s.actionTime, s.stopped, s.speed, s.throttle = "action", 0, 0, 0, 0
		s.lastDrive = now
		send(player, "Action", { titleNl = s.definition.titleNl })
	elseif command == "Drive" and s.phase == "action" and token == s.token and (value == 0 or value == 1) then
		if s.throttle ~= value then trace(player, "Drive", value == 1 and "accelerate" or "brake") end
		s.throttle, s.lastDrive = value, now
	elseif command == "Return" and (s.phase == "result" or s.phase == "action" or s.phase == "question" or s.phase == "answered" or s.phase == "cinematic") and token == s.token then
		lobby(player, s)
	elseif command == "NextScene" and s.phase == "result" and token == s.token and s.sceneIndex < #scenarios then
		beginScene(player, s, s.sceneIndex + 1)
	elseif command == "RetryScene" and s.phase == "result" and token == s.token then
		beginScene(player, s, s.sceneIndex)
	else
		-- Limit diagnostics for stale/invalid requests, including drive keepalives.
		if not s.lastReject or now - s.lastReject >= 1 then
			s.lastReject = now
			trace(player, "Reject:" .. command, "wrong phase, token or payload")
		end
	end
end)

local sample = 0
RunService.Heartbeat:Connect(function(dt)
	sample += dt
	local checkZones = sample >= 0.1
	if checkZones then sample = 0 end
	for player, s in pairs(sessions) do
		local root, humanoid = characterParts(player)
		if not root or not humanoid or humanoid.Health <= 0 then continue end
		if s.phase == "lobby" and checkZones then
			local found
			for name, p in pairs(pads) do
				local d = root.Position - p.Position
				if Vector2.new(d.X, d.Z).Magnitude <= 5 and d.Y >= 1 and d.Y <= 4.5 then found = name end
			end
			if found == "Training" and not s.theoryRead then
				clearDwell(player, s)
				if not s.notice or os.clock() - s.notice > 3 then
					s.notice = os.clock()
					send(player, "Notice", "Lees eerst alle boekpagina's en rond de theorie af.")
				end
			elseif found then
				if s.pad ~= found or (s.previous and (root.Position - s.previous).Magnitude > 12) then
					clearDwell(player, s)
					s.pad, s.since = found, os.clock()
				end
				s.previous = root.Position
				s.dwell = os.clock() - s.since
				send(player, "Countdown", { active = true, seconds = math.max(0, math.ceil(DWELL - s.dwell)) })
				if s.dwell >= DWELL then
					trace(player, "DwellComplete", "pad=" .. found)
					if found == "Theory" then
						clearDwell(player, s)
						s.phase, s.page = "book", 1
						root.Anchored = true
						sendBook(player, s)
					else beginScene(player, s) end
				end
			else clearDwell(player, s) end
		elseif s.phase == "cinematic" then
			s.sceneTime += dt
			local direction = s.definition.startX > 0 and -1 or 1
			positionActor(s, s.definition.startX + direction * math.min(s.sceneTime, 4) * 4.5)
			if s.sceneTime >= 4 then
				s.phase = "question"
				send(player, "Question", { prompt = s.definition.prompt, options = s.definition.options, titleNl = s.definition.titleNl, index = s.sceneIndex, total = #scenarios })
			end
		elseif s.phase == "action" then
			local step = math.min(dt, 0.1)
			s.actionTime += dt
			local direction = s.definition.startX > 0 and -1 or 1
			positionActor(s, -direction * 12 + direction * math.min(s.actionTime, 6) * 8)
			if os.clock() - s.lastDrive > 0.5 and s.throttle ~= 0 then
				trace(player, "DriveTimeout", "automatic brake: no input for 0.5s")
				s.throttle = 0
			end
			s.speed = math.clamp(s.speed + (s.throttle == 1 and 8 or -20) * step, 0, 12)
			s.block.Position -= Vector3.new(0, 0, s.speed * step)
			local z = s.block.Position.Z - s.origin.Z
			-- Training target, not a legal stop-line or a full yielding predicate.
			if z - 2 <= 2.25 then result(player, s, false, "Je reed voorbij het oefenvak. Rem eerder.")
			elseif z >= 5 and z <= 7 and s.speed < 0.1 then
				if s.stopped == 0 then trace(player, "StopCheck", "stationary inside target zone; holding for 1s") end
				s.stopped += step
				if s.stopped >= 1 then result(player, s, true, "Je stond één seconde stil in het oefenvak. Alleen de stopactie is beoordeeld, niet het volledige voorrang verlenen.") end
			else
				if s.stopped > 0 then trace(player, "StopCheck", "hold reset: moved or left target zone") end
				s.stopped = 0
			end
			if s.phase == "action" and s.actionTime >= 25 then result(player, s, false, "De oefentijd is voorbij. Probeer opnieuw.") end
		end
	end
end)
print("[AM Theory] Server ready — Milestone 1 prototype; session-only progress.")
