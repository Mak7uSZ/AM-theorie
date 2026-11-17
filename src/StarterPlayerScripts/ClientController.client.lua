-- LocalScript: StarterPlayer > StarterPlayerScripts > ClientController
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Content = require(ReplicatedStorage:WaitForChild("TopicContent"))
local remote = ReplicatedStorage:WaitForChild("PrototypeEvent")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "AMPrototypeGui", false, false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")
-- Full-bleed menu backdrop is separate from the inset-safe interactive GUI.
local backdropGui = Instance.new("ScreenGui")
backdropGui.Name, backdropGui.ResetOnSpawn, backdropGui.IgnoreGuiInset = "AMMenuBackdrop", false, true
backdropGui.DisplayOrder, backdropGui.Parent = 9, gui.Parent
local menuBackdrop = Instance.new("Frame")
menuBackdrop.Size, menuBackdrop.BackgroundColor3 = UDim2.fromScale(1, 1), Color3.fromRGB(14, 22, 35)
menuBackdrop.BorderSizePixel, menuBackdrop.Parent = 0, backdropGui
local mode, token, origin = "loading", 0, nil
local theoryRead, throttle, largeText = false, 0, false
local shotStarted = 0
local vehicle, sceneName, viewPosition, savedView
local firstPerson, looking, lookLeft, lookRight = false, false, false, false
local yaw, pitch = 0, math.rad(-6)
local DEBUG_LOGS = true
local function fitText(object, maximum)
	object.TextScaled = true
	local limit = Instance.new("UITextSizeConstraint")
	limit.MinTextSize, limit.MaxTextSize, limit.Parent = 10, maximum, object
end
local function send(command, value)
	if DEBUG_LOGS and command ~= "Drive" then
		print(string.format("[AM Theory][Client][mode=%s][session=%d] Request:%s value=%s", mode, token, command, tostring(value)))
	end
	remote:FireServer(command, value, token)
end
local function text(parent, value, position, size)
	local t = Instance.new("TextLabel")
	t.Position, t.Size = position, size
	t.BackgroundTransparency, t.TextColor3 = 1, Color3.new(1, 1, 1)
	t.Font, t.TextSize, t.TextWrapped = Enum.Font.Gotham, 18, true
	fitText(t, 18)
	t.Text, t.Parent = value, parent
	return t
end
local function button(parent, caption, x, y, width, callback)
	local b = Instance.new("TextButton")
	b.Position, b.Size = UDim2.fromScale(x, y), UDim2.fromScale(width, 0.1)
	b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(38, 113, 164), Color3.new(1, 1, 1)
	b.Font, b.TextSize, b.TextWrapped = Enum.Font.GothamBold, 16, true
	fitText(b, 16)
	b.Text, b.Parent = caption, parent
	local corner = Instance.new("UICorner")
	corner.Parent = b
	if callback then b.Activated:Connect(callback) end
	return b
end
local panel = Instance.new("Frame")
panel.AnchorPoint, panel.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
panel.Size, panel.BackgroundColor3 = UDim2.fromScale(0.92, 0.82), Color3.fromRGB(20, 29, 44)
panel.Parent = gui
local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize, constraint.Parent = Vector2.new(820, 560), panel
local status = text(gui, "Verbinden…", UDim2.fromScale(0.12, 0.10), UDim2.fromScale(0.76, 0.07))
status:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = 14
status.BackgroundTransparency, status.BackgroundColor3 = 0.1, Color3.fromRGB(20, 29, 44)
local toolbar = Instance.new("Frame")
toolbar.Size, toolbar.Position, toolbar.BackgroundTransparency = UDim2.fromScale(0.65, 0.12), UDim2.fromScale(0.18, 0.86), 1
toolbar.Parent = gui
local ridingHud = Instance.new("Frame")
ridingHud.AnchorPoint, ridingHud.Position = Vector2.new(0.5, 1), UDim2.fromScale(0.5, 0.97)
ridingHud.Size, ridingHud.BackgroundTransparency, ridingHud.Visible = UDim2.fromScale(0.78, 0.14), 1, false
ridingHud.Parent = gui
local decisionAnswers = Instance.new("Frame")
decisionAnswers.Name, decisionAnswers.BackgroundTransparency, decisionAnswers.Visible = "DecisionAnswers", 1, false
decisionAnswers.Parent = gui
local answerList = Instance.new("UIListLayout")
answerList.Padding, answerList.SortOrder = UDim.new(0, 8), Enum.SortOrder.LayoutOrder
answerList.Parent = decisionAnswers
-- BEGIN_DECISION_LAYOUT: reused by the geometry regression test.
local function measureDecisionLayout(width, height, count)
	local horizontal = width >= 900 or height < 380
	local answerHeight = height < 420 and 78 or 64
	if not horizontal then answerHeight = 52 end
	local answerWidth = math.min(1120, width - 32)
	local answersHeight = horizontal and answerHeight or count * answerHeight + (count - 1) * 8
	local answersY = height - answersHeight - 16
	local cardHeight = height < 480 and 104 or 136
	local cardY = math.max(8, math.min(math.floor(height * 0.14), answersY - cardHeight - 24))
	return {
		cardWidth = math.min(820, width - 32), cardHeight = cardHeight, cardY = cardY,
		answersWidth = answerWidth, answersHeight = answersHeight, answersY = answersY,
		buttonWidth = horizontal and (answerWidth - (count - 1) * 8) / count or answerWidth,
		buttonHeight = answerHeight, horizontal = horizontal,
	}
