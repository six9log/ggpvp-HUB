-- [[ GGPVP HUB - VERSÃO DEFINITIVA SELIWARE CONSERTADA ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

-- VARIÁVEIS DE CONTROLE GLOBAIS
_G.Aimbot = false
_G.AimbotPart = "Head"
_G.AimbotFOV = 120
_G.AimbotSmoothness = 0.15
_G.WallCheck = true
_G.SilentAim = false
_G.ESP = false
_G.Speed = 16
_G.JumpPower = 50
_G.FlyEnabled = false
_G.FlySpeed = 50
_G.HitboxSize = 2
_G.Noclip = false
_G.SpinBot = false
_G.ChatSpam = false
_G.KillAura = false
_G.AuraRange = 20
_G.AutoFarm = false
_G.FarmTarget = "Coin"
_G.Prefix = ";"

-- DRAWING API (Círculo do Aimbot)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 460
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

-- [[ INTERFACE DO USUÁRIO ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GGPVP_GUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Position = UDim2.new(0.5, -225, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.Text = "GGPVP HUB - SELIWARE EDITION"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Scroll.ScrollBarThickness = 4
Scroll.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 70, 0, 70)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.Text = "GGPVP"
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Parent = ScreenGui
OpenBtn.Draggable = true
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- FUNÇÕES DE CRIAÇÃO (CORRIGIDO: ADICIONADO NEWTOGGLE)
local function NewButton(txt, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = Scroll
    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

local function NewToggle(parent, txt, var)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = txt .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = parent
    btn.MouseButton1Click:Connect(function()
        _G[var] = not _G[var]
        btn.Text = txt .. (_G[var] and ": ON" or ": OFF")
        btn.BackgroundColor3 = _G[var] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
end

local function NewInput(placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.9, 0, 0, 35)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = Scroll
    box.FocusLost:Connect(function() callback(box.Text) end)
end

-- [[ LÓGICA DE COMBATE ]]
local function GetClosestPlayer()
    local target = nil
    local dist = _G.AimbotFOV
    local mouse = UserInputService:GetMouseLocation()

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(_G.AimbotPart) and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character[_G.AimbotPart].Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if magnitude < dist then
                    if _G.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (v.Character[_G.AimbotPart].Position - Camera.CFrame.Position).Unit * 1000)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                        if hit and hit:IsDescendantOf(v.Character) then
                            dist = magnitude
                            target = v.Character[_G.AimbotPart]
                        end
                    else
                        dist = magnitude
                        target = v.Character[_G.AimbotPart]
                    end
                end
            end
        end
    end
    return target
end

-- HOOKING PARA SILENT AIM (PROTEGIDO)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and _G.SilentAim and method == "FireServer" and tostring(self):find("Shoot") then
        local t = GetClosestPlayer()
        if t then args[1] = t.Position end
    end
    return oldNamecall(self, table.unpack(args))
end)
setreadonly(mt, true)

-- [[ MOVIMENTAÇÃO E FÍSICA ]]
local BV = Instance.new("BodyVelocity")
local BG = Instance.new("BodyGyro")
BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Root = LocalPlayer.Character.HumanoidRootPart
        local Hum = LocalPlayer.Character.Humanoid

        Hum.WalkSpeed = _G.Speed
        Hum.JumpPower = _G.JumpPower

        if _G.FlyEnabled then
            BV.Parent = Root
            BG.Parent = Root
            BG.CFrame = Camera.CFrame
            local Dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + Camera.CFrame.RightVector end
            BV.Velocity = Dir * _G.FlySpeed
        else
            BV.Parent = nil
            BG.Parent = nil
        end

        if _G.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
    
    -- LOOP AIMBOT
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Visible = _G.Aimbot
    if _G.Aimbot then
        local target = GetClosestPlayer()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), _G.AimbotSmoothness)
        end
    end
end)

-- [[ TROLLS E AUTOMAÇÃO ]]
task.spawn(function()
    while task.wait(0.1) do
        if _G.SpinBot and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(50), 0)
        end
        if _G.KillAura and LocalPlayer.Character then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= _G.AuraRange then
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end
        if _G.AutoFarm and LocalPlayer.Character then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find(_G.FarmTarget:lower()) then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v, 1)
                end
            end
        end
    end
end)

-- [[ BOTÕES E FINALIZAÇÃO ]]
NewButton("Ativar Aimbot", function(b)
    _G.Aimbot = not _G.Aimbot
    b.Text = _G.Aimbot and "Aimbot: ON" or "Aimbot: OFF"
    b.BackgroundColor3 = _G.Aimbot and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

NewToggle(Scroll, "Silent Aim", "SilentAim")
NewInput("Velocidade (16)", function(t) _G.Speed = tonumber(t) or 16 end)
NewInput("Pulo (50)", function(t) _G.JumpPower = tonumber(t) or 50 end)
NewToggle(Scroll, "Ativar Fly", "FlyEnabled")
NewToggle(Scroll, "Ativar Noclip", "Noclip")
NewToggle(Scroll, "Ativar SpinBot", "SpinBot")
NewToggle(Scroll, "Kill Aura", "KillAura")
NewInput("Alvo Farm", function(t) _G.FarmTarget = t end)
NewToggle(Scroll, "Auto Farm", "AutoFarm")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "GGPVP HUB";
    Text = "Executado e Consertado!";
    Duration = 5;
})
print("GGPVP ULTIMATE CARREGADO!")
