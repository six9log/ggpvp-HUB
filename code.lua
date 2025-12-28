-- [[ GGPVP PC EDITION | BY DNLL ]]
-- Focado em Precision Aimbot, Silent Aim e Visuals

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎯 GGPVP | PC PERFORMANCE",
   LoadingTitle = "Iniciando Módulos de Combate...",
   ConfigurationSaving = {Enabled = true, FolderName = "GGPVP_PC"}
})

-- [[ VARIÁVEIS DE COMBATE ]]
local LP = game.Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

_G.Aimbot = false
_G.AimbotSmoothness = 0.1 -- Quanto menor, mais rápido a mira trava
_G.SilentAim = false
_G.FOV = 150
_G.ShowFOV = true

-- [[ DESENHO DO FOV (VISUAL PC) ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

-- [[ ABAS ]]
local TabCombat = Window:CreateTab("Combate ⚔️")
local TabVisuals = Window:CreateTab("Visuals 👁️")
local TabSettings = Window:CreateTab("Ajustes ⚙️")

-- [[ ABA COMBATE ]]
TabCombat:CreateSection("Assistência de Mira")

TabCombat:CreateToggle({
   Name = "Aimbot Lock (Smooth)",
   CurrentValue = false,
   Callback = function(v) _G.Aimbot = v end
})

TabCombat:CreateToggle({
   Name = "Silent Aim (Hitbox)",
   CurrentValue = false,
   Callback = function(v) _G.SilentAim = v end
})

TabCombat:CreateSlider({
   Name = "Raio do FOV (Campo de Visão)",
   Min = 50, Max = 800, DefaultValue = 150,
   Callback = function(v) _G.FOV = v end
})

-- [[ ABA VISUALS ]]
TabVisuals:CreateSection("Espionagem")

TabVisuals:CreateToggle({
   Name = "ESP Players (Box)",
   CurrentValue = false,
   Callback = function(v) _G.PlayerESP = v end
})

TabVisuals:CreateToggle({
   Name = "Mostrar Círculo de Mira (FOV)",
   CurrentValue = true,
   Callback = function(v) _G.ShowFOV = v end
})

-- [[ LÓGICA DE PVP (EXECUÇÃO) ]]
task.spawn(function()
    while task.wait() do
        -- Atualiza Círculo FOV
        FOVCircle.Radius = _G.FOV
        FOVCircle.Visible = _G.ShowFOV
        FOVCircle.Position = game:GetService("GuiService"):GetScreenResolution() / 2 -- Centraliza no PC

        if _G.Aimbot then
            local target = nil
            local shortestDist = _G.FOV

            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if mouseDist < shortestDist then
                            target = p.Character.HumanoidRootPart
                            shortestDist = mouseDist
                        end
                    end
                end
            end

            if target then
                -- Movimento de câmera suave (Smoothness) para PC
                local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness)
            end
        end
    end
end)

-- [[ ABA AJUSTES ]]
TabSettings:CreateSection("Performance")
TabSettings:CreateButton({
    Name = "Otimizar FPS (Remove Sombras)",
    Callback = function()
        game:GetService("Lighting").GlobalShadows = false
        for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
            if v:IsA("PostEffect") then v.Enabled = false end
        end
    end
})

Rayfield:Notify({Title = "GGPVP PC LOADED", Content = "Use com sabedoria!", Duration = 5})
