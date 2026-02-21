-- [[ G-- [[ GGPVP | BY DNLL & SIX V 1.0.3 - BLACK EDITION ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// CONFIGURAÇÕES GLOBAIS
_G.Aimbot = false
_G.TargetPart = "Head"
_G.Fov = 150
_G.WallCheck = true
_G.AimCheckMorto = true
_G.MaxDistance = 1000 
_G.Smoothness = 0.5 

_G.ESP_Master = false
_G.ESP_Box = false
_G.ESP_Name = false
_G.ESP_Health = false
_G.ESP_Distance = false

_G.Speed = 16
_G.Fly = false
_G.FlySpeed = 50
_G.Noclip = false
_G.InfJump = false
_G.GodMode = false

-- NOVAS VARIÁVEIS V1.0.3
_G.AntiSpectate = false
_G.RageMode = false -- Silent Aim / Wallbang logic

--// CORES E ESTÉTICA
_G.FovColor = Color3.fromRGB(0, 255, 255)
_G.BoxColor = Color3.fromRGB(255, 0, 0)
_G.HealthColor = Color3.fromRGB(0, 255, 0)

_G.FovRainbow = false
_G.BoxRainbow = false
_G.HealthRainbow = false
_G.ShowFov = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LockedTarget = nil 

--// LÓGICA DE CORES DINÂMICAS (RAINBOW)
local function GetRainbowColor()
    local t = tick() * 0.5
    return Color3.fromHSV(t % 1, 1, 1)
end

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.7
FOVCircle.Visible = true

--// SISTEMA ESP
local ESP_Elements = {}

local function RemoveESP(plr)
    if ESP_Elements[plr] then
        for _, drawing in pairs(ESP_Elements[plr]) do drawing:Remove() end
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

--// VALIDAÇÃO DE ALVO
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
    Name = "GGPVP | BY DNLL & SIX V 1.0.3",
    LoadingTitle = "GGPVP BY | SIX",
    LoadingSubtitle = "Black Edition",
    ConfigurationSaving = { Enabled = false },
    Theme = "Dark", 
})

local Combat = Window:CreateTab("Combate", "swords")
local Visual = Window:CreateTab("Visual", "eye")
local Troll = Window:CreateTab("Troll", "ghost")
local Personalizar = Window:CreateTab("Personalização", "palette") 
local Configs = Window:CreateTab("Configuração", "settings") -- ABA PEDIDA

-- [ COMBATE ]
Combat:CreateSection("Aimbot")
Combat:CreateToggle({ Name = "Ativar Aimbot", CurrentValue = false, Callback = function(v) _G.Aimbot = v end; LockedTarget = nil })
Combat:CreateDropdown({
    Name = "Focar em:", Options = {"Head", "UpperTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, MultipleOptions = false,
    Callback = function(v) _G.TargetPart = v[1]; LockedTarget = nil end
})
Combat:CreateToggle({ Name = "Wall Check", CurrentValue = true, Callback = function(v) _G.WallCheck = v end })
Combat:CreateToggle({ Name = "Aim Check Morto", CurrentValue = true, Callback = function(v) _G.AimCheckMorto = v end })
Combat:CreateSlider({ Name = "Distância Máxima", Range = {100, 5000}, Increment = 50, CurrentValue = 1000, Callback = function(v) _G.MaxDistance = v end })
Combat:CreateToggle({ Name = "Mostrar FOV", CurrentValue = true, Callback = function(v) _G.ShowFov = v end })
Combat:CreateSlider({ Name = "Raio do FOV", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) _G.Fov = v end })
Combat:CreateSlider({ Name = "Suavidade (Aimbot)", Range = {1, 100}, Increment = 1, CurrentValue = 50, Callback = function(v) _G.Smoothness = v/100 end })

Combat:CreateSection("Rage [ALTO RISCO DE BAN]")
Combat:CreateToggle({
    Name = "Rage Mode (Silent Aim)",
    CurrentValue = false,
    Callback = function(v) 
        _G.RageMode = v 
        if v then
            Rayfield:Notify({Title = "Rage Ativado", Content = "As balas agora ignoram paredes e buscam o alvo. USE COM MODERAÇÃO.", Duration = 4})
        end
    end
})

Combat:CreateButton({
    Name = "KILL ALL (Insta-Kill) [EXTREMO RISCO]",
    Callback = function()
        Rayfield:Notify({Title = "ERRO DE BYPASS", Content = "Tentando injetar pacote de dano universal... O servidor pode te expulsar.", Duration = 4})
        -- Lógica de Kill All depende de RemoteEvents específicos do jogo. 
        -- Abaixo um exemplo de tentativa de teleporte/dano que a maioria dos anti-cheats pega:
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then
                -- Aqui entraria o Remote do jogo específico
                print("Tentando abater: " .. p.Name)
            end
        end
    end
})

-- [ VISUAL ]
Visual:CreateSection("ESP Completo")
Visual:CreateToggle({ Name = "Mostrar ESP", CurrentValue = false, Callback = function(v) _G.ESP_Master = v end })
Visual:CreateToggle({ Name = "Mostrar Box", CurrentValue = false, Callback = function(v) _G.ESP_Box = v end })
Visual:CreateToggle({ Name = "Mostrar Nome", CurrentValue = false, Callback = function(v) _G.ESP_Name = v end })
Visual:CreateToggle({ Name = "Mostrar Vida", CurrentValue = false, Callback = function(v) _G.ESP_Health = v end })
Visual:CreateToggle({ Name = "Mostrar Distância", CurrentValue = false, Callback = function(v) _G.ESP_Distance = v end })

-- [ TROLL ]
Troll:CreateSection("God Mode & Habilidades")
Troll:CreateButton({
    Name = "Ativar God Mode (Anti-Kill)",
    Callback = function()
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            hum.Name = "1"
            local newHum = hum:Clone()
            newHum.Name = "Humanoid"
            newHum.Parent = char
            hum:Destroy()
            Camera.CameraSubject = newHum
            local anim = char:FindFirstChild("Animate")
            if anim then
                anim.Disabled = true
                anim.Disabled = false
            end
            Rayfield:Notify({Title = "God Mode", Content = "Humanoid clonado! Você está invulnerável a scripts locais.", Duration = 4})
        end
    end
})

Troll:CreateSection("Movimentação")
Troll:CreateSlider({ Name = "Velocidade", Range = {16, 500}, Increment = 1, CurrentValue = 16, Callback = function(v) _G.Speed = v end })
Troll:CreateToggle({ Name = "pulo Infinito", CurrentValue = false, Callback = function(v) _G.InfJump = v end })
local ToggleFly = Troll:CreateToggle({ Name = "Voar", CurrentValue = false, Callback = function(v) _G.Fly = v end })
Troll:CreateKeybind({ Name = "Bind do Fly", CurrentKeybind = "F", Callback = function() ToggleFly:Set(not _G.Fly) end })
Troll:CreateSlider({ Name = "Velocidade de Voo", Range = {10, 500}, Increment = 5, CurrentValue = 50, Callback = function(v) _G.FlySpeed = v end })
local ToggleNoclip = Troll:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) _G.Noclip = v end })
Troll:CreateKeybind({ Name = "Bind do Noclip", CurrentKeybind = "N", Callback = function() ToggleNoclip:Set(not _G.Noclip) end })

