-- [[ GGPVP HUB - VERSÃO DEFINITIVA DELTA ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- [[ VARIÁVEIS DE CONTROLE ]]
_G.Aimbot = false
_G.WallCheck = true
_G.ESP = false
_G.Speed = 16

-- [[ INTERFACE SIMPLES (NÃO BUGAR NO DELTA) ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GGPVP_DELTA"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Botão de Minimizar
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
OpenBtn.Text = "GGPVP"
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Parent = ScreenGui
OpenBtn.Draggable = true

-- Painel
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 180, 0, 200)
Main.Position = UDim2.new(0.3, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UIList = Instance.new("UIListLayout")
UIList.Parent = Main
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function NewButton(txt, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = Main
    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

local function NewInput(placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.9, 0, 0, 40)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Parent = Main
    box.FocusLost:Connect(function() callback(box.Text) end)
end

-- Botões
NewButton("Aimbot: OFF", function(b)
    _G.Aimbot = not _G.Aimbot
    b.Text = _G.Aimbot and "Aimbot: ON" or "Aimbot: OFF"
    b.BackgroundColor3 = _G.Aimbot and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

NewButton("WallCheck: ON", function(b)
    _G.WallCheck = not _G.WallCheck
    b.Text = _G.WallCheck and "WallCheck: ON" or "WallCheck: OFF"
end)

NewButton("ESP Chams: OFF", function(b)
    _G.ESP = not _G.ESP
    b.Text = _G.ESP and "ESP: ON" or "ESP: OFF"
end)

NewInput("Velocidade (Ex: 50)", function(t) _G.Speed = tonumber(t) or 16 end)

OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [[ LÓGICA DE ALVO ]]
local function IsVisible(part)
    if not _G.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char, Camera})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

local function GetClosest()
    local target = nil
    local shortestDist = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local head = v.Character.Head
            local dist = (myRoot.Position - head.Position).Magnitude
            if dist < shortestDist and IsVisible(head) then
                shortestDist = dist
                target = head
            end
        end
    end
    return target
end

-- [[ LOOP PRINCIPAL ]]
RunService.RenderStepped:Connect(function()
    -- AIMBOT NA CABEÇA
    if _G.Aimbot then
        local target = GetClosest()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, 0.15)
        end
    end

    -- VELOCIDADE
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.Speed
    end

    -- ESP CHAMS
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local h = v.Character:FindFirstChild("GGPVP_ESP")
            if _G.ESP and v.Team ~= LocalPlayer.Team and v.Character.Humanoid.Health > 0 then
                if not h then
                    h = Instance.new("Highlight", v.Character)
                    h.Name = "GGPVP_ESP"
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                end
            else
                if h then h:Destroy() end
            end
        end
    end
end)
