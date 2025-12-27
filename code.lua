local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("GGPVP HUB - SUPREME", "DarkTheme")

-- [[ SERVIÇOS ]]
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- [[ CONFIGURAÇÕES GLOBAIS ]]
_G.AimbotEnabled = false
_G.AimbotSmoothness = 0 
_G.WallCheck = false
_G.NoRecoil = false
_G.InfiniteAmmo = false
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

-- [[ BOTÃO FLUTUANTE MOBILE (CORRIGIDO) ]]
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "GGPVP_Mobile"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "ABRIR"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 12
ToggleButton.Active = true
ToggleButton.Draggable = true 

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

-- Função de Abrir/Fechar Corrigida
ToggleButton.MouseButton1Click:Connect(function()
    Library:ToggleGui()
end)

-- [[ ANTI-AFK (NOVO) ]]
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- [[ CÍRCULO FOV ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Visible = true

-- [[ LÓGICA DE ALVO ]]
local function GetTarget()
    local Closest = nil
    local ShortestDistance = _G.FOVSize
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Team ~= LocalPlayer.Team then
            local Head = v.Character:FindFirstChild("Head") or v.Character:FindFirstChild("UpperTorso")
            if Head and v.Character:FindFirstChildOfClass("Humanoid") and v.Character.Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                if OnScreen then
                    local MouseDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                    local WorldDist = (LocalPlayer.Character.HumanoidRootPart.Position - Head.Position).Magnitude
                    if MouseDist < ShortestDistance and WorldDist <= _G.MaxDistance then
                        ShortestDistance = MouseDist
                        Closest = Head
                    end
                end
            end
        end
    end
    return Closest
end

-- [[ LOOP SUPREMO (TODAS AS FUNÇÕES) ]]
RunService.RenderStepped:Connect(function()
    -- FOV Update
    FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FOVCircle.Radius = _G.FOVSize
    
    -- Aimbot Preditivo
    if _G.AimbotEnabled then
        local Target = GetTarget()
        if Target then
            local Prediction = Target.Velocity * 0.12 
            local LookAt = CFrame.lookAt(Camera.CFrame.Position, Target.Position + Prediction)
            Camera.CFrame = Camera.CFrame:Lerp(LookAt, 1 - _G.AimbotSmoothness)
        end
    end
    
    -- No Recoil
    if _G.NoRecoil and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        Camera.CFrame = Camera.CFrame
    end

    -- God Mode & Speed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if _G.GodMode then LocalPlayer.Character.Humanoid.Health = 100 end
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
    end
end)

-- [[ MOVIMENTAÇÃO (FLY & NOCLIP) ]]
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

-- [[ VISUAL ESP ]]
local function CreateESP(Player)
    local Box = Drawing.new("Square"); local Dist = Drawing.new("Text")
    RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart; local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if OnScreen then
                if _G.ESP_Box then
                    Box.Size = Vector2.new(2000 / Pos.Z, 2500 / Pos.Z); Box.Position = Vector2.new(Pos.X - Box.Size.X/2, Pos.Y - Box.Size.Y/2)
                    Box.Visible = true; Box.Color = Color3.fromRGB(255, 0, 0)
                else Box.Visible = false end
                if _G.ESP_Distance then
                    Dist.Position = Vector2.new(Pos.X, Pos.Y + (2000 / Pos.Z / 2))
                    Dist.Text = math.floor((Root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m"
                    Dist.Visible = true; Dist.Center = true; Dist.Outline = true
                else Dist.Visible = false end
            else Box.Visible = false; Dist.Visible = false end
        else Box.Visible = false; Dist.Visible = false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- [[ ABAS DA INTERFACE ]]
local Combat = Window:NewTab("Combate")
local CombatSec = Combat:NewSection("Aimbot Supreme")
CombatSec:NewToggle("Ativar Aimbot", "Mira automática", function(s) _G.AimbotEnabled = s end)
CombatSec:NewSlider("Suavidade", "0=Grudar / 1=Suave", 100, 0, function(s) _G.AimbotSmoothness = s/100 end)
CombatSec:NewToggle("No Recoil", "Câmera estável", function(s) _G.NoRecoil = s end)
CombatSec:NewSlider("Raio FOV", "Área de mira", 800, 30, function(s) _G.FOVSize = s end)

local Troll = Window:NewTab("Troll")
local TrollSec = Troll:NewSection("Movimentação & God")
TrollSec:NewToggle("God Mode", "Vida Infinita", function(s) _G.GodMode = s end)
TrollSec:NewToggle("Noclip", "Atravessar Paredes", function(s) _G.Noclip = s end)
TrollSec:NewToggle("Fly", "Voar (W/S)", function(s) _G.FlyEnabled = s end)
TrollSec:NewSlider("Velocidade Fly", "Vôo", 300, 50, function(s) _G.FlySpeed = s end)
TrollSec:NewSlider("Velocidade Andar", "Walkspeed", 250, 16, function(s) _G.WalkSpeedValue = s end)

local Visual = Window:NewTab("Visual")
local VisualSec = Visual:NewSection("ESP")
VisualSec:NewToggle("Box ESP", "Quadrado", function(s) _G.ESP_Box = s end)
VisualSec:NewToggle("Distância", "Metros", function(s) _G.ESP_Distance = s end)

local Config = Window:NewTab("Config")
Config:NewSection("Ajustes")
Config:NewButton("Minimizar Menu", "Fecha a aba", function() Library:ToggleGui() end)
Config:NewButton("Destruir Script", "Remove tudo", function() 
    FOVCircle:Remove() 
    ScreenGui:Destroy()
    Library:Destroy() 
end)

Library:Notify("GGPVP SUPREME", "Botão ABRIR adicionado!", 5)
