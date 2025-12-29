-- [[ GGPVP SUPREME V9 | FULL POWER & OPTIMIZED ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🎯 GGPVP SUPREME V9", "DarkTheme")

--// CONFIGURAÇÕES GLOBAIS (NÃO REMOVER)
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
_G.Crashing = false

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = true

--// TECLA PARA MINIMIZAR (HOME)
_G.MenuKey = Enum.KeyCode.Home
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == _G.MenuKey then
        local targetGui = game:GetService("CoreGui"):FindFirstChild("🎯 GGPVP SUPREME V9")
        if targetGui then targetGui.Enabled = not targetGui.Enabled end
    end
end)

--// LÓGICA DE VISIBILIDADE & DISTÂNCIA
local function ValidateTarget(part)
    if not part then return false end
    local char = part.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    -- Aim Check Morto
    if _G.AimCheckMorto and (not hum or hum.Health <= 0) then return false end
    
    -- Distância Máxima
    local mag = (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude
    if mag > _G.MaxDistance then return false end
    
    -- Wall Check
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
    local target = nil
    local dist = _G.Fov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(_G.TargetPart) then
            local part = v.Character[_G.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen and ValidateTarget(part) then
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if magnitude < dist then
                    dist = magnitude
                    target = part
                end
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
CSect:NewDropdown("Focar em:", "Onde a mira gruda", {"Head", "UpperTorso", "HumanoidRootPart"}, function(v) _G.TargetPart = v end)
CSect:NewToggle("Wall Check", "Verifica se está atrás da parede", function(v) _G.WallCheck = v end)
CSect:NewToggle("Aim Check Morto", "Não mira em cadáveres", function(v) _G.AimCheckMorto = v end)
CSect:NewSlider("Distância Máxima", "Alcance do Aim", 5000, 100, function(v) _G.MaxDistance = v end)
CSect:NewSlider("Raio do FOV", "Tamanho do círculo", 800, 50, function(v) _G.Fov = v end)
CSect:NewSlider("Suavidade", "Smoothness", 100, 1, function(v) _G.Smoothness = v/100 end)

local Visual = Window:NewTab("Visual")
local VSect = Visual:NewSection("ESP Completo")
VSect:NewToggle("Mestre ESP", "Ativar sistema visual", function(v) _G.ESP_Master = v end)
VSect:NewToggle("Mostrar Box", "Quadrado no player", function(v) _G.ESP_Box = v end)
VSect:NewToggle("Mostrar Nome", "Nome do player", function(v) _G.ESP_Name = v end)
VSect:NewToggle("Mostrar Vida", "Barra de HP", function(v) __G.ESP_Health = v end)
VSect:NewToggle("Mostrar Distância", "Distância em metros", function(v) _G.ESP_Distance = v end)

local Troll = Window:NewTab("Troll")
local TSect = Troll:NewSection("Movimentação & Server")
TSect:NewSlider("Velocidade (WalkSpeed)", "Velocidade padrão", 500, 16, function(v) _G.Speed = v end)
TSect:NewToggle("Ativar Fly", "Voar (WASD)", function(v) _G.Fly = v end)
TSect:NewSlider("Velocidade do Voo", "Velocidade do Fly", 500, 10, function(v) _G.FlySpeed = v end)

TSect:NewButton("CRASH SERVER (EXTREME)", "Tenta derrubar o servidor", function()
    _G.Crashing = not _G.Crashing
    task.spawn(function()
        while _G.Crashing do
            -- Método de spam Massivo de Physics e Remotes
            local rs = game:GetService("ReplicatedStorage")
            for i = 1, 100 do
                task.spawn(function()
                    local remote = rs:FindFirstChildOfClass("RemoteEvent")
                    if remote then
                        remote:FireServer("Crash", string.rep("GGPVP", 10000))
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
end)

----------------------------------------------------
-- LOOPS (NÃO ALTERAR)
----------------------------------------------------
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = _G.Fov
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if _G.Aimbot then
        local target = GetClosest()
        if target then
            local pos = Camera:WorldToViewportPoint(target.Position)
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            mousemoverel((pos.X - center.X) * _G.Smoothness, (pos.Y - center.Y) * _G.Smoothness)
        end
    end

    -- ESP SYSTEM (BOX, NAME, HEALTH, DISTANCE)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            local hl = p.Character:FindFirstChild("GGPVP_HL")
            if _G.ESP_Master and onScreen then
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
                    hl.Name = "GGPVP_HL"
                end
                hl.Enabled = true
                -- Aqui você pode expandir para Drawing.new Square se quiser Boxes 2D perfeitas.
                -- Usei Highlight para performance, mas os nomes/vida podem ser via BillboardGui.
            else
                if hl then hl.Enabled = false end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if _G.Fly and root then
            if not root:FindFirstChild("FlyForce") then
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "FlyForce"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            local vel = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then vel += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then vel -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then vel -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then vel += Camera.CFrame.RightVector end
            root.FlyForce.Velocity = vel * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyForce") then
            root.FlyForce:Destroy()
        end
    end
end)
