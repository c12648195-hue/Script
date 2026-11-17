local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer

local onScreenButton
local AimbotToggleRef
local Rayfield

local Config = {
    AimbotEnabled    = false,
    ButtonLocked     = false,
    AimPart          = "Head",
    AimFOV           = 200,
    AimSmoothness    = 0.25,
    WallCheck        = true,
    ShowFOV          = false,
    FOVColor         = Color3.fromRGB(255, 80, 80),
    ESPEnabled       = false,
    ESPColor         = Color3.fromRGB(255, 60, 60),
    OffscreenEnabled = true,
    OffscreenRange   = 300,
    OffscreenSize    = 22,
    OffscreenColor   = Color3.fromRGB(255, 40, 40),
    OffscreenWallCheck = true,
    ButtonSize       = 44,
    ButtonColorOn    = Color3.fromRGB(0, 170, 90),
    ButtonColorOff   = Color3.fromRGB(200, 50, 50),
}

local function getGuiParent()
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then return hui end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function updateOnScreenButtonVisual()
    if not onScreenButton then return end
    onScreenButton.Size = UDim2.new(0, Config.ButtonSize, 0, Config.ButtonSize)
    onScreenButton.TextSize = math.clamp(math.floor(Config.ButtonSize * 0.32), 8, 22)
    if Config.AimbotEnabled then
        onScreenButton.BackgroundColor3 = Config.ButtonColorOn
        onScreenButton.Text = "AIMBOT: ON"
    else
        onScreenButton.BackgroundColor3 = Config.ButtonColorOff
        onScreenButton.Text = "AIMBOT: OFF"
    end
end

local function setAimbotState(newState)
    Config.AimbotEnabled = newState
    if AimbotToggleRef then
        pcall(function() AimbotToggleRef:Set(newState) end)
    end
    updateOnScreenButtonVisual()
end

local function createOnScreenButton()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZSHOOT_Gui"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999999
    sg.Enabled = true
    pcall(function() sg.Parent = getGuiParent() end)
    if not sg.Parent then
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local watermark = Instance.new("TextLabel")
    watermark.Name = "ZSHOOT_Watermark"
    watermark.Size = UDim2.new(0, 320, 0, 22)
    watermark.Position = UDim2.new(0, 10, 0, 10)
    watermark.BackgroundTransparency = 1
    watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
    watermark.TextStrokeTransparency = 0
    watermark.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    watermark.Font = Enum.Font.GothamBold
    watermark.TextSize = 16
    watermark.TextXAlignment = Enum.TextXAlignment.Left
    watermark.Text = "ZSHOOT | Criador: cauãzin"
    watermark.Parent = sg

    local btn = Instance.new("TextButton")
    btn.Name = "ZSHOOT_AimbotBtn"
    btn.Size = UDim2.new(0, Config.ButtonSize, 0, Config.ButtonSize)
    btn.Position = UDim2.new(0, 20, 0.5, -22)
    btn.BackgroundColor3 = Config.ButtonColorOff
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = math.clamp(math.floor(Config.ButtonSize * 0.32), 8, 22)
    btn.Text = "AIMBOT: OFF"
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.Visible = true
    btn.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(0, 0, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.4
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        setAimbotState(not Config.AimbotEnabled)
    end)

    local dragging = false
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if Config.ButtonLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return btn
end

onScreenButton = createOnScreenButton()

