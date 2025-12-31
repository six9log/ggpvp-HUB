-- [[ GGPVP | BY DNLL & SIX ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

--// CONFIGURAÇÕES (RESTAURADAS E COMPLETAS)
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
_G.Crashing = false

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// 1. TELA DE CARREGAMENTO (MINIMALISTA)
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
task.wait(1.5)
loader:Destroy()

--// 2. NOTIFICAÇÃO CANTO INFERIOR DIREITO
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
    task.delay(4, function() sg:Destroy() end)
end

Notify("CHEAT ATIVADO COM SUCESSO")

--// 3. JANELA PRINCIPAL
local Window = Library.CreateLib("GGPVP | BY DNLL & SIX", "DarkTheme")

--// 4. LÓGICA DE MINIMIZAR + DESTRAVAR MOUSE
local MenuVisible = true
local function ToggleMenu()
    MenuVisible = not MenuVisible
    local gui = CoreGui:FindFirstChild("GGPVP | BY DNLL & SIX")
    if gui then 
        gui.Enabled = MenuVisible
        -- Garante que o mouse destrave ao abrir o menu
        UIS.MouseIconEnabled = MenuVisible
        if MenuVisible then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        else
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end
end

--// 5. ABAS (TODAS AS FUNÇÕES ORIGINAIS RESTAURADAS)
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
TSect:NewKeybind("Bind do Fly", "Tecla para voar", Enum.KeyCode.F, function(key) _G.FlyKey = key end)

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

--// 6. LÓGICA DE VALIDAÇÃO (ORIGINAL COMPLETA)
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
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < shortest then shortest = mag; target = part end
            end
        end
    end
    return target
end

--// 7. SISTEMA ESP (DRAWING)
local ESP_Elements = {}
local function CreateESP(plr)
    if ESP_Elements[plr] then return end
    ESP_Elements[plr] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Dist = Drawing.new("Text")
    }
end

--// 8. LOOP PRINCIPAL
RunService.RenderStepped:Connect(function()
    local FOVCircle = Drawing.new("Circle") -- FOV visual
    FOVCircle.Visible = true; FOVCircle.Radius = _G.Fov; FOVCircle.Color = Color3.fromRGB(0, 255, 255); FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Transparency = 0.5
    task.delay(0.01, function() FOVCircle:Destroy() end)

    if _G.Aimbot then
        local target = GetClosest()
        if target then
            local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            if onScreen then
                mousemoverel((pos.X - center.X) * _G.Smoothness, (pos.Y - center.Y) * _G.Smoothness)
                local currentCF = Camera.CFrame
                Camera.CFrame = currentCF:Lerp(CFrame.new(currentCF.Position, target.Position), _G.Smoothness)
            end
        end
    end

    if _G.ESP_Master then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then
                if not ESP_Elements[p] then CreateESP(p) end
                local e = ESP_Elements[p]
                local char = p.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                    local root, hum = char.HumanoidRootPart, char.Humanoid
                    local pos, on = Camera:WorldToViewportPoint(root.Position)
                    if on and hum.Health > 0 then
                        local size = 2000 / pos.Z
                        e.Box.Visible = _G.ESP_Box; e.Box.Size = Vector2.new(size, size*1.5); e.Box.Position = Vector2.new(pos.X-size/2, pos.Y-size/2); e.Box.Color = Color3.new(1,0,0)
                        e.Name.Visible = _G.ESP_Name; e.Name.Text = p.Name; e.Name.Position = Vector2.new(pos.X, pos.Y-size/2-15); e.Name.Center = true; e.Name.Outline = true
                        e.Health.Visible = _G.ESP_Health; e.Health.Text = "HP: "..math.floor(hum.Health); e.Health.Position = Vector2.new(pos.X, pos.Y+size/2+5); e.Health.Center = true; e.Health.Outline = true
                        e.Dist.Visible = _G.ESP_Distance; e.Dist.Text = math.floor((LP.Character.HumanoidRootPart.Position-root.Position).Magnitude).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y+size/2+20); e.Dist.Center = true; e.Dist.Outline = true
                    else e.Box.Visible = false; e.Name.Visible = false; e.Health.Visible = false; e.Dist.Visible = false end
                end
            end
        end
    end
end)

--// 9. EVENTOS (BINDS E FECHAR)
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Home then ToggleMenu() end
    if not gpe and input.KeyCode == _G.FlyKey then
        _G.Fly = not _G.Fly
        Notify("FLY: " .. (_G.Fly and "ON" or "OFF"))
    end
end)

RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if _G.Fly and root then
            if not root:FindFirstChild("FlyForce") then
                local bv = Instance.new("BodyVelocity", root); bv.Name = "FlyForce"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            local v = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then v += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then v -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then v -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then v += Camera.CFrame.RightVector end
            root.FlyForce.Velocity = v * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyForce") then root.FlyForce:Destroy() end
    end
end)
