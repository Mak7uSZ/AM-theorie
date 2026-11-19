-- This harness runs the REAL source inserted by run-server-tests.ps1.
-- It simulates engine objects; it cannot validate Studio rendering or physics.
local realPrint = print
local logs = {}
local function print(...)
	table.insert(logs, table.concat({...}, " "))
end
local now = 0
local os = { clock = function() return now end }
local function signal()
	local callbacks = {}
	return {
		Connect = function(_, callback)
			table.insert(callbacks, callback)
			return { Disconnect = function() end }
		end,
		Fire = function(_, ...)
			for _, callback in ipairs(callbacks) do callback(...) end
		end,
	}
end
local vectorMeta = {}
local function vector(x, y, z) return setmetatable({ X = x, Y = y, Z = z or 0 }, vectorMeta) end
vectorMeta.__add = function(a, b) return vector(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
vectorMeta.__sub = function(a, b) return vector(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
vectorMeta.__index = function(a, key)
	if key == "Magnitude" then return math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z) end
end
local Vector3 = { new = vector, zero = vector(0, 0, 0) }
local Vector2 = { new = vector }
local CFrame = { new = function(position) return { Position = position } end }
local Color3 = { new = function(...) return {...} end, fromRGB = function(...) return {...} end }
local UDim2 = { fromScale = function(...) return {...} end, fromOffset = function(...) return {...} end }
local Enum = setmetatable({}, { __index = function(groups, group)
	local values = setmetatable({}, { __index = function(_, value) return group .. "." .. value end })
	rawset(groups, group, values)
	return values
end })
local methods = {}
local Instance = {}
function Instance.new(className)
	local data = { ClassName = className, Name = className, Position = Vector3.zero, children = {}, events = {} }
	if className == "RemoteEvent" then data.OnServerEvent = signal(); data.messages = {} end
	if className == "Humanoid" then data.Health = 100; data.Died = signal() end
	return setmetatable({}, {
		__index = function(_, key) return methods[key] or data[key] end,
		__newindex = function(self, key, value)
			if key == "Parent" then
				if data.Parent then data.Parent.children[data.Name] = nil end
				if value then value.children[data.Name] = self end
			elseif key == "CFrame" then data.Position = value.Position end
			data[key] = value
		end,
	})
end
function methods:WaitForChild(name) return assert(self.children[name], "Missing mock child " .. name) end
function methods:FindFirstChild(name) return self.children[name] end
function methods:FindFirstChildOfClass(className)
	for _, child in pairs(self.children) do if child.ClassName == className then return child end end
end
function methods:Destroy() self.Destroyed = true; self.Parent = nil end
function methods:PivotTo(cframe) self.LastPivot = cframe end
function methods:FireClient(player, kind, data)
	table.insert(self.messages, { player = player, kind = kind, data = data })
end
local fakePlayers = { PlayerAdded = signal(), PlayerRemoving = signal(), GetPlayers = function() return {} end }
local fakeRunService = { Heartbeat = signal() }
local fakeReplicatedStorage = Instance.new("Folder")
local workspace = Instance.new("Folder")
local task = { spawn = function(fn, ...) fn(...) end }
local services = { Players = fakePlayers, ReplicatedStorage = fakeReplicatedStorage, RunService = fakeRunService, ServerScriptService = Instance.new("Folder") }
local game = { GetService = function(_, name) return assert(services[name]) end }

--[[STUDIO_MODULES]]

--[[GAME_SOURCE]]

local contentForTest = Catalog
local scenarios = trainingByTopic.voorrang.questions
local signCards = trainingByTopic.verkeerstekens.questions
local checks = 0
local function expect(condition, message)
	checks += 1
	assert(condition, message)
end
local function frames(seconds)
	for _ = 1, math.ceil(seconds / 0.1) do
		now += 0.1
		fakeRunService.Heartbeat:Fire(0.1)
	end
end
local function request(player, command, value, sceneToken)
	now += 0.1
	remote.OnServerEvent:Fire(player, command, value, sceneToken or sessions[player].token)
end
local function newCharacter()
	local character = Instance.new("Model")
	local root = Instance.new("Part")
	root.Name, root.Parent = "HumanoidRootPart", character
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = character
	return character
end
local function newPlayer(id)
	local player = { Name = "Test" .. id, UserId = id, CharacterAdded = signal(), Character = newCharacter() }
	fakePlayers.PlayerAdded:Fire(player)
	return player
end
local function move(player, x, z)
	player.Character:FindFirstChild("HumanoidRootPart").Position = vector(x, 3.8, z)
end
local function latest(player, kind)
	for i = #remote.messages, 1, -1 do
		local message = remote.messages[i]
		if message.player == player and message.kind == kind then return message.data end
	end
end
local function readBook(player)
	move(player, -7, 0)
	frames(5.3)
	expect(sessions[player].phase == "book", "Theory dwell must open book")
	for _ = 2, #contentForTest.topics.voorrang.pages do request(player, "Page", 1) end
	request(player, "Finish")
	expect(sessions[player].topics.voorrang.theoryRead, "Last page must unlock training")
end
local function train(player)
	move(player, 7, 0)
	frames(5.3)
	expect(sessions[player].phase == "cinematic", "Training dwell must start cinematic")
end
local function question(player)
	frames(4.2)
	local s = sessions[player]
	expect(s.phase == "approach", "Overview must hand control to first-person approach")
	local startZ = s.block.Position.Z
	request(player, "Answer", 1)
	expect(s.phase == "approach", "Cannot answer before reaching decision point")
	for _ = 1, 40 do
		if s.phase ~= "approach" then break end
		request(player, "Drive", 1)
		frames(0.2)
	end
	expect(s.block.Position.Z < startZ, "Manual drive must actually move vehicle toward intersection")
	expect(s.phase == "question" and s.speed == 0, "Server must pause for question at approach threshold")
	expect(math.abs(s.block.Position.Z - s.origin.Z - QUESTION_Z) < 0.001, "Decision trigger must be position-based")
	local pausedZ = s.block.Position.Z
	request(player, "Drive", 1); frames(0.3)
	expect(s.block.Position.Z == pausedZ, "Drive requests must not bypass decision pause")
	local payload = latest(player, "Question")
	expect(payload.correct == nil and payload.correctAnswerIndex == nil and payload.explanationNl == nil, "Question must not reveal answer key")
end
local function finishOutcome(player, safe)
	local s = sessions[player]
	expect(s.phase == "outcome", "Answer must start automatic consequence immediately")
	local chosenBranch = s.branch
	request(player, "Answer", 99)
	expect(s.branch == chosenBranch, "Duplicate answer must not change chosen continuation")
	request(player, "Drive", 0)
	if safe then
		local stoppedZ = s.block.Position.Z
		frames(3.7)
		expect(s.block.Position.Z == stoppedZ, "Safe branch must wait for crossing road user")
		frames(1)
		expect(s.block.Position.Z < stoppedZ, "Safe branch must continue after waiting")
		frames(5.5)
	else frames(4.5) end
	expect(s.phase == "result", "Automatic consequence must reach result")
	local payload = latest(player, "Result")
	expect(payload.outcome == (safe and "safe" or "collision"), "Consequence must match server-graded choice")
	expect(payload.action == nil and payload.actionCount == nil, "Autopilot must not award manual driving credit")
	if not safe then expect(s.impacted, "Wrong choice must play staged impact before result") end
end

expect(#contentForTest.topics.voorrang.pages == 6, "Book must have six authored pages")
expect(#contentForTest.topics.voorrang.questionIds == 3 and #scenarios == 3, "Three scenarios must be configured")
for i, definition in ipairs(scenarios) do
	expect(contentForTest.topics.voorrang.questionIds[i] == definition.id, "Public question IDs must match server order")
end
local p = newPlayer(1)
local s = sessions[p]
expect(s.phase == "menu", "Player must join menu")
request(p, "Finish")
expect(not s.topics.voorrang.theoryRead, "Fake finish from menu must be rejected")
request(p, "Play")
expect(s.phase == "lobby", "Play must enter lobby")
move(p, 7, 0); frames(5.3)
expect(s.phase == "lobby", "Training before theory must stay locked")
move(p, -7, 0); frames(3)
move(p, 0, 18); frames(3)
expect(s.phase == "lobby" and s.pad == nil, "Leaving pad must cancel dwell")
move(p, -7, 0); frames(5.3)
request(p, "Finish")
expect(s.phase == "book" and not s.topics.voorrang.theoryRead, "Early book finish must be rejected")
request(p, "BookClose")
readBook(p)
train(p)
request(p, "Answer", 2)
expect(s.phase == "cinematic", "Answer during cinematic must be rejected")
question(p)
request(p, "NextScene")
expect(s.phase == "question" and s.sceneIndex == 1, "Cannot skip unfinished question")
request(p, "Answer", 99)
expect(s.phase == "question", "Out-of-range answer must be rejected")
request(p, "Answer", 2)
expect(s.knowledge and s.phase == "outcome", "Cyclist from right must be graded correctly")
request(p, "Answer", 1)
expect(s.knowledge, "Duplicate answer must not change grade")
finishOutcome(p, true)
local oldToken = s.token
request(p, "NextScene")
expect(s.sceneIndex == 2 and s.definition.unpaved and s.token ~= oldToken, "Next scene must load unpaved case with new token")
question(p)
request(p, "Answer", 1, oldToken)
expect(s.phase == "question", "Stale scene token must be rejected")
request(p, "Answer", 1)
finishOutcome(p, true)
request(p, "RetryScene")
expect(s.sceneIndex == 2 and s.phase == "cinematic", "Retry must keep current scene")
question(p)
request(p, "Answer", 3)
expect(not s.knowledge, "Incorrect answer must remain incorrect")
finishOutcome(p, false)
expect(latest(p, "Result").knowledgeCount == 1, "Retry must replace grade, without double-counting")
request(p, "NextScene"); question(p); request(p, "Answer", 3); finishOutcome(p, true)
expect(s.sceneIndex == 3 and latest(p, "Result").knowledgeCount == 2, "Tram scene must use its own answer key")
request(p, "NextScene")
expect(s.phase == "result" and s.sceneIndex == 3, "Last scene must not advance out of range")
local oldScene = s.scene
request(p, "Return")
expect(s.phase == "lobby" and oldScene.Destroyed and not p.Character:FindFirstChild("HumanoidRootPart").Anchored, "Return must clean scene and restore character")

-- Exercise every answer option in all scenes against the actual consequence code.
for sceneIndex, definition in ipairs(scenarios) do
	local branchTimes = {}
	for option = 1, #definition.options do
		s.results = {}
		s.activeTopic = "voorrang"
		beginScene(p, s, sceneIndex)
		question(p)
		request(p, "Answer", option)
		expect(s.branch == definition.branches[option], "Each answer must select its own configured branch")
		finishOutcome(p, option == definition.correct)
		branchTimes[s.branch] = s.outcomeTime
	end
	expect(branchTimes.rush < branchTimes.drive, "Accelerating and driving through must produce different timelines")
end
request(p, "Return")

train(p); frames(4.2)
expect(s.phase == "approach", "Approach setup failed")
local idleZ = s.block.Position.Z
frames(1)
expect(s.block.Position.Z == idleZ, "Vehicle must not auto-drive before user's input")
request(p, "Drive", 1); frames(0.2); request(p, "Drive", 0); frames(0.8)
expect(s.speed == 0, "Brake must stop approach vehicle")
request(p, "Drive", 1); frames(1.5)
expect(s.speed == 0, "Missing drive keepalives must trigger automatic brake")
frames(45)
expect(s.phase == "lobby" and s.scene == nil, "Idle approach timeout must restore lobby")
train(p); frames(4.2)
request(p, "Drive", 1)
remote.OnServerEvent:Fire(p, "Return", nil, s.token)
expect(s.phase == "lobby", "Drive keepalive must not rate-limit a simultaneous exit request")

local p2 = newPlayer(2)
request(p2, "Play"); readBook(p2)
train(p); train(p2)
expect(s.origin.X ~= sessions[p2].origin.X and s.scene ~= sessions[p2].scene, "Concurrent players need distinct scenes")
local p2Scene = sessions[p2].scene
p.Character = newCharacter(); p.CharacterAdded:Fire(p.Character)
expect(s.phase == "lobby" and s.scene == nil and s.topics.voorrang.theoryRead, "Respawn must clear scene but retain session theory")
expect(sessions[p2].scene == p2Scene and not p2Scene.Destroyed, "Respawn must not affect another player")
fakePlayers.PlayerRemoving:Fire(p2)
expect(p2Scene.Destroyed and sessions[p2] == nil, "Leaving must remove only that player's scene")
expect(table.concat(logs, "\n"):find("question=unpaved_01", 1, true) ~= nil, "Diagnostics must identify active question")

-- Second station: independent theory, recognition grading and multiplayer modes.
expect(#Catalog.order == 2, "Lobby must expose exactly two configured topics")
local stationFolder = world:FindFirstChild("TopicStations")
for _, topicId in ipairs(Catalog.order) do
	local station = stationFolder:FindFirstChild(topicId)
	expect(station and station:FindFirstChild("TheoryPad") and station:FindFirstChild("TrainingPad"), "Each topic needs two actual world pads")
end
local p3 = newPlayer(3)
local s3 = sessions[p3]
request(p3, "Play")
request(p3, "SignAnswer", 1)
expect(s3.phase == "lobby", "Cannot submit sign answers from lobby")
move(p3, 7, -16); frames(5.3)
expect(s3.phase == "lobby" and not s3.topics.verkeerstekens.theoryRead, "Signs training must require its own book")
move(p3, -7, -16); frames(3)
move(p3, 0, 19); frames(3)
expect(s3.phase == "lobby", "Leaving second theory circle must cancel its timer")
move(p3, -7, -16); frames(5.3)
expect(s3.phase == "book" and s3.bookTopic == "verkeerstekens", "Second theory pad must select correct book")
expect(latest(p3, "Book").topicId == "verkeerstekens" and latest(p3, "Book").signCode == "B1", "Book packet must include topic and matching sign")
request(p3, "Finish")
expect(not s3.topics.verkeerstekens.theoryRead, "Cannot finish signs book before last page")
for _ = 2, #Catalog.topics.verkeerstekens.pages do request(p3, "Page", 1) end
expect(latest(p3, "Book").signCode == "G13" and latest(p3, "Book").total == 7, "Signs book ends after three cycle-path pages")
request(p3, "Finish")
expect(s3.topics.verkeerstekens.theoryRead and not s3.topics.voorrang.theoryRead, "Completing signs must not complete priority theory")
move(p3, 7, 0); frames(5.3)
expect(s3.phase == "lobby" and s3.scene == nil, "Signs book must not unlock first topic's road training")
move(p3, 7, -16); frames(5.3)
expect(s3.phase == "sign_question" and s3.quizIndex == 1, "Second training circle must start actual recognition exercise")
local previousToken
for index, card in ipairs(signCards) do
	local payload = latest(p3, "SignQuestion")
	expect(payload.index == index and payload.signCode == card.signCode and payload.correct == nil and payload.explanationNl == nil, "Sign payload must contain visual but no key or explanation")
	expect(payload.promptNl == card.promptNl and #payload.options == #card.options, "Each sign question sends its own choices and prompt")
	expect(Catalog.topics.verkeerstekens.questionIds[index] == card.id, "Public sign question IDs must match server order")
	request(p3, "NextSign")
	expect(s3.phase == "sign_question" and s3.quizIndex == index, "Cannot skip unanswered sign card")
	request(p3, "SignAnswer", #payload.options + 1)
	expect(s3.phase == "sign_question", "Out-of-range sign choice must be rejected")
	if previousToken then
		request(p3, "SignAnswer", card.correct, previousToken)
		expect(s3.phase == "sign_question", "Old sign token cannot answer next card")
	end
	if index == 1 or card.signCode == "G13" then
		request(p3, "SignAnswer", card.correct == 1 and 2 or 1)
		expect(not latest(p3, "SignResult").correct, "Incorrect sign option must be graded false")
		request(p3, "RetrySign")
		expect(s3.quizIndex == index and s3.phase == "sign_question" and s3.token ~= payload.token, "Sign retry must retain card and issue fresh session")
	end
	request(p3, "SignAnswer", card.correct)
	expect(s3.phase == "sign_result" and latest(p3, "SignResult").correctCount == index, "Correct choices must accumulate once per card")
	expect(latest(p3, "SignResult").labelNl == card.options[card.correct] and latest(p3, "SignResult").explanationNl == card.explanationNl, "Sign feedback uses the answer and explanation from the current card")
	request(p3, "SignAnswer", 1)
	expect(latest(p3, "SignResult").correctCount == index, "Repeated answer must not inflate score")
	previousToken = s3.token
	if index < #signCards then request(p3, "NextSign") end
end
expect(s3.topics.verkeerstekens.trainingCompleted and s3.topics.verkeerstekens.bestCorrect == 7, "Completed sign round must record session best across both sets of signs")
request(p3, "NextSign")
expect(s3.phase == "sign_result" and s3.quizIndex == 7, "Final card must not advance out of range")
request(p3, "Return")
expect(latest(p3, "Lobby").topics.verkeerstekens.theoryRead and not latest(p3, "Lobby").topics.voorrang.theoryRead, "Progress packet must keep subjects separate")
move(p, 7, -16); frames(5.3)
expect(s.phase == "lobby" and not s.topics.verkeerstekens.theoryRead, "Priority theory must not unlock signs training")
move(p3, -7, 0); frames(2)
move(p3, -7, -16); frames(3)
expect(s3.phase == "lobby", "Switching stations must restart dwell instead of combining time")
frames(2.4)
expect(s3.phase == "book" and s3.bookTopic == "verkeerstekens", "Full dwell on new station must open only its book")
request(p3, "BookClose")
move(p3, 7, -16); frames(5.3)
train(p)
local simultaneousScene = s.scene
expect(s3.phase == "sign_question" and simultaneousScene, "One player may review signs while another drives")
request(p3, "SignAnswer", signCards[1].correct)
request(p3, "Return")
expect(s.scene == simultaneousScene and not simultaneousScene.Destroyed, "Sign quiz cleanup must not destroy another player's road scene")
request(p, "Return")
move(p3, 7, -16); frames(5.3)
p3.Character:FindFirstChildOfClass("Humanoid").Died:Fire()
expect(s3.phase == "dead", "Death during signs quiz must terminate active session")
p3.Character = newCharacter(); p3.CharacterAdded:Fire(p3.Character)
expect(s3.phase == "lobby" and s3.topics.verkeerstekens.theoryRead and not p3.Character:FindFirstChild("HumanoidRootPart").Anchored, "Respawn must restore control and retain own topic state")
expect(not s.topics.verkeerstekens.theoryRead, "Different players must not share sign progress")
realPrint(string.format("PASS: %d checks against actual server source (mock engine; Studio still required).", checks))
