-- [[ GGPVP PC - SUPREME V4 | ULTRA STICKY & OPTIMIZED ]]
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("🎯 GGPVP |by six", "DarkTheme")

--// SERVIÇOS
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--// CONFIGS
_G.Aimbot = false
_G.TargetPart = "Head" -- Padrão
_G.FovRadius = 120 
_G.FovVisible = true
_G.Smoothness = 0.5 
_G.WallCheck = true
_G.MaxDistance = 1000 -- NOVO: Distância padrão

_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 20 -- NOVO: Velocidade padrão do Fly

_G.ESP_Enabled = false
_G.ESP_Boxes = false
_G.ESP_Info = false

_G.LagServer = false

--// FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(0, 255, 255)

----------------------------------------------------
-- LÓGICA DE TARGET & MELHORIA DE MIRA
----------------------------------------------------
local function IsVisible(part)
    if not _G.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, part.Parent}
    -- Ignora água e partes transparentes para não bugar o WallCheck
    params.IgnoreWater = true
    
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    return result == nil
end

local function GetClosestTarget()
    local target, shortest = nil, _G.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character[_G.TargetPart]
                
                -- VERIFICAÇÃO DE DISTÂNCIA MÁXIMA (ADICIONADO)
                local mag = (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude
                if mag <= _G.MaxDistance then
                    local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
                    if onscreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            if IsVisible(part) then
                                shortest = dist
                                target = part
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

----------------------------------------------------
-- INTERFACE (MANTIDA + ADIÇÕES)
----------------------------------------------------
local Main = Window:NewTab("Combate")
local CombatSect = Main:NewSection("Aimbot (Melhorado)")
CombatSect:NewToggle("Ativar Aimbot", "Gruda no alvo", function(v) _G.Aimbot = v end)
CombatSect:NewToggle("Wall Check", "Não mira em paredes", function(v) _G.WallCheck = v end)
CombatSect:NewToggle("Ver FOV", "Círculo de mira", function(v) _G.FovVisible = v end)

-- NOVO: Seleção de Local (Cabeça ou Tronco)
CombatSect:NewDropdown("Local do Alvo", "Onde a mira vai grudar", {"Head", "HumanoidRootPart"}, function(v)
    _G.TargetPart = v
end)

CombatSect:NewSlider("Tamanho FOV", "Raio", 500, 30, function(v) _G.FovRadius = v end)
-- ADIÇÃO: Distância do Aimbot
CombatSect:NewSlider("Distância Máxima", "Distância de alcance", 5000, 100, function(v) _G.MaxDistance = v end)
-- Slider ajustado para maior precisão de "grude"
CombatSect:NewSlider("Suavidade (Grude)", "100 = Instantâneo", 100, 1, function(v) _G.Smoothness = v/100 end)

local Visuals = Window:NewTab("Visuals")
local VisualSect = Visuals:NewSection("ESP (Anti-Lag)")
VisualSect:NewToggle("Ativar ESP", "Wallhack", function(v) _G.ESP_Enabled = v end)
VisualSect:NewToggle("Caixas", "Boxes", function(v) _G.ESP_Boxes = v end)
VisualSect:NewToggle("Infos", "Nome/Vida", function(v) _G.ESP_Info = v end)

local Trol = Window:NewTab("Trol")
Trol:NewSection("Movimento"):NewSlider("Speed", "Velocidade", 500, 16, function(v) _G.Speed = v end)
Trol:NewSection("Fly"):NewToggle("Fly", "Voar", function(v) _G.Fly = v end)
-- ADIÇÃO: Slider para Velocidade do Voo
Trol:NewSlider("Velocidade do Voo", "Aumenta o Fly", 500, 10, function(v) _G.FlySpeed = v end)

-- ADIÇÃO: Seção de Crash
local CrashSect = Trol:NewSection("Server Crash")
CrashSect:NewButton("Crash Server (Method 1)", "Tenta derrubar o server", function()
    _G.Crashing = true
    while _G.Crashing do
        task.spawn(function()
            for i = 1, 500 do
                local remote = game:GetService("ReplicatedStorage"):FindFirstChildOfClass("RemoteEvent")
                if remote then
                    remote:FireServer("Crash", string.rep("GGPVP", 1000))
                end
            end
        end)
        task.wait()
    end
end)
CrashSect:NewButton("Parar Crash", "Para o envio de dados", function() _G.Crashing = false end)

local Config = Window:NewTab("Config")
Config:NewSection("Menu"):NewKeybind("Abrir/Fechar", "", Enum.KeyCode.RightControl, function(k) _G.MenuKey = k end)
Config:NewSection("Sair"):NewButton("Kill Script", "Limpar TUDO", function()
    _G.Aimbot = false; _G.ESP_Enabled = false; _G.FovVisible = false; _G.LagServer = false; _G.Crashing = false; FOVCircle:Destroy()
    pcall(function() CoreGui:FindFirstChild("🎯 GGPVP |by six"):Destroy() end)
end)

----------------------------------------------------
-- LOOPS ( MELHORIA NA VELOCIDADE DE RESPOSTA )
----------------------------------------------------
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.FovVisible
    FOVCircle.Radius = _G.FovRadius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    if _G.Aimbot then
        local target = GetClosestTarget()
        if target then
            -- Melhora no Grude: Usa CFrame direto com Lerp acelerado
            local targetPos = target.Position
            -- Se o Smoothness for alto (perto de 1), a mira fica "chiclete"
            local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.Smoothness)
        end
    end
