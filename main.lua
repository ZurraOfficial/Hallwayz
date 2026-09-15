--[[
    Hallwayz Hub - Roblox Script
    Load via: loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/main.lua"))()
    Version: 1.0.0
]]

-- ================================================================
-- KONFIGURASI
-- ================================================================
local CONFIG = {
    Name = "Hallwayz",
    Version = "1.0.0",
    KeyURL = "https://raw.githubusercontent.com/USERNAME/REPO/main/keys.txt",
    DefaultKey = "HALL-TRIAL-2024-FREE",
}

-- ================================================================
-- SERVICES
-- ================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ================================================================
-- STATE
-- ================================================================
local State = {
    SpeedEnabled = false,
    SpeedValue = 100,
    FlyEnabled = false,
    FlySpeed = 100,
    ESPEnabled = false,
    AimbotEnabled = false,
    AimbotFOV = 150,
    AimbotSmoothness = 0.15,
    AimbotTargetPart = "Head",
    NoclipEnabled = false,
    InfiniteJumpEnabled = false,
    FullbrightEnabled = false,
}

-- Simpan koneksi agar bisa di-disconnect
local Connections = {
    ESP = {},
    Aimbot = nil,
    Speed = nil,
    Fly = nil,
    Noclip = nil,
    InfiniteJump = nil,
}

-- ================================================================
-- ANTI-DUPLICATE
-- ================================================================
if CoreGui:FindFirstChild("HallwayzHub") then
    CoreGui:FindFirstChild("HallwayzHub"):Destroy()
end

-- Cleanup ESP yang mungkin masih ada
for _, obj in pairs(Workspace:GetChildren()) do
    if obj:IsA("BillboardGui") and obj.Name == "HallwayzESP" then
        obj:Destroy()
    end
end

-- ================================================================
-- SCREEN GUI
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HallwayzHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(45, 45, 55)
Stroke.Thickness = 1.5
Stroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 20)
TitleFix.Position = UDim2.new(0, 0, 1, -20)
TitleFix.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.04, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ " .. CONFIG.Name .. "  •  v" .. CONFIG.Version
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- ================================================================
-- KEY SECTION
-- ================================================================
local KeySection = Instance.new("Frame")
KeySection.Size = UDim2.new(1, -40, 0, 250)
KeySection.Position = UDim2.new(0, 20, 0, 60)
KeySection.BackgroundTransparency = 1
KeySection.Parent = MainFrame

local LockIcon = Instance.new("TextLabel")
LockIcon.Size = UDim2.new(1, 0, 0, 50)
LockIcon.BackgroundTransparency = 1
LockIcon.Text = "🔒"
LockIcon.TextSize = 40
LockIcon.Font = Enum.Font.GothamBold
LockIcon.Parent = KeySection

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 22)
Subtitle.Position = UDim2.new(0, 0, 0, 55)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Masukkan key untuk mengakses fitur"
Subtitle.TextColor3 = Color3.fromRGB(160, 160, 170)
Subtitle.TextSize = 13
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = KeySection

local KeyInputFrame = Instance.new("Frame")
KeyInputFrame.Size = UDim2.new(0.7, 0, 0, 42)
KeyInputFrame.Position = UDim2.new(0.15, 0, 0, 95)
KeyInputFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
KeyInputFrame.BorderSizePixel = 0
KeyInputFrame.Parent = KeySection
Instance.new("UICorner", KeyInputFrame).CornerRadius = UDim.new(0, 8)

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(50, 50, 60)
KeyStroke.Thickness = 1
KeyStroke.Parent = KeyInputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "HALL-XXXX-XXXX-XXXX"
KeyInput.PlaceholderColor3 = Color3.fromRGB(90, 90, 100)
KeyInput.TextColor3 = Color3.fromRGB(240, 240, 245)
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = KeyInputFrame

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.7, 0, 0, 42)
SubmitBtn.Position = UDim2.new(0.15, 0, 0, 150)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
SubmitBtn.BorderSizePixel = 0
SubmitBtn.Text = "Verifikasi Key"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Parent = KeySection
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 22)
StatusLabel.Position = UDim2.new(0, 0, 0, 200)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = KeySection

-- ================================================================
-- MAIN UI (Setelah key valid)
-- ================================================================
local MainUI = Instance.new("Frame")
MainUI.Size = UDim2.new(1, -40, 1, -80)
MainUI.Position = UDim2.new(0, 20, 0, 60)
MainUI.BackgroundTransparency = 1
MainUI.Visible = false
MainUI.Parent = MainFrame

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 36)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainUI
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -46)
TabContainer.Position = UDim2.new(0, 0, 0, 46)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainUI

