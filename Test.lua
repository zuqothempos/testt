-- ═══════════════════════════════════════
--        MA BIBLIOTHÈQUE GUI - v2.0
-- ═══════════════════════════════════════

local Library = {}
Library.__index = Library

-- ═══════════════════════════════════════
--         SYSTÈME DE CLÉS
-- ═══════════════════════════════════════
local KeySystem = {
    -- Ajoute tes clés ici
    PremiumKeys = {
        "PREMIUM-XXXX-YYYY-ZZZZ",
        "PREMIUM-AAAA-BBBB-CCCC",
    },
    AdminKeys = {
        "ADMIN-1234-5678-9012",
        "ADMIN-ABCD-EFGH-IJKL",
    },
    FreeKeys = {
        "FREE-0000-0000-0001",
        "FREE-0000-0000-0002",
    }
}

local function checkKey(key)
    for _, v in ipairs(KeySystem.AdminKeys) do
        if v == key then return "Admin" end
    end
    for _, v in ipairs(KeySystem.PremiumKeys) do
        if v == key then return "Premium" end
    end
    for _, v in ipairs(KeySystem.FreeKeys) do
        if v == key then return "Free" end
    end
    return nil
end

local KeyColors = {
    Admin   = Color3.fromRGB(255, 80,  80),
    Premium = Color3.fromRGB(255, 200, 50),
    Free    = Color3.fromRGB(100, 200, 100),
}
local KeyIcons = {
    Admin   = "👑 Admin",
    Premium = "⭐ Premium",
    Free    = "🔓 Free",
}

-- ═══════════════════════════════════════
--              CONFIGURATION
-- ═══════════════════════════════════════
local CONFIG = {
    Background    = Color3.fromRGB(20, 20, 30),
    TopBar        = Color3.fromRGB(30, 30, 45),
    TabBar        = Color3.fromRGB(25, 25, 38),
    TabActive     = Color3.fromRGB(80, 120, 255),
    TabInactive   = Color3.fromRGB(40, 40, 60),
    Element       = Color3.fromRGB(35, 35, 52),
    ElementHover  = Color3.fromRGB(50, 50, 75),
    ToggleOn      = Color3.fromRGB(80, 200, 120),
    ToggleOff     = Color3.fromRGB(60, 60, 80),
    SliderFill    = Color3.fromRGB(80, 120, 255),
    Text          = Color3.fromRGB(255, 255, 255),
    TextDim       = Color3.fromRGB(160, 160, 180),
    Border        = Color3.fromRGB(60, 60, 90),
    Dropdown      = Color3.fromRGB(28, 28, 42),
    ProfileBg     = Color3.fromRGB(25, 25, 40),

    WindowWidth   = 520,
    WindowHeight  = 400,
    ProfileHeight = 70,
    TabHeight     = 30,
    ElementHeight = 36,
    CornerRadius  = UDim.new(0, 6),
}

local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer

-- ═══════════════════════════════════════
--           FONCTIONS UTILITAIRES
-- ═══════════════════════════════════════
local function tween(obj, props, duration, style, direction)
    TweenService:Create(obj, TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    ), props):Play()
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or CONFIG.CornerRadius
    c.Parent = parent
    return c
end

local function addPadding(parent, all, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or all or 0)
    p.PaddingRight  = UDim.new(0, r or all or 0)
    p.PaddingTop    = UDim.new(0, t or all or 0)
    p.PaddingBottom = UDim.new(0, b or all or 0)
    p.Parent = parent
    return p
end

local function addListLayout(parent, padding, direction)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 6)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.Border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos = false
    handle = handle or frame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function getTime()
    local t = os.date("*t")
    return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