end)

-- SPEED/FLY ESTÁVEL (MANTIDO)
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
            -- AGORA USA A VARIÁVEL FLYSPEED DO NOVO SLIDER
            root.FlyForce.Velocity = vel * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyForce") then
            root.FlyForce:Destroy()
        end
    end
end)

-- ESP MANTIDO
-- ESP OTIMIZADO (COM LIMPEZA DE OBJETOS TRAVADOS)
local ESP_Table = {}

local function ClearESP(plr)
    if ESP_Table[plr] then
        pcall(function()
            ESP_Table[plr].Box.Visible = false
            ESP_Table[plr].Text.Visible = false
            ESP_Table[plr].Box:Destroy()
            ESP_Table[plr].Text:Destroy()
        end)
        ESP_Table[plr] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            -- Cria se não existir
            if not ESP_Table[p] then
                ESP_Table[p] = {Box = Drawing.new("Square"), Text = Drawing.new("Text")}
                ESP_Table[p].Box.Thickness = 1
                ESP_Table[p].Text.Size = 14
                ESP_Table[p].Text.Center = true
                ESP_Table[p].Text.Outline = true
            end

            local obj = ESP_Table[p]
            local char = p.Character
            
            -- Só mostra se o ESP estiver ON, o personagem existir e estiver vivo
            if _G.ESP_Enabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local pos, on = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                
                if on then
                    local size = 2000/pos.Z
                    obj.Box.Visible = _G.ESP_Boxes
                    obj.Box.Size = Vector2.new(size, size*1.2)
                    obj.Box.Position = Vector2.new(pos.X-size/2, pos.Y-size/2)
                    obj.Box.Color = Color3.fromRGB(255,255,255)

                    obj.Text.Visible = _G.ESP_Info
                    obj.Text.Text = p.Name.." ["..math.floor(char.Humanoid.Health).."]"
                    obj.Text.Position = Vector2.new(pos.X, pos.Y-size/2-15)
                    obj.Text.Color = Color3.fromRGB(255,255,255)
                else
                    obj.Box.Visible = false
                    obj.Text.Visible = false
                end
            else
                -- Limpa da tela se o jogador morrer ou você desligar o ESP
                obj.Box.Visible = false
                obj.Text.Visible = false
            end
        end
    end
end)

-- Limpa quando o jogador sai do servidor para não sobrar quadrado
game.Players.PlayerRemoving:Connect(ClearESP)