-- ScrollFrame untuk konten
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = TabContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- ================================================================
-- HELPER: BUAT TAB
-- ================================================================
local currentTab = nil

local function createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 80, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    -- Position berdasarkan jumlah tab
    local count = 0
    for _, child in pairs(TabBar:GetChildren()) do
        if child:IsA("TextButton") then count = count + 1 end
    end
    TabBtn.Position = UDim2.new(0, 4 + (count - 1) * 84, 0, 3)
    TabBtn.Size = UDim2.new(0, 80, 0, 30)

    TabBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(TabBar:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(30, 30, 36),
                    TextColor3 = Color3.fromRGB(160, 160, 170)
                }):Play()
            end
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(88, 101, 242),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        currentTab = name
    end)

    return TabBtn
end

-- ================================================================
-- HELPER: BUAT TOGGLE
-- ================================================================
local function createToggle(label, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -8, 0, 42)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ScrollFrame
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = label
    ToggleLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = ""
    ToggleBtn.Parent = ToggleFrame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 11)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new(0, 3, 0.5, -8)
    Dot.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    Dot.BorderSizePixel = 0
    Dot.Parent = ToggleBtn
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local toggled = default or false

    -- Set initial visual
    if toggled then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), { Position = UDim2.new(1, -19, 0.5, -8) }):Play()
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), { Position = UDim2.new(1, -19, 0.5, -8) }):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 40, 48) }):Play()
            TweenService:Create(Dot, TweenInfo.new(0.2), { Position = UDim2.new(0, 3, 0.5, -8) }):Play()
        end
        if callback then
            pcall(callback, toggled)
        end
    end)

    return ToggleFrame
end

-- ================================================================
-- HELPER: BUAT SLIDER
-- ================================================================
local function createSlider(label, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -8, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = ScrollFrame
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -24, 0, 22)
    SliderLabel.Position = UDim2.new(0, 12, 0, 6)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = label .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
    SliderLabel.TextSize = 13
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 6)
    Bar.Position = UDim2.new(0, 12, 0, 38)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Bar.BorderSizePixel = 0
    Bar.Parent = SliderFrame
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 3)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = Bar
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local value = default

    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Dot.Position = UDim2.new(pos, -7, 0.5, -7)
        SliderLabel.Text = label .. ": " .. value
        if callback then
            pcall(callback, value)
        end
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return SliderFrame
end

-- ================================================================
-- FITUR: SPEED
-- ================================================================
local function setSpeed(value)
    State.SpeedValue = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end

local function enableSpeed(enabled)
    State.SpeedEnabled = enabled
    if Connections.Speed then
        Connections.Speed:Disconnect()
        Connections.Speed = nil
    end

    if enabled then
        local function applySpeed()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = State.SpeedValue
                end
            end
        end
        applySpeed()
        Connections.Speed = LocalPlayer.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid")
            task.wait(0.5)
            applySpeed()
        end)
    else
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end