end
-- END_DECISION_LAYOUT
local function refreshDecisionLayout()
	if mode ~= "question" then return end
	local size, buttons = gui.AbsoluteSize, {}
	for _, child in ipairs(decisionAnswers:GetChildren()) do
		if child:IsA("TextButton") then table.insert(buttons, child) end
	end
	if size.X < 1 or size.Y < 1 or #buttons == 0 then return end
	local layout = measureDecisionLayout(size.X, size.Y, #buttons)
	panel.AnchorPoint, panel.Position = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, layout.cardY)
	panel.Size = UDim2.fromOffset(layout.cardWidth, layout.cardHeight)
	decisionAnswers.AnchorPoint = Vector2.new(0.5, 0)
	decisionAnswers.Position = UDim2.new(0.5, 0, 0, layout.answersY)
	decisionAnswers.Size = UDim2.fromOffset(layout.answersWidth, layout.answersHeight)
	answerList.FillDirection = layout.horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
	for _, answer in ipairs(buttons) do answer.Size = UDim2.fromOffset(layout.buttonWidth, layout.buttonHeight) end
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshDecisionLayout)
local impactFlash = Instance.new("Frame")
impactFlash.Size, impactFlash.BackgroundColor3 = UDim2.fromScale(1, 1), Color3.fromRGB(160, 40, 30)
impactFlash.BackgroundTransparency, impactFlash.Visible, impactFlash.ZIndex = 0.65, false, 10
impactFlash.Parent = gui
local function heading(title, body)
	panel.AnchorPoint, panel.BackgroundTransparency = Vector2.new(0.5, 0.5), 0
	panel.Size, panel.Position = UDim2.fromScale(0.92, 0.82), UDim2.fromScale(0.5, 0.5)
	ridingHud.Visible, decisionAnswers.Visible, status.Visible, menuBackdrop.Visible = false, false, false, false
	panel:ClearAllChildren()
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize, limit.Parent = Vector2.new(820, 560), panel
	panel.Visible = true
	toolbar.Visible = false
	local titleLabel = text(panel, title, UDim2.fromScale(0.04, 0.03), UDim2.fromScale(0.92, 0.11))
	titleLabel.Name = "PanelTitle"
	local content = text(panel, body, UDim2.fromScale(0.06, 0.19), UDim2.fromScale(0.88, 0.48))
	content:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = largeText and 22 or 17
	return content
end
local function restoreCamera()
	origin = nil
	vehicle, sceneName, viewPosition = nil, nil, nil
	firstPerson, looking, lookLeft, lookRight = false, false, false, false
	ridingHud.Visible, impactFlash.Visible = false, false
	decisionAnswers.Visible, menuBackdrop.Visible = false, false
	throttle = 0
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	if savedView then
		camera.FieldOfView = savedView.fov
		UserInputService.MouseBehavior = savedView.mouseBehavior
		UserInputService.MouseIconEnabled = savedView.mouseIcon
		savedView = nil
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then camera.CameraSubject = humanoid end
end
local function showLobby()
	mode = "lobby"
	restoreCamera()
	panel.Visible, toolbar.Visible = false, true
	status.Visible = true
	status.Text = theoryRead and "Voorrang: klaar voor training | voortgang alleen in deze sessie" or "Loop naar de blauwe theoriecirkel | voortgang alleen in deze sessie"
