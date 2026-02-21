-- [[ GGPVP | BY DNLL & SIX V 1.0.1 ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
_G.Noclip = false
_G.InfJump = false -- NOVA: Salto Infinito

_G.FovColor = Color3.fromRGB(0, 255, 255)
_G.BoxColor = Color3.fromRGB(255, 0, 0)
_G.HealthColor = Color3.fromRGB(0, 255, 0)

_G.ShowFov = true
_G.HitEffect = false 
_G.HitColor = Color3.fromRGB(255, 255, 255) -- Cor base do Hit
_G.RainbowHit = false -- Opção Arco-íris

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LastHealth = {}

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.7
FOVCircle.Visible = true

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
-- INTERFACE RAYFIELD
----------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "GGPVP | BY DNLL & SIX V 1.0.1",
    LoadingTitle = "Carregando GGPVP...",
    LoadingSubtitle = "Preparando cheats",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false, 
})

local Combat = Window:CreateTab("Combate", "swords")
local Visual = Window:CreateTab("Visual", "eye")
local Troll = Window:CreateTab("Troll", "ghost")
local Config = Window:CreateTab("Configuração", "settings")

-- [ COMBATE ]
Combat:CreateSection("Aimbot Supreme")
Combat:CreateToggle({ Name = "Ativar Aimbot", CurrentValue = false, Callback = function(v) _G.Aimbot = v end })
Combat:CreateDropdown({
    Name = "Focar em:", Options = {"Head", "UpperTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, MultipleOptions = false,
    Callback = function(v) _G.TargetPart = v[1] end
})
Combat:CreateToggle({ Name = "Wall Check", CurrentValue = true, Callback = function(v) _G.WallCheck = v end })
Combat:CreateToggle({ Name = "Aim Check Morto", CurrentValue = true, Callback = function(v) _G.AimCheckMorto = v end })
Combat:CreateSlider({ Name = "Distância Máxima", Range = {100, 5000}, Increment = 50, CurrentValue = 1000, Callback = function(v) _G.MaxDistance = v end })
Combat:CreateToggle({ Name = "Mostrar FOV", CurrentValue = true, Callback = function(v) _G.ShowFov = v end })
Combat:CreateSlider({ Name = "Raio do FOV", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) _G.Fov = v end })
Combat:CreateSlider({ Name = "Suavidade (Aimbot)", Range = {1, 100}, Increment = 1, CurrentValue = 20, Callback = function(v) _G.Smoothness = v/100 end })

-- [ VISUAL ]
Visual:CreateSection("ESP Completo")
Visual:CreateToggle({ Name = "Mestre ESP", CurrentValue = false, Callback = function(v) _G.ESP_Master = v end })
Visual:CreateToggle({ Name = "Mostrar Box", CurrentValue = false, Callback = function(v) _G.ESP_Box = v end })
Visual:CreateToggle({ Name = "Mostrar Nome", CurrentValue = false, Callback = function(v) _G.ESP_Name = v end })
Visual:CreateToggle({ Name = "Mostrar Vida", CurrentValue = false, Callback = function(v) _G.ESP_Health = v end })
Visual:CreateToggle({ Name = "Mostrar Distância", CurrentValue = false, Callback = function(v) _G.ESP_Distance = v end })

Visual:CreateSection("Efeito de Acerto (Hit)")
Visual:CreateToggle({ Name = "Hit Effect (Brilho ao acertar)", CurrentValue = false, Callback = function(v) _G.HitEffect = v end })
Visual:CreateToggle({ Name = "Hit Effect Arco-íris", CurrentValue = false, Callback = function(v) _G.RainbowHit = v end })
Visual:CreateColorPicker({ Name = "Cor do Hit Effect (Base)", Color = Color3.fromRGB(255, 255, 255), Callback = function(c) _G.HitColor = c end })

-- [ TROLL ]
Troll:CreateSection("Movimentação & Trolls")
Troll:CreateSlider({ Name = "Velocidade (WalkSpeed)", Range = {16, 500}, Increment = 1, CurrentValue = 16, Callback = function(v) _G.Speed = v end })
Troll:CreateToggle({ Name = "Salto Infinito", CurrentValue = false, Callback = function(v) _G.InfJump = v end })

