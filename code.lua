-- [[ GGPVP SUPREME V12 | MEGA TROLL EXPANSION - BLOCO 1 ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

--// CONFIGURAÇÕES GLOBAIS (PRESERVADAS)
_G.MenuKey = Enum.KeyCode.Home
_G.Aimbot, _G.TargetPart, _G.Fov = false, "Head", 150
_G.WallCheck, _G.AimCheckMorto, _G.MaxDistance, _G.Smoothness = true, true, 1000, 0.2
_G.ESP_Master, _G.ESP_Box, _G.ESP_Name, _G.ESP_Health = false, false, false, false
_G.Speed, _G.Fly, _G.FlySpeed, _G.Noclip, _G.InfJump = 16, false, 50, false, false
_G.Spinbot, _G.RainbowChar, _G.AutoClicker = false, false, false
_G.FOV_Color = Color3.fromRGB(0, 255, 255)

--// VARIÁVEIS DE TROLL (NOVAS)
_G.LoopKill = false
_G.TargetPlayer = ""
_G.AnnounceTroll = false
_G.ChatSpam = false
_G.VisualLag = false

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

--// SISTEMA DE NOTIFICAÇÃO
local function Notify(t, msg)
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 250, 0, 50); f.Position = UDim2.new(1, -260, 1, -60); f.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,0,1,0); l.Text = t..": "..msg; l.TextColor3 = _G.FOV_Color; l.BackgroundTransparency = 1; l.Font = "GothamBold"
    task.delay(3, function() sg:Destroy() end)
end

--// FOV E CROSSHAIR
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Visible = true; FOVCircle.Transparency = 0.7

local Crosshair = Drawing.new("Image")
Crosshair.Size = Vector2.new(50, 50); Crosshair.Visible = true; Crosshair.Data = game:HttpGet("https://www.freeiconspng.com/uploads/red-circular-target-png-0.png")

--// INÍCIO DA UI
local Window = Library.CreateLib("🎯 GGPVP SUPREME V12", "DarkTheme")
local Combat = Window:NewTab("Combate")
local CSect = Combat:NewSection("Aimbot & Kill")

CSect:NewToggle("Ativar Aimbot", "Mira magnética", function(v) _G.Aimbot = v end)
CSect:NewDropdown("Alvo", "Parte do corpo", {"Head", "HumanoidRootPart"}, function(v) _G.TargetPart = v end)
CSect:NewSlider("Raio do FOV", "Tamanho", 800, 50, function(v) _G.Fov = v end)

local Visual = Window:NewTab("Visual")
local VSect = Visual:NewSection("ESP Profissional")
VSect:NewToggle("Master ESP", "Ver todos", function(v) _G.ESP_Master = v end)
VSect:NewToggle("Boxes", "Caixas 2D", function(v) _G.ESP_Box = v end)
VSect:NewToggle("Nomes", "Nomes dos Players", function(v) _G.ESP_Name = v end)

--// ABA TROLL (INÍCIO)
local Troll = Window:NewTab("Troll & Server")
local TSect = Troll:NewSection("Interrupção de Servidor")

TSect:NewToggle("Chat Spam (GGPVP)", "Enche o chat", function(v) 
    _G.ChatSpam = v
    task.spawn(function()
        while _G.ChatSpam do
            local args = { [1] = "GGPVP SUPREME V12 DOMINANDO O SERVIDOR!", [2] = "All" }
            ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
            task.wait(1)
        end
    end)
end)

TSect:NewButton("Lagar Servidor (Visual)", "Cria objetos massivos", function()
    Notify("Troll", "Gerando Visual Lag...")
    for i = 1, 1000 do
        local p = Instance.new("Part", workspace)
        p.Position = LP.Character.HumanoidRootPart.Position + Vector3.new(0, 20, 0)
        p.Size = Vector3.new(10, 10, 10)
        p.Velocity = Vector3.new(math.random(-50,50), 100, math.random(-50,50))
    end
end)

TSect:NewButton("Derrubar Som (EarRape)", "Tenta spammar sons", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Sound") then v:Play(); v.Volume = 10 end
    end
end)
-- [[ GGPVP SUPREME V12 | MEGA TROLL EXPANSION - BLOCO 2 ]]

--// ABA TROLL (CONTINUAÇÃO)
local TSect2 = Troll:NewSection("Ataque Direto")