-- ================================================================
-- FITUR: FLY
-- ================================================================
local function enableFly(enabled)
    State.FlyEnabled = enabled

    if Connections.Fly then
        Connections.Fly:Disconnect()
        Connections.Fly = nil
    end

    if enabled then
        local character = LocalPlayer.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not rootPart then return end

        -- Buat BodyVelocity & BodyGyro
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "HallwayzFly"
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = rootPart

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "HallwayzFlyGyro"
        bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bodyGyro.P = 1000
        bodyGyro.D = 50
        bodyGyro.Parent = rootPart

        local flySpeed = State.FlySpeed

        Connections.Fly = RunService.RenderStepped:Connect(function()
            if not character.Parent or not rootPart.Parent then return end

            local direction = Vector3.zero
            local camCFrame = Camera.CFrame

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camCFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camCFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                bodyVelocity.Velocity = direction.Unit * flySpeed
            else
                bodyVelocity.Velocity = Vector3.zero
            end

            bodyGyro.CFrame = camCFrame
        end)

        -- Cleanup saat character mati
        character.Humanoid.Died:Connect(function()
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end)
    else
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local bv = rootPart:FindFirstChild("HallwayzFly")
                local bg = rootPart:FindFirstChild("HallwayzFlyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
        end
    end
end

-- ================================================================
-- FITUR: NOCLIP
-- ================================================================
local function enableNoclip(enabled)
    State.NoclipEnabled = enabled

    if Connections.Noclip then
        Connections.Noclip:Disconnect()
        Connections.Noclip = nil
    end

    if enabled then
        Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ================================================================
-- FITUR: INFINITE JUMP
-- ================================================================
local function enableInfiniteJump(enabled)
    State.InfiniteJumpEnabled = enabled

    if Connections.InfiniteJump then
        Connections.InfiniteJump:Disconnect()
        Connections.InfiniteJump = nil
    end

    if enabled then
        Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

-- ================================================================
-- FITUR: FULLBRIGHT
-- ================================================================
local originalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

local function enableFullbright(enabled)
    State.FullbrightEnabled = enabled
    if enabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.FogEnd = 1e10
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end
end

-- ================================================================
-- FITUR: ESP
-- ================================================================
local function createESP(player)
    if player == LocalPlayer then return end

    local function addESP(character)
        if not character then return end

        local function onChildAdded(child)
            if child:IsA("BasePart") and child.Name == "Head" then
                -- Hapus ESP lama jika ada
                local oldESP = child:FindFirstChild("HallwayzESP")
                if oldESP then oldESP:Destroy() end

                local BillboardGui = Instance.new("BillboardGui")
                BillboardGui.Name = "HallwayzESP"
                BillboardGui.Adornee = child
                BillboardGui.Size = UDim2.new(0, 200, 0, 50)
                BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
                BillboardGui.AlwaysOnTop = true
                BillboardGui.Parent = child

                local NameLabel = Instance.new("TextLabel")
                NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = player.Name
                NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                NameLabel.TextStrokeTransparency = 0
                NameLabel.TextSize = 14
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.Parent = BillboardGui

                local DistanceLabel = Instance.new("TextLabel")
                DistanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                DistanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                DistanceLabel.BackgroundTransparency = 1
                DistanceLabel.Text = "0 studs"
                DistanceLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                DistanceLabel.TextStrokeTransparency = 0
                DistanceLabel.TextSize = 12
                DistanceLabel.Font = Enum.Font.Gotham
                DistanceLabel.Parent = BillboardGui

                -- Update distance
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if not child or not child.Parent or not LocalPlayer.Character then
                        connection:Disconnect()
                        return
                    end
                    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = math.floor((root.Position - child.Position).Magnitude)
                        DistanceLabel.Text = dist .. " studs"
                    end
                end)

                table.insert(Connections.ESP, connection)
            end
        end

        character.ChildAdded:Connect(onChildAdded)
        for _, child in pairs(character:GetChildren()) do
            onChildAdded(child)
        end

        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "HallwayzHighlight"
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end

    if player.Character then
        addESP(player.Character)
    end

    player.CharacterAdded:Connect(addESP)
end

local function clearESP()
    -- Hapus semua BillboardGui ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, desc in pairs(player.Character:GetDescendants()) do
                if desc.Name == "HallwayzESP" then
                    desc:Destroy()
                end
                if desc.Name == "HallwayzHighlight" then
                    desc:Destroy()
                end
            end
        end
    end

    -- Disconnect semua
    for _, conn in pairs(Connections.ESP) do
        pcall(function() conn:Disconnect() end)
    end
    Connections.ESP = {}
end

local function enableESP(enabled)
    State.ESPEnabled = enabled

    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
        end

        Players.PlayerAdded:Connect(function(player)
            if State.ESPEnabled then
                createESP(player)
            end
        end)
    else
        clearESP()
    end
end

-- ================================================================
-- FITUR: AIMBOT
-- ================================================================
local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = State.AimbotFOV

    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(State.AimbotTargetPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function enableAimbot(enabled)
    State.AimbotEnabled = enabled

    if Connections.Aimbot then
        Connections.Aimbot:Disconnect()
        Connections.Aimbot = nil
    end

    if enabled then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            if not State.AimbotEnabled then return end

            local target = getClosestPlayerToCursor()
            if target and target.Character then
                local part = target.Character:FindFirstChild(State.AimbotTargetPart)
                if part then
                    local targetPos = part.Position
                    Camera.CFrame = Camera.CFrame:Lerp(
                        CFrame.new(Camera.CFrame.Position, targetPos),
                        State.AimbotSmoothness
                    )
                end
            end
        end)
    end
end