end
local showMenu
local function overlay(kind, fromMenu)
	if not fromMenu then send("Overlay", true) end
	mode = "overlay"
	if kind == "progress" then
		heading("Voortgang", "Alleen deze serversessie.\n\nVoorrang: " .. (theoryRead and "THEORIE GELEZEN — 3 oefenscènes beschikbaar" or "THEORIE NOG NIET GELEZEN") .. "\n\nDeze demo geeft nog geen geslaagd onderwerp of examencijfer.")
	else
		heading("Instellingen", "Leesbaarheid van de boektekst.\n\nInstellingen worden niet opgeslagen.")
		local toggle
		toggle = button(panel, largeText and "Grote tekst: AAN" or "Grote tekst: UIT", 0.2, 0.69, 0.6, function()
			largeText = not largeText
			toggle.Text = largeText and "Grote tekst: AAN" or "Grote tekst: UIT"
		end)
	end
	menuBackdrop.Visible = fromMenu
	button(panel, "Terug", 0.3, 0.84, 0.4, function()
		if fromMenu then showMenu() else send("Overlay", false); showLobby() end
	end)
end
showMenu = function()
	mode = "menu"
	restoreCamera()
	status.Text = "AM Theory Simulator | technisch prototype"
	heading("AM Theory Simulator", "Voorrang — eerste leerinhoud\n\nLees het geïllustreerde boek en probeer 3 oefenscènes: fietser van rechts, onverharde weg en tram.\n\nConcept: actualiteitscontrole open. Geen officiële CBR-les.")
	menuBackdrop.Visible, panel.BackgroundTransparency = true, 1
	button(panel, "Spelen", 0.3, 0.68, 0.4, function() send("Play") end)
	button(panel, "Instellingen", 0.08, 0.84, 0.38, function() overlay("settings", true) end)
	button(panel, "Voortgang", 0.54, 0.84, 0.38, function() overlay("progress", true) end)
end
toolbar.Size = UDim2.fromScale(0.65, 0.08)
local settingsButton = button(toolbar, "Instellingen", 0, 0, 0.48, function() overlay("settings", false) end)
local progressButton = button(toolbar, "Voortgang", 0.52, 0, 0.48, function() overlay("progress", false) end)
settingsButton.Size, progressButton.Size = UDim2.fromScale(0.48, 1), UDim2.fromScale(0.48, 1)
local forwardButton = button(ridingHud, "Vooruit (W / ↑)", 0, 0, 0.32)
forwardButton.Size = UDim2.fromScale(0.32, 0.48)
forwardButton.InputBegan:Connect(function(input)
	if mode == "approach" and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then throttle = 1 end
end)
local brakeButton = button(ridingHud, "Rem (Spatie)", 0.34, 0, 0.32, function() throttle = 0 end)
brakeButton.Size = UDim2.fromScale(0.32, 0.48)
local exitButton = button(ridingHud, "Naar lobby", 0.68, 0, 0.32, function() send("Return") end)
exitButton.Size = UDim2.fromScale(0.32, 0.48)
local lookHint = text(ridingHud, "Q / E: links / rechts kijken • Rechtermuisknop slepen: rondkijken • Snelheid: studs/s", UDim2.fromScale(0, 0.52), UDim2.fromScale(1, 0.45))
lookHint:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = 13

