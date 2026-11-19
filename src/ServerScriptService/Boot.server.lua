-- Script: ServerScriptService > Boot
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Catalog = require(ReplicatedStorage:WaitForChild("TopicContent"))
local trainingFolder = ServerScriptService:WaitForChild("Training")
local trainingByTopic = {}
for _, topicId in ipairs(Catalog.order) do
	trainingByTopic[topicId] = require(trainingFolder:WaitForChild(topicId))
end

local remote = Instance.new("RemoteEvent")
remote.Name = "PrototypeEvent"
remote.Parent = ReplicatedStorage
local world = Instance.new("Folder")
world.Name = "AMPrototype"
world.Parent = workspace
local sessions = {}
local DWELL = 5
local QUESTION_Z = 18
local START_Z = 36
local DEBUG_LOGS = true
local function trace(player, event, details)
	if not DEBUG_LOGS then return end
	local s = sessions[player]
	print(string.format("[AM Theory][Server][%s:%d][phase=%s][session=%s][question=%s][topic=%s] %s %s",
		player.Name, player.UserId, s and s.phase or "none", s and s.token or 0,
		s and s.definition and s.definition.id or "none", s and (s.activeTopic or s.bookTopic) or "none", event, details or ""))
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
local stations = Instance.new("Folder")
stations.Name, stations.Parent = "TopicStations", world
for index, topicId in ipairs(Catalog.order) do
	local topic = Catalog.topics[topicId]
	local station = Instance.new("Folder")
	station.Name, station.Parent = topicId, stations
	for _, padKind in ipairs({ "Theory", "Training" }) do
		local x = padKind == "Theory" and -7 or 7
		local color = padKind == "Theory" and Color3.fromRGB(45, 155, 220) or Color3.fromRGB(240, 145, 45)
		if index == 2 then color = padKind == "Theory" and Color3.fromRGB(155, 100, 220) or Color3.fromRGB(55, 180, 135) end
		local p = part(station, padKind .. "Pad", Vector3.new(0.4, 10, 10), Vector3.new(x, 0.8, -(index - 1) * 16), color)
		p.Shape, p.Orientation = Enum.PartType.Cylinder, Vector3.new(0, 0, 90)
		local hint = padKind == "Theory" and "THEORIE | blijf 5 seconden staan" or "TRAINING | rond eerst dit boek af"
		label(p, topic.titleNl .. "\n" .. hint)
		pads[topicId .. "_" .. padKind] = { part = p, kind = padKind, topicId = topicId }
	end
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
		elseif kind == "Outcome" then details = "branch=" .. data.branch
		elseif kind == "Result" then
			details = string.format("knowledge=%s outcome=%s reason=%s", tostring(data.knowledge), data.outcome, data.reason)
		elseif kind == "SignQuestion" then details = "card=" .. data.index .. "/" .. data.total
		elseif kind == "SignResult" then details = "correct=" .. tostring(data.correct) .. " round=" .. data.correctCount
		elseif kind == "Notice" then details = data end
		trace(player, "Send:" .. kind, details)
	end
	remote:FireClient(player, kind, data)
end
local function sendBook(player, s)
	local topic = Catalog.topics[s.bookTopic]
	local page = topic.pages[s.page]
	send(player, "Book", {
		topicId = topic.topicId, topicTitleNl = topic.titleNl, sourceName = topic.sourceName,
		page = s.page, total = #topic.pages, titleNl = page.titleNl, text = page.text,
		imageKey = page.imageKey, signCode = page.signCode, captionNl = page.captionNl, reviewStatus = topic.reviewStatus,
	})
end
local function progressSnapshot(s)
	local snapshot = {}
	for _, topicId in ipairs(Catalog.order) do
		local progress = s.topics[topicId]
		snapshot[topicId] = {
			theoryRead = progress.theoryRead, bestCorrect = progress.bestCorrect, trainingCompleted = progress.trainingCompleted,
			totalQuestions = #trainingByTopic[topicId].questions,
		}
	end
	return { topics = snapshot }
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
	s.scene, s.block, s.handlebar, s.actor, s.origin = nil, nil, nil, nil, nil
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
	s.bookTopic, s.activeTopic, s.quizIndex, s.quizResults = nil, nil, nil, nil
	s.phase = "lobby"
	moveCharacter(player, Vector3.new(0, 5, 19), false)
	send(player, "Lobby", progressSnapshot(s))