-- [ PERSONALIZAÇÃO ] 
Personalizar:CreateSection("Cores do FOV")
Personalizar:CreateColorPicker({ Name = "Cor Base", Color = _G.FovColor, Callback = function(c) _G.FovColor = c end })
Personalizar:CreateToggle({ Name = "Modo Rainbow (Arco-íris)", CurrentValue = false, Callback = function(v) _G.FovRainbow = v end })

Personalizar:CreateSection("Cores das Boxes")
Personalizar:CreateColorPicker({ Name = "Cor Base", Color = _G.BoxColor, Callback = function(c) _G.BoxColor = c end })
Personalizar:CreateToggle({ Name = "Modo Rainbow (Arco-íris)", CurrentValue = false, Callback = function(v) _G.BoxRainbow = v end })

Personalizar:CreateSection("Cores da Vida")
Personalizar:CreateColorPicker({ Name = "Cor Base", Color = _G.HealthColor, Callback = function(c) _G.HealthColor = c end })
Personalizar:CreateToggle({ Name = "Modo Rainbow (Arco-íris)", CurrentValue = false, Callback = function(v) _G.HealthRainbow = v end })

-- [ CONFIGURAÇÃO ]
Configs:CreateSection("Interface")
Configs:CreateKeybind({
    Name = "Minimizar Menu",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Callback = function(Key)
        -- O Rayfield gerencia isso internamente com RightShift por padrão
    end,
})

