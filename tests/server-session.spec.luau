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
local fakeModule = Instance.new("ModuleScript")
fakeModule.Name, fakeModule.Parent = "TopicContent", fakeReplicatedStorage
local workspace = Instance.new("Folder")
local task = { spawn = function(fn, ...) fn(...) end }
local contentForTest = (function()
--[[TOPIC_CONTENT]]
end)()
local function require(module)
	assert(module == fakeModule)
	return contentForTest
end
local services = { Players = fakePlayers, ReplicatedStorage = fakeReplicatedStorage, RunService = fakeRunService }
local game = { GetService = function(_, name) return assert(services[name]) end }

--[[SERVER_SOURCE]]

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
	for _ = 2, #contentForTest.pages do request(player, "Page", 1) end
	request(player, "Finish")
	expect(sessions[player].theoryRead, "Last page must unlock training")
end
local function train(player)
	move(player, 7, 0)
	frames(5.3)
	expect(sessions[player].phase == "cinematic", "Training dwell must start cinematic")
end
local function question(player)
	frames(4.2)
	expect(sessions[player].phase == "question", "Cinematic must end in question")
	local payload = latest(player, "Question")
	expect(payload.correct == nil and payload.correctAnswerIndex == nil and payload.explanationNl == nil, "Question must not reveal answer key")
end
local function stopSuccessfully(player)
	request(player, "BeginAction")
	local s = sessions[player]
	expect(s.phase == "action", "Answer must enable action")
	frames(0.2)
	expect(s.phase == "action" and s.stopped == 0, "Stopping at starting position must not pass")
	-- Supply a measured block position; engine physics/rendering are outside this harness.
	s.block.Position = s.origin + vector(3.5, 2, 6)
	frames(1.2)
	expect(s.phase == "result" and latest(player, "Result").action, "Holding inside target must pass stop check")
end

expect(#contentForTest.pages == 6, "Book must have six authored pages")
expect(#contentForTest.questionIds == 3 and #scenarios == 3, "Three scenarios must be configured")
for i, definition in ipairs(scenarios) do
	expect(contentForTest.questionIds[i] == definition.id, "Public question IDs must match server order")
end
local p = newPlayer(1)
local s = sessions[p]
expect(s.phase == "menu", "Player must join menu")
request(p, "Finish")
expect(not s.theoryRead, "Fake finish from menu must be rejected")
request(p, "Play")
expect(s.phase == "lobby", "Play must enter lobby")
move(p, 7, 0); frames(5.3)
expect(s.phase == "lobby", "Training before theory must stay locked")
move(p, -7, 0); frames(3)
move(p, 0, 18); frames(3)
expect(s.phase == "lobby" and s.pad == nil, "Leaving pad must cancel dwell")
move(p, -7, 0); frames(5.3)
request(p, "Finish")
expect(s.phase == "book" and not s.theoryRead, "Early book finish must be rejected")
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
expect(s.knowledge and s.phase == "answered", "Cyclist from right must be graded correctly")
request(p, "Answer", 1)
expect(s.knowledge, "Duplicate answer must not change grade")
stopSuccessfully(p)
local oldToken = s.token
request(p, "NextScene")
expect(s.sceneIndex == 2 and s.definition.unpaved and s.token ~= oldToken, "Next scene must load unpaved case with new token")
question(p)
request(p, "Answer", 1, oldToken)
expect(s.phase == "question", "Stale scene token must be rejected")
request(p, "Answer", 1)
request(p, "BeginAction")
s.block.Position = s.origin + vector(3.5, 2, 4)
frames(0.1)
expect(s.phase == "result" and not latest(p, "Result").action, "Overshooting target must fail independently")
request(p, "RetryScene")
expect(s.sceneIndex == 2 and s.phase == "cinematic", "Retry must keep current scene")
question(p)
request(p, "Answer", 3)
expect(not s.knowledge, "Incorrect answer must remain incorrect")
stopSuccessfully(p)
expect(latest(p, "Result").knowledgeCount == 1 and latest(p, "Result").actionCount == 2, "Retry must replace grade, without double-counting")
request(p, "NextScene"); question(p); request(p, "Answer", 3); stopSuccessfully(p)
expect(s.sceneIndex == 3 and latest(p, "Result").knowledgeCount == 2, "Tram scene must use its own answer key")
request(p, "NextScene")
expect(s.phase == "result" and s.sceneIndex == 3, "Last scene must not advance out of range")
local oldScene = s.scene
request(p, "Return")
expect(s.phase == "lobby" and oldScene.Destroyed and not p.Character:FindFirstChild("HumanoidRootPart").Anchored, "Return must clean scene and restore character")

local p2 = newPlayer(2)
request(p2, "Play"); readBook(p2)
train(p); train(p2)
expect(s.origin.X ~= sessions[p2].origin.X and s.scene ~= sessions[p2].scene, "Concurrent players need distinct scenes")
local p2Scene = sessions[p2].scene
p.Character = newCharacter(); p.CharacterAdded:Fire(p.Character)
expect(s.phase == "lobby" and s.scene == nil and s.theoryRead, "Respawn must clear scene but retain session theory")
expect(sessions[p2].scene == p2Scene and not p2Scene.Destroyed, "Respawn must not affect another player")
fakePlayers.PlayerRemoving:Fire(p2)
expect(p2Scene.Destroyed and sessions[p2] == nil, "Leaving must remove only that player's scene")
expect(table.concat(logs, "\n"):find("question=unpaved_01", 1, true) ~= nil, "Diagnostics must identify active question")
realPrint(string.format("PASS: %d checks against actual server source (mock engine; Studio still required).", checks))