-- ═══════════════════════════════════════
--        ÉCRAN DE SAISIE DE CLÉ
-- ═══════════════════════════════════════
local function showKeyScreen(callback)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeyScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game.CoreGui

    -- Fond flouté
    local blur = Instance.new("Frame")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blur.BackgroundTransparency = 0.5
    blur.BorderSizePixel = 0
    blur.Parent = screenGui

    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 360, 0, 200)
    keyFrame.Position = UDim2.new(0.5, -180, 0.5, -100)
    keyFrame.BackgroundColor3 = CONFIG.Background
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = screenGui
    addCorner(keyFrame, UDim.new(0, 10))
    addStroke(keyFrame, CONFIG.Border, 1)

    -- Animation entrée
    keyFrame.Size = UDim2.new(0, 0, 0, 0)
    keyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(keyFrame, {
        Size = UDim2.new(0, 360, 0, 200),
        Position = UDim2.new(0.5, -180, 0.5, -100)
    }, 0.4, Enum.EasingStyle.Back)

    -- Titre
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "🔑  Entrez votre clé"
    title.TextColor3 = CONFIG.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = keyFrame

    -- Sous-titre
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 20)
    sub.Position = UDim2.new(0, 10, 0, 45)
    sub.BackgroundTransparency = 1
    sub.Text = "Clé Free / Premium / Admin"
    sub.TextColor3 = CONFIG.TextDim
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.Parent = keyFrame

    -- Input clé
    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1, -40, 0, 36)
    inputBg.Position = UDim2.new(0, 20, 0, 80)
    inputBg.BackgroundColor3 = CONFIG.Element
    inputBg.BorderSizePixel = 0
    inputBg.Parent = keyFrame
    addCorner(inputBg, UDim.new(0, 6))
    addStroke(inputBg, CONFIG.Border, 1)

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -16, 1, 0)
    inputBox.Position = UDim2.new(0, 8, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    inputBox.PlaceholderColor3 = CONFIG.TextDim
    inputBox.Text = ""
    inputBox.TextColor3 = CONFIG.Text
    inputBox.Font = Enum.Font.GothamSemibold
    inputBox.TextSize = 13
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = inputBg

    -- Message erreur
    local errLabel = Instance.new("TextLabel")
    errLabel.Size = UDim2.new(1, -20, 0, 18)
    errLabel.Position = UDim2.new(0, 10, 0, 122)
    errLabel.BackgroundTransparency = 1
    errLabel.Text = ""
    errLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    errLabel.Font = Enum.Font.Gotham
    errLabel.TextSize = 11
    errLabel.Parent = keyFrame

    -- Bouton valider
    local validateBtn = Instance.new("TextButton")
    validateBtn.Size = UDim2.new(1, -40, 0, 36)
    validateBtn.Position = UDim2.new(0, 20, 0, 148)
    validateBtn.BackgroundColor3 = CONFIG.TabActive
    validateBtn.Text = "Valider la clé"
    validateBtn.TextColor3 = CONFIG.Text
    validateBtn.Font = Enum.Font.GothamBold
    validateBtn.TextSize = 13
    validateBtn.BorderSizePixel = 0
    validateBtn.Parent = keyFrame
    addCorner(validateBtn, UDim.new(0, 6))

    validateBtn.MouseButton1Click:Connect(function()
        local key = inputBox.Text
        local role = checkKey(key)
        if role then
            tween(validateBtn, {BackgroundColor3 = CONFIG.ToggleOn}, 0.2)
            validateBtn.Text = "✓ Accès autorisé"
            task.delay(0.6, function()
                tween(keyFrame, {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.delay(0.35, function()
                    screenGui:Destroy()
                    callback(role)
                end)
            end)
        else
            errLabel.Text = "❌ Clé invalide, réessayez."
            tween(inputBg, {BackgroundColor3 = Color3.fromRGB(80, 30, 30)}, 0.1)
            task.delay(0.5, function()
                tween(inputBg, {BackgroundColor3 = CONFIG.Element}, 0.3)
            end)
        end
    end)
end

-- ═══════════════════════════════════════
--           CRÉATION DE FENÊTRE
-- ═══════════════════════════════════════
function Library:CreateWindow(title, requireKey)
    local Window = {}
    Window._tabs = {}
    Window._activeTab = nil

    local function buildWindow(role)
        role = role or "Free"

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CustomLib"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = game.CoreGui

        -- Fenêtre principale
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight)
        mainFrame.Position = UDim2.new(0.5, -CONFIG.WindowWidth/2, 0.5, -CONFIG.WindowHeight/2)
        mainFrame.BackgroundColor3 = CONFIG.Background
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        addCorner(mainFrame, UDim.new(0, 8))
        addStroke(mainFrame, CONFIG.Border, 1)

        -- Animation ouverture
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        tween(mainFrame, {
            Size = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight),
            Position = UDim2.new(0.5, -CONFIG.WindowWidth/2, 0.5, -CONFIG.WindowHeight/2)
        }, 0.4, Enum.EasingStyle.Back)

        -- ─────────────────────────────
        --         BARRE DU HAUT
        -- ─────────────────────────────
        local topBar = Instance.new("Frame")
        topBar.Size = UDim2.new(1, 0, 0, 40)
        topBar.BackgroundColor3 = CONFIG.TopBar
        topBar.BorderSizePixel = 0
        topBar.Parent = mainFrame
        addCorner(topBar, UDim.new(0, 8))

        local topBarFix = Instance.new("Frame")
        topBarFix.Size = UDim2.new(1, 0, 0.5, 0)
        topBarFix.Position = UDim2.new(0, 0, 0.5, 0)
        topBarFix.BackgroundColor3 = CONFIG.TopBar
        topBarFix.BorderSizePixel = 0
        topBarFix.Parent = topBar

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -80, 1, 0)
        titleLabel.Position = UDim2.new(0, 12, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title or "Ma GUI"
        titleLabel.TextColor3 = CONFIG.Text
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.Parent = topBar

        -- Bouton fermer
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 12
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = topBar
        addCorner(closeBtn, UDim.new(0, 6))
        closeBtn.MouseButton1Click:Connect(function()
            tween(mainFrame, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.35, function() screenGui:Destroy() end)
        end)

        -- Bouton minimiser
        local minBtn = Instance.new("TextButton")
        minBtn.Size = UDim2.new(0, 28, 0, 28)
        minBtn.Position = UDim2.new(1, -70, 0.5, -14)
        minBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 40)
        minBtn.Text = "—"
        minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minBtn.Font = Enum.Font.GothamBold
        minBtn.TextSize = 12
        minBtn.BorderSizePixel = 0
        minBtn.Parent = topBar
        addCorner(minBtn, UDim.new(0, 6))

        local minimized = false
        local originalSize = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight)
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            tween(mainFrame, {
                Size = minimized and UDim2.new(0, CONFIG.WindowWidth, 0, 40) or originalSize
            }, 0.3, Enum.EasingStyle.Back)
        end)

        makeDraggable(mainFrame, topBar)

        -- ─────────────────────────────
        --       PROFIL JOUEUR
        -- ─────────────────────────────
        local profileBar = Instance.new("Frame")
        profileBar.Size = UDim2.new(1, 0, 0, CONFIG.ProfileHeight)
        profileBar.Position = UDim2.new(0, 0, 0, 40)
        profileBar.BackgroundColor3 = CONFIG.ProfileBg
        profileBar.BorderSizePixel = 0
        profileBar.Parent = mainFrame
        addStroke(profileBar, CONFIG.Border, 1)

        -- Avatar du joueur
        local avatarFrame = Instance.new("Frame")
        avatarFrame.Size = UDim2.new(0, 50, 0, 50)
        avatarFrame.Position = UDim2.new(0, 10, 0.5, -25)
        avatarFrame.BackgroundColor3 = CONFIG.Element
        avatarFrame.BorderSizePixel = 0
        avatarFrame.Parent = profileBar
        addCorner(avatarFrame, UDim.new(1, 0))
        addStroke(avatarFrame, KeyColors[role] or CONFIG.Border, 2)

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.new(1, 0, 1, 0)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png"
        avatarImg.Parent = avatarFrame
        addCorner(avatarImg, UDim.new(1, 0))

        -- Nom du joueur
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 180, 0, 22)
        nameLabel.Position = UDim2.new(0, 70, 0, 12)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = LocalPlayer.DisplayName
        nameLabel.TextColor3 = CONFIG.Text
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Parent = profileBar

        -- Username sous le display name
        local userLabel = Instance.new("TextLabel")
        userLabel.Size = UDim2.new(0, 180, 0, 16)
        userLabel.Position = UDim2.new(0, 70, 0, 34)
        userLabel.BackgroundTransparency = 1
        userLabel.Text = "@" .. LocalPlayer.Name
        userLabel.TextColor3 = CONFIG.TextDim
        userLabel.TextXAlignment = Enum.TextXAlignment.Left
        userLabel.Font = Enum.Font.Gotham
        userLabel.TextSize = 10
        userLabel.Parent = profileBar

        -- Badge de rôle
        local roleBadge = Instance.new("Frame")
        roleBadge.Size = UDim2.new(0, 90, 0, 22)
        roleBadge.Position = UDim2.new(0, 70, 0, 34)
        roleBadge.BackgroundColor3 = KeyColors[role] or CONFIG.TabActive
        roleBadge.BackgroundTransparency = 0.7
        roleBadge.BorderSizePixel = 0
        roleBadge.Parent = profileBar
        addCorner(roleBadge, UDim.new(0, 4))

        local roleLabel = Instance.new("TextLabel")
        roleLabel.Size = UDim2.new(1, 0, 1, 0)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Text = KeyIcons[role] or role
        roleLabel.TextColor3 = KeyColors[role] or CONFIG.Text
        roleLabel.Font = Enum.Font.GothamBold
        roleLabel.TextSize = 11
        roleLabel.Parent = roleBadge

        -- Réorganise nameLabel pour laisser place au badge
        nameLabel.Position = UDim2.new(0, 70, 0, 8)
        userLabel.Position = UDim2.new(0, 70, 0, 28)
        roleBadge.Position = UDim2.new(0, 70, 0, 44)

        -- ─────────────────────────────
        --       HORLOGE EN TEMPS RÉEL
        -- ─────────────────────────────
        local clockFrame = Instance.new("Frame")
        clockFrame.Size = UDim2.new(0, 100, 0, 30)
        clockFrame.Position = UDim2.new(1, -110, 0.5, -15)
        clockFrame.BackgroundColor3 = CONFIG.Element
        clockFrame.BorderSizePixel = 0
        clockFrame.Parent = profileBar
        addCorner(clockFrame, UDim.new(0, 6))
        addStroke(clockFrame, CONFIG.Border, 1)

        local clockIcon = Instance.new("TextLabel")
        clockIcon.Size = UDim2.new(0, 20, 1, 0)
        clockIcon.Position = UDim2.new(0, 6, 0, 0)
        clockIcon.BackgroundTransparency = 1
        clockIcon.Text = "🕐"
        clockIcon.TextSize = 12
        clockIcon.Font = Enum.Font.Gotham
        clockIcon.Parent = clockFrame

        local clockLabel = Instance.new("TextLabel")
        clockLabel.Size = UDim2.new(1, -30, 1, 0)
        clockLabel.Position = UDim2.new(0, 26, 0, 0)
        clockLabel.BackgroundTransparency = 1
        clockLabel.Text = getTime()
        clockLabel.TextColor3 = CONFIG.TabActive
        clockLabel.Font = Enum.Font.GothamBold
        clockLabel.TextSize = 13
        clockLabel.TextXAlignment = Enum.TextXAlignment.Left
        clockLabel.Parent = clockFrame

        -- Mise à jour chaque seconde
        RunService.Heartbeat:Connect(function()
            clockLabel.Text = getTime()
        end)

        -- ─────────────────────────────
        --         BARRE DES ONGLETS
        -- ─────────────────────────────
        local tabBarY = 40 + CONFIG.ProfileHeight
        local tabBar = Instance.new("Frame")
        tabBar.Size = UDim2.new(1, 0, 0, CONFIG.TabHeight)
        tabBar.Position = UDim2.new(0, 0, 0, tabBarY)
        tabBar.BackgroundColor3 = CONFIG.TabBar
        tabBar.BorderSizePixel = 0
        tabBar.Parent = mainFrame
        addListLayout(tabBar, 4, Enum.FillDirection.Horizontal)
        addPadding(tabBar, 4)

        -- Zone de contenu
        local contentAreaY = tabBarY + CONFIG.TabHeight
        local contentArea = Instance.new("Frame")
        contentArea.Size = UDim2.new(1, 0, 1, -contentAreaY)
        contentArea.Position = UDim2.new(0, 0, 0, contentAreaY)
        contentArea.BackgroundTransparency = 1
        contentArea.BorderSizePixel = 0
        contentArea.Parent = mainFrame

        -- ═══════════════════════════════
        --       CRÉATION D'ONGLET
        -- ═══════════════════════════════
        function Window:AddTab(tabName)
            local Tab = {}

            local tabBtn = Instance.new("TextButton")
            tabBtn.Size = UDim2.new(0, 90, 1, -6)
            tabBtn.BackgroundColor3 = CONFIG.TabInactive
            tabBtn.Text = tabName
            tabBtn.TextColor3 = CONFIG.TextDim
            tabBtn.Font = Enum.Font.GothamSemibold
            tabBtn.TextSize = 12
            tabBtn.BorderSizePixel = 0
            tabBtn.Parent = tabBar
            addCorner(tabBtn, UDim.new(0, 5))

            local scrollFrame = Instance.new("ScrollingFrame")
            scrollFrame.Size = UDim2.new(1, 0, 1, 0)
            scrollFrame.BackgroundTransparency = 1
            scrollFrame.BorderSizePixel = 0
            scrollFrame.ScrollBarThickness = 3
            scrollFrame.ScrollBarImageColor3 = CONFIG.TabActive
            scrollFrame.Visible = false
            scrollFrame.Parent = contentArea
            addListLayout(scrollFrame, 6)
            addPadding(scrollFrame, 8)

            local layout = scrollFrame:FindFirstChildWhichIsA("UIListLayout")
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
            end)

            local function activate()
                if Window._activeTab then
                    tween(Window._activeTab.btn, {BackgroundColor3 = CONFIG.TabInactive}, 0.15)
                    tween(Window._activeTab.btn, {TextColor3 = CONFIG.TextDim}, 0.15)
                    Window._activeTab.frame.Visible = false
                end
                Window._activeTab = {btn = tabBtn, frame = scrollFrame}
                tween(tabBtn, {BackgroundColor3 = CONFIG.TabActive}, 0.15)
                tween(tabBtn, {TextColor3 = CONFIG.Text}, 0.15)
                scrollFrame.Visible = true
            end

            tabBtn.MouseButton1Click:Connect(activate)
            if #Window._tabs == 0 then activate() end
            table.insert(Window._tabs, {btn = tabBtn, frame = scrollFrame})

            -- ═══════════════════════════
            --       ÉLÉMENTS
            -- ═══════════════════════════
            local function makeElement(labelText, descText)
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, -16, 0, CONFIG.ElementHeight)
                container.BackgroundColor3 = CONFIG.Element
                container.BorderSizePixel = 0
                container.Parent = scrollFrame
                addCorner(container)
                addStroke(container, CONFIG.Border, 1)

                container.MouseEnter:Connect(function()
                    tween(container, {BackgroundColor3 = CONFIG.ElementHover}, 0.1)
                end)
                container.MouseLeave:Connect(function()
                    tween(container, {BackgroundColor3 = CONFIG.Element}, 0.1)
                end)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.5, 0, 1, 0)
                label.Position = UDim2.new(0, 10, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = labelText or ""
                label.TextColor3 = CONFIG.Text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Font = Enum.Font.GothamSemibold
                label.TextSize = 12
                label.Parent = container

                if descText then
                    label.Size = UDim2.new(0.5, 0, 0.5, 0)
                    local desc = Instance.new("TextLabel")
                    desc.Size = UDim2.new(0.6, 0, 0.5, 0)
                    desc.Position = UDim2.new(0, 10, 0.5, 0)
                    desc.BackgroundTransparency = 1
                    desc.Text = descText
                    desc.TextColor3 = CONFIG.TextDim
                    desc.TextXAlignment = Enum.TextXAlignment.Left
                    desc.Font = Enum.Font.Gotham
                    desc.TextSize = 10
                    desc.Parent = container
                end

                return container, label
            end

            function Tab:AddLabel(text)
                local container, label = makeElement(text)
                container.BackgroundColor3 = CONFIG.TabBar
                label.Size = UDim2.new(1, -20, 1, 0)
                label.TextXAlignment = Enum.TextXAlignment.Center
                label.TextColor3 = CONFIG.TextDim
            end

            function Tab:AddButton(labelText, desc, callback)
                local container = makeElement(labelText, desc)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 80, 0, 22)
                btn.Position = UDim2.new(1, -90, 0.5, -11)
                btn.BackgroundColor3 = CONFIG.TabActive
                btn.Text = "Exécuter"
                btn.TextColor3 = CONFIG.Text
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 11
                btn.BorderSizePixel = 0
                btn.Parent = container
                addCorner(btn, UDim.new(0, 4))
                btn.MouseButton1Click:Connect(function()
                    tween(btn, {BackgroundColor3 = Color3.fromRGB(50, 80, 200)}, 0.1)
                    task.delay(0.15, function()
                        tween(btn, {BackgroundColor3 = CONFIG.TabActive}, 0.1)
                    end)
                    if callback then callback() end
                end)
            end

            function Tab:AddToggle(labelText, desc, default, callback)
                local state = default or false
                local container = makeElement(labelText, desc)

                local toggleBg = Instance.new("Frame")
                toggleBg.Size = UDim2.new(0, 44, 0, 22)
                toggleBg.Position = UDim2.new(1, -54, 0.5, -11)
                toggleBg.BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff
                toggleBg.BorderSizePixel = 0
                toggleBg.Parent = container
                addCorner(toggleBg, UDim.new(1, 0))

                local toggleCircle = Instance.new("Frame")
                toggleCircle.Size = UDim2.new(0, 16, 0, 16)
                toggleCircle.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleCircle.BorderSizePixel = 0
                toggleCircle.Parent = toggleBg
                addCorner(toggleCircle, UDim.new(1, 0))

                local clickZone = Instance.new("TextButton")
                clickZone.Size = UDim2.new(1, 0, 1, 0)
                clickZone.BackgroundTransparency = 1
                clickZone.Text = ""
                clickZone.Parent = toggleBg

                clickZone.MouseButton1Click:Connect(function()
                    state = not state
                    tween(toggleBg, {BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff}, 0.2)
                    tween(toggleCircle, {
                        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                    }, 0.2, Enum.EasingStyle.Back)
                    if callback then callback(state) end
                end)

                return {
                    SetState = function(s)
                        state = s
                        tween(toggleBg, {BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff}, 0.2)
                        tween(toggleCircle, {
                            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                        }, 0.2)
                    end,
                    GetState = function() return state end
                }
            end

            function Tab:AddSlider(labelText, desc, min, max, default, callback)
                local value = default or min
                local container = makeElement(labelText, desc)
                container.Size = UDim2.new(1, -16, 0, 50)

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 40, 0, 20)
                valueLabel.Position = UDim2.new(1, -50, 0, 8)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(value)
                valueLabel.TextColor3 = CONFIG.TabActive
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.TextSize = 12
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = container

                local sliderBg = Instance.new("Frame")
                sliderBg.Size = UDim2.new(1, -20, 0, 6)
                sliderBg.Position = UDim2.new(0, 10, 1, -16)
                sliderBg.BackgroundColor3 = CONFIG.ToggleOff
                sliderBg.BorderSizePixel = 0
                sliderBg.Parent = container
                addCorner(sliderBg, UDim.new(1, 0))

                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                sliderFill.BackgroundColor3 = CONFIG.SliderFill
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderBg
                addCorner(sliderFill, UDim.new(1, 0))

                local sliderBtn = Instance.new("TextButton")
                sliderBtn.Size = UDim2.new(1, 0, 1, 0)
                sliderBtn.BackgroundTransparency = 1
                sliderBtn.Text = ""
                sliderBtn.Parent = sliderBg

                local sliding = false
                sliderBtn.MouseButton1Down:Connect(function() sliding = true end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
                RunService.RenderStepped:Connect(function()
                    if sliding then
                        local mouse = UserInputService:GetMouseLocation()
                        local abs = sliderBg.AbsolutePosition
                        local size = sliderBg.AbsoluteSize
                        local pct = math.clamp((mouse.X - abs.X) / size.X, 0, 1)
                        value = math.floor(min + (max - min) * pct)
                        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
                        valueLabel.Text = tostring(value)
                        if callback then callback(value) end
                    end
                end)

                return {
                    SetValue = function(v)
                        value = math.clamp(v, min, max)
                        local pct = (value - min) / (max - min)
                        tween(sliderFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
                        valueLabel.Text = tostring(value)
                    end,
                    GetValue = function() return value end
                }
            end

            function Tab:AddInput(labelText, placeholder, callback)
                local container = makeElement(labelText)
                local inputBg = Instance.new("Frame")
                inputBg.Size = UDim2.new(0, 160, 0, 24)
                inputBg.Position = UDim2.new(1, -170, 0.5, -12)
                inputBg.BackgroundColor3 = CONFIG.Dropdown
                inputBg.BorderSizePixel = 0
                inputBg.Parent = container
                addCorner(inputBg, UDim.new(0, 4))
                addStroke(inputBg, CONFIG.Border, 1)

                local inputBox = Instance.new("TextBox")
                inputBox.Size = UDim2.new(1, -10, 1, 0)
                inputBox.Position = UDim2.new(0, 5, 0, 0)
                inputBox.BackgroundTransparency = 1
                inputBox.PlaceholderText = placeholder or "Entrez une valeur..."
                inputBox.PlaceholderColor3 = CONFIG.TextDim
                inputBox.Text = ""
                inputBox.TextColor3 = CONFIG.Text
                inputBox.Font = Enum.Font.Gotham
                inputBox.TextSize = 11
                inputBox.ClearTextOnFocus = false
                inputBox.Parent = inputBg

                inputBox.FocusLost:Connect(function(enter)
                    if enter and callback then callback(inputBox.Text) end
                    tween(inputBg, {BackgroundColor3 = CONFIG.Dropdown}, 0.1)
                end)
                inputBox.Focused:Connect(function()
                    tween(inputBg, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.1)
                end)
            end

            function Tab:AddDropdown(labelText, options, callback)
                local selected = options[1]
                local open = false
                local container = makeElement(labelText)
                container.ClipsDescendants = false

                local dropBtn = Instance.new("TextButton")
                dropBtn.Size = UDim2.new(0, 160, 0, 24)
                dropBtn.Position = UDim2.new(1, -170, 0.5, -12)
                dropBtn.BackgroundColor3 = CONFIG.Dropdown
                dropBtn.Text = selected .. "  ▾"
                dropBtn.TextColor3 = CONFIG.Text
                dropBtn.Font = Enum.Font.GothamSemibold
                dropBtn.TextSize = 11
                dropBtn.BorderSizePixel = 0
                dropBtn.ZIndex = 5
                dropBtn.Parent = container
                addCorner(dropBtn, UDim.new(0, 4))
                addStroke(dropBtn, CONFIG.Border, 1)

                local dropList = Instance.new("Frame")
                dropList.Size = UDim2.new(0, 160, 0, 0)
                dropList.Position = UDim2.new(1, -170, 1, 2)
                dropList.BackgroundColor3 = CONFIG.Dropdown
                dropList.BorderSizePixel = 0
                dropList.ClipsDescendants = true
                dropList.ZIndex = 10
                dropList.Visible = false
                dropList.Parent = container
                addCorner(dropList, UDim.new(0, 4))
                addStroke(dropList, CONFIG.Border, 1)
                addListLayout(dropList, 2)
                addPadding(dropList, 4)

                for _, option in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, -8, 0, 24)
                    optBtn.BackgroundColor3 = CONFIG.Dropdown
                    optBtn.Text = option
                    optBtn.TextColor3 = CONFIG.Text
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 11
                    optBtn.BorderSizePixel = 0
                    optBtn.ZIndex = 11
                    optBtn.Parent = dropList
                    addCorner(optBtn, UDim.new(0, 4))

                    optBtn.MouseEnter:Connect(function()
                        tween(optBtn, {BackgroundColor3 = CONFIG.ElementHover}, 0.1)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        tween(optBtn, {BackgroundColor3 = CONFIG.Dropdown}, 0.1)
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        selected = option
                        dropBtn.Text = option .. "  ▾"
                        open = false
                        tween(dropList, {Size = UDim2.new(0, 160, 0, 0)}, 0.2)
                        task.delay(0.2, function() dropList.Visible = false end)
                        if callback then callback(option) end
                    end)
                end

                local totalHeight = #options * 28 + 8
                dropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    dropList.Visible = true
                    tween(dropList, {
                        Size = open and UDim2.new(0, 160, 0, totalHeight) or UDim2.new(0, 160, 0, 0)
                    }, 0.2, Enum.EasingStyle.Back)
                    if not open then task.delay(0.2, function() dropList.Visible = false end) end
                end)

                return {
                    GetSelected = function() return selected end,
                    SetSelected = function(v)
                        selected = v
                        dropBtn.Text = v .. "  ▾"
                    end
                }
            end

            function Tab:AddSeparator(text)
                local sep = Instance.new("Frame")
                sep.Size = UDim2.new(1, -16, 0, 20)
                sep.BackgroundTransparency = 1
                sep.Parent = scrollFrame

                local line = Instance.new("Frame")
                line.Size = UDim2.new(1, 0, 0, 1)
                line.Position = UDim2.new(0, 0, 0.5, 0)
                line.BackgroundColor3 = CONFIG.Border
                line.BorderSizePixel = 0
                line.Parent = sep

                if text then
                    local sepLabel = Instance.new("TextLabel")
                    sepLabel.Size = UDim2.new(0, 0, 1, 0)
                    sepLabel.AutomaticSize = Enum.AutomaticSize.X
                    sepLabel.Position = UDim2.new(0.5, 0, 0, 0)
                    sepLabel.AnchorPoint = Vector2.new(0.5, 0)
                    sepLabel.BackgroundColor3 = CONFIG.Background
                    sepLabel.Text = "  " .. text .. "  "
                    sepLabel.TextColor3 = CONFIG.TextDim
                    sepLabel.Font = Enum.Font.Gotham
                    sepLabel.TextSize = 10
                    sepLabel.BorderSizePixel = 0
                    sepLabel.Parent = sep
                end
            end

            return Tab
        end
    end

    -- Lance l'écran de clé si demandé, sinon ouvre directement
    if requireKey then
        showKeyScreen(function(role)
            buildWindow(role)
        end)
    else
        buildWindow("Free")
    end

    return Window
end

return Library


