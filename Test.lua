-- ═══════════════════════════════════════
--        MA BIBLIOTHÈQUE GUI - v1.0
-- ═══════════════════════════════════════

local Library = {}
Library.__index = Library

-- ═══════════════════════════════════════
--              CONFIGURATION
-- ═══════════════════════════════════════
local CONFIG = {
    -- Couleurs principales
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

    -- Dimensions
    WindowWidth   = 500,
    WindowHeight  = 350,
    TabHeight     = 30,
    ElementHeight = 36,
    Padding       = 8,
    CornerRadius  = UDim.new(0, 6),
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════
--           FONCTIONS UTILITAIRES
-- ═══════════════════════════════════════
local function tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or CONFIG.CornerRadius
    corner.Parent = parent
    return corner
end

local function addPadding(parent, all, left, right, top, bottom)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, left or all or 0)
    pad.PaddingRight  = UDim.new(0, right or all or 0)
    pad.PaddingTop    = UDim.new(0, top or all or 0)
    pad.PaddingBottom = UDim.new(0, bottom or all or 0)
    pad.Parent = parent
    return pad
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
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or CONFIG.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
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
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ═══════════════════════════════════════
--           CRÉATION DE FENÊTRE
-- ═══════════════════════════════════════
function Library:CreateWindow(title)
    local Window = {}
    Window._tabs = {}
    Window._activeTab = nil

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomLib"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game.CoreGui

    -- Fenêtre principale
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight)
    mainFrame.Position = UDim2.new(0.5, -CONFIG.WindowWidth/2, 0.5, -CONFIG.WindowHeight/2)
    mainFrame.BackgroundColor3 = CONFIG.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    addCorner(mainFrame, UDim.new(0, 8))
    addStroke(mainFrame, CONFIG.Border, 1)

    -- Animation d'ouverture
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(mainFrame, {
        Size = UDim2.new(0, CONFIG.WindowWidth, 0, CONFIG.WindowHeight),
        Position = UDim2.new(0.5, -CONFIG.WindowWidth/2, 0.5, -CONFIG.WindowHeight/2)
    }, 0.4, Enum.EasingStyle.Back)

    -- Barre du haut
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = CONFIG.TopBar
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    addCorner(topBar, UDim.new(0, 8))

    -- Correctif coins bas de topBar
    local topBarFix = Instance.new("Frame")
    topBarFix.Size = UDim2.new(1, 0, 0.5, 0)
    topBarFix.Position = UDim2.new(0, 0, 0.5, 0)
    topBarFix.BackgroundColor3 = CONFIG.TopBar
    topBarFix.BorderSizePixel = 0
    topBarFix.Parent = topBar

    -- Titre
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
        tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
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
    local originalSize = mainFrame.Size
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(mainFrame, {Size = UDim2.new(0, CONFIG.WindowWidth, 0, 40)}, 0.3)
        else
            tween(mainFrame, {Size = originalSize}, 0.3, Enum.EasingStyle.Back)
        end
    end)

    makeDraggable(mainFrame, topBar)

    -- Barre des onglets
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, CONFIG.TabHeight)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundColor3 = CONFIG.TabBar
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame
    addListLayout(tabBar, 4, Enum.FillDirection.Horizontal)
    addPadding(tabBar, 4)

    -- Zone de contenu
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -78)
    contentArea.Position = UDim2.new(0, 0, 0, 78)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainFrame

    -- ═══════════════════════════════════
    --           CRÉATION D'ONGLET
    -- ═══════════════════════════════════
    function Window:AddTab(tabName)
        local Tab = {}
        Tab._elements = {}

        -- Bouton de l'onglet
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

        -- ScrollFrame pour le contenu
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

        -- Auto resize
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

        -- ═══════════════════════════════
        --        ÉLÉMENTS D'ONGLET
        -- ═══════════════════════════════

        -- Fonction interne : créer un conteneur d'élément
        local function makeElement(labelText, descText)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -16, 0, CONFIG.ElementHeight)
            container.BackgroundColor3 = CONFIG.Element
            container.BorderSizePixel = 0
            container.Parent = scrollFrame
            addCorner(container)
            addStroke(container, CONFIG.Border, 1)

            -- Hover effect
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

        -- ─────────────────────────────
        --            LABEL
        -- ─────────────────────────────
        function Tab:AddLabel(text)
            local container, label = makeElement(text)
            container.BackgroundColor3 = CONFIG.TabBar
            label.Size = UDim2.new(1, -20, 1, 0)
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextColor3 = CONFIG.TextDim
        end

        -- ─────────────────────────────
        --           BOUTON
        -- ─────────────────────────────
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

        -- ─────────────────────────────
        --           TOGGLE
        -- ─────────────────────────────
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
                SetState = function(newState)
                    state = newState
                    tween(toggleBg, {BackgroundColor3 = state and CONFIG.ToggleOn or CONFIG.ToggleOff}, 0.2)
                    tween(toggleCircle, {
                        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                    }, 0.2)
                end,
                GetState = function() return state end
            }
        end

        -- ─────────────────────────────
        --           SLIDER
        -- ─────────────────────────────
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

        -- ─────────────────────────────
        --           INPUT
        -- ─────────────────────────────
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

        -- ─────────────────────────────
        --          DROPDOWN
        -- ─────────────────────────────
        function Tab:AddDropdown(labelText, options, callback)
            local selected = options[1]
            local open = false

            local container = makeElement(labelText)
            container.Size = UDim2.new(1, -16, 0, CONFIG.ElementHeight)
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

        -- ─────────────────────────────
        --         SÉPARATEUR
        -- ─────────────────────────────
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

    return Window
end

return Library