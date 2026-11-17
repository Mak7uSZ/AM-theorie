-- LocalScript: StarterPlayer > StarterPlayerScripts > ClientController
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("PrototypeEvent")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "AMPrototypeGui", false, false
gui.Parent = player:WaitForChild("PlayerGui")
local mode, token, origin = "loading", 0, nil
local theoryRead, throttle, largeText = false, 0, false
local shotStarted = 0
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
local function heading(title, body)
	panel:ClearAllChildren()
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize, limit.Parent = Vector2.new(820, 560), panel
	panel.Visible = true
	toolbar.Visible = false
	text(panel, title, UDim2.fromScale(0.04, 0.03), UDim2.fromScale(0.92, 0.13))
	local content = text(panel, body, UDim2.fromScale(0.06, 0.19), UDim2.fromScale(0.88, 0.48))
	content:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = largeText and 22 or 17
	return content
end
local function restoreCamera()
	origin = nil
	throttle = 0
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then camera.CameraSubject = humanoid end
end
local function showLobby()
	mode = "lobby"
	restoreCamera()
	panel.Visible, toolbar.Visible = false, true
	status.Text = theoryRead and "Voorrang: klaar voor training | voortgang alleen in deze sessie" or "Loop naar de blauwe theoriecirkel | voortgang alleen in deze sessie"
end
local showMenu
local function overlay(kind, fromMenu)
	if not fromMenu then send("Overlay", true) end
	mode = "overlay"
	if kind == "progress" then
		heading("Voortgang", "Alleen deze serversessie.\n\nVoorrang: " .. (theoryRead and "THEORIE GELEZEN — training beschikbaar" or "THEORIE NOG NIET GELEZEN") .. "\n\nDeze demo geeft nog geen geslaagd onderwerp of examencijfer.")
	else
		heading("Instellingen", "Leesbaarheid van de boektekst.\n\nInstellingen worden niet opgeslagen.")
		local toggle
		toggle = button(panel, largeText and "Grote tekst: AAN" or "Grote tekst: UIT", 0.2, 0.69, 0.6, function()
			largeText = not largeText
			toggle.Text = largeText and "Grote tekst: AAN" or "Grote tekst: UIT"
		end)
	end
	button(panel, "Terug", 0.3, 0.84, 0.4, function()
		if fromMenu then showMenu() else send("Overlay", false); showLobby() end
	end)
end
showMenu = function()
	mode = "menu"
	restoreCamera()
	status.Text = "AM Theory Simulator | technisch prototype"
	heading("AM Theory Simulator", "Milestone 1 — Voorrang\n\nLoop vrij rond, lees het conceptboek en probeer één tramscène.\n\nGeen officiële CBR-les. Alle leerinhoud is concept.")
	button(panel, "Spelen", 0.3, 0.68, 0.4, function() send("Play") end)
	button(panel, "Instellingen", 0.08, 0.84, 0.38, function() overlay("settings", true) end)
	button(panel, "Voortgang", 0.54, 0.84, 0.38, function() overlay("progress", true) end)
