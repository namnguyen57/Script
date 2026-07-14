-- ==========================================================
-- SCRIPT: NAW HUB V1
-- TÁC GIẢ: namnguyen57 | tiktok:naweyu
-- ==========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. TẠO SPLASH SCREEN XOAY VÒNG
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
Instance.new("UICorner", Spinner).CornerRadius = UDim.new(1, 0)

local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Size = UDim2.new(1, 0, 0, 100)
AuthorLabel.Position = UDim2.new(0, 0, 0.5, 60)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "NAW HUB V2 PRO\nLoading features..."
AuthorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthorLabel.Font = Enum.Font.SourceSansBold
AuthorLabel.TextSize = 22
AuthorLabel.Parent = Background

local spinTween = TweenService:Create(Spinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
spinTween:Play()

task.wait(1.5)
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
local ESP_Enabled = false
local TeleportTarget = ""

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

-- Fly Loop (Đã sửa để bay mượt và di chuyển theo Camera)
local flyBv, flyBg
RunService.RenderStepped:Connect(function()
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local camera = workspace.CurrentCamera
            
            if not flyBv or flyBv.Parent ~= hrp then
                flyBv = Instance.new("BodyVelocity")
                flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBv.Parent = hrp
            end
            if not flyBg or flyBg.Parent ~= hrp then
                flyBg = Instance.new("BodyGyro")
                flyBg.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBg.P = 9e4
                flyBg.Parent = hrp
            end
            
            flyBg.CFrame = camera.CFrame
            if hum and hum.MoveDirection.Magnitude > 0 then
                -- Kết hợp hướng di chuyển với hướng nhìn của Camera để có thể bay lên/xuống
                local moveDir = hum.MoveDirection
                flyBv.Velocity = Vector3.new(moveDir.X, camera.CFrame.LookVector.Y * moveDir.Magnitude, moveDir.Z) * 60
            else
                flyBv.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if flyBv then pcall(function() flyBv:Destroy() end) flyBv = nil end
        if flyBg then pcall(function() flyBg:Destroy() end) flyBg = nil end
    end
end)

-- ESP Loop
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local highlight = char:FindFirstChild("NAW_ESP")
                        if ESP_Enabled then
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Name = "NAW_ESP"
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.Parent = char
                            end
                        else
                            if highlight then highlight:Destroy() end
                        end
                    end
                end
            end
        end)
    end
end)

-- Hàm Teleport
local function TeleportToPlayer(targetName)
    if targetName == "" then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (string.find(string.lower(p.Name), string.lower(targetName)) or string.find(string.lower(p.DisplayName), string.lower(targetName))) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                break
            end
        end
    end
end

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
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Kéo rê menu
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- LEFT SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size, Sidebar.BackgroundColor3 = UDim2.new(0, 150, 1, -25), Color3.fromRGB(10, 10, 12)
Sidebar.BorderSizePixel, Sidebar.Parent = 0, MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size, LogoLabel.BackgroundTransparency = UDim2.new(1, 0, 0, 45), 1
LogoLabel.Text, LogoLabel.TextColor3 = " 🔵 Naw Hub V2", Color3.fromRGB(255, 255, 255)
LogoLabel.Font, LogoLabel.TextSize, LogoLabel.TextXAlignment = Enum.Font.SourceSansBold, 18, Enum.TextXAlignment.Left
LogoLabel.Parent = Sidebar

-- TOPBAR & FOOTER
local Topbar = Instance.new("Frame", MainFrame)
Topbar.Size, Topbar.Position, Topbar.BackgroundColor3 = UDim2.new(1, -150, 0, 45), UDim2.new(0, 150, 0, 0), Color3.fromRGB(14, 14, 18)
Topbar.BorderSizePixel = 0

local Footer = Instance.new("Frame", MainFrame)
Footer.Size, Footer.Position, Footer.BackgroundColor3 = UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 1, -25), Color3.fromRGB(10, 10, 12)
Footer.BorderSizePixel = 0

local FooterText = Instance.new("TextLabel", Footer)
FooterText.Size, FooterText.Position, FooterText.BackgroundTransparency = UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), 1
FooterText.Text, FooterText.TextColor3, FooterText.Font, FooterText.TextSize = "v2.0 PRO | Coded by namnguyen57", Color3.fromRGB(120, 120, 130), Enum.Font.SourceSans, 12
FooterText.TextXAlignment = Enum.TextXAlignment.Left

