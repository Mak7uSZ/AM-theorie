-- Executes the real client against UI stubs. Checks layout/state, not rendering.
local actualPrint = print
local print = function(...) end
local viewport = { X = 1440, Y = 860 }
local function signal()
	local callbacks = {}
	return {
		Connect = function(_, callback) table.insert(callbacks, callback); return { Disconnect = function() end } end,
		Fire = function(_, ...) for _, callback in ipairs(callbacks) do callback(...) end end,
	}
end
local function dim(scale, offset) return { Scale = scale, Offset = offset } end
local UDim = { new = dim }
local UDim2 = {
	new = function(xs, xo, ys, yo) return { X = dim(xs, xo), Y = dim(ys, yo) } end,
	fromScale = function(x, y) return { X = dim(x, 0), Y = dim(y, 0) } end,
	fromOffset = function(x, y) return { X = dim(0, x), Y = dim(0, y) } end,
}
local function vector(x, y, z) return { X = x, Y = y, Z = z or 0 } end
local Vector2, Vector3 = { new = vector }, { new = vector }
local Color3 = { new = function(...) return {...} end, fromRGB = function(...) return {...} end }
local Enum = setmetatable({}, { __index = function(groups, group)
	local values = setmetatable({}, { __index = function(_, value) return group .. "." .. value end })
	rawset(groups, group, values)
	return values
end })
local methods, Instance = {}, {}
function Instance.new(className)
	local data = { ClassName = className, Name = className, children = {}, signals = {}, Visible = true, AnchorPoint = vector(0, 0) }
	if className == "TextButton" then data.Activated, data.InputBegan = signal(), signal() end
	return setmetatable({}, {
		__index = function(self, key)
			if key == "AbsoluteSize" then
				if className == "ScreenGui" then return viewport end
				local parentSize = data.Parent and data.Parent.AbsoluteSize or viewport
				local size = data.Size or UDim2.fromOffset(0, 0)
				local x, y = parentSize.X * size.X.Scale + size.X.Offset, parentSize.Y * size.Y.Scale + size.Y.Offset
				for _, child in ipairs(self:GetChildren()) do
					if child.ClassName == "UISizeConstraint" and child.MaxSize then x, y = math.min(x, child.MaxSize.X), math.min(y, child.MaxSize.Y) end
				end
				return vector(x, y)
			end
			return methods[key] or data[key]
		end,
		__newindex = function(self, key, value)
			if key == "Parent" and value then table.insert(value.children, self) end
			data[key] = value
		end,
	})
end
function methods:GetChildren()
	local children = {}
	for _, child in ipairs(self.children) do if child.Parent == self then table.insert(children, child) end end
	return children
end
function methods:FindFirstChild(name)
	for _, child in ipairs(self:GetChildren()) do if child.Name == name then return child end end
end
function methods:WaitForChild(name) return assert(self:FindFirstChild(name), "Missing child " .. name) end
function methods:FindFirstChildOfClass(className)
	for _, child in ipairs(self:GetChildren()) do if child.ClassName == className then return child end end
end
function methods:IsA(className) return self.ClassName == className end
function methods:Destroy() self.Parent = nil end
function methods:ClearAllChildren() for _, child in ipairs(self:GetChildren()) do child:Destroy() end end
function methods:GetPropertyChangedSignal(property)
	self.signals[property] = self.signals[property] or signal()
	return self.signals[property]
