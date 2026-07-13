-- ==========================================================
-- SCRIPT: NAW HUB V1 
-- TÁC GIẢ: namnguyen57 |
-- ==========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. TẠO SPLASH SCREEN XOAY VÒNG AN TOÀN
local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "NawSplash"
SplashGui.ResetOnSpawn = false
SplashGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Background.Parent = SplashGui

local Spinner = Instance.new("Frame")
Spinner.Size = UDim2.new(0, 80, 0, 80)
Spinner.Position = UDim2.new(0.5, -40, 0.5, -40)
Spinner.BackgroundTransparency = 1
Spinner.Parent = Background

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 5
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Parent = Spinner

local UICornerSpinner = Instance.new("UICorner")
UICornerSpinner.CornerRadius = UDim.new(1, 0)
UICornerSpinner.Parent = Spinner

local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Size = UDim2.new(1, 0, 0, 100)
AuthorLabel.Position = UDim2.new(0, 0, 0.5, 60)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "NAW HUB V1\nLoading by namnguyen57..."
AuthorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthorLabel.Font = Enum.Font.SourceSansBold
AuthorLabel.TextSize = 22
AuthorLabel.Parent = Background

local spinTween = TweenService:Create(Spinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
spinTween:Play()

task.wait(2) -- Giảm bớt thời gian chờ cho nhanh gọn

pcall(function()
    TweenService:Create(Background, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(AuthorLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
end)
task.wait(0.5)
SplashGui:Destroy()

-- 2. BIẾN TRẠNG THÁI & LOGIC TÍNH NĂNG
local AntiAFK_Enabled = false
local Speed_Enabled = false
local Noclip_Enabled = false
local Fly_Enabled = false

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if AntiAFK_Enabled then
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- Boost FPS
local function OptimizeGame()
    pcall(function()
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").FogEnd = 9e9
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic end
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
        end
    end)
end

-- Speed Loop
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if Speed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 60
            elseif not Speed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if LocalPlayer.Character.Humanoid.WalkSpeed == 60 then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 16
                end
            end
        end)
    end
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if Noclip_Enabled and LocalPlayer.Character then
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- Fly Loop
local flyBv, flyBg
RunService.RenderStepped:Connect(function()
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local camera = workspace.CurrentCamera
            
            if not flyBv or flyBv.Parent ~= hrp then
                flyBv = Instance.new("BodyVelocity")
                flyBv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                flyBv.Parent = hrp
            end
            if not flyBg or flyBg.Parent ~= hrp then
                flyBg = Instance.new("BodyGyro")
                flyBg.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                flyBg.Parent = hrp
            end
            
            flyBg.CFrame = camera.CFrame
            if hum and hum.MoveDirection.Magnitude > 0 then
                flyBv.Velocity = hum.MoveDirection * 60
            else
                flyBv.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if flyBv then pcall(function() flyBv:Destroy() end) flyBv = nil end
        if flyBg then pcall(function() flyBg:Destroy() end) flyBg = nil end
    end
end)

-- 3. KHỞI TẠO GIAO DIỆN CHÍNH
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NawHubPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 320)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = true -- Cho hiện mặc định luôn khi test
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Kéo rê menu mượt mà
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- LEFT SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -25)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(1, 0, 0, 45)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = " 🔵 Naw Hub V1"
LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoLabel.Font = Enum.Font.SourceSansBold
LogoLabel.TextSize = 18
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.Parent = Sidebar

-- TOPBAR
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, -150, 0, 45)
Topbar.Position = UDim2.new(0, 150, 0, 0)
Topbar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame

local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(0.9, 0, 0, 28)
SearchBar.Position = UDim2.new(0.05, 0, 0.2, 0)
SearchBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SearchBar.Text = ""
SearchBar.PlaceholderText = "Search features..."
SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBar.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
SearchBar.Font = Enum.Font.SourceSans
SearchBar.TextSize = 14
SearchBar.Parent = Topbar
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)

-- FOOTER
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(1, -20, 1, 0)
FooterText.Position = UDim2.new(0, 10, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "v1.0.0 | https://github.com/namnguyen57"
FooterText.TextColor3 = Color3.fromRGB(120, 120, 130)
FooterText.Font = Enum.Font.SourceSans
FooterText.TextSize = 12
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.Parent = Footer

-- FLOATING BUTTON (NÚT TRÒN BẬT TẮT)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Text = "NAW"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 25)

