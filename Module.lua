repeat 
	task.wait()
until game:IsLoaded() and game:GetService('Players') and game:GetService('Players').LocalPlayer

local Lighting: Lighting = game:GetService('Lighting')
local TeleportService: TeleportService = game:GetService('TeleportService')
local VirtualUser: VirtualUser = game:GetService('VirtualUser')
local RunService: RunService = game:GetService('RunService')
local HttpService: HttpService = game:GetService('HttpService')

local PlaceId: number = game.PlaceId
local JobId: string = game.JobId

local Library: any? = loadstring(game:HttpGet("https://raw.githubusercontent.com/96soul/Library/refs/heads/main/Main", true))()
local Folder: string = "Fetching'Script/Config/" .. game.Players.LocalPlayer.UserId .. "/" .. PlaceId .. ".json"
local Configs: any? = {}
local Indexing: string = {}
local Nets: any? = {}

local translate = function(en: string, th: string)
	if Configs['Lauguage'] == "ไทย" then
		return tostring(th)
	else
		return tostring(en)
	end
end

game.Players.LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController();
	VirtualUser:ClickButton2(Vector2.new());
end)

local Module: any = {} do
	Module.connect = function(Value: boolean, interval: number, func: any?, customFunc: any?)
		while Value do
			local startTick = tick()
			if func then func()  end
			if customFunc and customFunc() then break end
			repeat
				RunService.Heartbeat:Wait()
			until tick() - startTick >= (interval or 0.1) 
		end
	end

	function Module:again(fn): any
		return task.spawn(function()
			while task.wait(0.1) do
				fn()
			end
		end)
	end

	Module.alive = function(v)
		return typeof(v) == "Instance" and v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0
	end

	Module.hop = function()
		local ListServers = function(cursor: SharedTable) return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100" .. ((cursor and "&cursor="..cursor) or ""))) end
		local Server, Next
		repeat
			local Servers = ListServers(Next)
			Server = Servers.data[1]
			Next = Servers.nextPageCursor
		until Server;TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, game.Players.LocalPlayer)
	end

	Module.rj = function()
		if #game.Players:GetPlayers() <= 1 then
			game.Players.LocalPlayer:Kick("\nRejoining...")
			wait()
			TeleportService:Teleport(PlaceId, game.Players.LocalPlayer)
		else
			TeleportService:TeleportToPlaceInstance(PlaceId, JobId, game.Players.LocalPlayer)
		end
	end

	Module.html = function(text: string, color: Color3)
		if type(text) == "string" and typeof(color) == "Color3" then
			local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
			return string.format('<font color="rgb(%d, %d, %d)">%s</font>', r, g, b, text)
		end
		return text
	end

	Module.name = function()
		return tostring(game:GetService('MarketplaceService'):GetProductInfo(PlaceId).Name)
	end

	Module.esp = function(meta: Set?)
		local v = meta.Instance
		local title = meta.Name or v.Name
		local MainColor = meta.Color or Color3.fromRGB(255, 255, 255)
		local DropColor = meta.Drop or Color3.fromRGB(127, 127, 127)
		if not v:FindFirstChild('Constant') then
			local bill = Instance.new('BillboardGui',v)
			bill.Name = 'Constant'
			bill.Size = UDim2.fromOffset(100, 100)
			bill.MaxDistance = math.huge
			bill.Adornee = v
			bill.AlwaysOnTop = true

			local circle = Instance.new("Frame", bill)
			circle.Position = UDim2.fromScale(0.5, 0.5)
			circle.AnchorPoint = Vector2.new(0.5, 0.5)
			circle.Size = UDim2.fromOffset(6, 6)
			circle.BackgroundColor3 = Color3.fromRGB(255,255,255)

			local gradient = Instance.new("UIGradient", circle)
			gradient.Rotation = 90
			gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)})

			local stroke = Instance.new("UIStroke", circle)
			stroke.Thickness = 0.5

			local name = Instance.new('TextLabel',bill)
			name.Font = Enum.Font.GothamBold
			name.AnchorPoint = Vector2.new(0, 0.5)
			name.Size = UDim2.fromScale(1, 0.3)
			name.TextScaled = true
			name.BackgroundTransparency = 1
			name.TextStrokeTransparency = 0
			name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			name.Position = UDim2.new(0, 0, 0.5, 24)
			name.TextColor3 = Color3.fromRGB(255, 255, 255)
			name.Text = "nil"

			local gradient = Instance.new("UIGradient", name)
			gradient.Rotation = 0
			gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)})
		else
			if v:IsA("Model") then
				v:FindFirstChild('Constant'):FindFirstChild("TextLabel").Text = title .. '\n[ ' .. math.floor(tonumber((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v:GetPivot().Position).Magnitude / 3) + 1) .. ' ]'
			elseif v:IsA("BasePart") then
				v:FindFirstChild('Constant'):FindFirstChild("TextLabel").Text = title .. '\n[ ' .. math.floor(tonumber((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude / 3) + 1) .. ' ]'
			end
		end
	end

	Module.unesp = function(v: any?)
		if v:FindFirstChild('Constant') then
			v:FindFirstChild('Constant'):Destroy()
		end
	end

	Module.tablecheck = function(config: any, _table: string)
		for _,v in pairs(_table) do
			if config[v] == true then
				return true 
			end 
		end 
		return false 
	end

	Module.def = function(v: string, a: boolean | string | number | table | any)
		if type(v) == "table" then
			for i, k in pairs(v) do
				if Configs[i] == nil then
					Configs[i] = k
				end
			end
		else
			if Configs[v] == nil then
				Configs[v] = a
			end
		end
	end

	Module.save = function(key: string, value: boolean | string | number | table | any)
		if key ~= nil then Configs[key] = value;end
		if not isfolder("Fetching'Script") then makefolder("Fetching'Script");end
		writefile(Folder, HttpService:JSONEncode(Configs))
	end

	function Module:load()
		local base = "Fetching'Script/Config/" .. game.Players.LocalPlayer.UserId
		local path = base .. "/" .. PlaceId .. ".json"
		if not isfolder("Fetching'Script") then makefolder("Fetching'Script") end
		if not isfolder("Fetching'Script/Config") then makefolder("Fetching'Script/Config") end
		if not isfolder(base) then makefolder(base) end
		if not isfile(path) then Module.save() end
		return HttpService:JSONDecode(readfile(path))
	end

	Module.tab = function(window: table ,title: string, desc: string, icon: number)
		local Options = {
			Title = title,
			Desc = desc,
			Icon = icon
		}
		return window:Add(Options) 
	end

	Module.sec = function(tab: table ,title: string, desc: string)
		local Options = {
			Title = title,
			Side = desc
		}
		return tab:Sec(Options) 
	end

	Module.button = function(meta: any)
		local sec = meta.sec or false
		local Title = meta.title or "Title"
		local Icon = meta.icon or ""
		local Callback = meta.call or function() return end
		if Icon == "" then
			local Options = {
				Title = Title,
				Callback = Callback
			}
			return sec:Button(Options) 
		else
			local Options = {
				Title = Title,
				Icon = Icon,
				Callback = Callback
			}
			return sec:ButtomImage(Options)
		end
	end

	Module.toggle = function(meta: table)
		local Section = meta.sec
		local Title = meta.title or "Toggle"
		local Index = meta.index or false
		local Setting = meta.setting or ""
		local Callback = meta.call
		local C
		if Index and Setting ~= "" then
			if not table.find(Indexing, Setting) then
				table.insert(Indexing, Setting)
			end
		end
		local Options = {
			Title = Title,
			Value = Configs[Setting],
			Callback = function(value)
				Configs[Setting] = value
				Module.save(Setting, value)
				if value then
					C = task.spawn(function()
						if Nets[Setting] then
							Nets[Setting](Configs[Setting])
						end
					end)
				else
					if C then
						task.cancel(C)
					end
				end

				if typeof(Callback) == "function" then
					Callback(value)
				end
			end
		}
		if Section and typeof(Section.Toggle) == "function" then
			return Section:Toggle(Options)
		else
			warn("Invalid section or section:Toggle not found")
		end
	end

	Module.list = function(sec: table, title: string, list: table, m: boolean, setting: string)
		sec:Dropdown({Title = title,Multi = m,List = list,Value = Configs[setting],Callback = function(v)
			Configs[setting] = v
			Module.save(setting, v)
		end})
	end

	Module.def('X', 0)
	Module.def('Y', 0)
	Module.init = function()
		if Configs['X'] == 0 and Configs['Y'] == 0 then
			if game:GetService('UserInputService').KeyboardEnabled then
				return UDim2.new(0, 750, 0, 800)
			else
				return UDim2.new(0, 500, 0, 350)
			end
		else
			return UDim2.new(0, Configs['X'], 0, Configs['Y'])
		end
	end

	function Module:setup(window: table)
		local Home = window:Add({Title = translate("Configure", "คอนฟิกเกอร์"),Desc = translate("Managers", "ระบบหลัก"),Icon = 132831270943713}) do
			local Performance = Home:Sec({Title = translate("Performance", "ประสิทธิภาพ"), Side = "r"}) do
				Module.toggle({sec = Performance,title = translate("Enable White Screen", "เปิดใช้งานจอขาว"),setting = "White Screen",call = function(v)
					if v then
						RunService:Set3dRenderingEnabled(false)
					else
						RunService:Set3dRenderingEnabled(true)
					end
				end})
				Module.button({
					sec = Performance,
					title = translate("Boost FPS", "แก้แลค"),
					call = function()
						pcall(function()
							local Terrain = workspace:FindFirstChildOfClass('Terrain')
							Terrain.WaterWaveSize = 0
							Terrain.WaterWaveSpeed = 0
							Terrain.WaterReflectance = 0
							Terrain.WaterTransparency = 0
							game.Lighting.GlobalShadows = false
							game.Lighting.FogEnd = 9e9
							settings().Rendering.QualityLevel = 1
							for i,v in pairs(game:GetDescendants()) do
								if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
									v.Material = "Plastic"
									v.Reflectance = 0
								elseif v:IsA("Decal") then
									v.Transparency = 1
								elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
									v.Lifetime = NumberRange.new(0)
								elseif v:IsA("Explosion") then
									v.BlastPressure = 1
									v.BlastRadius = 1
								end
							end
							for i,v in pairs(Lighting:GetDescendants()) do
								if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
									v.Enabled = false
								end
							end
						end)	
					end
				})
			end

			local Server = Home:Sec({Title = translate("Server", "เซิร์ฟเวอร์"), Side = "r"}) do
				Module.def('Input JobID', JobId)
				Server:Textbox({Value = Configs["Input JobID"], Callback = function(v)
					Configs["Input JobID"] = v
					Module.save("Input JobID", v)
				end
				})
				Module.button({
					sec = Server,
					title = translate("Join", "เข้าร่วม"),
					call = function()
						TeleportService:TeleportToPlaceInstance(PlaceId, Configs['Input JobID'], game.Players.LocalPlayer)
					end
				})
				Module.button({
					sec = Server,
					title = translate("Clipboard JobId", "คัดลอกไอดี"),
					call = function()
						setclipboard(JobId)
					end
				})
				Module.button({
					sec = Server,
					title = translate("Rejoin", "รีจอยน์"),
					call = function()
						Module.rj()
					end})
				Module.button({
					sec = Server,
					title = translate("Change Server", "เปลี่ยนเซิร์ฟเวอร์"),
					call = function()
						Module.hop()
					end
				})
			end

			local Config = Home:Sec({Title = translate("Configs", "การตั้งค่า"), Side = "l"}) do
				Module.def('Lauguage', 'English [ Default ]')
				Module.toggle({sec = Config,title = translate("Keep Script", "ออโต้รันสคริปต์"), setting = "Keep Script"})
				Module.list(Config, translate("Language", 'เลือกภาษา'), {'ไทย', 'English [ Default ]'}, false, 'Lauguage')
				Module.button({
					sec = Config,
					title = translate("Change Language", "เปลี่ยนภาษา"),
					call = function()
						Module.rj()
					end
				})
				Config:Line()
				Module.button({
					sec = Config,
					title = translate("Remove Configs [ Only This Game ]", "ลบการตั้งค่า [ เฉพาะแมพนี้ ]"),
					call = function()
						delfile(Folder)
					end
				})
				Module.button({
					sec = Config,
					title = translate("Remove Configs [ All ]", "ลบการตั้งค่า [ ทุกแมพ ]"),
					call = function()
						if isfile("Fetching'Script/Config/" .. game.Players.LocalPlayer.UserId) then
							delfile("Fetching'Script/Config/" .. game.Players.LocalPlayer.UserId)
						else
							warn("Configs not found")
						end
					end
				})
			end
		end

		local TeleportCheck = false
		game.Players.LocalPlayer.OnTeleport:Connect(function(State)
			if Configs['Keep Script'] and (not TeleportCheck) and queueonteleport then
				TeleportCheck = true
				queueonteleport("loadstring(game:HttpGet('https://github.com/96soul/-/blob/main/load.gg?raw=true', true))()")
			end
		end)

		do repeat wait() until game:GetService("CoreGui").lnwza.Background
			game:GetService("CoreGui").lnwza.Background:GetPropertyChangedSignal("Size"):Connect(function()
				local size = game:GetService("CoreGui").lnwza.Background.Size
				Module.save('X', size.X.Offset)
				Module.save('Y', size.Y.Offset)
			end)
		end

		return Home
	end
end

Configs = Module:load()

return table.unpack({
	Module,
	Nets,
	Configs,
	Indexing,
	translate,
	Library,
})