end
function methods:FireServer(...) self.lastRequest = {...} end
local fakeRemote = Instance.new("RemoteEvent")
fakeRemote.Name, fakeRemote.OnClientEvent = "PrototypeEvent", signal()
local fakeStorage = Instance.new("Folder")
fakeRemote.Parent = fakeStorage
local fakeModule = Instance.new("ModuleScript")
fakeModule.Name, fakeModule.Parent = "TopicContent", fakeStorage
local fakePlayer = Instance.new("Player")
local playerGui = Instance.new("Folder")
playerGui.Name, playerGui.Parent = "PlayerGui", fakePlayer
fakePlayer.Character = Instance.new("Model")
local humanoid = Instance.new("Humanoid")
humanoid.Parent = fakePlayer.Character
local input = { MouseBehavior = Enum.MouseBehavior.Default, MouseIconEnabled = true }
for _, name in ipairs({ "InputBegan", "InputEnded", "InputChanged", "WindowFocusReleased" }) do input[name] = signal() end
local fakeRunService = { RenderStepped = signal() }
local workspace = { CurrentCamera = { FieldOfView = 70 } }
local services = { Players = { LocalPlayer = fakePlayer }, ReplicatedStorage = fakeStorage, RunService = fakeRunService, UserInputService = input }
local game = { GetService = function(_, name) return assert(services[name]) end }
local task = { defer = function(fn) fn() end, delay = function() end }
local contentForTest = (function()
--[[TOPIC_CONTENT]]
end)()
local function require(_) return contentForTest end

--[[CLIENT_SOURCE]]

local checks = 0
local function expect(condition, message) checks += 1; assert(condition, message) end
local function emit(kind, data) fakeRemote.OnClientEvent:Fire(kind, data) end
emit("Menu")
expect(menuBackdrop.Visible and menuBackdrop.Size.X.Scale == 1 and menuBackdrop.Size.Y.Scale == 1, "Menu backdrop must cover full screen")
expect(backdropGui.IgnoreGuiInset and not gui.IgnoreGuiInset, "Full backdrop and safe content need separate inset behavior")
expect(not status.Visible, "Global status must not cover menu title")
overlay("settings", true)
expect(menuBackdrop.Visible and not status.Visible, "Menu settings must keep world covered without title overlap")
emit("Lobby", { topics = { voorrang = { theoryRead = false }, verkeerstekens = { theoryRead = false } } })
expect(not menuBackdrop.Visible and status.Visible and not panel.Visible, "Only Play/Lobby transition may reveal lobby")
local priorityTopic = contentForTest.topics.voorrang
local page = priorityTopic.pages[1]
emit("Book", { page = 1, total = 6, titleNl = page.titleNl, text = page.text, imageKey = page.imageKey, captionNl = page.captionNl, reviewStatus = priorityTopic.reviewStatus })
expect(not status.Visible and panel.Visible, "Book must not share global status layer")
expect(panel:FindFirstChild("BookSource").Text:find("CONCEPT"), "Book pending review must show its status")
local title = panel:FindFirstChild("PanelTitle")
expect(title.Position.Y.Scale + title.Size.Y.Scale < 0.15, "Book title must end before source row")
emit("Cinematic", { token = 1, origin = vector(0, 0, 0), sceneName = "Test", titleNl = "Test", index = 1, total = 3 })
emit("Approach", { sceneName = "Test" })
expect(status.Visible and ridingHud.Visible and not menuBackdrop.Visible, "Approach must reveal world and driving HUD")
local definition = { index = 1, total = 3, titleNl = "Test", prompt = "Choose an action", options = { "Option one", "Option two", "Option three" } }
emit("Question", definition)
expect(not status.Visible and not ridingHud.Visible and decisionAnswers.Visible, "Question must hide overlapping HUD")
expect(panel.BackgroundTransparency >= 0.5, "Question background must be translucent")
local answerCount = 0
for _, child in ipairs(decisionAnswers:GetChildren()) do
	if child:IsA("TextButton") then
		answerCount += 1
		expect(child.BackgroundTransparency >= 0.35, "Answer must not be opaque")
	end
