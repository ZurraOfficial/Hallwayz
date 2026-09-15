--[[
    Hallwayz Hub
    Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/ZurraOfficial/Hallwayz/main/main.lua"))()
    Version: 1.0.0
]]

-- ============================================================
-- CONFIG — WAJIB DIISI
-- ============================================================
local CONFIG = {
    Name = "Hallwayz",
    Subtitle = "Steal an Egg",
    Version = "v1.0.0",

    -- Lootlabs: link "Get Key" yang buka di browser
    LootlabsURL = "https://links.lootlabs.gg/s?1Q3QoHte",

    -- Daftar key valid (via GitHub raw)
    KeysURL = "https://raw.githubusercontent.com/ZurraOfficial/Hallwayz/main/keys.txt",

    -- Discord invite
    DiscordURL = "https://discord.gg/wallzyq",

    -- Kalau true, key akan diikat ke HWID (1 key = 1 device)
    UseHWID = false,
}

-- ============================================================
-- THEME
-- ============================================================
local Theme = {
    BG          = Color3.fromRGB(10, 10, 15),
    Sidebar     = Color3.fromRGB(15, 15, 20),
    Card        = Color3.fromRGB(19, 19, 24),
    CardHover   = Color3.fromRGB(24, 24, 30),
    Border      = Color3.fromRGB(28, 28, 36),
    BorderHover = Color3.fromRGB(45, 45, 55),
    Text        = Color3.fromRGB(232, 232, 236),
    TextMuted   = Color3.fromRGB(120, 120, 135),
    Accent      = Color3.fromRGB(107, 127, 255),
    AccentDark  = Color3.fromRGB(80, 100, 220),
    Success     = Color3.fromRGB(74, 222, 128),
    Error       = Color3.fromRGB(248, 113, 113),
    Warning     = Color3.fromRGB(250, 204, 21),
}

