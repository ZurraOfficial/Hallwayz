--[[
    Hallwayz Hub
    Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/ZurraOfficial/Hallwayz/main/main.lua"))()
]]

local CONFIG = {
    Name = "Hallwayz",
    Subtitle = "Maverick",
    Version = "v1.0.0",
    LootlabsURL = "https://links.lootlabs.gg/s?1Q3QoHte",
    KeysURL = "https://raw.githubusercontent.com/ZurraOfficial/Hallwayz/main/keys.txt",
    DiscordURL = "https://discord.gg/wallzyq",
}

local Theme = {
    BG          = Color3.fromRGB(11, 11, 16),
    Sidebar     = Color3.fromRGB(15, 15, 22),
    Card        = Color3.fromRGB(20, 20, 30),
    CardHover   = Color3.fromRGB(26, 26, 38),
    Border      = Color3.fromRGB(30, 30, 44),
    BorderHover = Color3.fromRGB(48, 48, 66),
    Text        = Color3.fromRGB(232, 232, 240),
    TextMuted   = Color3.fromRGB(105, 105, 128),
    Accent      = Color3.fromRGB(107, 127, 255),
    AccentDark  = Color3.fromRGB(75, 95, 220),
    AccentGlow  = Color3.fromRGB(140, 155, 255),
    Success     = Color3.fromRGB(74, 222, 128),
    Error       = Color3.fromRGB(248, 113, 113),
    Warning     = Color3.fromRGB(250, 204, 21),
    Divider     = Color3.fromRGB(26, 26, 38),
}

local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

for _, obj in pairs(CoreGui:GetChildren()) do
    if obj.Name == "HallwayzUI" then obj:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HallwayzUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

-- ============================================================
-- HELPERS
-- ============================================================
local function new(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    return obj
end

local function corner(r, p) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function stroke(c, t, p) return new("UIStroke", { Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p }) end
local function tween(o, t, p)
    local tw = TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
    tw:Play(); return tw
end

-- ============================================================
-- VECTOR ICON LIBRARY (drawn with Frames — no unicode, no asset)
-- ============================================================
local function makeIconShape(parent, w, h, x, y, color, rot)
    local f = new("Frame", {
        Size = UDim2.new(0, w, 0, h),
        Position = UDim2.new(0, x, 0, y),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Rotation = rot or 0,
        Parent = parent,
    })
    return f
end

local IconLib = {}

function IconLib.Info(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    -- Circle outline (use 2 circles: outer filled, inner bg)
    local outer = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundColor3 = color, BorderSizePixel = 0, Parent = holder })
    corner(100, outer)
    local inner = new("Frame", { Size = UDim2.new(1,-4,1,-4), Position = UDim2.new(0,2,0,2), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = holder })
    corner(100, inner)
    -- Dot
    new("Frame", { Size = UDim2.new(0,3,0,3), Position = UDim2.new(0.5,-1.5,0,4), BackgroundColor3 = color, BorderSizePixel = 0, Parent = holder })
    corner(100, holder:FindFirstChildOfClass("Frame"))
    -- Bar (stem of "i")
    local stem = new("Frame", { Size = UDim2.new(0,3,0,7), Position = UDim2.new(0.5,-1.5,0,9), BackgroundColor3 = color, BorderSizePixel = 0, Parent = holder })
    return holder
end

function IconLib.Bolt(parent, color)
    -- Lightning bolt made of two slanted frames
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    local p1 = makeIconShape(holder, 8, 12, 6, 2, color, 0)
    p1.Size = UDim2.new(0, 7, 0, 8)
    local p2 = makeIconShape(holder, 7, 8, 5, 8, color, 0)
    -- Use two overlapping rectangles skewed
    p1.Size = UDim2.new(0, 6, 0, 9)
    p1.Position = UDim2.new(0, 7, 0, 1)
    p1.Rotation = 15
    p2.Size = UDim2.new(0, 6, 0, 9)
    p2.Position = UDim2.new(0, 4, 0, 8)
    p2.Rotation = 15
    -- Middle horizontal
    local mid = makeIconShape(holder, 10, 4, 4, 7, color, 0)
    return holder