local ToggleFly = Troll:CreateToggle({ Name = "Voar (Fly)", CurrentValue = false, Callback = function(v) _G.Fly = v end })
Troll:CreateKeybind({ Name = "Bind do Fly", CurrentKeybind = "F", HoldToInteract = false, Callback = function()
    ToggleFly:Set(not _G.Fly) 
end})
Troll:CreateSlider({ Name = "Velocidade de Voo", Range = {10, 500}, Increment = 5, CurrentValue = 50, Callback = function(v) _G.FlySpeed = v end })

local ToggleNoclip = Troll:CreateToggle({ Name = "Noclip (Atravessar Parede)", CurrentValue = false, Callback = function(v) _G.Noclip = v end })
Troll:CreateKeybind({ Name = "Bind do Noclip", CurrentKeybind = "N", HoldToInteract = false, Callback = function()
    ToggleNoclip:Set(not _G.Noclip)
end})

-- [ CONFIGURAÇÃO ]
Config:CreateSection("Ajustes Visuais")
Config:CreateColorPicker({ Name = "Cor do FOV", Color = Color3.fromRGB(0, 255, 255), Callback = function(c) _G.FovColor = c end })
Config:CreateColorPicker({ Name = "Cor do Box", Color = Color3.fromRGB(255, 0, 0), Callback = function(c) _G.BoxColor = c end })
Config:CreateColorPicker({ Name = "Cor da Vida", Color = Color3.fromRGB(0, 255, 0), Callback = function(c) _G.HealthColor = c end })

Rayfield:Notify({
    Title = "GGPVP Injetado!",
    Content = "Pressione a tecla do menu para fechar/abrir.",
    Duration = 5,
    Image = 4483362458,
})

----------------------------------------------------
-- LOOPS & FUNÇÕES
----------------------------------------------------
-- Lógica Pulo Infinito
UIS.JumpRequest:Connect(function()
    if _G.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Efeito de Confete/Brilho (Criador Visual)
local function SpawnHitEffect(position)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Position = position
    part.Parent = workspace
    
    local emit = Instance.new("ParticleEmitter")
    emit.Parent = part
    emit.Texture = "rbxassetid://243660364"
    emit.LightEmission = 1
    
    -- Checa se o Arco-íris está ligado ou usa a cor do painel
    if _G.RainbowHit then
        emit.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
    else
        emit.Color = ColorSequence.new(_G.HitColor)
    end
    
    emit.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
    emit.Speed = NumberRange.new(5, 15)
    emit.SpreadAngle = Vector2.new(360, 360)
    emit.Lifetime = NumberRange.new(0.5, 1)
    
    emit:Emit(15)
    game.Debris:AddItem(part, 1.5)
end

-- NOCLIP LOOP CORRIGIDO (Evita Rubberband)
RunService.Stepped:Connect(function()
    if _G.Noclip and LP.Character then
        local hum = LP.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(11) end -- 11 = Desativa física impedindo voltar para trás
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- RENDER RENDERSTEPPED LOOP
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFov
    FOVCircle.Radius = _G.Fov
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Color = _G.FovColor

    -- AIMBOT (Sem puxar torto, apenas Camera Lerp)
    if _G.Aimbot then
        local target = GetClosest()
        if target then
            local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if onScreen then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), _G.Smoothness)
            end
        end
    end

    -- ESP & HIT EFFECT LOGIC
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            if not ESP_Elements[p] then CreateESP(p) end
            local e = ESP_Elements[p]
            local char = p.Character
            if _G.ESP_Master and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local root, hum = char.HumanoidRootPart, char.Humanoid
                local pos, on = Camera:WorldToViewportPoint(root.Position)
                local dist = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")) and (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude or 0
                
                -- HIT EFFECT CHECKER
                if _G.HitEffect then
                    local pHealth = hum.Health
                    local oldHealth = LastHealth[p.Name] or pHealth
                    if pHealth < oldHealth and pHealth > 0 then
                        SpawnHitEffect(root.Position)
                    end
                    LastHealth[p.Name] = pHealth
                end

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

-- HEARTBEAT LOOP (FLY & SPEED)
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