end
expect(answerCount == 3, "All choices need their own bottom buttons")
for _, size in ipairs({ {1440, 860}, {1920, 1080}, {982, 560}, {900, 450}, {600, 500}, {600, 360}, {390, 620}, {320, 320} }) do
	viewport = vector(size[1], size[2])
	gui:GetPropertyChangedSignal("AbsoluteSize"):Fire()
	local layout = measureDecisionLayout(viewport.X, viewport.Y, 3)
	expect(layout.cardY >= 0 and layout.cardWidth <= viewport.X, "Question must fit viewport")
	expect(layout.cardY + layout.cardHeight + 12 <= layout.answersY, "Question and answers must not overlap")
	expect(layout.answersY + layout.answersHeight <= viewport.Y, "Answers must fit viewport")
	expect(layout.buttonWidth > 0 and layout.buttonHeight > 0, "Answer buttons must remain visible")
	expect(panel.Size.X.Offset == layout.cardWidth and decisionAnswers.Position.Y.Offset == layout.answersY, "Actual widgets must apply tested geometry")
end
emit("Outcome", { branch = "yield" })
expect(not panel.Visible and not decisionAnswers.Visible and status.Visible, "Chosen answer must clear both overlays")
emit("Reset")
expect(not decisionAnswers.Visible and not menuBackdrop.Visible, "Respawn must clear question and menu layers")
expect(workspace.CurrentCamera.FieldOfView == 70, "Camera settings must restore on reset")
emit("Menu")
expect(menuBackdrop.Visible and not status.Visible, "Returning menu must restore fullscreen backdrop")
local function descendant(node, name)
	if node.Name == name then return node end
	for _, child in ipairs(node:GetChildren()) do
		local found = descendant(child, name)
		if found then return found end
	end
end
local signsTopic = contentForTest.topics.verkeerstekens
for index, signPage in ipairs(signsTopic.pages) do
	emit("Book", { topicId = "verkeerstekens", page = index, total = #signsTopic.pages, titleNl = signPage.titleNl, text = signPage.text, signCode = signPage.signCode, captionNl = signPage.captionNl, reviewStatus = signsTopic.reviewStatus })
	local sketch = descendant(panel, "RoadSignSketch")
	expect(sketch and #sketch:GetChildren() > 3, "Every sign book page must render a real schematic without image ID")
	expect(not status.Visible, "Signs book source row must not collide with global HUD")
	expect(panel:FindFirstChild("BookSource").Text == "Bron: " .. signsTopic.sourceName, "Reviewed sign page should display its source")
end
emit("SignQuestion", { token = 99, index = 1, total = 4, signCode = "B6", options = { "One", "Two", "Three", "Four" } })
expect(mode == "sign_question" and token == 99 and descendant(panel, "RoadSignSketch"), "Sign quiz must show its schematic and session token")
expect(not firstPerson and not decisionAnswers.Visible and not status.Visible, "Sign cards must not leave first-person driving overlays active")
local clicked = 0
for _, child in ipairs(panel:GetChildren()) do
	if child:IsA("TextButton") and child.Text ~= "Naar lobby" then
		clicked += 1
		child.Activated:Fire()
		expect(fakeRemote.lastRequest[1] == "SignAnswer" and fakeRemote.lastRequest[2] == clicked and fakeRemote.lastRequest[3] == 99, "Each sign option must send its own index and token")
	end
end
expect(clicked == 4, "Sign question must have four options")
emit("SignResult", { correct = true, signCode = "B6", labelNl = "Test label", index = 1, total = 4, correctCount = 1 })
expect(mode == "sign_result" and panel.Visible and not ridingHud.Visible, "Recognition feedback must keep controls clean")
emit("Lobby", { topics = { voorrang = { theoryRead = false }, verkeerstekens = { theoryRead = true, trainingCompleted = true, bestCorrect = 4 } } })
expect(topicProgress.verkeerstekens.bestCorrect == 4 and not topicProgress.voorrang.theoryRead, "Client progress must preserve independent topics")
overlay("progress", false)
expect(not status.Visible and panel.Visible, "Progress with two topics must not overlap status")
actualPrint(string.format("PASS: %d client UI checks (mock objects; visual Studio check still required).", checks))
