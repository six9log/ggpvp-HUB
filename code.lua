-- [[ GGPVP SUPREME V12 | FINAL REPARO DANO & TUDO ATIVADO ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🎯 GGPVP SUPREME V12", "DarkTheme")

--// CONFIGURAÇÕES (NÃO REMOVER NADA)
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

--// TECLA HOME PARA MINIMIZAR
local MenuVisible = true
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Home then
        MenuVisible = not MenuVisible
        local gui = game:GetService("CoreGui"):FindFirstChild("🎯 GGPVP SUPREME V12")
        if gui then gui.Enabled = MenuVisible end
    end
end)

--// SISTEMA ESP (DRAWING)
local ESP_Elements = {}
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
    e.Box.Color = Color3.fromRGB(255, 0, 0)
    e.Name.Size = 14
    e.Name.Center = true
    e.Name.Outline = true
    e.Health.Size = 14
    e.Health.Center = true
    e.Health.Outline = true
    e.Dist.Size = 14
    e.Dist.Center = true
    e.Dist.Outline = true
end

--// VALIDAÇÃO DE ALVO
local function Validate(part)
    if not part or not part.Parent then return false end
    local char = part.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if _G.AimCheckMorto and (not hum or hum.Health <= 0) then return false end
    if not root then return false end
    
    local mag = (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude
    if mag > _G.MaxDistance then return false end
    
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
                local magnitude = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if magnitude < shortest then
                    shortest = magnitude
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
VSect:NewToggle("Mostrar Vida", "Barra de HP", function(v) _G.ESP_Health = v end)
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
            local rs = game:GetService("ReplicatedStorage")
            for i = 1, 150 do
                local remote = rs:FindFirstChildOfClass("RemoteEvent")
                if remote then remote:FireServer("Crash", string.rep("GGPVP", 1000)) end
            end
            task.wait()
        end
    end)
end)

----------------------------------------------------
-- LOOP PRINCIPAL (DANO CORRIGIDO + ESP)
----------------------------------------------------
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = _G.Fov
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = true

    -- LÓGICA DE AIMBOT PARA MATAR (DANO REGISTRADO)
    if _G.Aimbot then
        local target = GetClosest()
        if target then
            local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            if onScreen then
                -- Move o mouse (Gira o Personagem para o Servidor)
                mousemoverel((pos.X - center.X) * _G.Smoothness, (pos.Y - center.Y) * _G.Smoothness)
                
                -- Alinha a Câmera (Garante que o tiro vá no alvo)
                local currentCF = Camera.CFrame
                local targetCF = CFrame.new(currentCF.Position, target.Position)
                Camera.CFrame = currentCF:Lerp(targetCF, _G.Smoothness)
            end
        end
    end

    -- SISTEMA ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            if not ESP_Elements[p] then CreateESP(p) end
            local e = ESP_Elements[p]
            local char = p.Character
            if _G.ESP_Master and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local root, hum = char.HumanoidRootPart, char.Humanoid
                local pos, on = Camera:WorldToViewportPoint(root.Position)
                if on and hum.Health > 0 then
                    local size = 2000 / pos.Z
                    e.Box.Visible = _G.ESP_Box
                    e.Box.Size = Vector2.new(size, size * 1.5)
                    e.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    e.Name.Visible = _G.ESP_Name
                    e.Name.Text = p.Name
                    e.Name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    e.Health.Visible = _G.ESP_Health
                    e.Health.Text = "HP: " .. math.floor(hum.Health)
                    e.Health.Position = Vector2.new(pos.X, pos.Y + size/2 + 5)
                    e.Dist.Visible = _G.ESP_Distance
                    e.Dist.Text = math.floor((LP.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m"
                    e.Dist.Position = Vector2.new(pos.X, pos.Y + size/2 + 20)
                else
                    e.Box.Visible = false; e.Name.Visible = false; e.Health.Visible = false; e.Dist.Visible = false
                end
            elseif e then
                e.Box.Visible = false; e.Name.Visible = false; e.Health.Visible = false; e.Dist.Visible = false
            end
        end
    end
end)

-- LOOP DE FÍSICA (SPEED/FLY)
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

-- LIMPEZA AO SAIR
Players.PlayerRemoving:Connect(function(p)
    if ESP_Elements[p] then
        for _, obj in pairs(ESP_Elements[p]) do obj:Destroy() end
        ESP_Elements[p] = nil
    end
end)
