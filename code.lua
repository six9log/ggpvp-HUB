-- [[ GGPVP | BY DNLL & SIX ]]
-- Versão Estabilizada (Rayfield Engine)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// CONFIGURAÇÕES GLOBAIS (PRESERVADAS)
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
_G.FovColor = Color3.fromRGB(0, 255, 255)
_G.BoxColor = Color3.fromRGB(255, 0, 0)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// JANELA PRINCIPAL
local Window = Rayfield:CreateWindow({
   Name = "GGPVP | BY DNLL & SIX",
   LoadingTitle = "Carregando GGPVP...",
   LoadingSubtitle = "by DNLL & SIX",
   ConfigurationSaving = { Enabled = false }
})

--// NOTIFICAÇÃO
Rayfield:Notify({
   Title = "SISTEMA",
   Content = "CHEAT ATIVADO COM SUCESSO",
   Duration = 5,
   Image = 4483362458,
})

--// ABAS
local CombatTab = Window:CreateTab("Combate", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local TrollTab = Window:CreateTab("Troll & Move", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)

--// COMBATE
CombatTab:CreateToggle({
   Name = "Ativar Aimbot",
   CurrentValue = false,
   Callback = function(v) _G.Aimbot = v end,
})

CombatTab:CreateDropdown({
   Name = "Focar em:",
   Options = {"Head", "UpperTorso", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   Callback = function(v) _G.TargetPart = v[1] end,
})

CombatTab:CreateSlider({
   Name = "Raio do FOV",
   Range = {50, 800},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(v) _G.Fov = v end,
})

CombatTab:CreateSlider({
   Name = "Suavidade (Smoothness)",
   Range = {1, 100},
   Increment = 1,
   CurrentValue = 20,
   Callback = function(v) _G.Smoothness = v/100 end,
})

--// VISUAL
VisualTab:CreateToggle({
   Name = "Mestre ESP",
   CurrentValue = false,
   Callback = function(v) _G.ESP_Master = v end,
})

VisualTab:CreateToggle({
   Name = "Mostrar Box",
   CurrentValue = false,
   Callback = function(v) _G.ESP_Box = v end,
})

VisualTab:CreateToggle({
   Name = "Mostrar Nome",
   CurrentValue = false,
   Callback = function(v) _G.ESP_Name = v end,
})

VisualTab:CreateToggle({
   Name = "Mostrar Vida (Verde)",
   CurrentValue = false,
   Callback = function(v) _G.ESP_Health = v end,
})

--// TROLL & MOVE
TrollTab:CreateSlider({
   Name = "Velocidade (WalkSpeed)",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) _G.Speed = v end,
})

local FlyToggle = TrollTab:CreateToggle({
   Name = "Ativar Fly",
   CurrentValue = false,
   Callback = function(v) _G.Fly = v end,
})

TrollTab:CreateKeybind({
   Name = "Atalho do Fly",
   CurrentKeybind = "F",
   HoldToInteract = false,
   Callback = function()
       _G.Fly = not _G.Fly
       FlyToggle:Set(_G.Fly) -- Sincroniza o menu
   end,
})

TrollTab:CreateButton({
   Name = "CRASH SERVER (EXTREME)",
   Callback = function()
       _G.Crashing = not _G.Crashing
       task.spawn(function()
           while _G.Crashing do
               local rs = game:GetService("ReplicatedStorage")
               for i = 1, 100 do
                   local r = rs:FindFirstChildOfClass("RemoteEvent")
                   if r then r:FireServer("Crash", string.rep("GGPVP", 500)) end
               end
               task.wait()
           end
       end)
   end,
})

--// CONFIG
ConfigTab:CreateColorPicker({
    Name = "Cor do FOV",
    Color = Color3.fromRGB(0, 255, 255),
    Callback = function(color) _G.FovColor = color end
})

ConfigTab:CreateColorPicker({
    Name = "Cor da Box ESP",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(color) _G.BoxColor = color end
})

--// LÓGICA DE ESP COM LIMPEZA DE CACHE (SEM BUG NA TELA)
local ESP_Elements = {}
local function CleanESP()
    for _, e in pairs(ESP_Elements) do
        e.Box.Visible = false
        e.Name.Visible = false
        e.Health.Visible = false
    end
end

local function GetClosest()
    local target, shortest = nil, _G.Fov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(_G.TargetPart) then
            local part = v.Character[_G.TargetPart]
            local pos, screen = Camera:WorldToViewportPoint(part.Position)
            if screen then
                local hum = v.Character:FindFirstChild("Humanoid")
                if not _G.AimCheckMorto or (hum and hum.Health > 0) then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < shortest then shortest = mag; target = part end
                end
            end
        end
    end
    return target
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.5
FOVCircle.Visible = true

RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = _G.Fov
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Color = _G.FovColor
    FOVCircle.Visible = true

    if _G.Aimbot then
        local t = GetClosest()
        if t then
            local pos = Camera:WorldToViewportPoint(t.Position)
            mousemoverel((pos.X - (Camera.ViewportSize.X/2)) * _G.Smoothness, (pos.Y - (Camera.ViewportSize.Y/2)) * _G.Smoothness)
        end
    end

    if not _G.ESP_Master then CleanESP() return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not ESP_Elements[p] then 
                ESP_Elements[p] = {Box = Drawing.new("Square"), Name = Drawing.new("Text"), Health = Drawing.new("Text")}
            end
            local e = ESP_Elements[p]
            local root = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChild("Humanoid")
            local pos, on = Camera:WorldToViewportPoint(root.Position)

            if on and hum and hum.Health > 0 then
                local s = 2000 / pos.Z
                e.Box.Visible = _G.ESP_Box
                e.Box.Size = Vector2.new(s, s*1.5)
                e.Box.Position = Vector2.new(pos.X-s/2, pos.Y-s/2)
                e.Box.Color = _G.BoxColor
                
                e.Name.Visible = _G.ESP_Name
                e.Name.Text = p.Name
                e.Name.Position = Vector2.new(pos.X, pos.Y-s/2-15)
                e.Name.Center = true
                e.Name.Outline = true

                e.Health.Visible = _G.ESP_Health
                e.Health.Text = "HP: "..math.floor(hum.Health)
                e.Health.Position = Vector2.new(pos.X, pos.Y+s/2+5)
                e.Health.Color = Color3.fromRGB(0, 255, 0)
                e.Health.Center = true
                e.Health.Outline = true
            else
                e.Box.Visible = false
                e.Name.Visible = false
                e.Health.Visible = false
            end
        end
    end
end)

--// MOVIMENTAÇÃO
RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        local root = LP.Character.HumanoidRootPart
        if _G.Fly and root then
            if not root:FindFirstChild("FlyF") then 
                local bv = Instance.new("BodyVelocity", root)
                bv.Name = "FlyF"; bv.MaxForce = Vector3.new(9e9,9e9,9e9) 
            end
            local v = Vector3.new(0,0.1,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then v += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then v -= Camera.CFrame.LookVector end
            root.FlyF.Velocity = v * _G.FlySpeed
        elseif root:FindFirstChild("FlyF") then root.FlyF:Destroy() end
    end
end)