end

function IconLib.Egg(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    local egg = new("Frame", {
        Size = UDim2.new(0, 12, 0, 15),
        Position = UDim2.new(0, 3, 0, 2),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = holder,
    })
    corner(100, egg)
    return holder
end

function IconLib.Home(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    -- Roof (triangle via rotated square)
    local roof = makeIconShape(holder, 10, 10, 4, 1, color, 45)
    roof.Size = UDim2.new(0, 10, 0, 10)
    -- Body
    local body = makeIconShape(holder, 12, 9, 3, 7, color, 0)
    return holder
end

function IconLib.Sparkle(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    -- Diamond shape
    local d1 = makeIconShape(holder, 8, 8, 5, 4, color, 45)
    -- Small dots
    local d2 = makeIconShape(holder, 2, 2, 2, 2, color, 45)
    local d3 = makeIconShape(holder, 2, 2, 15, 12, color, 45)
    local d4 = makeIconShape(holder, 2, 2, 2, 14, color, 45)
    return holder
end

function IconLib.Trend(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    -- Ascending line (2 segments)
    local seg1 = makeIconShape(holder, 8, 2, 3, 11, color, -45)
    local seg2 = makeIconShape(holder, 8, 2, 9, 8, color, -45)
    -- Arrow head
    local arr = makeIconShape(holder, 5, 5, 14, 4, color, 45)
    return holder
end

function IconLib.Wrench(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    -- Handle
    local handle = makeIconShape(holder, 3, 11, 8, 6, color, 35)
    -- Head (circle-ish)
    local head = new("Frame", {
        Size = UDim2.new(0, 7, 0, 7),
        Position = UDim2.new(0, 5, 0, 1),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = holder,
    })
    corner(100, head)
    local headHole = new("Frame", {
        Size = UDim2.new(0, 3, 0, 3),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = head,
    })
    corner(100, headHole)
    return holder
end

function IconLib.Save(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    -- Floppy outline
    local outer = makeIconShape(holder, 14, 14, 2, 2, color, 0)
    -- Cut corner
    local cut = makeIconShape(holder, 5, 5, 11, 2, Theme.Sidebar, 0)
    -- Label bottom
    local label = makeIconShape(holder, 8, 5, 5, 10, Theme.Sidebar, 0)
    -- Top slot
    local slot = makeIconShape(holder, 6, 4, 6, 3, Theme.Sidebar, 0)
    return holder
end

function IconLib.Search(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    -- Circle
    local circle = new("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = holder,
    })
    corner(100, circle)
    local hole = new("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = circle,
    })
    corner(100, hole)
    -- Handle (diagonal line)
    local handle = makeIconShape(holder, 2, 6, 10, 10, color, -45)
    return holder
end

function IconLib.Close(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    local l1 = makeIconShape(holder, 12, 2, 1, 6, color, 45)
    local l2 = makeIconShape(holder, 12, 2, 1, 6, color, -45)
    return holder
end

function IconLib.Minimize(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    local line = makeIconShape(holder, 12, 2, 1, 7, color, 0)
    return holder
end

function IconLib.Key(parent, color)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    -- Circle head
    local head = new("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 1, 0, 4),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = holder,
    })
    corner(100, head)
    local hole = new("Frame", {
        Size = UDim2.new(0, 3, 0, 3),
        Position = UDim2.new(0.5, -1.5, 0.5, -1.5),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = head,
    })
    corner(100, hole)
    -- Shaft
    local shaft = makeIconShape(holder, 9, 2, 8, 8, color, 0)
    -- Teeth
    local t1 = makeIconShape(holder, 2, 3, 12, 8, color, 0)
    local t2 = makeIconShape(holder, 2, 3, 15, 8, color, 0)
    return holder
end

function IconLib.Chevron(parent, color, dir)
    local holder = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = parent })
    local rot = dir == "up" and -45 or (dir == "down" and 135 or 0)
    local l1 = makeIconShape(holder, 6, 2, 5, 6, color, 45)
    local l2 = makeIconShape(holder, 6, 2, 8, 6, color, -45)
    if dir == "down" then
        l1.Position = UDim2.new(0, 5, 0, 8)
        l2.Position = UDim2.new(0, 8, 0, 8)
        l1.Rotation = -45
        l2.Rotation = 45
    end
    return holder
end

-- ============================================================
-- LOGO (Hallwayz — 3 parallelogram miring)
-- ============================================================
local function buildLogo(parent, size)
    size = size or 32
    local holder = new("Frame", {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local sk = size / 32

    -- Left top
    local lt = new("Frame", {
        Size = UDim2.new(0, 8 * sk, 0, 13 * sk),
        Position = UDim2.new(0, 6 * sk, 0, 3 * sk),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Rotation = 20,
        Parent = holder,
    })
    corner(1, lt)

    -- Left bottom
    local lb = new("Frame", {
        Size = UDim2.new(0, 8 * sk, 0, 13 * sk),
        Position = UDim2.new(0, 6 * sk, 0, 16 * sk),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Rotation = 20,
        Parent = holder,
    })
    corner(1, lb)

    -- Right
    local rt = new("Frame", {
        Size = UDim2.new(0, 9 * sk, 0, 26 * sk),
        Position = UDim2.new(0, 17 * sk, 0, 3 * sk),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Rotation = 20,
        Parent = holder,
    })
    corner(1, rt)

    -- Small diagonal connector
    local diag = new("Frame", {
        Size = UDim2.new(0, 11 * sk, 0, 2 * sk),
        Position = UDim2.new(0, 7 * sk, 0, 15 * sk),
        BackgroundColor3 = Theme.AccentGlow,
        BorderSizePixel = 0,
        Rotation = -25,
        Parent = holder,
    })
    corner(1, diag)

    return holder
end

-- ============================================================
-- FPS COUNTER
-- ============================================================
local fpsValue = 60
task.spawn(function()
    while ScreenGui.Parent do
        local t = tick()
        RunService.RenderStepped:Wait()
        local d = tick() - t
        if d > 0 then fpsValue = math.floor(1 / d) end
    end
end)

-- ============================================================
-- KEY VALIDATION
-- ============================================================
local function fetchValidKeys()
    if not CONFIG.KeysURL or CONFIG.KeysURL == "" then return {} end
    local ok, result = pcall(game.HttpGet, game, CONFIG.KeysURL, true)
    if not ok or not result then return {} end
    local keys = {}
    for line in result:gmatch("[^\r\n]+") do
        line = line:gsub("%s+", "")
        if line ~= "" and not line:match("^#") then keys[line:lower()] = true end
    end
    return keys
end

local function validateKey(inputKey)
    if not inputKey or inputKey == "" then return false, "Key tidak boleh kosong" end
    local vk = fetchValidKeys()
    if vk[inputKey:lower()] then return true, "Key valid" end
    return false, "Key tidak valid"
end

-- ============================================================
-- KEY UI
-- ============================================================
local function buildKeyUI(onSuccess)
    local Dim = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })

    local KeyCard = new("Frame", {
        Size = UDim2.new(0, 380, 0, 290),
        Position = UDim2.new(0.5, -190, 0.5, -145),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        Parent = Dim,
    })
    corner(14, KeyCard)
    stroke(Theme.Border, 1, KeyCard)

    local glow = new("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Transparency = 0.7, Parent = KeyCard })
    task.spawn(function()
        while KeyCard.Parent do
            tween(glow, 2, { Transparency = 0.2 })
            task.wait(2)
            tween(glow, 2, { Transparency = 0.85 })
            task.wait(2)
        end
    end)

    local uk = new("UIScale", { Scale = 1, Parent = KeyCard })
    local function updScale()
        local vp = Camera.ViewportSize
        uk.Scale = math.min((vp.X * 0.9) / 380, (vp.Y * 0.9) / 290, 1)
    end
    updScale()
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updScale)

    -- Header
    local Header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = KeyCard,
    })
    corner(14, Header)
    new("Frame", { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = Header })

    local logoHolder = new("Frame", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 16, 0.5, -16),
        BackgroundTransparency = 1,
        Parent = Header,
    })
    buildLogo(logoHolder, 32)

    new("TextLabel", {
        Size = UDim2.new(1, -70, 0, 18),
        Position = UDim2.new(0, 58, 0, 15),
        BackgroundTransparency = 1,
        Text = CONFIG.Name,
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -70, 0, 13),
        Position = UDim2.new(0, 58, 0, 34),
        BackgroundTransparency = 1,
        Text = "Key System • " .. CONFIG.Version,
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header,
    })

    local keyClose = new("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -38, 0, 19),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Text = "",
        Parent = Header,
    })
    corner(6, keyClose)
    local kcHolder = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0.5, -7, 0.5, -7), BackgroundTransparency = 1, Parent = keyClose })
    IconLib.Close(kcHolder, Theme.TextMuted)

    keyClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    keyClose.MouseEnter:Connect(function() tween(keyClose, 0.12, { BackgroundColor3 = Theme.CardHover }) end)
    keyClose.MouseLeave:Connect(function() tween(keyClose, 0.12, { BackgroundColor3 = Theme.Card }) end)

    -- Body
    local Body = new("Frame", {
        Size = UDim2.new(1, -28, 1, -84),
        Position = UDim2.new(0, 14, 0, 80),
        BackgroundTransparency = 1,
        Parent = KeyCard,
    })

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "Masukkan key untuk melanjutkan",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Body,
    })

    local InputBox = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = Body,
    })
    corner(8, InputBox)
    local inputStroke = stroke(Theme.Border, 1, InputBox)

    local keyIconHolder = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 12, 0.5, -7), BackgroundTransparency = 1, Parent = InputBox })
    IconLib.Key(keyIconHolder, Theme.TextMuted)

    local KeyInput = new("TextBox", {
        Size = UDim2.new(1, -102, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "FREE_XXXXXXXXXXXXXXXX",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Code,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = InputBox,
    })

    local pasteBtn = new("TextButton", {
        Size = UDim2.new(0, 52, 0, 26),
        Position = UDim2.new(1, -58, 0.5, -13),
        BackgroundColor3 = Theme.CardHover,
        BorderSizePixel = 0,
        Text = "Paste",
        TextColor3 = Theme.Text,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        Parent = InputBox,
    })
    corner(6, pasteBtn)
    pasteBtn.MouseButton1Click:Connect(function()
        local ok, clip = pcall(function() return game:GetService("GuiService"):GetClipboard() end)
        if ok and clip and clip ~= "" then KeyInput.Text = clip end
    end)

    local getBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.new(0, 0, 0, 74),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Text = "Dapatkan Key di Lootlabs",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Parent = Body,
    })
    corner(8, getBtn)
    local getStroke = stroke(Theme.Border, 1, getBtn)
    getBtn.MouseButton1Click:Connect(function()
        pcall(function() game:GetService("GuiService"):OpenBrowserWindow(CONFIG.LootlabsURL) end)
    end)
    getBtn.MouseEnter:Connect(function()
        tween(getBtn, 0.12, { BackgroundColor3 = Theme.CardHover })
        tween(getStroke, 0.12, { Color = Theme.BorderHover })
    end)
    getBtn.MouseLeave:Connect(function()
        tween(getBtn, 0.12, { BackgroundColor3 = Theme.Card })
        tween(getStroke, 0.12, { Color = Theme.Border })
    end)

    local StatusLabel = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 120),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = Body,
    })

    local verifyBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 142),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "Verifikasi Key",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = Body,
    })
    corner(8, verifyBtn)
    verifyBtn.MouseEnter:Connect(function() tween(verifyBtn, 0.12, { BackgroundColor3 = Theme.AccentDark }) end)
    verifyBtn.MouseLeave:Connect(function() tween(verifyBtn, 0.12, { BackgroundColor3 = Theme.Accent }) end)

    local function submit()
        local key = KeyInput.Text
        if key == "" then
            StatusLabel.Text = "Key tidak boleh kosong"
            StatusLabel.TextColor3 = Theme.Error
            tween(inputStroke, 0.15, { Color = Theme.Error })
            task.delay(1.5, function() tween(inputStroke, 0.3, { Color = Theme.Border }) end)
            return
        end
        StatusLabel.Text = "Memverifikasi..."
        StatusLabel.TextColor3 = Theme.Warning
        verifyBtn.Text = "..."
        task.wait(0.4)
        local valid, msg = validateKey(key)
        if valid then
            StatusLabel.Text = msg
            StatusLabel.TextColor3 = Theme.Success
            tween(inputStroke, 0.2, { Color = Theme.Success })
            task.wait(0.35)
            tween(Dim, 0.3, { BackgroundTransparency = 1 })
            tween(KeyCard, 0.3, { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
            task.wait(0.3)
            Dim:Destroy()
            onSuccess()
        else
            StatusLabel.Text = msg
            StatusLabel.TextColor3 = Theme.Error
            verifyBtn.Text = "Verifikasi Key"
            tween(inputStroke, 0.15, { Color = Theme.Error })
            task.delay(1.5, function() tween(inputStroke, 0.3, { Color = Theme.Border }) end)
            local orig = InputBox.Position
            for i = 1, 4 do
                InputBox.Position = orig + UDim2.new(0, (i % 2 == 0 and 6 or -6), 0, 0)
                task.wait(0.035)
            end
            InputBox.Position = orig
        end
    end

    verifyBtn.MouseButton1Click:Connect(submit)
    KeyInput.FocusLost:Connect(function(enter) if enter then submit() end end)
end

-- ============================================================
-- SIDEBAR ITEMS
-- ============================================================
local SIDEBAR_ITEMS = {
    { id = "info",     label = "Information",   iconFn = "Info" },
    { id = "hatch",    label = "Hatch & Steal", iconFn = "Bolt", active = true },
    { id = "hatchery", label = "Hatchery",      iconFn = "Egg" },
    { id = "barn",     label = "Barn",          iconFn = "Home" },
    { id = "rift",     label = "Rift",          iconFn = "Sparkle" },
    { id = "upgrades", label = "Upgrades",      iconFn = "Trend" },
    { id = "extras",   label = "Extras",        iconFn = "Wrench" },
    { id = "presets",  label = "Presets",       iconFn = "Save" },
}

-- ============================================================
-- MAIN UI
-- ============================================================
local function buildMainUI()
    local Main = new("Frame", {
        Size = UDim2.new(0, 660, 0, 420),
        Position = UDim2.new(0.5, -330, 0.5, -210),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    corner(12, Main)
    stroke(Theme.Border, 1, Main)

    local mScale = new("UIScale", { Scale = 1, Parent = Main })
    local function updMainScale()
        local vp = Camera.ViewportSize
        local s = math.min((vp.X * 0.9) / 660, (vp.Y * 0.85) / 420, 1)
        mScale.Scale = s
    end
    updMainScale()
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updMainScale)

    Main.Size = UDim2.new(0, 0, 0, 0)
    tween(Main, 0.3, { Size = UDim2.new(0, 660, 0, 420) })

    -- Drag
    local dragging = false
    local dragStart, startPos
    local dragArea = new("Frame", {
        Size = UDim2.new(0, 660, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = Main,
    })
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- ============================================================
    -- SIDEBAR
    -- ============================================================
    local Sidebar = new("Frame", {
        Size = UDim2.new(0, 170, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Main,
    })
    corner(12, Sidebar)
    new("Frame", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Sidebar,
    })

    -- Brand
    local brand = new("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent = Sidebar,
    })
    local brandLogo = new("Frame", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 14, 0.5, -15),
        BackgroundTransparency = 1,
        Parent = brand,
    })
    buildLogo(brandLogo, 30)

    new("TextLabel", {
        Size = UDim2.new(1, -60, 0, 16),
        Position = UDim2.new(0, 52, 0, 16),
        BackgroundTransparency = 1,
        Text = CONFIG.Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = brand,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -60, 0, 12),
        Position = UDim2.new(0, 52, 0, 33),
        BackgroundTransparency = 1,
        Text = CONFIG.Subtitle,
        TextColor3 = Theme.TextMuted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = brand,
    })

    new("Frame", {
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.new(0, 12, 0, 60),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        Parent = Sidebar,
    })

    -- List
    local ListFrame = new("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -60 - 50),
        Position = UDim2.new(0, 6, 0, 64),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ListFrame,
    })

    -- Discord
    local DiscordCard = new("TextButton", {
        Size = UDim2.new(1, -16, 0, 32),
        Position = UDim2.new(0, 8, 1, -40),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Text = "",
        Parent = Sidebar,
    })
    corner(8, DiscordCard)
    stroke(Theme.Border, 1, DiscordCard)
    new("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = CONFIG.DiscordURL:gsub("https?://", ""),
        TextColor3 = Theme.TextMuted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = DiscordCard,
    })
    DiscordCard.MouseButton1Click:Connect(function()
        pcall(function() game:GetService("GuiService"):OpenBrowserWindow(CONFIG.DiscordURL) end)
    end)

    -- ============================================================
    -- CONTENT
    -- ============================================================
    local Content = new("Frame", {
        Size = UDim2.new(1, -170, 1, 0),
        Position = UDim2.new(0, 170, 0, 0),
        BackgroundTransparency = 1,
        Parent = Main,
    })

    -- Top bar
    local TopBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundTransparency = 1,
        Parent = Content,
    })

    local PageTitle = new("TextLabel", {
        Size = UDim2.new(0, 260, 0, 16),
        Position = UDim2.new(0, 18, 0, 12),
        BackgroundTransparency = 1,
        Text = "Hatch & Steal",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })
    new("TextLabel", {
        Size = UDim2.new(0, 340, 0, 13),
        Position = UDim2.new(0, 18, 0, 29),
        BackgroundTransparency = 1,
        Text = "Choose what to take, then go and take it",
        TextColor3 = Theme.TextMuted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    -- Search
    local SearchBox = new("Frame", {
        Size = UDim2.new(0, 160, 0, 28),
        Position = UDim2.new(1, -258, 0, 13),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    corner(6, SearchBox)
    stroke(Theme.Border, 1, SearchBox)
    local searchIconHolder = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 10, 0.5, -7), BackgroundTransparency = 1, Parent = SearchBox })
    IconLib.Search(searchIconHolder, Theme.TextMuted)
    new("TextBox", {
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.Text,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchBox,
    })

    -- Window controls
    local function makeWinBtn(iconFn, xOffset)
        local Btn = new("TextButton", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(1, xOffset, 0, 14),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Text = "",
            Parent = TopBar,
        })
        corner(6, Btn)
        local holder = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0.5, -7, 0.5, -7), BackgroundTransparency = 1, Parent = Btn })
        IconLib[iconFn](holder, Theme.TextMuted)
        Btn.MouseEnter:Connect(function() tween(Btn, 0.12, { BackgroundColor3 = Theme.CardHover }) end)
        Btn.MouseLeave:Connect(function() tween(Btn, 0.12, { BackgroundColor3 = Theme.Card }) end)
        return Btn
    end

    local MinBtn = makeWinBtn("Minimize", -66)
    local CloseBtn = makeWinBtn("Close", -36)

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    new("Frame", {
        Size = UDim2.new(1, -28, 0, 1),
        Position = UDim2.new(0, 14, 0, 54),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        Parent = Content,
    })

    -- Pages
    local Pages = new("Frame", {
        Size = UDim2.new(1, -20, 1, -62),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        Parent = Content,
    })

    local pageMap = {}
    for _, item in ipairs(SIDEBAR_ITEMS) do
        local page = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = Pages,
        })
        pageMap[item.id] = page
    end

    -- Fill empty pages with 2 placeholder cards
    local function fillEmptyPage(page)
        local scroll = new("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = page,
        })
        new("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            Parent = scroll,
        })
        new("UIGridLayout", {
            CellSize = UDim2.new(0.5, -6, 0, 190),
            CellPadding = UDim2.new(0, 10, 0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = scroll,
        })

        for i = 1, 2 do
            local card = new("Frame", {
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                LayoutOrder = i,
                Parent = scroll,
            })
            corner(10, card)
            stroke(Theme.Border, 1, card)

            new("TextLabel", {
                Size = UDim2.new(1, -24, 0, 18),
                Position = UDim2.new(0, 14, 0, 14),
                BackgroundTransparency = 1,
                Text = (i == 1 and "Section A" or "Section B"),
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card,
            })

            new("Frame", {
                Size = UDim2.new(1, -28, 0, 1),
                Position = UDim2.new(0, 14, 0, 42),
                BackgroundColor3 = Theme.Divider,
                BorderSizePixel = 0,
                Parent = card,
            })

            new("TextLabel", {
                Size = UDim2.new(1, -28, 1, -56),
                Position = UDim2.new(0, 14, 0, 50),
                BackgroundTransparency = 1,
                Text = "Empty — fitur akan ditambahkan",
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Parent = card,
            })
        end
    end

    for _, item in ipairs(SIDEBAR_ITEMS) do
        fillEmptyPage(pageMap[item.id])
    end

    -- Sidebar buttons
    local sidebarButtons = {}

    local function selectPage(id)
        for _, it in ipairs(SIDEBAR_ITEMS) do
            pageMap[it.id].Visible = (it.id == id)
        end
        for _, b in pairs(sidebarButtons) do
            local isActive = (b._id == id)
            tween(b, 0.12, { BackgroundColor3 = isActive and Theme.CardHover or Theme.Sidebar })
            tween(b._label, 0.12, { TextColor3 = isActive and Theme.Text or Theme.TextMuted })
            for _, c in pairs(b._iconHolder:GetChildren()) do
                if c:IsA("Frame") then
                    for _, sub in pairs(c:GetDescendants()) do
                        if sub:IsA("Frame") then
                            tween(sub, 0.12, { BackgroundColor3 = isActive and Theme.Text or Theme.TextMuted })
                        end
                    end
                end
            end
        end
    end

    for i, item in ipairs(SIDEBAR_ITEMS) do
        local Btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = item.active and Theme.CardHover or Theme.Sidebar,
            BorderSizePixel = 0,
            Text = "",
            LayoutOrder = i,
            Parent = ListFrame,
        })
        corner(7, Btn)

        local IconHolder = new("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 12, 0.5, -8),
            BackgroundTransparency = 1,
            Parent = Btn,
        })
        local initColor = item.active and Theme.Text or Theme.TextMuted
        IconLib[item.iconFn](IconHolder, initColor)

        local Label = new("TextLabel", {
            Size = UDim2.new(1, -44, 1, 0),
            Position = UDim2.new(0, 36, 0, 0),
            BackgroundTransparency = 1,
            Text = item.label,
            TextColor3 = initColor,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Btn,
        })

        Btn._id = item.id
        Btn._label = Label
        Btn._iconHolder = IconHolder
        table.insert(sidebarButtons, Btn)

        Btn.MouseEnter:Connect(function()
            local curActive = false
            for _, b in pairs(sidebarButtons) do
                if b._label.TextColor3 == Theme.Text and b == Btn then curActive = true end
            end
            if not curActive then tween(Btn, 0.1, { BackgroundColor3 = Theme.Card }) end
        end)
        Btn.MouseLeave:Connect(function()
            local curActive = false
            for _, b in pairs(sidebarButtons) do
                if b._label.TextColor3 == Theme.Text and b == Btn then curActive = true end
            end
            if not curActive then tween(Btn, 0.1, { BackgroundColor3 = Theme.Sidebar }) end
        end)

        Btn.MouseButton1Click:Connect(function()
            selectPage(item.id)
            PageTitle.Text = item.label
        end)
    end

    selectPage("hatch")
end

-- ============================================================
-- START
-- ============================================================
buildKeyUI(function()
    buildMainUI()
end)

print("[Hallwayz] Loaded.")
