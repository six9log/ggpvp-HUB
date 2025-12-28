-- [[ GGPVP PC - SUPREME V2 | STABLE EDITION ]]

local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("🎯 GGPVP | PC SUPREME", "DarkTheme")

--// SERVIÇOS
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--// CONFIG
_G.Aimbot = false
_G.TargetPart = "Head"
_G.FovRadius = 150
_G.FovVisible = false -- Começa desligado
_G.Smoothness = 1
_G.MaxAimDistance = 2000
_G.WallCheck = false

_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 20

_G.ESP_Enabled = false
_G.ESP_Boxes = false
_G.ESP_Names = false
_G.ESP_Health = false

_G.MenuKey = Enum.KeyCode.RightControl

--// FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(0,255,255)

----------------------------------------------------
-- WALL CHECK (REVISADO)
----------------------------------------------------
local function IsVisible(part)
	if not _G.WallCheck then return true end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	-- Ignora você e o personagem do alvo para o raio não bater no "braço" dele e cancelar a mira
	params.FilterDescendantsInstances = {LP.Character, part.Parent}
	params.IgnoreWater = true

	local origin = Camera.CFrame.Position
	local dir = (part.Position - origin)
	local result = workspace:Raycast(origin, dir, params)

	return result == nil
end

----------------------------------------------------
-- TARGET (ULTRA STICKY)
----------------------------------------------------
local function GetClosestTarget()
	local closest, shortest = nil, _G.FovRadius
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			local part = p.Character:FindFirstChild(_G.TargetPart)

			if hum and root and part and hum.Health > 0 then
				local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
				if onscreen then
					local dist = (Vector2.new(pos.X,pos.Y)-center).Magnitude
					local worldDist = (LP.Character.HumanoidRootPart.Position-root.Position).Magnitude

					if dist < shortest and worldDist <= _G.MaxAimDistance then
						if IsVisible(part) then
							shortest = dist
							closest = part
						end
					end
				end
			end
		end
	end
	return closest
end

----------------------------------------------------
-- UI
----------------------------------------------------
local Main = Window:NewTab("Combate")
local Visuals = Window:NewTab("Visuals")
local Trol = Window:NewTab("Trol")
local Config = Window:NewTab("Configurações")

Main:NewSection("Aimbot")
	:NewToggle("Ativar Aimbot","",function(v) _G.Aimbot = v end)
	:NewToggle("Wall Check","",function(v) _G.WallCheck = v end)
    :NewToggle("Exibir FOV","",function(v) _G.FovVisible = v end) -- Adicionado para funcionar
	:NewDropdown("Parte do Corpo","",{"Head","HumanoidRootPart"},function(v) _G.TargetPart = v end)
	:NewSlider("FOV","",800,50,function(v) _G.FovRadius = v end)
	:NewSlider("Grude (Smooth)","100 = instantâneo",100,1,function(v) _G.Smoothness = v/100 end)

Trol:NewSection("Movimentação")
	:NewSlider("Speed","",50,16,function(v) _G.Speed = v end)
	:NewToggle("Fly","",function(v) _G.Fly = v end)
	:NewSlider("Fly Speed","",200,20,function(v) _G.FlySpeed = v end)

Visuals:NewSection("ESP")
	:NewToggle("Ativar ESP","",function(v) _G.ESP_Enabled = v end)
	:NewToggle("Boxes","",function(v) _G.ESP_Boxes = v end)
	:NewToggle("Nomes","",function(v) _G.ESP_Names = v end)
	:NewToggle("Vida","",function(v) _G.ESP_Health = v end)

Config:NewSection("Sistema")
	:NewKeybind("Menu","",_G.MenuKey,function(k) _G.MenuKey = k end)
	:NewButton("Kill Script","",function()
		_G.Aimbot = false
		_G.ESP_Enabled = false
		_G.Fly = false
        _G.FovVisible = false
		FOVCircle:Destroy()
		pcall(function()
			local ui = CoreGui:FindFirstChild("🎯 GGPVP | PC SUPREME")
			if ui then ui:Destroy() end
		end)
	end)

----------------------------------------------------
-- LOOPS
----------------------------------------------------
RunService.RenderStepped:Connect(function()
	FOVCircle.Visible = _G.FovVisible
	FOVCircle.Radius = _G.FovRadius
	FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)

	if _G.Aimbot then
		local target = GetClosestTarget()
		if target then
            -- Travamento direto para grudar como chiclete
			local cf = CFrame.new(Camera.CFrame.Position, target.Position)
			Camera.CFrame = Camera.CFrame:Lerp(cf, _G.Smoothness)
		end
	end
end)

-- SPEED + FLY (Heartbeat é melhor para física)
RunService.Heartbeat:Connect(function()
	local char = LP.Character
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	hum.WalkSpeed = _G.Speed

	if _G.Fly then
		if not root:FindFirstChild("FlyForce") then
			local bv = Instance.new("BodyVelocity")
			bv.Name = "FlyForce"
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.Parent = root
		end
		local vel = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then vel += Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then vel -= Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then vel -= Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then vel += Camera.CFrame.RightVector end
		root.FlyForce.Velocity = vel * _G.FlySpeed
	else
		if root:FindFirstChild("FlyForce") then
			root.FlyForce:Destroy()
		end
	end
end)

----------------------------------------------------
-- ESP GLOBAL
----------------------------------------------------
local ESPObjects = {}

RunService.RenderStepped:Connect(function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			local char = p.Character
			if not ESPObjects[p] then
				ESPObjects[p] = {
					Box = Drawing.new("Square"),
					Text = Drawing.new("Text")
				}
				ESPObjects[p].Box.Thickness = 1
				ESPObjects[p].Box.Filled = false
                ESPObjects[p].Box.Color = Color3.fromRGB(255,255,255)
				ESPObjects[p].Text.Size = 14
				ESPObjects[p].Text.Center = true
				ESPObjects[p].Text.Outline = true
                ESPObjects[p].Text.Color = Color3.fromRGB(255,255,255)
			end

			local esp = ESPObjects[p]
			if _G.ESP_Enabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
				local pos, on = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
				if on then
					local size = 2000/pos.Z
					esp.Box.Visible = _G.ESP_Boxes
					esp.Box.Size = Vector2.new(size,size*1.2)
					esp.Box.Position = Vector2.new(pos.X-size/2,pos.Y-size/2)

					esp.Text.Visible = _G.ESP_Names or _G.ESP_Health
					esp.Text.Text = p.Name.." ["..math.floor(char.Humanoid.Health).."]"
					esp.Text.Position = Vector2.new(pos.X,pos.Y-size/2-15)
				else
					esp.Box.Visible = false
					esp.Text.Visible = false
				end
			else
				esp.Box.Visible = false
				esp.Text.Visible = false
			end
		end
	end
end)

-- MENU TOGGLE
UIS.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == _G.MenuKey then
		local ui = CoreGui:FindFirstChild("🎯 GGPVP | PC SUPREME")
		if ui then ui.Enabled = not ui.Enabled end
	end
end)
