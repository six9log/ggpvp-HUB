-- [[ GGPVP | BY DNLL & SIX ]]
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
_G.Crashing = false

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// 1. TELA DE CARREGAMENTO (LOADING)
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
    task.delay(4, function() sg:Destroy() end)
end

Notify("CHEAT ATIVADO COM SUCESSO")

--// 3. INTERFACE E CONTROLE DO MOUSE
local Window = Library.CreateLib("GGPVP | BY DNLL & SIX", "DarkTheme")
local MenuVisible = true

local function ToggleMenu()
    MenuVisible = not MenuVisible
    local gui = CoreGui:FindFirstChild("GGPVP | BY DNLL & SIX")
    if gui then 
        gui.Enabled = MenuVisible
        UIS.MouseIconEnabled = MenuVisible
        UIS.MouseBehavior = MenuVisible and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
    end
end

--// 4. VALIDAÇÃO DE ALVO (RESTAURADA DO ORIGINAL)
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

--// ABAS
local Combat = Window:NewTab("Combate")
local CSect = Combat:NewSection("Aimbot Supreme")
CSect:NewToggle("Ativar Aimbot", "Mira automática", function(v) _G.Aimbot = v end)
CSect:NewDropdown("Focar em:", "Parte do corpo", {"Head", "UpperTorso", "HumanoidRootPart"}, function(v) _G.TargetPart = v end)
CSect:NewToggle("Wall Check", "Verifica paredes", function(v) _G.WallCheck = v end)
CSect:NewSlider("Raio do FOV", "FOV", 800, 50, function(v) _G.Fov = v end)
CSect:NewSlider("Suavidade", "Smoothness", 100, 1, function(v) _G.Smoothness = v/100 end)

local Visual = Window:NewTab("Visual")
local VSect = Visual:NewSection("ESP Completo")
VSect:NewToggle("Mestre ESP", "Ligar Visual", function(v) _G.ESP_Master = v end)
VSect:NewToggle("Boxes", "Quadrados", function(v) _G.ESP_Box = v end)
VSect:NewToggle("Nomes", "Identificação", function(v) _G.ESP_Name = v end)
VSect:NewToggle("Vida", "Barra de HP", function(v) _G.ESP_Health = v end)
VSect:NewToggle("Distância", "Metros", function(v) _G.ESP_Distance = v end)

local Troll = Window:NewTab("Troll")
local TSect = Troll:NewSection("Server & Move")
TSect:NewSlider("Velocidade", "WalkSpeed", 500, 16, function(v) _G.Speed = v end)
TSect:NewKeybind("Atalho Fly", "Tecla Voo", Enum.KeyCode.F, function(k) _G.FlyKey = k end)
TSect:NewButton("CRASH SERVER", "Spam de Remotos", function()
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
end)

--// LOOPS E ESP (RESTAURADOS)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.fromRGB(0, 255, 255); FOVCircle.Visible = true

local ESP_Elements = {}
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = _G.Fov
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    if _G.Aimbot then
        local target = nil; local shortest = _G.Fov
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild(_G.TargetPart) then
                local p = v.Character[_G.TargetPart]
                local pos, screen = Camera:WorldToViewportPoint(p.Position)
                if screen and Validate(p) then
                    local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                    if mag < shortest then shortest = mag; target = p end
                end
            end
        end
        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, _G.Smoothness)
        end
    end

    -- ESP Lógica Original
    if _G.ESP_Master then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not ESP_Elements[p] then 
                    ESP_Elements[p] = {Box = Drawing.new("Square"), Name = Drawing.new("Text"), Health = Drawing.new("Text"), Dist = Drawing.new("Text")}
                end
                local e = ESP_Elements[p]
                local root, hum = p.Character.HumanoidRootPart, p.Character.Humanoid
                local pos, on = Camera:WorldToViewportPoint(root.Position)
                if on then
                    local size = 2000 / pos.Z
                    e.Box.Visible = _G.ESP_Box; e.Box.Size = Vector2.new(size, size*1.5); e.Box.Position = Vector2.new(pos.X-size/2, pos.Y-size/2); e.Box.Color = Color3.new(1,0,0)
                    e.Name.Visible = _G.ESP_Name; e.Name.Text = p.Name; e.Name.Position = Vector2.new(pos.X, pos.Y-size/2-15); e.Name.Center = true; e.Name.Outline = true
                    e.Health.Visible = _G.ESP_Health; e.Health.Text = "HP: "..math.floor(hum.Health); e.Health.Position = Vector2.new(pos.X, pos.Y+size/2+5); e.Health.Center = true; e.Health.Outline = true
                    e.Dist.Visible = _G.ESP_Distance; e.Dist.Text = math.floor((LP.Character.HumanoidRootPart.Position - root.Position).Magnitude).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y+size/2+20); e.Dist.Center = true; e.Dist.Outline = true
                else e.Box.Visible = false; e.Name.Visible = false; e.Health.Visible = false; e.Dist.Visible = false end
            end
        end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Home then ToggleMenu() end
    if not gpe and input.KeyCode == _G.FlyKey then _G.Fly = not _G.Fly; Notify("FLY: " .. (_G.Fly and "ON" or "OFF")) end
end)

-- Loop de Fly/Speed
RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = _G.Speed
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if _G.Fly and root then
            if not root:FindFirstChild("FlyForce") then local bv = Instance.new("BodyVelocity", root); bv.Name = "FlyForce"; bv.MaxForce = Vector3.new(9e9,9e9,9e9) end
            local v = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then v += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then v -= Camera.CFrame.LookVector end
            root.FlyForce.Velocity = v * _G.FlySpeed
        elseif root and root:FindFirstChild("FlyForce") then root.FlyForce:Destroy() end
    end
end)