-- ============================================================
-- ICONS — Roblox asset IDs (ganti sesuai selera)
-- Semua ini adalah ikon Lucide-style yang umum dipakai di Roblox UI
-- Kalau ada yang ngga muncul, tinggal ganti ID-nya
-- ============================================================
local Icons = {
    Information = "rbxassetid://10734950309",
    HatchSteal  = "rbxassetid://10734898355",
    Hatchery    = "rbxassetid://10723407389",
    Barn        = "rbxassetid://10709790948",
    Rift        = "rbxassetid://10734923549",
    Upgrades    = "rbxassetid://10734896206",
    Extras      = "rbxassetid://10734924949",
    Presets     = "rbxassetid://10734896332",
    Search      = "rbxassetid://10734922122",
    Close       = "rbxassetid://10747373176",
    Minimize    = "rbxassetid://10734898088",
    Chevron     = "rbxassetid://10709790930",
    Key         = "rbxassetid://10734898355",
    Logo        = "", -- kosongkan kalau mau pakai bentuk frame (fallback)
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CLEANUP
-- ============================================================
if CoreGui:FindFirstChild("HallwayzUI") then
    CoreGui:FindFirstChild("HallwayzUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HallwayzUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- ============================================================
-- HELPERS
-- ============================================================
local function new(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    return obj
end

local function corner(radius, parent)
    return new("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

local function stroke(color, thickness, parent)
    return new("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function padding(px, parent)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, px),
        PaddingBottom = UDim.new(0, px),
        PaddingLeft = UDim.new(0, px),
        PaddingRight = UDim.new(0, px),
        Parent = parent
    })
end

-- ============================================================
-- FPS COUNTER
-- ============================================================
local fpsValue = 60
task.spawn(function()
    while ScreenGui.Parent do
        local t = tick()
        RunService.RenderStepped:Wait()
        local delta = tick() - t
        if delta > 0 then
            fpsValue = math.floor(1 / delta)
        end
    end
end)

-- ============================================================
-- KEY VALIDATION
-- ============================================================
local function fetchValidKeys()
    if not CONFIG.KeysURL or CONFIG.KeysURL == "" then
        return {}
    end
    local ok, result = pcall(function()
        return game:HttpGet(CONFIG.KeysURL, true)
    end)
    if not ok or not result then return {} end
    local keys = {}
    for line in result:gmatch("[^\r\n]+") do
        line = line:gsub("%s+", "")
        if line ~= "" and not line:match("^#") then
            keys[line] = true
        end
    end
    return keys
end

local function getHWID()
    local ok, hwid = pcall(function()
        if gethwid then return gethwid() end
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    return ok and hwid or "unknown"
end

local function validateKey(inputKey)
    if not inputKey or inputKey == "" then
        return false, "Key tidak boleh kosong"
    end
    local validKeys = fetchValidKeys()
    if validKeys[inputKey] then
        return true, "Key valid"
    end
    return false, "Key tidak valid"
end

-- ============================================================
-- KEY UI
-- ============================================================
local function buildKeyUI(onSuccess)
    -- Dim background
    local Dim = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })

    -- Card
    local KeyCard = new("Frame", {
        Size = UDim2.new(0, 440, 0, 320),
        Position = UDim2.new(0.5, -220, 0.5, -160),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        Parent = Dim,
    })
    corner(16, KeyCard)
    stroke(Theme.Border, 1, KeyCard)

    -- Subtle accent glow
    local Glow = new("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1.5,
        Transparency = 0.7,
        Parent = KeyCard,
    })
    task.spawn(function()
        while KeyCard.Parent do
            tween(Glow, 2, { Transparency = 0.2 })
            task.wait(2)
            tween(Glow, 2, { Transparency = 0.85 })
            task.wait(2)
        end
    end)

    -- Header
    local Header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 74),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = KeyCard,
    })
    corner(16, Header)

    -- Hide bottom corners of header
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -16),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Header,
    })

    -- Logo (drawn shape — pengganti logo kamu)
    local LogoBox = new("Frame", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 16, 0.5, -22),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = Header,
    })
    corner(10, LogoBox)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "H",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22,
        Font = Enum.Font.GothamBlack,
        Parent = LogoBox,
    })

    -- Title
    new("TextLabel", {
        Size = UDim2.new(1, -80, 0, 22),
        Position = UDim2.new(0, 72, 0, 16),
        BackgroundTransparency = 1,
        Text = CONFIG.Name,
        TextColor3 = Theme.Text,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -80, 0, 16),
        Position = UDim2.new(0, 72, 0, 38),
        BackgroundTransparency = 1,
        Text = "Key System • " .. CONFIG.Version,
        TextColor3 = Theme.TextMuted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header,
    })

    -- Close button
    local KeyCloseBtn = new("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -40, 0, 22),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Text = "",
        Parent = Header,
    })
    corner(8, KeyCloseBtn)
    new("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0.5, -7),
        BackgroundTransparency = 1,
        Image = Icons.Close,
        ImageColor3 = Theme.TextMuted,
        Parent = KeyCloseBtn,
    })
    KeyCloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    KeyCloseBtn.MouseEnter:Connect(function()
        tween(KeyCloseBtn, 0.15, { BackgroundColor3 = Theme.CardHover })
    end)
    KeyCloseBtn.MouseLeave:Connect(function()
        tween(KeyCloseBtn, 0.15, { BackgroundColor3 = Theme.Card })
    end)

    -- Body
    local Body = new("Frame", {
        Size = UDim2.new(1, -32, 1, -100),
        Position = UDim2.new(0, 16, 0, 88),
        BackgroundTransparency = 1,
        Parent = KeyCard,
    })

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Masukkan key untuk melanjutkan",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Body,
    })

    -- Input
    local InputBox = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = Body,
    })
    corner(10, InputBox)
    local InputStroke = stroke(Theme.Border, 1, InputBox)

    new("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 14, 0.5, -8),
        BackgroundTransparency = 1,
        Image = Icons.Key,
        ImageColor3 = Theme.TextMuted,
        Parent = InputBox,
    })

    local KeyInput = new("TextBox", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "XXXX-XXXX-XXXX-XXXX",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = InputBox,
    })

    local PasteBtn = new("TextButton", {
        Size = UDim2.new(0, 60, 0, 30),
        Position = UDim2.new(1, -68, 0.5, -15),
        BackgroundColor3 = Theme.CardHover,
        BorderSizePixel = 0,
        Text = "Paste",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Parent = InputBox,
    })
    corner(6, PasteBtn)
    PasteBtn.MouseButton1Click:Connect(function()
        local ok, clip = pcall(function()
            return game:GetService("GuiService"):GetClipboard()
        end)
        if ok and clip and clip ~= "" then
            KeyInput.Text = clip
        end
    end)

    -- Get key button
    local GetKeyBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 46),
        Position = UDim2.new(0, 0, 0, 92),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Text = "Dapatkan Key di Lootlabs",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        Parent = Body,
    })
    corner(10, GetKeyBtn)
    local GetKeyStroke = stroke(Theme.Border, 1, GetKeyBtn)

    GetKeyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(CONFIG.LootlabsURL)
        end)
    end)
    GetKeyBtn.MouseEnter:Connect(function()
        tween(GetKeyBtn, 0.15, { BackgroundColor3 = Theme.CardHover })
        tween(GetKeyStroke, 0.15, { Color = Theme.BorderHover })
    end)
    GetKeyBtn.MouseLeave:Connect(function()
        tween(GetKeyBtn, 0.15, { BackgroundColor3 = Theme.Card })
        tween(GetKeyStroke, 0.15, { Color = Theme.Border })
    end)

    -- Status
    local StatusLabel = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 148),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.TextMuted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = Body,
    })

    -- Verify button
    local VerifyBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 46),
        Position = UDim2.new(0, 0, 0, 178),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "Verifikasi Key",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = Body,
    })
    corner(10, VerifyBtn)

    VerifyBtn.MouseEnter:Connect(function()
        tween(VerifyBtn, 0.15, { BackgroundColor3 = Theme.AccentDark })
    end)
    VerifyBtn.MouseLeave:Connect(function()
        tween(VerifyBtn, 0.15, { BackgroundColor3 = Theme.Accent })
    end)

    -- Submit logic
    local function submit()
        local key = KeyInput.Text

        if key == "" then
            StatusLabel.Text = "Key tidak boleh kosong"
            StatusLabel.TextColor3 = Theme.Error
            tween(InputStroke, 0.15, { Color = Theme.Error })
            task.delay(1.5, function()
                tween(InputStroke, 0.3, { Color = Theme.Border })
            end)
            return
        end

        StatusLabel.Text = "Memverifikasi..."
        StatusLabel.TextColor3 = Theme.Warning
        VerifyBtn.Text = "Memverifikasi..."
        task.wait(0.6)

        local valid, message = validateKey(key)
        if valid then
            StatusLabel.Text = message
            StatusLabel.TextColor3 = Theme.Success
            tween(InputStroke, 0.2, { Color = Theme.Success })
            task.wait(0.5)

            -- Fade out
            tween(Dim, 0.35, { BackgroundTransparency = 1 })
            tween(KeyCard, 0.35, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
            })
            task.wait(0.4)
            Dim:Destroy()

            onSuccess()
        else
            StatusLabel.Text = message
            StatusLabel.TextColor3 = Theme.Error
            VerifyBtn.Text = "Verifikasi Key"
            tween(InputStroke, 0.15, { Color = Theme.Error })
            task.delay(1.5, function()
                tween(InputStroke, 0.3, { Color = Theme.Border })
            end)

            -- Shake
            local original = InputBox.Position
            for i = 1, 4 do
                InputBox.Position = original + UDim2.new(0, (i % 2 == 0 and 8 or -8), 0, 0)
                task.wait(0.04)
            end
            InputBox.Position = original
        end
    end

    VerifyBtn.MouseButton1Click:Connect(submit)
    KeyInput.FocusLost:Connect(function(enter)
        if enter then submit() end
    end)