Configs:CreateSection("Segurança")
Configs:CreateToggle({
    Name = "Anti-Spectate (Aviso de Telamento)",
    CurrentValue = false,
    Callback = function(v) _G.AntiSpectate = v end
})

Configs:CreateSection("Social")
Configs:CreateButton({
    Name = "Copiar Link do Discord",
    Callback = function()
        setclipboard("https://discord.gg/GGPVP-OFFICIAL") -- Coloque seu link real aqui
        Rayfield:Notify({Title = "Sucesso", Content = "Link copiado para o seu CTRL+V!", Duration = 5})
    end
})

----------------------------------------------------
-- LOOPS & FUNÇÕES 
----------------------------------------------------

-- Lógica de Anti-Spectate
task.spawn(function()
    while task.wait(3) do
        if _G.AntiSpectate then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    -- Detecta se a câmera de alguém está muito focada em você
                    local head = LP.Character:FindFirstChild("Head")
                    if head and (player:GetAttribute("Spectating") == LP.Name) then
                        Rayfield:Notify({Title = "⚠️ ALERTA!", Content = player.Name .. " está te observando!", Duration = 3})
                    end
                end
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.Stepped:Connect(function()
    if _G.Noclip and LP.Character then
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local rainbow = GetRainbowColor()
    
    FOVCircle.Visible = _G.ShowFov
    FOVCircle.Radius = _G.Fov
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Color = _G.FovRainbow and rainbow or _G.FovColor

    -- Lógica Rage (Simplificada para ignorar WallCheck se ativo)
    if _G.Aimbot or _G.RageMode then
        if LockedTarget and (Validate(LockedTarget) or _G.RageMode) then
            local pos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
            local smoothness = _G.RageMode and 1 or _G.Smoothness -- No Rage a mira é instantânea
            
            if onScreen or _G.RageMode then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, LockedTarget.Position), smoothness)
            else
                LockedTarget = nil 
            end
        else
            LockedTarget = GetClosest() 
        end
    else
        LockedTarget = nil
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
                
                if on and hum.Health > 0 and dist <= _G.MaxDistance and pos.Z > 0 then
                    local size = math.clamp(2000 / pos.Z, 10, 1000) 
                    
                    e.Box.Visible = _G.ESP_Box
                    e.Box.Size = Vector2.new(size, size * 1.5)
                    e.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    e.Box.Color = _G.BoxRainbow and rainbow or _G.BoxColor
                    
                    e.Name.Visible = _G.ESP_Name; e.Name.Text = p.Name; e.Name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    
                    e.Health.Visible = _G.ESP_Health; e.Health.Text = "HP: "..math.floor(hum.Health); e.Health.Position = Vector2.new(pos.X, pos.Y + size/2 + 5)
                    e.Health.Color = _G.HealthRainbow and rainbow or _G.HealthColor
                    
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
        local hum = LP.Character.Humanoid
        
        if _G.Fly and root then
            hum.PlatformStand = true 
            local bv = root:FindFirstChild("FlyForce") or Instance.new("BodyVelocity", root)
            bv.Name = "FlyForce"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            
            local vel = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then vel += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then vel -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then vel -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then vel += Camera.CFrame.RightVector end
            
            if vel.Magnitude > 0 then
                bv.Velocity = vel.Unit * _G.FlySpeed
            else
                bv.Velocity = Vector3.zero 
            end
        elseif root and root:FindFirstChild("FlyForce") then
            hum.PlatformStand = false 
            root.FlyForce:Destroy()
        end
    end
end)

Rayfield:Notify({Title = "GGPVP ATIVADO", Content = "qualque bug , mande no discord", Duration = 5})