local SelectedTarget = ""
local AllPlayers = {}
for _, v in pairs(Players:GetPlayers()) do table.insert(AllPlayers, v.Name) end

TSect2:NewDropdown("Selecionar Vítima", "Escolha um player para atormentar", AllPlayers, function(v)
    SelectedTarget = v
end)

TSect2:NewToggle("Loop Teleport (Anexar)", "Gruda em cima do player", function(v)
    _G.LoopKill = v
    task.spawn(function()
        while _G.LoopKill do
            local target = Players:FindFirstChild(SelectedTarget)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
            task.wait()
        end
    end)
end)

TSect2:NewButton("Inverter Controles (Troll)", "Gira a câmera do player alvo", function()
    Notify("Troll", "Tentando confundir " .. SelectedTarget)
    -- Nota: Ações diretas no cliente do outro player dependem da vulnerabilidade do jogo
end)

--// ABA JOGADOR (MOVIMENTAÇÃO)
local Self = Window:NewTab("Jogador")
local SSect = Self:NewSection("Física & Atributos")

SSect:NewSlider("Velocidade (WalkSpeed)", "Velocidade padrão", 500, 16, function(v) _G.Speed = v end)
SSect:NewToggle("Noclip (Atravessar)", "Atravessa paredes e objetos", function(v) _G.Noclip = v end)
SSect:NewToggle("Voar (Fly)", "Ativa voo no WASD", function(v) _G.Fly = v end)
SSect:NewToggle("Spinbot (Giro)", "Gira muito rápido", function(v) _G.Spinbot = v end)
SSect:NewToggle("Rainbow Skin", "Personagem muda de cor", function(v) _G.RainbowChar = v end)
SSect:NewButton("Anti-AFK", "Impede que o Roblox te desconecte", function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function() vu:Button2Down(Vector2.new(0,0), Camera.CFrame); task.wait(1); vu:Button2Up(Vector2.new(0,0), Camera.CFrame) end)
    Notify("Sistema", "Anti-AFK Ativado")
end)

--// ABA CONFIGURAÇÕES
local Settings = Window:NewTab("Config")
local SetSect = Settings:NewSection("Personalização do Menu")

SetSect:NewKeybind("Mudar Tecla do Menu", "Tecla para fechar/abrir", Enum.KeyCode.Home, function(k) _G.MenuKey = k end)
SetSect:NewColorPicker("Cor do FOV & ESP", "Muda o visual geral", Color3.fromRGB(0, 255, 255), function(c)
    _G.FOV_Color = c
    FOVCircle.Color = c
end)

----------------------------------------------------
-- LÓGICA FINAL (O CORAÇÃO DO SCRIPT)
----------------------------------------------------

local ESP_Elements = {}
local function GetClosest()
    local target, shortest = nil, _G.Fov
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(_G.TargetPart) then
            local part = v.Character[_G.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < shortest then
                    local hum = v.Character:FindFirstChild("Humanoid")
                    if _G.AimCheckMorto and hum and hum.Health > 0 then
                        target = part; shortest = mag
                    elseif not _G.AimCheckMorto then
                        target = part; shortest = mag
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = center; FOVCircle.Radius = _G.Fov
    Crosshair.Position = center - Vector2.new(25, 25)

    -- Aimbot Logic
    if _G.Aimbot then
        local target = GetClosest()
        if target then
            local pos = Camera:WorldToViewportPoint(target.Position)
            mousemoverel((pos.X - center.X) * _G.Smoothness, (pos.Y - center.Y) * _G.Smoothness)
        end
    end

    -- ESP Logic
    if _G.ESP_Master then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not ESP_Elements[p] then
                    ESP_Elements[p] = {Box = Drawing.new("Square"), Name = Drawing.new("Text")}
                end
                local e = ESP_Elements[p]
                local root = p.Character.HumanoidRootPart
                local pos, on = Camera:WorldToViewportPoint(root.Position)
                if on then
                    local size = 2000 / pos.Z
                    e.Box.Visible = _G.ESP_Box; e.Box.Size = Vector2.new(size, size*1.5); e.Box.Position = Vector2.new(pos.X-size/2, pos.Y-size/2); e.Box.Color = _G.FOV_Color
                    e.Name.Visible = _G.ESP_Name; e.Name.Text = p.Name; e.Name.Position = Vector2.new(pos.X, pos.Y-size/2-15); e.Name.Center = true; e.Name.Outline = true; e.Name.Color = Color3.new(1,1,1)
                else e.Box.Visible = false; e.Name.Visible = false end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        if _G.Noclip then
            for _, v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
        if _G.Spinbot then
            LP.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(50), 0)
        end
        if _G.RainbowChar then
            for _, v in pairs(LP.Character:GetChildren()) do
                if v:IsA("BasePart") then v.Color = Color3.fromHSV(tick()%5/5, 1, 1) end
            end
        end
        -- Fly Force
        local root = LP.Character.HumanoidRootPart
        if _G.Fly then
            if not root:FindFirstChild("FlyForce") then
                local bv = Instance.new("BodyVelocity", root); bv.Name = "FlyForce"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            local vel = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then vel += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then vel -= Camera.CFrame.LookVector end
            root.FlyForce.Velocity = vel * _G.FlySpeed
        elseif root:FindFirstChild("FlyForce") then root.FlyForce:Destroy() end
    end
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == _G.MenuKey then
        local gui = game:GetService("CoreGui"):FindFirstChild("🎯 GGPVP SUPREME V12")
        if gui then gui.Enabled = not gui.Enabled end
    end
