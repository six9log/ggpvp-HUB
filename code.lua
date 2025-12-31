-- [[ GGPVP | BY DNLL & SIX ]]
-- Versão Salva na Nuvem (Kavo UI - Estabilizada)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

--// CONFIGURAÇÕES GLOBAIS
_G.Aimbot = false
_G.TargetPart = "Head"
_G.Fov = 150
_G.WallCheck = true
_G.AimCheckMorto = true
_G.MaxDistance = 1000
_G.Smoothness = 0.2

_G.ESP_Master = false
_G.ESP_Box = false
_G.ESP_Name = false
_G.ESP_Health = false
_G.ESP_Distance = false

_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 50
_G.FlyKey = Enum.KeyCode.F
_G.MenuKey = Enum.KeyCode.Home
_G.Crashing = false

_G.FovColor = Color3.fromRGB(0, 255, 255)
_G.BoxColor = Color3.fromRGB(255, 0, 0)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// 1. TELA DE CARREGAMENTO (PRESERVADA)
local loader = Instance.new("ScreenGui", CoreGui)
local mainFrame = Instance.new("Frame", loader)
mainFrame.Size = UDim2.new(0, 300, 0, 100)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", mainFrame)
local loadTxt = Instance.new("TextLabel", mainFrame)
loadTxt.Size = UDim2.new(1, 0, 1, 0)
loadTxt.Text = "CARREGANDO GGPVP..."
loadTxt.TextColor3 = Color3.fromRGB(0, 255, 255)
loadTxt.Font = Enum.Font.GothamBold
loadTxt.TextSize = 18
loadTxt.BackgroundTransparency = 1
task.wait(1)
loader:Destroy()

--// 2. NOTIFICAÇÃO
local function Notify(msg)
    local sg = Instance.new("ScreenGui", CoreGui)
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 220, 0, 45)
    frame.Position = UDim2.new(1, -230, 1, -55)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "⚡ " .. msg
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1
    task.delay(3, function() sg:Destroy() end)
end

Notify("CHEAT ATIVADO COM SUCESSO")

--// 3. JANELA PRINCIPAL
local Window = Library.CreateLib("GGPVP | BY DNLL & SIX", "DarkTheme")

--// 4. FOV DRAWING
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.5
FOVCircle.Visible = true

--// 5. ABAS (COMBATE / VISUAL / TROLL / CONFIG)
local Combat = Window:NewTab("Combate")
local CSect = Combat:NewSection("Aimbot Supreme")
CSect:NewToggle("Ativar Aimbot", "Mira automática", function(v) _G.Aimbot = v end)
CSect:NewDropdown("Focar em:", "Parte do corpo", {"Head", "UpperTorso", "HumanoidRootPart"}, function(v) _G.TargetPart = v end)
CSect:NewToggle("Wall Check", "Verifica paredes", function(v) _G.WallCheck = v end)
CSect:NewToggle("Aim Check Morto", "Ignora mortos", function(v) _G.AimCheckMorto = v end)
CSect:NewSlider("Distância Máxima", "Alcance", 5000, 100, function(v) _G.MaxDistance = v end)
CSect:NewSlider("Raio do FOV", "Tamanho", 800, 50, function(v) _G.Fov = v end)
CSect:NewSlider("Suavidade", "Smoothness", 100, 1, function(v) _G.Smoothness = v/100 end)

local Visual = Window:NewTab("Visual")
local VSect = Visual:NewSection("ESP Completo")
VSect:NewToggle("Mestre ESP", "Ligar Visual", function(v) _G.ESP_Master = v end)
VSect:NewToggle("Mostrar Box", "Quadrados", function(v) _G.ESP_Box = v end)
VSect:NewToggle("Mostrar Nome", "Nomes", function(v) _G.ESP_Name = v end)
VSect:NewToggle("Mostrar Vida", "HP Verde", function(v) _G.ESP_Health = v end)
VSect:NewToggle("Mostrar Distância", "Metros", function(v) _G.ESP_Distance = v end)

local Troll = Window:NewTab("Troll")
local TSect = Troll:NewSection("Movimentação & Server")
TSect:NewSlider("Velocidade", "WalkSpeed", 500, 16, function(v) _G.Speed = v end)

local FlyToggle = TSect:NewToggle("Ativar Fly", "Voar (WASD)", function(v) _G.Fly = v end)
TSect:NewSlider("Velocidade do Voo", "Fly Speed", 500, 10, function(v) _G.FlySpeed = v end)
TSect:NewKeybind("Bind do Fly", "Atalho teclado", Enum.KeyCode.F, function(key) _G.FlyKey = key end)

TSect:NewButton("CRASH SERVER", "Lag Extreme", function()
    _G.Crashing = not _G.Crashing
    task.spawn(function()
        while _G.Crashing do
            local rs = game:GetService("ReplicatedStorage")
            for i = 1, 150 do
                local r = rs:FindFirstChildOfClass("RemoteEvent")
                if r then r:FireServer("Crash", string.rep("GGPVP", 1000)) end
            end
            task.wait()
        end
    end)
end)

