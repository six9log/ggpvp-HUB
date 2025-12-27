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
_G.WallCheck = true
_G.NoRecoil = false
_G.FOVSize = 150
_G.MaxDistance = 2000
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
ToggleButton.Text = "ABRIR"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Draggable = true
ToggleButton.Active = true

local function toggleUI()
    local gui = game:GetService("CoreGui"):FindFirstChild("KavoConfigGui") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("KavoConfigGui")
    if gui then
        gui.Enabled = not gui.Enabled
    end
end
ToggleButton.MouseButton1Click:Connect(toggleUI)

-- [[ FUNÇÃO WALL CHECK & ALVO ]]
local function IsValid(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
        if _G.WallCheck then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local ray = Camera:ViewportPointToRay(Camera:WorldToViewportPoint(head.Position).X, Camera:WorldToViewportPoint(head.Position).Y)
                local part = workspace:FindPartOnRayWithIgnoreList(Ray.new(ray.Origin, ray.Direction * 2000), {LocalPlayer.Character, Camera})
                return part and part:IsDescendantOf(plr.Character)
            end
        else
            return true
        end
    end
    return false
end

local function GetClosest()
    local target = nil
    local dist = _G.FOVSize
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team and IsValid(v) then
            local pos, screen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if screen then
                local mdist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mdist < dist then
                    dist = mdist
                    target = v.Character.Head
                end
            end
        end
    end
    return target
end

-- [[ LOOPS ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
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

RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- [[ ESP ]]
local function MakeESP(plr)
    local box = Drawing.new("Square"); box.Color = Color3.fromRGB(255, 0, 0); box.Thickness = 1
    local dist = Drawing.new("Text"); dist.Color = Color3.fromRGB(255, 255, 255); dist.Size = 15; dist.Center = true
    local line = Drawing.new("Line"); line.Color = Color3.fromRGB(255, 255, 255); line.Thickness = 1

    RunService.RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 and plr ~= LocalPlayer then
            local root = plr.Character.HumanoidRootPart
            local pos, screen = Camera:WorldToViewportPoint(root.Position)
            if screen then
                box.Visible = _G.ESP_Box
                box.Size = Vector2.new(2000/pos.Z, 2500/pos.Z)
                box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                
                dist.Visible = _G.ESP_Distance
                dist.Position = Vector2.new(pos.X, pos.Y + (box.Size.Y/2))
                dist.Text = tostring(math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)) .. "m"
                
                if _G.ESP_Skeleton and plr.Character:FindFirstChild("Head") then
                    line.Visible = true
                    line.From = Vector2.new(pos.X, pos.Y)
                    line.To = Vector2.new(Camera:WorldToViewportPoint(plr.Character.Head.Position).X, Camera:WorldToViewportPoint(plr.Character.Head.Position).Y)
                else line.Visible = false end
            else box.Visible = false; dist.Visible = false; line.Visible = false end
        else box.Visible = false; dist.Visible = false; line.Visible = false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do MakeESP(v) end
Players.PlayerAdded:Connect(MakeESP)

-- [[ MENU UI ]]
local Combat = Window:NewTab("Combate")
local CombatSec = Combat:NewSection("Aimbot & Recoil")
CombatSec:NewToggle("Ativar Aimbot", "Mira automática", function(s) _G.AimbotEnabled = s end)
CombatSec:NewToggle("Wall Check", "Não foca atrás da parede", function(s) _G.WallCheck = s end)
CombatSec:NewToggle("No Recoil", "Câmera Parada", function(s) _G.NoRecoil = s end)
CombatSec:NewSlider("Suavidade (Smooth)", "Lentidão da mira", 100, 0, function(s) _G.AimbotSmoothness = s/100 end)
CombatSec:NewSlider("Raio do FOV", "Área de detecção", 800, 30, function(s) _G.FOVSize = s end)

local Troll = Window:NewTab("Troll")
local TrollSec = Troll:NewSection("Modificações")
TrollSec:NewToggle("God Mode", "Vida 100%", function(s) _G.GodMode = s end)
TrollSec:NewToggle("Noclip", "Atravessar Paredes", function(s) _G.Noclip = s end)
TrollSec:NewSlider("Velocidade Andar", "Walkspeed", 250, 16, function(s) _G.WalkSpeedValue = s end)
TrollSec:NewSlider("Velocidade Fly", "Vôo", 300, 50, function(s) _G.FlySpeed = s end)

local Visual = Window:NewTab("Visual")
local VisualSec = Visual:NewSection("ESP Settings")
VisualSec:NewToggle("ESP Box", "Caixa vermelha", function(s) _G.ESP_Box = s end)
VisualSec:NewToggle("ESP Skeleton", "Linha branca", function(s) _G.ESP_Skeleton = s end)
VisualSec:NewToggle("ESP Distancia", "Metros (Branco)", function(s) _G.ESP_Distance = s end)

local Config = Window:NewTab("Config")
Config:NewSection("Ajustes")
Config:NewButton("Destruir Script", "Limpar", function() ScreenGui:Destroy(); FOVCircle:Remove(); Library:Destroy() end)