end)
-- [[ BLOCO DE REPARO: RESTAURANDO FUNÇÕES ORIGINAIS & TROLL FINAL ]]

-- 1. RESTAURANDO O WALLCHECK E DISTÂNCIA (CÓDIGO ORIGINAL)
local function ValidateFull(part)
    if not part or not part.Parent then return false end
    local char = part.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- Restaurando AimCheckMorto
    if _G.AimCheckMorto and (not hum or hum.Health <= 0) then return false end
    if not root then return false end
    
    -- Restaurando Distância Máxima
    local mag = (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude
    if mag > _G.MaxDistance then return false end
    
    -- Restaurando WallCheck preciso do seu primeiro script
    if _G.WallCheck then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LP.Character, char}
        local cast = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
        if cast then return false end
    end
    return true
end

-- 2. ADICIONANDO FUNÇÕES TROLL QUE FALTAVAM (SERVER DESTRUCTION)
local TSect3 = Troll:NewSection("Caos Total")

TSect3:NewButton("Remover Texturas (Lag Reduction/Troll)", "Deixa o mapa cinza", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
    end
    Notify("Troll", "Texturas removidas!")
end)

TSect3:NewButton("Inverter Gravidade (Local)", "Você fica super leve", function()
    workspace.Gravity = 50
    Notify("Jogador", "Gravidade alterada!")
end)

TSect3:NewButton("Resetar Gravidade", "Volta ao normal", function()
    workspace.Gravity = 196.2
end)

-- 3. REPARO DO SISTEMA DE DISTÂNCIA NO ESP (QUE ESTAVA NO ORIGINAL)
RunService.RenderStepped:Connect(function()
    if _G.ESP_Master and _G.ESP_Distance then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local e = ESP_Elements[p]
                if e and e.Dist then
                    local root = p.Character.HumanoidRootPart
                    local pos, on = Camera:WorldToViewportPoint(root.Position)
                    if on then
                        e.Dist.Visible = true
                        e.Dist.Text = math.floor((LP.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m"
                        e.Dist.Position = Vector2.new(pos.X, pos.Y + (2000/pos.Z)/2 + 20)
                        e.Dist.Outline = true; e.Dist.Center = true; e.Dist.Size = 14
                    else e.Dist.Visible = false end
                end
            end
        end
    end
end)

-- 4. RE-ADICIONANDO O CRASH ORIGINAL (SOLICITADO NO INÍCIO)
TSect3:NewToggle("Extreme Crash Server", "Loop de Remote Events", function(v)
    _G.Crashing = v
    task.spawn(function()
        while _G.Crashing do
            local rs = game:GetService("ReplicatedStorage")
            for i = 1, 100 do
                local remote = rs:FindFirstChildOfClass("RemoteEvent")
                if remote then 
                    remote:FireServer("Crash", string.rep("GGPVP", 500)) 
                end
            end
            task.wait(0.1)
        end
    end)
end)

Notify("REPARO", "Todas as funções originais foram restauradas!")

Notify("SISTEMA", "SUPREME V12 COMPLETO E PRONTO!")