-- FLOATING BUTTON
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size, ToggleBtn.Position, ToggleBtn.BackgroundColor3 = UDim2.new(0, 50, 0, 50), UDim2.new(0, 10, 0.4, 0), Color3.fromRGB(0, 170, 255)
ToggleBtn.Text, ToggleBtn.TextColor3, ToggleBtn.Font, ToggleBtn.TextSize = "NAW", Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 14
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 25)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- CONTAINER
local Container = Instance.new("Frame", MainFrame)
Container.Size, Container.Position, Container.BackgroundTransparency = UDim2.new(1, -160, 1, -80), UDim2.new(0, 155, 0, 50), 1

-- TAB SYSTEM
local Tabs, TabButtons, TabCount = {}, {}, 0

local function CreateTab(name)
    TabCount = TabCount + 1
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size, TabPage.BackgroundTransparency, TabPage.CanvasSize = UDim2.new(1, 0, 1, 0), 1, UDim2.new(0, 0, 0, 500)
    TabPage.ScrollBarThickness, TabPage.Visible = 3, (TabCount == 1)
    
    local ListLayout = Instance.new("UIListLayout", TabPage)
    ListLayout.Padding, ListLayout.SortOrder = UDim.new(0, 10), Enum.SortOrder.LayoutOrder
    Tabs[name] = TabPage
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size, TabBtn.Position = UDim2.new(0.9, 0, 0, 35), UDim2.new(0.05, 0, 0, 45 + (TabCount - 1) * 40)
    TabBtn.BackgroundColor3 = (TabCount == 1) and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(10, 10, 12)
    TabBtn.Text, TabBtn.TextColor3 = "   " .. name, (TabCount == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
    TabBtn.Font, TabBtn.TextSize, TabBtn.TextXAlignment, TabBtn.BorderSizePixel = Enum.Font.SourceSansBold, 14, Enum.TextXAlignment.Left, 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, page in pairs(Tabs) do page.Visible = (tName == name) end
        for bName, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = (bName == name) and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(10, 10, 12)
            btn.TextColor3 = (bName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
        end
    end)
    TabButtons[name] = TabBtn
    return TabPage
end

local function CreateSection(parent, title, sizeY)
    local SectionFrame = Instance.new("Frame", parent)
    SectionFrame.Size, SectionFrame.BackgroundColor3, SectionFrame.BorderSizePixel = UDim2.new(0.96, 0, 0, sizeY), Color3.fromRGB(20, 20, 26), 0
    Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
    
    local SectionTitle = Instance.new("TextLabel", SectionFrame)
    SectionTitle.Size, SectionTitle.Position, SectionTitle.BackgroundTransparency = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 0), 1
    SectionTitle.Text, SectionTitle.TextColor3, SectionTitle.Font, SectionTitle.TextSize = title, Color3.fromRGB(0, 170, 255), Enum.Font.SourceSansBold, 14
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    return SectionFrame
end

-- HÀM TOGGLE MỚI (NÚT HÌNH VUÔNG)
local function CreateToggle(section, name, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position, Frame.BackgroundTransparency = UDim2.new(0.94, 0, 0, 30), UDim2.new(0.03, 0, 0, yPos), 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(0.7, 0, 1, 0), 1, name
    Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.fromRGB(210, 210, 215), Enum.Font.SourceSans, 14, Enum.TextXAlignment.Left

    local ToggleBg = Instance.new("Frame", Frame)
    ToggleBg.Size, ToggleBg.Position, ToggleBg.BackgroundColor3 = UDim2.new(0, 20, 0, 20), UDim2.new(1, -25, 0.5, -10), Color3.fromRGB(45, 45, 55)
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(0, 4) -- Hình vuông hơi bo góc nhẹ cho đẹp
    
    local CheckMark = Instance.new("Frame", ToggleBg)
    CheckMark.Size, CheckMark.Position, CheckMark.BackgroundColor3 = UDim2.new(0, 12, 0, 12), UDim2.new(0.5, -6, 0.5, -6), Color3.fromRGB(0, 170, 255)
    CheckMark.BackgroundTransparency = 1 -- Ẩn khi chưa bật
    Instance.new("UICorner", CheckMark).CornerRadius = UDim.new(0, 2)
    
    local active = false
    local Click = Instance.new("TextButton", ToggleBg)
    Click.Size, Click.BackgroundTransparency, Click.Text = UDim2.new(1, 0, 1, 0), 1, ""

    Click.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        TweenService:Create(CheckMark, TweenInfo.new(0.2), {BackgroundTransparency = active and 0 or 1}):Play()
    end)
