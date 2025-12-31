-- [[ GGPVP | BY DNLL & SIX ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("GGPVP | BY DNLL & SIX", "DarkTheme")

--// CONFIGURAÇÕES GLOBAIS
_G.Aimbot = false
_G.TargetPart = "Head"
_G.Fov = 150
_G.WallCheck = true
_G.AimCheckMorto = true
_G.MaxDistance = 1000 -- Distância máxima inicial
_G.Smoothness = 0.2

_G.ESP_Master = false
_G.ESP_Box = false
_G.ESP_Name = false
_G.ESP_Health = false
_G.ESP_Distance = false

_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 50
_G.MenuKey = Enum.KeyCode.Home

_G.FovColor = Color3.fromRGB(0, 255, 255)
_G.BoxColor = Color3.fromRGB(255, 0, 0)
_G.HealthColor = Color3.fromRGB(0, 255, 0)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// NOTIFICAÇÃO
local function Notify(text)
    local sg = Instance.new("ScreenGui", CoreGui)
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.Position = UDim2.new(1, -230, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", frame)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = "⚡ " .. text
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    task.delay(4, function() sg:Destroy() end)
end

Notify("GGPVP CARREGADO!")

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.7
FOVCircle.Visible = true

--// TECLA PARA MINIMIZAR
local MenuVisible = true
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == _G.MenuKey then
        MenuVisible = not MenuVisible
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui:FindFirstChild("Main") or gui:FindFirstChild("Container")) then
                gui.Enabled = MenuVisible
            end
        end
    end
end)

--// SISTEMA ESP (COM LIMPEZA)
local ESP_Elements = {}

local function RemoveESP(plr)
    if ESP_Elements[plr] then
        for _, drawing in pairs(ESP_Elements[plr]) do
            drawing:Remove()
        end
        ESP_Elements[plr] = nil
    end
end

local function CreateESP(plr)
    if ESP_Elements[plr] then return end
    ESP_Elements[plr] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Dist = Drawing.new("Text")
    }
    local e = ESP_Elements[plr]
    e.Box.Thickness = 1
    e.Name.Size = 14; e.Name.Center = true; e.Name.Outline = true
    e.Health.Size = 14; e.Health.Center = true; e.Health.Outline = true
    e.Dist.Size = 14; e.Dist.Center = true; e.Dist.Outline = true
end

-- Limpa quando alguém sai
Players.PlayerRemoving:Connect(RemoveESP)

--// VALIDAÇÃO
local function Validate(part)
    if not part or not part.Parent then return false end
    local char = part.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not root or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude > _G.MaxDistance) then return false end
    if _G.AimCheckMorto and (not hum or hum.Health <= 0) then return false end
    
    if _G.WallCheck then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LP.Character, char}
        local cast = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
        if cast then return false end
    end
    return true
end