local rayfieldOK = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if rayfieldOK and Rayfield then
    local Window = Rayfield:CreateWindow({
        Name = "ZSHOOT | por cauãzin",
        LoadingTitle = "ZSHOOT",
        LoadingSubtitle = "Criador: cauãzin",
        Theme = "Default",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false,
    })

    local CombatTab = Window:CreateTab("Combate", nil)
    CombatTab:CreateSection("Aimbot")

    CombatTab:CreateParagraph({
        Title = "Como funciona o Aimbot",
        Content = "Quando ligado, o Aimbot puxa sua mira automaticamente para o jogador mais próximo do centro da tela (dentro do FOV). Se houver duas pessoas na tela, ele escolhe a que estiver mais perto da sua mira central. Para funcionar de forma 'travada' coloque a Suavidade no valor máximo (1).",
    })

    AimbotToggleRef = CombatTab:CreateToggle({
        Name = "Ativar Aimbot",
        CurrentValue = false,
        Flag = "AimbotToggle",
        Callback = function(v)
            Config.AimbotEnabled = v
            updateOnScreenButtonVisual()
        end,
    })

    CombatTab:CreateSlider({
        Name = "FOV do Aimbot (área de mira)",
        Range = {10, 800}, Increment = 10, Suffix = "px",
        CurrentValue = 200, Flag = "AimbotFOV",
        Callback = function(v) Config.AimFOV = v end,
    })

    CombatTab:CreateParagraph({
        Title = "O que é FOV?",
        Content = "FOV é o círculo invisível no centro da tela. Quanto MAIOR o valor, mais longe do centro o Aimbot consegue achar alvos. Quanto MENOR, mais preciso.",
    })

    CombatTab:CreateSlider({
        Name = "Suavidade (Smoothness)",
        Range = {0.02, 1}, Increment = 0.01,
        CurrentValue = 0.25, Flag = "AimbotSmooth",
        Callback = function(v) Config.AimSmoothness = v end,
    })

    CombatTab:CreateParagraph({
        Title = "O que é Suavidade?",
        Content = "É a velocidade com que a mira se move até o alvo. Perto de 1 = trava instantâneo. Perto de 0.02 = a mira desliza devagar. Se quiser que a mira 'prenda' na pessoa, use valor 1.",
    })

    CombatTab:CreateDropdown({
        Name = "Parte do Corpo (onde mirar)",
        Options = {"Head", "HumanoidRootPart", "Torso"},
        CurrentOption = "Head", Flag = "AimPartDropdown",
        Callback = function(opt) Config.AimPart = opt end,
    })

    CombatTab:CreateParagraph({
        Title = "Partes do corpo",
        Content = "Head = cabeça (mais preciso). HumanoidRootPart = centro do corpo (mais fácil em movimento). Torso = peito/abdômen.",
    })

    CombatTab:CreateToggle({
        Name = "Wall Check (não mira atrás de parede)",
        CurrentValue = true, Flag = "WallCheckToggle",
        Callback = function(v) Config.WallCheck = v end,
    })

    CombatTab:CreateParagraph({
        Title = "O que é Wall Check?",
        Content = "Impede o Aimbot de mirar em jogadores atrás de paredes. Se ligado, só mira em quem você consegue VER.",
    })

    CombatTab:CreateToggle({
        Name = "Mostrar Círculo FOV",
        CurrentValue = false, Flag = "ShowFOVToggle",
        Callback = function(v) Config.ShowFOV = v end,
    })

    local ESPTab = Window:CreateTab("Visual (ESP)", nil)
    ESPTab:CreateSection("ESP (destaque dos jogadores)")

    ESPTab:CreateToggle({
        Name = "Ativar ESP",
        CurrentValue = false, Flag = "ESPToggle",
        Callback = function(v) Config.ESPEnabled = v end,
    })

    ESPTab:CreateParagraph({
        Title = "O que é ESP?",
        Content = "ESP deixa todos os jogadores com um contorno colorido visível através das paredes. Serve para localizar todo mundo no mapa, mesmo escondidos.",
    })

    ESPTab:CreateSection("Setinha de Alvo (Offscreen)")

    ESPTab:CreateToggle({
        Name = "Ativar Setinha de Alvo",
        CurrentValue = true, Flag = "OffscreenToggle",
        Callback = function(v) Config.OffscreenEnabled = v end,
    })

    ESPTab:CreateParagraph({
        Title = "Como funciona a Setinha (atualizada)",
        Content = "A setinha aparece na BORDA da tela apontando para o jogador VISÍVEL mais próximo de você que NÃO está no seu campo de visão. Ela SÓ aparece se: (1) o jogador estiver dentro do Alcance configurado, e (2) NÃO houver parede entre você e ele. Se o mais próximo estiver atrás de parede, ela ignora e procura o próximo visível. Se ninguém estiver visível dentro do alcance, a setinha desaparece.",
    })

    ESPTab:CreateSlider({
        Name = "Alcance da Setinha",
        Range = {50, 1000}, Increment = 25, Suffix = " studs",
        CurrentValue = 300, Flag = "OffscreenRange",
        Callback = function(v) Config.OffscreenRange = v end,
    })

    ESPTab:CreateParagraph({
        Title = "Alcance",
        Content = "Distância máxima (studs) para a setinha aparecer. Se o jogador mais próximo visível estiver além desse valor, a setinha não aparece. Aumente para avisar de jogadores mais longe, diminua para focar só nos que estão perto.",
    })

    ESPTab:CreateToggle({
        Name = "Setinha só com visão livre (sem parede)",
        CurrentValue = true, Flag = "OffscreenWallToggle",
        Callback = function(v) Config.OffscreenWallCheck = v end,
    })

    ESPTab:CreateParagraph({
        Title = "Visão livre",
        Content = "Se LIGADO, a setinha só aparece para jogadores que você consegue VER (sem parede no caminho). Se DESLIGADO, ela mostra o mais próximo mesmo que esteja atrás de parede.",
    })

    ESPTab:CreateSlider({
        Name = "Tamanho da Setinha",
        Range = {10, 60}, Increment = 1, Suffix = " px",
        CurrentValue = 22, Flag = "OffscreenSize",
        Callback = function(v) Config.OffscreenSize = v end,
    })

    ESPTab:CreateParagraph({
        Title = "Tamanho",
        Content = "Tamanho visual do triângulo/seta na borda da tela.",
    })

    local ButtonTab = Window:CreateTab("Botão na Tela", nil)
    ButtonTab:CreateSection("Aparência")

    ButtonTab:CreateSlider({
        Name = "Tamanho do Botão",
        Range = {30, 200}, Increment = 1, Suffix = " px",
        CurrentValue = 44, Flag = "ButtonSizeSlider",
        Callback = function(v)
            Config.ButtonSize = v
            updateOnScreenButtonVisual()
        end,
    })

    ButtonTab:CreateParagraph({
        Title = "Tamanho do botão",
        Content = "Aumente para deixar o botão do Aimbot na tela maior. O texto se ajusta automaticamente.",
    })

    ButtonTab:CreateColorPicker({
        Name = "Cor (Aimbot LIGADO)",
        Color = Config.ButtonColorOn,
        Flag = "ButtonColorOnPicker",
        Callback = function(color)
            Config.ButtonColorOn = color
            updateOnScreenButtonVisual()
        end,
    })

    ButtonTab:CreateColorPicker({
        Name = "Cor (Aimbot DESLIGADO)",
        Color = Config.ButtonColorOff,
        Flag = "ButtonColorOffPicker",
        Callback = function(color)
            Config.ButtonColorOff = color
            updateOnScreenButtonVisual()
        end,
    })

    ButtonTab:CreateSection("Comportamento")

    ButtonTab:CreateToggle({
        Name = "Travar botão (não arrastar)",
        CurrentValue = false, Flag = "ButtonLockToggle",
        Callback = function(v) Config.ButtonLocked = v end,
    })

    ButtonTab:CreateParagraph({
        Title = "Travar posição",
        Content = "Se ligado, você não consegue arrastar o botão. Bom para quando já posicionou ele onde queria.",
    })

    pcall(function()
        Rayfield:Notify({
            Title = "ZSHOOT",
            Content = "Script criado por cauãzin. Bom jogo!",
            Duration = 6,
        })
    end)