end
local function result(player, s, outcome, reason)
	trace(player, "DecisionOutcome", string.format("branch=%s z=%.2f elapsed=%.2f", s.branch, s.block.Position.Z - s.origin.Z, s.outcomeTime))
	s.phase, s.throttle = "result", 0
	s.results[s.sceneIndex] = { knowledge = s.knowledge }
	local knowledgeCount = 0
	for _, score in pairs(s.results) do
		if score.knowledge then knowledgeCount += 1 end
	end
	local total = #trainingByTopic[s.activeTopic].questions
	if s.sceneIndex == total then
		local progress = s.topics[s.activeTopic]
		progress.trainingCompleted = true
		progress.bestCorrect = math.max(progress.bestCorrect or 0, knowledgeCount)
	end
	send(player, "Result", {
		knowledge = s.knowledge, outcome = outcome, reason = reason, explanationNl = s.definition.explanationNl,
		titleNl = s.definition.titleNl, index = s.sceneIndex, total = total, knowledgeCount = knowledgeCount,
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
local function positionVehicle(s, z)
	s.block.Position = s.origin + Vector3.new(3.5, 2, z)
	s.handlebar.Position = s.block.Position + Vector3.new(0, 1.2, -1)
end
local function beginScene(player, s, index)
	clearDwell(player, s)
	clearScene(s)
	local questions = trainingByTopic[s.activeTopic].questions
	s.sceneIndex = index or 1
	s.definition = questions[s.sceneIndex]
	s.results = s.results or {}
	s.knowledge = false
	s.branch, s.outcomeTime, s.approachTime = nil, 0, 0
	local occupied = {}
	for _, other in pairs(sessions) do if other.slot then occupied[other.slot] = true end end
	local slot = 1
	while occupied[slot] do slot += 1 end
	s.slot = slot
	s.token += 1
	s.phase, s.sceneTime, s.speed, s.throttle = "cinematic", 0, 0, 0
	s.origin = Vector3.new(slot * 160, 0, 200)
	s.scene = Instance.new("Folder")
	s.scene.Name, s.scene.Parent = s.definition.id .. "_" .. player.UserId, world
	local o = s.origin
	part(s.scene, "Ground", Vector3.new(85, 1, 85), o, Color3.fromRGB(65, 85, 65))
	local roadColor = s.definition.unpaved and Color3.fromRGB(160, 125, 80) or Color3.fromRGB(45, 45, 50)
	part(s.scene, "ApproachRoad", Vector3.new(14, 0.2, 80), o + Vector3.new(0, 0.6, 0), roadColor)
	part(s.scene, "CrossingRoad", Vector3.new(80, 0.2, 14), o + Vector3.new(0, 0.75, -6.5), Color3.fromRGB(45, 45, 50))
	if s.definition.actorKind == "tram" then
		for _, z in ipairs({ -5, -8 }) do
			part(s.scene, "Rail", Vector3.new(75, 0.2, 0.3), o + Vector3.new(0, 0.9, z), Color3.fromRGB(190, 190, 190))
		end
	end
	s.actor, s.actorHeight = createActor(s.scene, s.definition, o)
	positionActor(s, s.definition.startX)
	s.block = part(s.scene, "PracticeBlock", Vector3.new(3, 2, 4), o + Vector3.new(3.5, 2, START_Z), Color3.fromRGB(40, 180, 210))
	s.handlebar = part(s.scene, "Handlebar", Vector3.new(2.8, 0.18, 0.18), s.block.Position + Vector3.new(0, 1.2, -1), Color3.fromRGB(35, 40, 45))
	moveCharacter(player, o + Vector3.new(18, 5, 20), true)
	send(player, "Cinematic", { origin = o, vehicle = s.block, sceneName = s.scene.Name, token = s.token, titleNl = s.definition.titleNl, index = s.sceneIndex, total = #questions })
end
local function beginSignCard(player, s, index)
	clearDwell(player, s)
	clearScene(s)
	local training = trainingByTopic[s.activeTopic]
	s.quizIndex = index or 1
	s.definition = training.questions[s.quizIndex]
	s.quizResults = s.quizResults or {}
	s.phase, s.token = "sign_question", s.token + 1
	local root = characterParts(player)
	if root then root.Anchored = true end
	send(player, "SignQuestion", {
		topicId = s.activeTopic, token = s.token, signCode = s.definition.signCode,
		index = s.quizIndex, total = #training.questions, options = s.definition.options, promptNl = s.definition.promptNl,
	})
end

local trainingStarts = { scene = beginScene, sign = beginSignCard }

local function setupPlayer(player)
	if sessions[player] then return end
	local s = { phase = "menu", started = false, topics = {}, token = 0, lastRemote = 0, dwell = 0 }
	for _, topicId in ipairs(Catalog.order) do s.topics[topicId] = { theoryRead = false, trainingCompleted = false } end
	sessions[player] = s
	trace(player, "Join")
	player.RespawnLocation = spawn
	local function spawned(character)
		clearDwell(player, s)
		clearScene(s)
		s.definition, s.sceneIndex, s.results = nil, nil, nil
		s.bookTopic, s.activeTopic, s.quizIndex, s.quizResults = nil, nil, nil, nil
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
		send(player, s.started and "Lobby" or "Menu", progressSnapshot(s))
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
	local rateKey = command == "Drive" and "lastDriveRemote" or "lastRemote"
	if now - (s[rateKey] or 0) < 0.06 then return end
	s[rateKey] = now
	local root, humanoid = characterParts(player)
	if not root or not humanoid or humanoid.Health <= 0 then return end
	local training = s.activeTopic and trainingByTopic[s.activeTopic]
	if command ~= "Drive" then
		local scalar = type(value) == "number" or type(value) == "boolean"
		trace(player, "Request:" .. command, "value=" .. (scalar and tostring(value) or type(value)))
	end
	if command == "Sync" then
		if s.phase == "menu" then send(player, "Menu")
		elseif s.phase == "lobby" then send(player, "Lobby", progressSnapshot(s)) end
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
		s.page = math.clamp(s.page + value, 1, #Catalog.topics[s.bookTopic].pages)
		sendBook(player, s)
	elseif command == "Finish" and s.phase == "book" and s.page == #Catalog.topics[s.bookTopic].pages then
		s.topics[s.bookTopic].theoryRead = true
		lobby(player, s)
	elseif command == "SignAnswer" and s.phase == "sign_question" and token == s.token then
		if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > #s.definition.options then return end
		local correct = value == s.definition.correct
		s.quizResults[s.quizIndex], s.phase = correct, "sign_result"
		local correctCount = 0
		for _, answer in pairs(s.quizResults) do if answer then correctCount += 1 end end
		local total = #training.questions
		if s.quizIndex == total then
			local progress = s.topics[s.activeTopic]
			progress.trainingCompleted = true
			progress.bestCorrect = math.max(progress.bestCorrect or 0, correctCount)
		end
		send(player, "SignResult", {
			correct = correct, labelNl = s.definition.options[s.definition.correct], signCode = s.definition.signCode,
			explanationNl = s.definition.explanationNl,
			index = s.quizIndex, total = total, correctCount = correctCount,
		})
	elseif command == "NextSign" and s.phase == "sign_result" and token == s.token and s.quizIndex < #training.questions then
		beginSignCard(player, s, s.quizIndex + 1)
	elseif command == "RetrySign" and s.phase == "sign_result" and token == s.token then
		beginSignCard(player, s, s.quizIndex)
	elseif command == "Answer" and s.phase == "question" and token == s.token then
		local options = s.definition.options
		if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > #options then
			trace(player, "Reject:Answer", "invalid option index")
			return
		end
		s.knowledge, s.phase = value == s.definition.correct, "outcome"
		s.branch, s.outcomeTime, s.throttle, s.speed, s.impacted = s.definition.branches[value], 0, 0, 0, false
		trace(player, "DecisionAccepted", "option=" .. value .. " branch=" .. s.branch)
		send(player, "Outcome", { branch = s.branch, correct = s.knowledge, choiceNl = s.definition.options[value] })
	elseif command == "Drive" and s.phase == "approach" and token == s.token and (value == 0 or value == 1) then
		if s.throttle ~= value then trace(player, "Drive", value == 1 and "accelerate" or "brake") end
		s.throttle, s.lastDrive = value, now
	elseif command == "Return" and (s.phase == "result" or s.phase == "approach" or s.phase == "question" or s.phase == "outcome" or s.phase == "cinematic" or s.phase == "sign_question" or s.phase == "sign_result") and token == s.token then
		lobby(player, s)
	elseif command == "NextScene" and s.phase == "result" and token == s.token and s.sceneIndex < #training.questions then
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
			for name, pad in pairs(pads) do
				local d = root.Position - pad.part.Position
				if Vector2.new(d.X, d.Z).Magnitude <= 5 and d.Y >= 1 and d.Y <= 4.5 then found = name end
			end
			local selected = found and pads[found]
			if selected and selected.kind == "Training" and not s.topics[selected.topicId].theoryRead then
				clearDwell(player, s)
				if not s.notice or os.clock() - s.notice > 3 then
					s.notice = os.clock()
					send(player, "Notice", "Rond eerst het boek van " .. Catalog.topics[selected.topicId].titleNl .. " af.")
				end
			elseif found then
				if s.pad ~= found or (s.previous and (root.Position - s.previous).Magnitude > 12) then
					clearDwell(player, s)
					s.pad, s.since = found, os.clock()
				end
				s.previous = root.Position
				s.dwell = os.clock() - s.since
				send(player, "Countdown", { active = true, seconds = math.max(0, math.ceil(DWELL - s.dwell)), topicTitleNl = Catalog.topics[selected.topicId].titleNl })
				if s.dwell >= DWELL then
					trace(player, "DwellComplete", "pad=" .. found)
					if selected.kind == "Theory" then
						clearDwell(player, s)
						s.phase, s.page, s.bookTopic = "book", 1, selected.topicId
						root.Anchored = true
						sendBook(player, s)
					else
						s.activeTopic = selected.topicId
						trainingStarts[trainingByTopic[s.activeTopic].kind](player, s)
					end
				end
			else clearDwell(player, s) end
		elseif s.phase == "cinematic" then
			s.sceneTime += dt
			local direction = s.definition.startX > 0 and -1 or 1
			positionActor(s, s.definition.startX + direction * math.min(s.sceneTime, 4) * 4.5)
			if s.sceneTime >= 4 then
				s.phase, s.approachTime, s.lastDrive = "approach", 0, os.clock()
				send(player, "Approach", { vehicle = s.block, sceneName = s.scene.Name, token = s.token })
			end
		elseif s.phase == "approach" then
			local step = math.min(dt, 0.1)
			s.approachTime += dt
			if os.clock() - s.lastDrive > 0.5 and s.throttle ~= 0 then
				trace(player, "DriveTimeout", "automatic brake: no input for 0.5s")
				s.throttle = 0
			end
			s.speed = math.clamp(s.speed + (s.throttle == 1 and 6 or -16) * step, 0, 8)
			local z = math.max(QUESTION_Z, s.block.Position.Z - s.origin.Z - s.speed * step)
			positionVehicle(s, z)
			if z <= QUESTION_Z then
				s.phase, s.speed, s.throttle = "question", 0, 0
				trace(player, "DecisionPoint", "first-person approach reached intersection")
				send(player, "Question", { prompt = s.definition.prompt, options = s.definition.options, titleNl = s.definition.titleNl, index = s.sceneIndex, total = #trainingByTopic[s.activeTopic].questions })
			elseif s.approachTime >= 45 then
				lobby(player, s)
				send(player, "Notice", "Oefening afgebroken: je reed niet naar het beslispunt. Je kunt opnieuw beginnen.")
			end
		elseif s.phase == "outcome" then
			s.outcomeTime += math.min(dt, 0.1)
			local t = s.outcomeTime
			local direction = s.definition.startX > 0 and -1 or 1
			if s.branch == "yield" then
				positionActor(s, -direction * 12 + direction * math.min(t, 8) * 8)
				local z = math.max(-24, QUESTION_Z - math.max(0, t - 4) * 8)
				positionVehicle(s, z)
				if z <= -24 then result(player, s, "safe", "Je verleent voorrang, wacht tot de ander voorbij is en rijdt daarna veilig verder. Dit vervolg werd automatisch afgespeeld.") end
			else
				-- Distinct normal-drive and rushed branches converge at a staged impact.
				local speed = s.branch == "rush" and 14 or 9
				local collisionTime = (QUESTION_Z - s.definition.laneZ) / speed
				local fraction = math.min(1, t / collisionTime)
				positionActor(s, -direction * 12 + (3.5 + direction * 12) * fraction)
				positionVehicle(s, QUESTION_Z - (QUESTION_Z - s.definition.laneZ) * fraction)
				if t >= collisionTime and not s.impacted then
					s.impacted = true
					trace(player, "Impact", "branch=" .. s.branch)
					send(player, "Impact")
				end
				if t >= collisionTime + 1 then
					result(player, s, "collision", "In deze demonstratie leidde doorrijden zonder voorrang te verlenen tot een botsing. Dit is een geënsceneerd gevolg, geen voorspelling dat iedere fout altijd zo afloopt.")
				end
			end
		end
	end
end)
print("[AM Theory] Server ready — Milestone 1 prototype; session-only progress.")