end

-- HÀM TEXTBOX (NHẬP TÊN NGƯỜI CHƠI)
local function CreateTextBox(section, placeholder, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position, Frame.BackgroundColor3 = UDim2.new(0.94, 0, 0, 30), UDim2.new(0.03, 0, 0, yPos), Color3.fromRGB(30, 30, 38)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

    local Box = Instance.new("TextBox", Frame)
    Box.Size, Box.Position, Box.BackgroundTransparency = UDim2.new(1, -10, 1, 0), UDim2.new(0, 5, 0, 0), 1
    Box.PlaceholderText, Box.Text, Box.TextColor3 = placeholder, "", Color3.fromRGB(255, 255, 255)
    Box.Font, Box.TextSize, Box.TextXAlignment = Enum.Font.SourceSans, 14, Enum.TextXAlignment.Left
    Box.FocusLost:Connect(function() callback(Box.Text) end)
end

-- HÀM BUTTON (NÚT BẤM THƯỜNG)
local function CreateButton(section, name, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position, Frame.BackgroundColor3 = UDim2.new(0.94, 0, 0, 30), UDim2.new(0.03, 0, 0, yPos), Color3.fromRGB(0, 110, 200)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size, Btn.BackgroundTransparency, Btn.Text = UDim2.new(1, 0, 1, 0), 1, name
    Btn.TextColor3, Btn.Font, Btn.TextSize = Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 14
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================================
-- CÀI ĐẶT CÁC TAB
-- ==========================================================

-- 1. TAB BOOST FPS
local TabFPS = CreateTab("🚀 Boost FPS")
local SecFPS = CreateSection(TabFPS, "Performance", 110)
CreateToggle(SecFPS, "Boost FPS (Optimize Graphic)", 35, function(v) if v then OptimizeGame() end end)
CreateToggle(SecFPS, "Auto Anti-AFK All Game", 70, function(v) AntiAFK_Enabled = v end)

-- 2. TAB MOVEMENT
local TabMove = CreateTab("⚡ Movement")
local SecMove = CreateSection(TabMove, "Player Movement", 150)
CreateToggle(SecMove, "Speed Hack (x60)", 35, function(v) Speed_Enabled = v end)
CreateToggle(SecMove, "Noclip (Wall)", 70, function(v) Noclip_Enabled = v end)
CreateToggle(SecMove, "Fly (Move & Look to fly)", 105, function(v) Fly_Enabled = v end)

-- 3. TAB VISUALS & TELEPORT (MỚI)
local TabExtra = CreateTab("👁️ Visuals & TP")
local SecVis = CreateSection(TabExtra, "ESP Settings", 70)
CreateToggle(SecVis, "ESP Players (Xuyên Tường)", 35, function(v) ESP_Enabled = v end)

local SecTP = CreateSection(TabExtra, "Teleport", 120)
CreateTextBox(SecTP, "Nhập một phần tên người chơi...", 35, function(txt) TeleportTarget = txt end)
CreateButton(SecTP, "Teleport Đến Người Chơi", 75, function() TeleportToPlayer(TeleportTarget) end)

-- 4. TAB DISCORD
local TabDiscord = CreateTab("💬 Information")
local SecCredits = CreateSection(TabDiscord, "Credits", 70)
local InfoLabel = Instance.new("TextLabel", SecCredits)
InfoLabel.Size, InfoLabel.Position, InfoLabel.BackgroundTransparency = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 35), 1
InfoLabel.Text, InfoLabel.TextColor3 = "Owner: namnguyen57 - Update V2 PRO", Color3.fromRGB(180, 180, 190)
InfoLabel.Font, InfoLabel.TextSize, InfoLabel.TextXAlignment = Enum.Font.SourceSans, 14, Enum.TextXAlignment.Left