else
    warn("[ZSHOOT] Rayfield falhou ao carregar. Botão ainda funciona. Criador: cauãzin.")
end

local function isVisible(part)
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    local origin = cam.CFrame.Position
    local dir = (part.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local result = Workspace:Raycast(origin, dir, rayParams)
    return result == nil
end

local function getClosestTarget()
    local closest, shortestDist = nil, math.huge
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local part = char:FindFirstChild(Config.AimPart)
        if not part then continue end

        local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > Config.AimFOV then continue end
        if Config.WallCheck and not isVisible(part) then continue end

        if dist < shortestDist then
            shortestDist = dist
            closest = part
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not Config.AimbotEnabled then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local target = getClosestTarget()
    if not target then return end

    local currentCFrame = cam.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, target.Position)
    cam.CFrame = currentCFrame:Lerp(targetCFrame, math.clamp(Config.AimSmoothness, 0.01, 1))
end)

local fovCircle
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.Color     = Config.FOVColor
    fovCircle.Filled    = false
    fovCircle.Visible   = false
end)

RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    if Config.ShowFOV and Config.AimbotEnabled then
        fovCircle.Visible  = true
        fovCircle.Radius   = Config.AimFOV / 2
        fovCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    else
        fovCircle.Visible  = false
    end
end)