-- ================================================================
-- RENDER UI SETELAH KEY VALID
-- ================================================================
local function buildMainUI()
    -- Tab: Main
    createTab("Main")

    createToggle("Speed Hack", false, function(state)
        enableSpeed(state)
    end)

    createSlider("Speed Value", 16, 500, 100, function(value)
        State.SpeedValue = value
        if State.SpeedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    end)

    createToggle("Fly", false, function(state)
        enableFly(state)
    end)

    createSlider("Fly Speed", 20, 500, 100, function(value)
        State.FlySpeed = value
    end)

    -- Tab: Combat
    createTab("Combat")

    createToggle("Aimbot", false, function(state)
        enableAimbot(state)
    end)

    createSlider("Aimbot FOV", 50, 500, 150, function(value)
        State.AimbotFOV = value
    end)

    createSlider("Aimbot Smoothness", 1, 100, 15, function(value)
        State.AimbotSmoothness = value / 100
    end)

    -- Tab: Visual
    createTab("Visual")

    createToggle("ESP", false, function(state)
        enableESP(state)
    end)

    createToggle("Fullbright", false, function(state)
        enableFullbright(state)
    end)

    -- Tab: Player
    createTab("Player")

    createToggle("Noclip", false, function(state)
        enableNoclip(state)
    end)

    createToggle("Infinite Jump", false, function(state)
        enableInfiniteJump(state)
    end)
end

-- ================================================================
-- VERIFIKASI KEY
-- ================================================================
local function getValidKeys()
    if not CONFIG.KeyURL or CONFIG.KeyURL == "" then
        return {}
    end

    local success, result = pcall(function()
        return game:HttpGet(CONFIG.KeyURL)
    end)

    if not success or not result then
        return {}
    end

    local keys = {}
    for line in result:gmatch("[^\r\n]+") do
        line = line:gsub("%s+", "")
        if line ~= "" and not line:match("^#") then
            keys[line] = true
        end
    end
    return keys
end

local function verifyKey(inputKey)
    if not inputKey or inputKey == "" then
        return false
    end

    local validKeys = getValidKeys()
    if validKeys[inputKey] then
        return true
    end

    -- Fallback
    if inputKey == CONFIG.DefaultKey then
        return true
    end

    return false
end

-- ================================================================
-- EVENT: SUBMIT KEY
-- ================================================================
SubmitBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text

    StatusLabel.Text = "⏳ Memverifikasi..."
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
    SubmitBtn.Text = "Memverifikasi..."
    task.wait(0.5)

    if verifyKey(key) then
        StatusLabel.Text = "✅ Key valid!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 120)

        task.wait(0.3)
        KeySection.Visible = false
        MainUI.Visible = true
        MainFrame.Size = UDim2.new(0, 520, 0, 420)

        buildMainUI()
    else
        StatusLabel.Text = "❌ Key tidak valid"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        SubmitBtn.Text = "Verifikasi Key"

        -- Efek shake
        local originalPos = KeyInputFrame.Position
        for i = 1, 4 do
            KeyInputFrame.Position = originalPos + UDim2.new(0, (i % 2 == 0 and 8 or -8), 0, 0)
            task.wait(0.05)
        end
        KeyInputFrame.Position = originalPos
    end
end)

KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        SubmitBtn.MouseButton1Click:Fire()
    end
end)

-- ================================================================
-- CLOSE BUTTON
-- ================================================================
CloseBtn.MouseButton1Click:Connect(function()
    -- Cleanup fitur
    enableSpeed(false)
    enableFly(false)
    enableESP(false)
    enableAimbot(false)
    enableNoclip(false)
    enableInfiniteJump(false)
    enableFullbright(false)

    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()

    task.wait(0.35)
    ScreenGui:Destroy()
end)

-- ================================================================
-- NOTIFIKASI LOADED
-- ================================================================
local Notif = Instance.new("TextLabel")
Notif.Size = UDim2.new(0, 320, 0, 42)
Notif.Position = UDim2.new(1, -340, 0, 20)
Notif.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Notif.BorderSizePixel = 0
Notif.Text = "  ⚡ " .. CONFIG.Name .. " loaded successfully"
Notif.TextColor3 = Color3.fromRGB(240, 240, 245)
Notif.TextSize = 13
Notif.Font = Enum.Font.Gotham
Notif.TextXAlignment = Enum.TextXAlignment.Left
Notif.Parent = ScreenGui
Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)

task.delay(3, function()
    TweenService:Create(Notif, TweenInfo.new(0.5), {
        Position = UDim2.new(1, 20, 0, 20),
        BackgroundTransparency = 1,
        TextTransparency = 1
    }):Play()
    task.wait(0.6)
    Notif:Destroy()
end)

print("[Hallwayz] Script loaded successfully.")