end

-- ============================================================
-- MAIN UI
-- ============================================================
local SIDEBAR_ITEMS = {
    { id = "info",      label = "Information",    icon = Icons.Information },
    { id = "hatch",     label = "Hatch & Steal",  icon = Icons.HatchSteal, active = true },
    { id = "hatchery",  label = "Hatchery",       icon = Icons.Hatchery },
    { id = "barn",      label = "Barn",           icon = Icons.Barn },
    { id = "rift",      label = "Rift",           icon = Icons.Rift },
    { id = "upgrades",  label = "Upgrades",       icon = Icons.Upgrades },
    { id = "extras",    label = "Extras",         icon = Icons.Extras },
    { id = "presets",   label = "Presets",        icon = Icons.Presets },
}

local function buildMainUI()
    local Main = new("Frame", {
        Size = UDim2.new(0, 880, 0, 560),
        Position = UDim2.new(0.5, -440, 0.5, -280),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    corner(16, Main)
    stroke(Theme.Border, 1, Main)

    local MainSize = UDim2.new(0, 880, 0, 560)
    local MainPos = Main.Position
    Main.Size = UDim2.new(0, 0, 0, 0)
    tween(Main, 0.35, { Size = MainSize })

    -- ============================================================
    -- SIDEBAR
    -- ============================================================
    local Sidebar = new("Frame", {
        Size = UDim2.new(0, 220, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Main,
    })
    corner(16, Sidebar)

    -- Hide right corners
    new("Frame", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Sidebar,
    })

    -- Brand header
    local BrandFrame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundTransparency = 1,
        Parent = Sidebar,
    })

    -- Logo
    local Logo = new("Frame", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 18, 0.5, -20),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = BrandFrame,
    })
    corner(10, Logo)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "H",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBlack,
        Parent = Logo,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -75, 0, 20),
        Position = UDim2.new(0, 68, 0, 18),
        BackgroundTransparency = 1,
        Text = CONFIG.Name,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = BrandFrame,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -75, 0, 14),
        Position = UDim2.new(0, 68, 0, 38),
        BackgroundTransparency = 1,
        Text = CONFIG.Subtitle,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = BrandFrame,
    })

    -- Sidebar list
    local ListFrame = new("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -72 - 56),
        Position = UDim2.new(0, 6, 0, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ListFrame,
    })

    -- Discord card (bottom)
    local DiscordCard = new("TextButton", {
        Size = UDim2.new(1, -16, 0, 40),
        Position = UDim2.new(0, 8, 1, -48),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Text = "",
        Parent = Sidebar,
    })
    corner(10, DiscordCard)
    stroke(Theme.Border, 1, DiscordCard)

    new("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = CONFIG.DiscordURL:gsub("https://", ""):gsub("http://", ""),
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = DiscordCard,
    })

    DiscordCard.MouseButton1Click:Connect(function()
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(CONFIG.DiscordURL)
        end)
    end)

    -- ============================================================
    -- CONTENT AREA
    -- ============================================================
    local Content = new("Frame", {
        Size = UDim2.new(1, -220, 1, 0),
        Position = UDim2.new(0, 220, 0, 0),
        BackgroundTransparency = 1,
        Parent = Main,
    })

    -- Top bar (title + search + window controls)
    local TopBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent = Content,
    })

    local PageTitle = new("TextLabel", {
        Size = UDim2.new(0, 300, 0, 20),
        Position = UDim2.new(0, 24, 0, 14),
        BackgroundTransparency = 1,
        Text = "Hatch & Steal",
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })
    local PageSub = new("TextLabel", {
        Size = UDim2.new(0, 400, 0, 16),
        Position = UDim2.new(0, 24, 0, 34),
        BackgroundTransparency = 1,
        Text = "Choose what to take, then go and take it",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    -- Search bar
    local SearchBox = new("Frame", {
        Size = UDim2.new(0, 200, 0, 34),
        Position = UDim2.new(1, -340, 0, 14),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    corner(8, SearchBox)
    stroke(Theme.Border, 1, SearchBox)

    new("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 12, 0.5, -7),
        BackgroundTransparency = 1,
        Image = Icons.Search,
        ImageColor3 = Theme.TextMuted,
        Parent = SearchBox,
    })
    new("TextBox", {
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchBox,
    })

    -- Window controls
    local function makeWinBtn(icon, order)
        local Btn = new("TextButton", {
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(1, -40 - (order * 32), 0, 17),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Text = "",
            Parent = TopBar,
        })
        corner(6, Btn)
        new("ImageLabel", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0.5, -6, 0.5, -6),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = Theme.TextMuted,
            Parent = Btn,
        })
        Btn.MouseEnter:Connect(function()
            tween(Btn, 0.15, { BackgroundColor3 = Theme.CardHover })
        end)
        Btn.MouseLeave:Connect(function()
            tween(Btn, 0.15, { BackgroundColor3 = Theme.Card })
        end)
        return Btn
    end

    local MinBtn = makeWinBtn(Icons.Minimize, 0)
    local CloseBtn = makeWinBtn(Icons.Close, 1)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- ============================================================
    -- PAGES (Content router)
    -- ============================================================
    local Pages = new("Frame", {
        Size = UDim2.new(1, -24, 1, -80),
        Position = UDim2.new(0, 12, 0, 68),
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

    -- ============================================================
    -- EMPTY PAGE TEMPLATE
    -- Membuat header + 2 kolom kosong siap diisi fitur
    -- ============================================================
    local function fillEmptyPage(page, title, subtitle)
        -- Scroll frame
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

        -- Grid 2 kolom
        local grid = new("UIGridLayout", {
            CellSize = UDim2.new(0.5, -6, 0, 200),
            CellPadding = UDim2.new(0, 12, 0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = scroll,
        })
        padding(12, scroll)

        -- 2 placeholder cards
        for i = 1, 2 do
            local card = new("Frame", {
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                LayoutOrder = i,
                Parent = scroll,
            })
            corner(12, card)
            stroke(Theme.Border, 1, card)

            -- header row
            new("TextLabel", {
                Size = UDim2.new(1, -32, 0, 24),
                Position = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Text = (i == 1 and "Section A" or "Section B"),
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card,
            })

            -- divider
            new("Frame", {
                Size = UDim2.new(1, -32, 0, 1),
                Position = UDim2.new(0, 16, 0, 48),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = card,
            })

            new("TextLabel", {
                Size = UDim2.new(1, -32, 1, -60),
                Position = UDim2.new(0, 16, 0, 56),
                BackgroundTransparency = 1,
                Text = "Empty — fitur akan ditambahkan di sini",
                TextColor3 = Theme.TextMuted,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Parent = card,
            })
        end
    end

    -- Isi tiap page dengan template kosong
    for _, item in ipairs(SIDEBAR_ITEMS) do
        fillEmptyPage(pageMap[item.id], item.label, "")
    end

    -- ============================================================
    -- SIDEBAR BUTTONS
    -- ============================================================
    local sidebarButtons = {}

    local function selectPage(id)
        for _, item in ipairs(SIDEBAR_ITEMS) do
            local page = pageMap[item.id]
            page.Visible = (item.id == id)
        end
        -- Update active state
        for _, btn in pairs(sidebarButtons) do
            local isActive = (btn._id == id)
            tween(btn, 0.15, {
                BackgroundColor3 = isActive and Theme.CardHover or Theme.Sidebar,
            })
            tween(btn._label, 0.15, {
                TextColor3 = isActive and Theme.Text or Theme.TextMuted,
            })
            tween(btn._icon, 0.15, {
                ImageColor3 = isActive and Theme.Text or Theme.TextMuted,
            })
        end
    end

    for i, item in ipairs(SIDEBAR_ITEMS) do
        local Btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = item.active and Theme.CardHover or Theme.Sidebar,
            BorderSizePixel = 0,
            Text = "",
            LayoutOrder = i,
            Parent = ListFrame,
        })
        corner(8, Btn)

        local Icon = new("ImageLabel", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 14, 0.5, -8),
            BackgroundTransparency = 1,
            Image = item.icon,
            ImageColor3 = item.active and Theme.Text or Theme.TextMuted,
            Parent = Btn,
        })

        local Label = new("TextLabel", {
            Size = UDim2.new(1, -44, 1, 0),
            Position = UDim2.new(0, 38, 0, 0),
            BackgroundTransparency = 1,
            Text = item.label,
            TextColor3 = item.active and Theme.Text or Theme.TextMuted,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Btn,
        })

        Btn._id = item.id
        Btn._label = Label
        Btn._icon = Icon
        sidebarButtons[#sidebarButtons + 1] = Btn

        Btn.MouseEnter:Connect(function()
            if Btn._id ~= item.active then
                tween(Btn, 0.12, { BackgroundColor3 = Theme.Card })
            end
        end)
        Btn.MouseLeave:Connect(function()
            local currentlyActive = false
            for _, b in pairs(sidebarButtons) do
                if b._label.TextColor3 == Theme.Text then
                    -- do nothing
                end
            end
            if Btn._id ~= nil then
                local isActive = false
                for _, otherBtn in pairs(sidebarButtons) do
                    if otherBtn._label.TextColor3 == Theme.Text and otherBtn == Btn then
                        isActive = true
                    end
                end
                if not isActive then
                    tween(Btn, 0.12, { BackgroundColor3 = Theme.Sidebar })
                end
            end
        end)

        Btn.MouseButton1Click:Connect(function()
            selectPage(item.id)
            -- Update title
            PageTitle.Text = item.label
        end)
    end

    -- Initial page
    selectPage("hatch")

    -- ============================================================
    -- BOTTOM STATUS BAR
    -- ============================================================
    local StatusBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundTransparency = 1,
        Parent = Content,
    })

    local function makeStatChip(text, order, width)
        local chip = new("Frame", {
            Size = UDim2.new(0, width or 90, 0, 22),
            Position = UDim2.new(1, -(width or 90) * order - 8 * order - 12, 0.5, -11),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Parent = StatusBar,
        })
        corner(6, chip)
        stroke(Theme.Border, 1, chip)
        new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextMuted,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            Parent = chip,
        })
        return chip
    end

    -- Version
    makeStatChip(CONFIG.Version, 1, 60)

    -- FPS
    local fpsChip = makeStatChip("-- FPS", 2, 80)
    local fpsLabel = fpsChip:FindFirstChildOfClass("TextLabel")
    task.spawn(function()
        while fpsChip.Parent do
            fpsLabel.Text = tostring(fpsValue) .. " FPS"
            task.wait(0.5)
        end
    end)

    -- Executor
    local execName = "Unknown"
    if identifyexecutor then
        local ok, n = pcall(identifyexecutor)
        if ok and n then execName = n end
    end
    makeStatChip("Executor: " .. execName, 3, 150)
end

-- ============================================================
-- START
-- ============================================================
buildKeyUI(function()
    buildMainUI()
end)

print("[Hallwayz] Loaded.")