local offscreenTriangle
local offscreenLabel
pcall(function()
    offscreenTriangle = Drawing.new("Triangle")
    offscreenTriangle.Thickness = 1
    offscreenTriangle.Filled = true
    offscreenTriangle.Color = Config.OffscreenColor
    offscreenTriangle.Visible = false

    offscreenLabel = Drawing.new("Text")
    offscreenLabel.Size = 14
    offscreenLabel.Center = true
    offscreenLabel.Outline = true
    offscreenLabel.Color = Color3.new(1, 1, 1)
    offscreenLabel.OutlineColor = Color3.new(0, 0, 0)
    offscreenLabel.Visible = false
end)

-- Retorna o jogador VISÍVEL mais próximo dentro do alcance (ou nil)
local function getClosestVisiblePlayerForOffscreen()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local camPos = cam.CFrame.Position

    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local dist = (hrp.Position - camPos).Magnitude
        if dist <= Config.OffscreenRange then
            table.insert(list, {hrp = hrp, dist = dist})
        end
    end

    table.sort(list, function(a, b) return a.dist < b.dist end)

    for _, entry in ipairs(list) do
        if Config.OffscreenWallCheck then
            if isVisible(entry.hrp) then
                return entry.hrp, entry.dist
            end
        else
            return entry.hrp, entry.dist
        end
    end

    return nil
end

RunService.RenderStepped:Connect(function()
    if not offscreenTriangle or not offscreenLabel then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    if not Config.OffscreenEnabled then
        offscreenTriangle.Visible = false
        offscreenLabel.Visible = false
        return
    end

    local targetPart, targetDist = getClosestVisiblePlayerForOffscreen()
    if not targetPart then
        offscreenTriangle.Visible = false
        offscreenLabel.Visible = false
        return
    end

    local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local margin = 40
    local isBehind = screenPos.Z < 0
    local sx, sy = screenPos.X, screenPos.Y

    if isBehind then
        sx = vp.X - sx
        sy = vp.Y - sy
    end

    local onScreenStrict = onScreen and sx > margin and sx < vp.X - margin and sy > margin and sy < vp.Y - margin
    if onScreenStrict then
        offscreenTriangle.Visible = false
        offscreenLabel.Visible = false
        return
    end

    local dx = sx - center.X
    local dy = sy - center.Y
    if isBehind then
        dx = -dx
        dy = -dy
    end

    local angle = math.atan2(dy, dx)
    local halfW = vp.X / 2 - margin
    local halfH = vp.Y / 2 - margin
    local dirX, dirY = math.cos(angle), math.sin(angle)
    local scaleX = halfW / math.max(math.abs(dirX), 0.0001)
    local scaleY = halfH / math.max(math.abs(dirY), 0.0001)
    local scale = math.min(scaleX, scaleY)

    local ex = center.X + dirX * scale
    local ey = center.Y + dirY * scale
    local size = Config.OffscreenSize

    local p1 = Vector2.new(ex + dirX * size, ey + dirY * size)
    local perpX, perpY = -dirY, dirX
    local p2 = Vector2.new(ex - dirX * size * 0.3 + perpX * size * 0.7, ey - dirY * size * 0.3 + perpY * size * 0.7)
    local p3 = Vector2.new(ex - dirX * size * 0.3 - perpX * size * 0.7, ey - dirY * size * 0.3 - perpY * size * 0.7)

    offscreenTriangle.PointA = p1
    offscreenTriangle.PointB = p2
    offscreenTriangle.PointC = p3
    offscreenTriangle.Color = Config.OffscreenColor
    offscreenTriangle.Visible = true

    offscreenLabel.Text = tostring(math.floor(targetDist)) .. "m"
    offscreenLabel.Position = Vector2.new(ex - dirX * (size + 18), ey - dirY * (size + 18))
    offscreenLabel.Visible = true
end)

local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end
    local h = Instance.new("Highlight")
    h.Name = "ESP_" .. player.Name
    h.FillColor = Config.ESPColor
    h.FillTransparency = 0.6
    h.OutlineColor = Color3.new(1, 1, 1)
    h.OutlineTransparency = 0
    h.Enabled = false
    pcall(function() h.Parent = getGuiParent() end)
    if not h.Parent then
        h.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    espObjects[player] = h
end

local function removeESP(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    for player, hl in pairs(espObjects) do
        if not Config.ESPEnabled then
            hl.Enabled = false
            continue
        end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            hl.Adornee = char
            hl.Enabled = true
        else
            hl.Enabled = false
        end
    end
end)