remote.OnClientEvent:Connect(function(kind, data)
	if DEBUG_LOGS and kind ~= "Countdown" and kind ~= "Notice" then
		print(string.format("[AM Theory][Client][mode=%s][session=%d] Receive:%s", mode, token, kind))
	end
	if kind == "Menu" then showMenu()
	elseif kind == "Lobby" then theoryRead = data.theoryRead; showLobby()
	elseif kind == "Countdown" then
		status.Text = data.active and ("Blijf in de cirkel: " .. data.seconds) or "Timer gereset — blijf 5 seconden in een cirkel."
	elseif kind == "Notice" then status.Text = data
	elseif kind == "Book" then
		mode = "book"
		local body = heading(data.titleNl .. " | " .. data.page .. "/" .. data.total, data.text)
		local source = text(panel, "CONCEPT • actualiteitscontrole open • Bron: RVV 1990", UDim2.fromScale(0.04, 0.15), UDim2.fromScale(0.92, 0.04))
		source:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = 12
		body.Position, body.Size = UDim2.fromScale(0.04, 0.23), UDim2.fromScale(0.45, 0.39)
		body.TextXAlignment, body.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
		-- Accept either a symbolic key or a direct ID pasted into a page.
		local imageReference = tostring(data.imageKey or "")
		local imageId = tostring((Content.images or {})[imageReference] or imageReference)
		imageId = imageId:match("^%s*(.-)%s*$")
		if imageId:match("^%d+$") then imageId = "rbxassetid://" .. imageId end
		if imageId:match("^rbxassetid://%d+$") then
			local picture = Instance.new("ImageLabel")
			picture.Name, picture.BackgroundTransparency = "TheoryIllustration", 1
			picture.Position, picture.Size = UDim2.fromScale(0.53, 0.23), UDim2.fromScale(0.43, 0.39)
			picture.ScaleType, picture.Image, picture.Parent = Enum.ScaleType.Fit, imageId, panel
			if DEBUG_LOGS then print("[AM Theory][Client] Book image: page=" .. data.page .. " image=" .. imageId) end
			task.delay(8, function()
				if picture.Parent and not picture.IsLoaded then
					warn("[AM Theory][Client] Image not loaded: " .. imageId .. ". Check asset permissions, ID and moderation.")
				end
			end)
		else
			text(panel, "Illustratie niet ingesteld\n\nControleer TopicContent.images. Gebruik op de pagina een sleutel zoals 'bestuurders' of een geldig afbeeldings-ID.", UDim2.fromScale(0.53, 0.21), UDim2.fromScale(0.43, 0.43))
		end
		local caption = text(panel, data.captionNl, UDim2.fromScale(0.04, 0.64), UDim2.fromScale(0.92, 0.08))
		caption:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = 13
		local back = button(panel, "Vorige", 0.05, 0.75, 0.26, function() send("Page", -1) end)
		back.Visible = data.page > 1
		if data.page < data.total then
			button(panel, "Volgende", 0.69, 0.75, 0.26, function() send("Page", 1) end)
		else
			button(panel, "Theorie afronden", 0.4, 0.75, 0.55, function() send("Finish") end)
		end
		button(panel, "Sluiten", 0.3, 0.88, 0.4, function() send("BookClose") end)
	elseif kind == "Cinematic" then
		local camera = workspace.CurrentCamera
		if not savedView then
			savedView = { fov = camera.FieldOfView, mouseBehavior = UserInputService.MouseBehavior, mouseIcon = UserInputService.MouseIconEnabled }
		end
		mode, token, origin, shotStarted = "cinematic", data.token, data.origin, os.clock()
		vehicle, sceneName, viewPosition = data.vehicle, data.sceneName, nil
		firstPerson, looking, lookLeft, lookRight, throttle = false, false, false, false, 0
		yaw, pitch = 0, math.rad(-6)
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		panel.Visible, toolbar.Visible, ridingHud.Visible, impactFlash.Visible = false, false, false, false
		decisionAnswers.Visible, menuBackdrop.Visible, status.Visible = false, false, true
		camera.CameraType = Enum.CameraType.Scriptable
		status.Text = string.format("Scène %d/%d: %s (4 seconden) | CONCEPT", data.index, data.total, data.titleNl)
	elseif kind == "Approach" then
		mode, firstPerson, throttle = "approach", true, 0
		vehicle, sceneName = data.vehicle, data.sceneName
		workspace.CurrentCamera.FieldOfView = 80
		panel.Visible, toolbar.Visible, ridingHud.Visible = false, false, true
		status.Visible = true
		status.Text = "Jouw beurt: rijd naar het kruispunt. Daar neem je een beslissing."
	elseif kind == "Question" then
		mode, throttle = "question", 0
		local prompt = heading(string.format("%d/%d — %s", data.index, data.total, data.titleNl), data.prompt)
		panel.BackgroundTransparency = 0.55
		prompt.Position, prompt.Size = UDim2.fromScale(0.04, 0.28), UDim2.fromScale(0.92, 0.66)
		prompt.TextStrokeTransparency = 0.55
		for _, child in ipairs(decisionAnswers:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		for index, option in ipairs(data.options) do
			local answer = button(decisionAnswers, option, 0, 0, 1, function() send("Answer", index) end)
			answer.LayoutOrder, answer.BackgroundTransparency, answer.TextStrokeTransparency = index, 0.4, 0.6
		end
		decisionAnswers.Visible = true
		refreshDecisionLayout()
		task.defer(refreshDecisionLayout)
	elseif kind == "Outcome" then
		mode, throttle = "outcome", 0
		panel.Visible, ridingHud.Visible = false, false
		decisionAnswers.Visible, status.Visible = false, true
		local actions = { yield = "Je wacht en laat de ander voorgaan.", drive = "Je rijdt door zonder voorrang te verlenen.", rush = "Je versnelt om er nog vóór te komen." }
		status.Text = "Automatisch vervolg: " .. actions[data.branch]
	elseif kind == "Impact" then
		impactFlash.Visible = true
		status.Text = "Botsing — dit is het geënsceneerde gevolg van je keuze."
		local impactToken = token
		task.delay(0.18, function() if token == impactToken then impactFlash.Visible = false end end)
	elseif kind == "Result" then
		mode, throttle = "result", 0
		panel.Size, panel.Position = UDim2.fromScale(0.92, 0.82), UDim2.fromScale(0.5, 0.5)
		heading(string.format("Resultaat %d/%d — %s", data.index, data.total, data.titleNl),
			"Beslissing: " .. (data.knowledge and "goed" or "nog oefenen") .. "\nGevolg: " .. (data.outcome == "safe" and "veilig verder" or "botsing") .. "\n\n" .. data.explanationNl .. "\n\n" .. data.reason ..
			string.format("\n\nGoede beslissingen: %d/%d. Geen aparte rijvaardigheidsscore: het vervolg was automatisch.", data.knowledgeCount, data.index))
		button(panel, "Opnieuw", 0.05, 0.72, 0.40, function() send("RetryScene") end)
		if data.index < data.total then
			button(panel, "Volgende scène", 0.55, 0.72, 0.40, function() send("NextScene") end)
		end
		button(panel, "Terug naar lobby", 0.2, 0.86, 0.6, function() send("Return") end)
	elseif kind == "Reset" then
		mode = "dead"
		restoreCamera()
		panel.Visible, toolbar.Visible = false, false
		status.Text = "Opnieuw verschijnen…"
		status.Visible = true
	end
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not firstPerson then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		looking = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
	if input.KeyCode == Enum.KeyCode.Q then lookLeft = true end
	if input.KeyCode == Enum.KeyCode.E then lookRight = true end
	if mode == "approach" then
		if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then throttle = 1 end
		if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.S then throttle = 0 end
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if firstPerson and looking and input.UserInputType == Enum.UserInputType.MouseMovement then
		yaw = math.clamp(yaw + input.Delta.X * 0.004, math.rad(-100), math.rad(100))
		pitch = math.clamp(pitch - input.Delta.Y * 0.003, math.rad(-35), math.rad(25))
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Q then lookLeft = false end
	if input.KeyCode == Enum.KeyCode.E then lookRight = false end
	if input.UserInputType == Enum.UserInputType.MouseButton2 and looking then
		looking = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up
		or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then throttle = 0 end
end)
UserInputService.WindowFocusReleased:Connect(function()
	throttle, looking, lookLeft, lookRight = 0, false, false, false
	if firstPerson then UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
end)
local elapsed = 0
RunService.RenderStepped:Connect(function(dt)
	if origin then
		local camera = workspace.CurrentCamera
		if firstPerson then
			if not vehicle or not vehicle.Parent then
				local world = workspace:FindFirstChild("AMPrototype")
				local scene = world and sceneName and world:FindFirstChild(sceneName)
				vehicle = scene and scene:FindFirstChild("PracticeBlock")
			end
			if vehicle then
				local eye = vehicle.Position + Vector3.new(0, 2.4, 0.7)
				viewPosition = viewPosition and viewPosition:Lerp(eye, 1 - math.exp(-dt * 18)) or eye
				local angle = lookLeft and math.rad(-65) or (lookRight and math.rad(65) or yaw)
				local direction = Vector3.new(math.sin(angle) * math.cos(pitch), math.sin(pitch), -math.cos(angle) * math.cos(pitch))
				camera.CFrame = CFrame.lookAt(viewPosition, viewPosition + direction)
				camera.Focus = CFrame.new(viewPosition + direction * 25)
			end
		else
			local pan = math.min(os.clock() - shotStarted, 4) * 2
			camera.CFrame = CFrame.lookAt(origin + Vector3.new(32 - pan, 18, 32), origin + Vector3.new(0, 1, 0))
		end
	end
	if mode == "approach" then
		elapsed += dt
		if elapsed >= 0.16 then elapsed = 0; send("Drive", throttle) end
	end
end)
send("Sync")
print("[AM Theory] Client ready.")