end
toolbar.Size = UDim2.fromScale(0.65, 0.08)
local settingsButton = button(toolbar, "Instellingen", 0, 0, 0.48, function() overlay("settings", false) end)
local progressButton = button(toolbar, "Voortgang", 0.52, 0, 0.48, function() overlay("progress", false) end)
settingsButton.Size, progressButton.Size = UDim2.fromScale(0.48, 1), UDim2.fromScale(0.48, 1)

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
		heading("Voorrang — CONCEPT | " .. data.page .. "/" .. data.total, data.text)
		local back = button(panel, "Vorige", 0.05, 0.71, 0.26, function() send("Page", -1) end)
		back.Visible = data.page > 1
		if data.page < data.total then
			button(panel, "Volgende", 0.69, 0.71, 0.26, function() send("Page", 1) end)
		else
			button(panel, "Theorie afronden", 0.4, 0.71, 0.55, function() send("Finish") end)
		end
		button(panel, "Sluiten", 0.3, 0.85, 0.4, function() send("BookClose") end)
	elseif kind == "Cinematic" then
		mode, token, origin, shotStarted = "cinematic", data.token, data.origin, os.clock()
		panel.Visible, toolbar.Visible = false, false
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		status.Text = "Tramscène — technische demo (3 seconden)"
	elseif kind == "Question" then
		mode = "question"
		heading("Tram — conceptvraag", data.prompt)
		for index, option in ipairs(data.options) do
			button(panel, option, 0.06, 0.64 + (index - 1) * 0.115, 0.88, function() send("Answer", index) end)
		end
	elseif kind == "AnswerFeedback" then
		mode = "answered"
		heading(data.correct and "Kennis: goed" or "Kennis: nog oefenen", data.text .. "\n\nNu volgt een aparte actiebeoordeling. Houd Vooruit ingedrukt, laat los om te remmen. Stop één seconde in het gele vak.")
		button(panel, "Start de actie", 0.15, 0.71, 0.7, function() send("BeginAction") end)
		button(panel, "Terug naar lobby", 0.2, 0.85, 0.6, function() send("Return") end)
	elseif kind == "Action" then
		mode, throttle = "action", 0
		local instructions = heading("Stop vóór de witte lijn", "W / ↑ / Vooruit: rijden. Loslaten / Spatie / Rem: remmen.\nStop 1 seconde in het gele vak. Eenheden: studs, geen km/h.")
		-- Keep the road visible above a compact control panel.
		panel.Size, panel.Position = UDim2.fromScale(0.92, 0.36), UDim2.fromScale(0.5, 0.78)
		instructions:FindFirstChildOfClass("UITextSizeConstraint").MaxTextSize = 15
		local forward = button(panel, "Vooruit (vasthouden)", 0.04, 0.73, 0.44)
		forward.Size = UDim2.fromScale(0.44, 0.22)
		forward.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then throttle = 1 end
		end)
		local brake = button(panel, "Rem", 0.52, 0.73, 0.44, function() throttle = 0 end)
		brake.Size = UDim2.fromScale(0.44, 0.22)
		status.Text = "Stop in het gele vak — maximaal 25 seconden"
	elseif kind == "Result" then
		mode, throttle = "result", 0
		panel.Size, panel.Position = UDim2.fromScale(0.92, 0.82), UDim2.fromScale(0.5, 0.5)
		heading("Resultaat — technische demo", "Kennis: " .. (data.knowledge and "goed" or "nog oefenen") .. "\nActie: " .. (data.action and "goed" or "nog oefenen") .. "\n\n" .. data.reason .. "\n\nGeen onderwerppas of examenscore. Probeer gerust opnieuw.")
		button(panel, "Terug naar lobby", 0.2, 0.8, 0.6, function() send("Return") end)
	elseif kind == "Reset" then
		mode = "dead"
		restoreCamera()
		panel.Visible, toolbar.Visible = false, false
		status.Text = "Opnieuw verschijnen…"
	end
	if kind ~= "Action" then
		panel.Size, panel.Position = UDim2.fromScale(0.92, 0.82), UDim2.fromScale(0.5, 0.5)
	end
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or mode ~= "action" then return end
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then throttle = 1 end
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.S then throttle = 0 end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up
		or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then throttle = 0 end
end)
UserInputService.WindowFocusReleased:Connect(function() throttle = 0 end)
local elapsed = 0
RunService.RenderStepped:Connect(function(dt)
	if origin then
		local camera = workspace.CurrentCamera
		local pan = mode == "cinematic" and math.min(os.clock() - shotStarted, 3) * 2 or 6
		camera.CFrame = CFrame.lookAt(origin + Vector3.new(32 - pan, 30, 36), origin + Vector3.new(0, 0, 7))
	end
	if mode == "action" then
		elapsed += dt
		if elapsed >= 0.16 then elapsed = 0; send("Drive", throttle) end
	end
end)
send("Sync")
print("[AM Theory] Client ready.")
