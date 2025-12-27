local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("GGPVP HUB", "DarkTheme")

-- [[ SERVIÇOS ]]
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- [[ VARIÁVEIS GLOBAIS ]]
_G.AimbotEnabled = false
_G.AimbotSmoothness = 0 
_G.WallCheck = true -- Agora padrão ativado
_G.MaxAimDistance = 1000 -- Nova variável de distância
_G.NoRecoil = false
_G.FOVSize = 150
_G.GodMode = false
_G.Noclip = false
_G.FlyEnabled = false
_G.FlySpeed = 50
_G.WalkSpeedValue = 16
_G.ESP_Box = false
_G.ESP_Skeleton = false
_G.ESP_Distance = false

-- [[ BOTÃO MOBILE FIX ]]
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
ScreenGui.Parent = game:GetService("CoreGui")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.Text = "GGPVP"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Draggable = true
ToggleButton.Active = true

local function toggleUI()
    local gui = game:GetService("CoreGui"):FindFirstChild("KavoConfigGui") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("KavoConfigGui")
    if gui then gui.Enabled = not gui.Enabled end
end
ToggleButton.MouseButton1Click:Connect(toggleUI)

-- [[ LÓGICA DE VISIBILIDADE (WALL CHECK) ]]
local function IsVisible(TargetPart)
    local Character = LocalPlayer.Character
    if not Character then return false end
    
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = {Character, Camera}
    
    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit * (TargetPart.Position - Camera.CFrame.Position).Magnitude
    local Result = workspace:Raycast(Camera.CFrame.Position, Direction, Params)
    
    if Result then
        return Result.Instance:IsDescendantOf(TargetPart.Parent)
    end
    return true
end

-- [[ BUSCA DE ALVO ]]
local function GetClosest()
    local target = nil
    local shortestDist = _G.FOVSize
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local head = v.Character.Head
            local pos, screen = Camera:WorldToViewportPoint(head.Position)
            
            if screen then
                local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                local worldDist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                
                -- Verifica FOV + Distância do Slider + Se está atrás da parede
                if mouseDist < shortestDist and worldDist <= _G.MaxAimDistance then
                    if IsVisible(head) then
                        shortestDist = mouseDist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- [[ LOOP PRINCIPAL ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1

RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = _G.FOVSize
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Visible = _G.AimbotEnabled

    if _G.AimbotEnabled then
        local t = GetClosest()
        if t then
            local look = CFrame.new(Camera.CFrame.Position, t.Position + (t.Velocity * 0.12))
            Camera.CFrame = Camera.CFrame:Lerp(look, 1 - _G.AimbotSmoothness)
        end
    end
    
    if _G.NoRecoil and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        Camera.CFrame = Camera.CFrame
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if _G.GodMode then LocalPlayer.Character.Humanoid.Health = 100 end
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
    end
end)

-- [[ FLY & NOCLIP ]]
local bv, bg
RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    
    if _G.FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if not bv then
            bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(1,1,1)*math.huge
            bg = Instance.new("BodyGyro", root); bg.MaxTorque = Vector3.new(1,1,1)*math.huge
        end
        bg.CFrame = Camera.CFrame
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        bv.Velocity = dir * _G.FlySpeed
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
    end
end)

-- [[ ESP ]]
local function MakeESP(plr)
    local box = Drawing.new("Square"); box.Color = Color3.fromRGB(255, 0, 0); box.Thickness = 1
    local distText = Drawing.new("Text"); distText.Color = Color3.fromRGB(255, 255, 255); distText.Size = 15; distText.Center = true
    local line = Drawing.new("Line"); line.Color = Color3.fromRGB(255, 255, 255); line.Thickness = 1

    RunService.RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 and plr ~= LocalPlayer then
            local root = plr.Character.HumanoidRootPart
            local pos, screen = Camera:WorldToViewportPoint(root.Position)
            if screen then
                box.Visible = _G.ESP_Box
                box.Size = Vector2.new(2000/pos.Z, 2500/pos.Z)
                box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                
                distText.Visible = _G.ESP_Distance
                distText.Position = Vector2.new(pos.X, pos.Y + (box.Size.Y/2))
                distText.Text = tostring(math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)) .. "m"
                
                if _G.ESP_Skeleton and plr.Character:FindFirstChild("Head") then
                    line.Visible = true
                    line.From = Vector2.new(pos.X, pos.Y)
                    line.To = Vector2.new(Camera:WorldToViewportPoint(plr.Character.Head.Position).X, Camera:WorldToViewportPoint(plr.Character.Head.Position).Y)
                else line.Visible = false end
            else box.Visible = false; distText.Visible = false; line.Visible = false end
        else box.Visible = false; distText.Visible = false; line.Visible = false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do MakeESP(v) end
Players.PlayerAdded:Connect(MakeESP)

-- [[ INTERFACE ]]
local Combat = Window:NewTab("Combate")
local CombatSec = Combat:NewSection("Aimbot Supreme")
CombatSec:NewToggle("Ativar Aimbot", "Mira automática", function(s) _G.AimbotEnabled = s end)
CombatSec:NewToggle("No Recoil", "Câmera Parada", function(s) _G.NoRecoil = s end)
CombatSec:NewSlider("Distância Máxima Mira", "Alcance do Aimbot", 5000, 100, function(s) _G.MaxAimDistance = s end)
CombatSec:NewSlider("Suavidade (Smooth)", "Lentidão da mira", 100, 0, function(s) _G.AimbotSmoothness = s/100 end)
CombatSec:NewSlider("Raio do FOV", "Área de detecção", 800, 30, function(s) _G.FOVSize = s end)

local Troll = Window:NewTab("Troll")
local TrollSec = Troll:NewSection("Modificações")
TrollSec:NewToggle("Ativar Fly (Vôo)", "Pode voar pelo mapa", function(s) _G.FlyEnabled = s end)
TrollSec:NewSlider("Velocidade Fly", "Vôo", 300, 50, function(s) _G.FlySpeed = s end)
TrollSec:NewToggle("Noclip", "Atravessar Paredes", function(s) _G.Noclip = s end)
TrollSec:NewSlider("Velocidade Andar", "Walkspeed", 250, 16, function(s) _G.WalkSpeedValue = s end)
TrollSec:NewToggle("God Mode", "Vida 100%", function(s) _G.GodMode = s end)

local Visual = Window:NewTab("Visual")
local VisualSec = Visual:NewSection("ESP Settings")
VisualSec:NewToggle("ESP Box", "Caixa vermelha", function(s) _G.ESP_Box = s end)
VisualSec:NewToggle("ESP Skeleton", "Linha branca", function(s) _G.ESP_Skeleton = s end)
VisualSec:NewToggle("ESP Distancia", "Metros (Branco)", function(s) _G.ESP_Distance = s end)

local Config = Window:NewTab("Config")
Config:NewSection("Ajustes")
Config:NewButton("Destruir Script", "Limpar", function() ScreenGui:Destroy(); FOVCircle:Remove(); Library:Destroy() end)

Library:Notify("GGPVP HUB", "Tudo configurado! WallCheck e Fly prontos.", 5)