local Config = Window:NewTab("Config")
local ConfSect = Config:NewSection("Ajustes de Sistema")
ConfSect:NewKeybind("Tecla do Menu", "Minimizar", Enum.KeyCode.Home, function(key) _G.MenuKey = key end)
ConfSect:NewColorPicker("Cor do FOV", "Círculo", Color3.fromRGB(0, 255, 255), function(color) _G.FovColor = color end)
ConfSect:NewColorPicker("Cor Box (ESP)", "Quadrados", Color3.fromRGB(255, 0, 0), function(color) _G.BoxColor = color end)

--// 6. LÓGICA DE CONTROLE (O QUE SALVAMOS)
local MenuVisible = true
local function StopFly()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local root = LP.Character.HumanoidRootPart
        if root:FindFirstChild("FlyF") then root.FlyF:Destroy() end
        if root:FindFirstChild("FlyG") then root.FlyG:Destroy() end
    end
end

UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == _G.MenuKey then
        MenuVisible = not MenuVisible
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui:FindFirstChild("Main") or gui:FindFirstChild("Container")) then
                gui.Enabled = MenuVisible
            end
        end
        UIS.MouseIconEnabled = MenuVisible
        if not MenuVisible then UIS.MouseBehavior = Enum.MouseBehavior.Default end
    end
    
    if not gpe and input.KeyCode == _G.FlyKey then
        _G.Fly = not _G.Fly
        FlyToggle:UpdateToggle(_G.Fly)
        if not _G.Fly then StopFly() end
    end
end)

--// 7. FUNÇÕES DE SUPORTE (AIMBOT/ESP)
local function Validate(part)
    if not part or not part.Parent then return false end
    local char = part.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
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

local ESP_Elements = {}
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = _G.Fov
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Color = _G.FovColor

    if _G.Aimbot then
        local target, shortest = nil, _G.Fov
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild(_G.TargetPart) then
                local part = v.Character[_G.TargetPart]
                local pos, screen = Camera:WorldToViewportPoint(part.Position)
                if screen and Validate(part) then
                    local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                    if mag < shortest then shortest = mag; target = part end
                end
            end
        end
        if target then
            local pos = Camera:WorldToViewportPoint(target.Position)
            mousemoverel((pos.X - (Camera.ViewportSize.X/2)) * _G.Smoothness, (pos.Y - (Camera.ViewportSize.Y/2)) * _G.Smoothness)
        end
    end

    if _G.ESP_Master then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not ESP_Elements[p] then 
                    ESP_Elements[p] = {Box = Drawing.new("Square"), Name = Drawing.new("Text"), Health = Drawing.new("Text"), Dist = Drawing.new("Text")}
                end
                local e = ESP_Elements[p]
                local root, hum = p.Character.HumanoidRootPart, p.Character.Humanoid
                local pos, on = Camera:WorldToViewportPoint(root.Position)
                if on and hum.Health > 0 then
                    local s = 2000 / pos.Z
                    e.Box.Visible = _G.ESP_Box; e.Box.Size = Vector2.new(s, s*1.5); e.Box.Position = Vector2.new(pos.X-s/2, pos.Y-s/2); e.Box.Color = _G.BoxColor
                    e.Name.Visible = _G.ESP_Name; e.Name.Text = p.Name; e.Name.Position = Vector2.new(pos.X, pos.Y-s/2-15); e.Name.Center = true; e.Name.Outline = true
                    e.Health.Visible = _G.ESP_Health; e.Health.Text = "HP: "..math.floor(hum.Health); e.Health.Position = Vector2.new(pos.X, pos.Y+s/2+5); e.Health.Center = true; e.Health.Outline = true; e.Health.Color = Color3.fromRGB(0, 255, 0)
                    e.Dist.Visible = _G.ESP_Distance; e.Dist.Text = math.floor((LP.Character.HumanoidRootPart.Position-root.Position).Magnitude).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y+s/2+20); e.Dist.Center = true; e.Dist.Outline = true
                else e.Box.Visible = false; e.Name.Visible = false; e.Health.Visible = false; e.Dist.Visible = false end
            end
        end
    else
        for _, e in pairs(ESP_Elements) do e.Box.Visible = false; e.Name.Visible = false; e.Health.Visible = false; e.Dist.Visible = false end
    end
end)

--// 8. LOOP DE FÍSICA
RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if _G.Fly then
                local bv = root:FindFirstChild("FlyF") or Instance.new("BodyVelocity", root)
                bv.Name = "FlyF"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                local bg = root:FindFirstChild("FlyG") or Instance.new("BodyGyro", root)
                bg.Name = "FlyG"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                
                local v = Vector3.new(0, 0.1, 0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then v += Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then v -= Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then v -= Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then v += Camera.CFrame.RightVector end
                bv.Velocity = v * _G.FlySpeed
                bg.CFrame = Camera.CFrame
            else
                StopFly()
            end
        end
    end
end)