local function GetClosest()
    local target, shortest = nil, _G.Fov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(_G.TargetPart) then
            local part = v.Character[_G.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and Validate(part) then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < shortest then shortest = mag; target = part end
            end
        end
    end
    return target
end

----------------------------------------------------
-- INTERFACE
----------------------------------------------------
local Combat = Window:NewTab("Combate")
local CSect = Combat:NewSection("Aimbot Supreme")
CSect:NewToggle("Ativar Aimbot", "Mira automática", function(v) _G.Aimbot = v end)
CSect:NewDropdown("Focar em:", "Parte do corpo", {"Head", "UpperTorso", "HumanoidRootPart"}, function(v) _G.TargetPart = v end)
CSect:NewToggle("Wall Check", "Verifica paredes", function(v) _G.WallCheck = v end)
CSect:NewToggle("Aim Check Morto", "Ignora jogadores mortos", function(v) _G.AimCheckMorto = v end)
CSect:NewSlider("Distância Máxima", "Alcance Geral", 5000, 100, function(v) _G.MaxDistance = v end)
CSect:NewSlider("Raio do FOV", "Tamanho do círculo", 800, 50, function(v) _G.Fov = v end)
CSect:NewSlider("Suavidade", "Smoothness", 100, 1, function(v) _G.Smoothness = v/100 end)

local Visual = Window:NewTab("Visual")
local VSect = Visual:NewSection("ESP Completo")
VSect:NewToggle("Mestre ESP", "Ativar visual", function(v) _G.ESP_Master = v end)
VSect:NewToggle("Mostrar Box", "Quadrado", function(v) _G.ESP_Box = v end)
VSect:NewToggle("Mostrar Nome", "Nomes", function(v) _G.ESP_Name = v end)
VSect:NewToggle("Mostrar Vida", "HP", function(v) _G.ESP_Health = v end)
VSect:NewToggle("Mostrar Distância", "Metros", function(v) _G.ESP_Distance = v end)

local Troll = Window:NewTab("Troll")
local TSect = Troll:NewSection("Movimentação")
TSect:NewSlider("Velocidade", "WalkSpeed", 500, 16, function(v) _G.Speed = v end)
TSect:NewToggle("Voar", "Ativar Fly", function(v) _G.Fly = v end)
TSect:NewSlider("Velocidade Voo", "FlySpeed", 500, 10, function(v) _G.FlySpeed = v end)

local Config = Window:NewTab("Configuração")
local ConfSect = Config:NewSection("Ajustes Visuais")
ConfSect:NewKeybind("Abrir/Fechar Menu", "Trocar tecla", Enum.KeyCode.Home, function(key) _G.MenuKey = key end)
ConfSect:NewColorPicker("Cor do FOV", "Círculo", Color3.fromRGB(0, 255, 255), function(c) _G.FovColor = c end)
ConfSect:NewColorPicker("Cor do Box", "Quadrado ESP", Color3.fromRGB(255, 0, 0), function(c) _G.BoxColor = c end)
ConfSect:NewColorPicker("Cor da Vida", "Texto HP", Color3.fromRGB(0, 255, 0), function(c) _G.HealthColor = c end)

----------------------------------------------------
-- LOOPS
----------------------------------------------------
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = _G.Fov
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Color = _G.FovColor

    if _G.Aimbot then
        local target = GetClosest()
        if target then
            local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            if onScreen then
                mousemoverel((pos.X - center.X) * _G.Smoothness, (pos.Y - center.Y) * _G.Smoothness)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), _G.Smoothness)
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            if not ESP_Elements[p] then CreateESP(p) end
            local e = ESP_Elements[p]
            local char = p.Character
            
            if _G.ESP_Master and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local root, hum = char.HumanoidRootPart, char.Humanoid
                local pos, on = Camera:WorldToViewportPoint(root.Position)
                local dist = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")) and (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude or 0
                
                if on and hum.Health > 0 and dist <= _G.MaxDistance then
                    local size = 2000 / pos.Z
                    e.Box.Visible = _G.ESP_Box; e.Box.Size = Vector2.new(size, size * 1.5); e.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2); e.Box.Color = _G.BoxColor
                    e.Name.Visible = _G.ESP_Name; e.Name.Text = p.Name; e.Name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    e.Health.Visible = _G.ESP_Health; e.Health.Text = "HP: "..math.floor(hum.Health); e.Health.Position = Vector2.new(pos.X, pos.Y + size/2 + 5); e.Health.Color = _G.HealthColor
                    e.Dist.Visible = _G.ESP_Distance; e.Dist.Text = math.floor(dist).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y + size/2 + 20)
                else
                    e.Box.Visible = false; e.Name.Visible = false; e.Health.Visible = false; e.Dist.Visible = false
                end
            elseif e then
                e.Box.Visible = false; e.Name.Visible = false; e.Health.Visible = false; e.Dist.Visible = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if _G.Fly and root then
            local bv = root:FindFirstChild("FlyForce") or Instance.new("BodyVelocity", root)
            bv.Name = "FlyForce"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            local vel = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then vel += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then vel -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then vel -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then vel += Camera.CFrame.RightVector end
            bv.Velocity = vel * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyForce") then
            root.FlyForce:Destroy()
        end
    end
end)