local tDragging, tDragInput, tDragStart, tStartPos
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragging = true
        tDragStart = input.Position
        tStartPos = ToggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then tDragging = false end
        end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        tDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == tDragInput and tDragging then
        local delta = input.Position - tDragStart
        ToggleBtn.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- CONTAINER CHỨA NỘI DUNG CÁC TAB
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -160, 1, -80)
Container.Position = UDim2.new(0, 155, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- HỆ THỐNG QUẢN LÝ TAB TỰ ĐỘNG CĂN CHỈNH (FIX CỨNG)
local Tabs = {}
local TabButtons = {}
local TabCount = 0

local function CreateTab(name)
    TabCount = TabCount + 1
    
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 500) -- Kéo dài để cuộn thoải mái
    TabPage.ScrollBarThickness = 3
    TabPage.Visible = (TabCount == 1)
    TabPage.Parent = Container
    
    -- Dùng UIListLayout để các ô tính năng tự xếp chồng lên nhau gọn gàng
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = TabPage
    
    Tabs[name] = TabPage
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.Position = UDim2.new(0.05, 0, 0, 45 + (TabCount - 1) * 40)
    TabBtn.BackgroundColor3 = (TabCount == 1) and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(10, 10, 12)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = "   " .. name
    TabBtn.TextColor3 = (TabCount == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 14
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, page in pairs(Tabs) do
            page.Visible = (tName == name)
        end
        for bName, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = (bName == name) and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(10, 10, 12)
            btn.TextColor3 = (bName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
        end
    end)
    TabButtons[name] = TabBtn
    return TabPage
end

-- Hàm tạo Section (Ô vuông lớn)
local function CreateSection(parent, title, sizeY)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(0.96, 0, 0, sizeY)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Parent = parent
    Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -20, 0, 30)
    SectionTitle.Position = UDim2.new(0, 10, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
    SectionTitle.Font = Enum.Font.SourceSansBold
    SectionTitle.TextSize = 14
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = SectionFrame
    
    return SectionFrame
end

-- Hàm tạo Nút Gạt Switch (Toggle)
local function CreateToggle(section, name, yPos, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.94, 0, 0, 30)
    Frame.Position = UDim2.new(0.03, 0, 0, yPos)
    Frame.BackgroundTransparency = 1
    Frame.Parent = section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(210, 210, 215)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 36, 0, 18)
    ToggleBg.Position = UDim2.new(1, -36, 0.2, 0)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleBg.Parent = Frame
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(0, 9)
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 2, 0, 2)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = ToggleBg
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 7)
    
    local active = false
    local Click = Instance.new("TextButton")
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.BackgroundTransparency = 1
    Click.Text = ""
    Click.Parent = ToggleBg

    Click.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        pcall(function()
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 55)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {
                Position = active and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = active and Color3.fromRGB(14, 14, 18) or Color3.fromRGB(255, 255, 255)
            }):Play()
        end)
    end)
end

-- ==========================================================
-- ĐƯA CÁC TÍNH NĂNG VÀO CÁC TAB (ĐÃ FIX KHÔNG TRỐNG)
-- ==========================================================

-- 1. TAB BOOST FPS
local TabFPS = CreateTab("🚀 Boost FPS")
local SecFPS = CreateSection(TabFPS, "Performance Boost", 110)
CreateToggle(SecFPS, "Boost FPS (Optimize Graphic)", 35, function(v) if v then OptimizeGame() end end)
CreateToggle(SecFPS, "Auto Anti-AFK All Game", 70, function(v) AntiAFK_Enabled = v end)

-- 2. TAB MOVEMENT
local TabMove = CreateTab("⚡ Movement")
local SecMove = CreateSection(TabMove, "Player Movement", 150)
CreateToggle(SecMove, "Speed Hack (x60)", 35, function(v) Speed_Enabled = v end)
CreateToggle(SecMove, "Noclip (Wall)", 70, function(v) Noclip_Enabled = v end)
CreateToggle(SecMove, "Fly (Follow Cam)", 105, function(v) Fly_Enabled = v end)

-- 3. TAB DISCORD
local TabDiscord = CreateTab("💬 Discord")
local SecCredits = CreateSection(TabDiscord, "Information", 100)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 50)
InfoLabel.Position = UDim2.new(0.05, 0, 0, 35)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Owner: namnguyen57\nThank you for using Naw Hub V1!"
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 14
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = SecCredits
