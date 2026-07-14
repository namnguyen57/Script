-- ==========================================================
-- SCRIPT: NAW HUB V1
-- TÁC GIẢ: namnguyen57 |
-- ==========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- 1. SPLASH SCREEN ĐẲNG CẤP (CINEMATIC INTRO)
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 0

local SplashGui = Instance.new("ScreenGui", CoreGui)
SplashGui.Name = "NawHub"

local Background = Instance.new("Frame", SplashGui)
Background.Size, Background.BackgroundColor3 = UDim2.new(1, 0, 1, 0), Color3.fromRGB(10, 10, 12)

local LogoFrame = Instance.new("Frame", Background)
LogoFrame.Size, LogoFrame.Position, LogoFrame.BackgroundTransparency = UDim2.new(0, 300, 0, 100), UDim2.new(0.5, -150, 0.5, -60), 1

local MainTitle = Instance.new("TextLabel", LogoFrame)
MainTitle.Size, MainTitle.BackgroundTransparency = UDim2.new(1, 0, 0, 40), 1
MainTitle.Text, MainTitle.TextColor3 = "NAW HUB V1", Color3.fromRGB(255, 255, 255)
MainTitle.Font, MainTitle.TextSize = Enum.Font.GothamBlack, 32

local SubTitle = Instance.new("TextLabel", LogoFrame)
SubTitle.Size, SubTitle.Position, SubTitle.BackgroundTransparency = UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 45), 1
SubTitle.Text, SubTitle.TextColor3 = "PREMIUM ULTIMATE BY NAMNGUYEN57", Color3.fromRGB(0, 170, 255)
SubTitle.Font, SubTitle.TextSize = Enum.Font.GothamBold, 12

-- Thanh Loading Bar sang xịn mịn
local BarBg = Instance.new("Frame", LogoFrame)
BarBg.Size, BarBg.Position, BarBg.BackgroundColor3 = UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 80), Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size, BarFill.BackgroundColor3 = UDim2.new(0, 0, 1, 0), Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- Chạy hiệu ứng Intro
TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 20}):Play()
task.wait(0.2)
local loadTween = TweenService:Create(BarFill, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
loadTween:Play()
loadTween.Completed:Wait()

pcall(function()
    TweenService:Create(Blur, TweenInfo.new(0.4), {Size = 0}):Play()
    TweenService:Create(Background, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(MainTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(SubTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
end)
task.wait(0.4)
SplashGui:Destroy()
Blur:Destroy()

-- 2. BIẾN TRẠNG THÁI & LOGIC TÍNH NĂNG
local AntiAFK_Enabled = false
local Speed_Enabled = false
local Noclip_Enabled = false
local Fly_Enabled = false
local ESP_Enabled = false
local TeleportTarget = ""
local FlySpeed = 50

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if AntiAFK_Enabled then pcall(function() game:GetService("VirtualUser"):CaptureController() game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0)) end) end
end)

-- Boost FPS (Optimize Graphic)
local function OptimizeGame()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then
                v.Enabled = false
            end
        end
    end)
end

-- Server Utilities (Rejoin & Hop Server)
local function RejoinServer()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
end

local function ServerHop()
    pcall(function()
        local serverList = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(serverList.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end

-- Auto Rejoin on Kick
guiOnKick = true
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    if guiOnKick then RejoinServer() end
end)

-- Speed Loop
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if Speed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 60
            elseif not Speed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if LocalPlayer.Character.Humanoid.WalkSpeed == 60 then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
            end
        end)
    end
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if Noclip_Enabled and LocalPlayer.Character then
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end)
    end
end)

-- Fly Loop (Đã Sửa: Cố định góc PlatformStand + Di chuyển đa hướng mượt mà)
local flyBv, flyBg
RunService.RenderStepped:Connect(function()
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local cam = workspace.CurrentCamera
            
            hum.PlatformStand = true
            if not flyBv or flyBv.Parent ~= hrp then
                flyBv = Instance.new("BodyVelocity", hrp)
                flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            end
            if not flyBg or flyBg.Parent ~= hrp then
                flyBg = Instance.new("BodyGyro", hrp)
                flyBg.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBg.P = 9e4
            end
            
            flyBg.CFrame = cam.CFrame
            local moveDir = hum.MoveDirection
            
            if moveDir.Magnitude > 0 then
                -- Tính toán Vector di chuyển tương quan chuẩn xác theo góc nhìn Camera
                local sideVector = cam.CFrame.RightVector * (moveDir:Dot(cam.CFrame.RightVector))
                local forwardVector = cam.CFrame.LookVector * (moveDir:Dot(cam.CFrame.LookVector))
                flyBv.Velocity = (sideVector + forwardVector).Unit * FlySpeed
            else
                flyBv.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if flyBv then pcall(function() flyBv:Destroy() flyBv = nil end) end
        if flyBg then pcall(function() flyBg:Destroy() flyBg = nil end) end
        pcall(function() if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end end)
    end
end)

-- ESP Player Xuyên Tường (Đã Sửa: Đưa thẳng vào Workspace Character)
local function ManageESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("NAW_Highlight")
            if ESP_Enabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "NAW_Highlight"
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = p.Character
                end
            else
                if hl then hl:Destroy() end
            end
        end
    end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); ManageESP() end) end)
task.spawn(function() while task.wait(1) do ManageESP() end end)

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

-- 3. KHỞI TẠO GIAO DIỆN CHÍNH HẠNG SANG
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NawHubV1Premium"
ScreenGui.ResetOnSpawn = false

-- NÚT TOGGLE KHỐI NEON PHÁT SÁNG CỰC XỊN
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size, ToggleBtn.Position = UDim2.new(0, 45, 0, 45), UDim2.new(0, 20, 0.5, -22)
ToggleBtn.BackgroundColor3, ToggleBtn.Text = Color3.fromRGB(15, 15, 20), "NW"
ToggleBtn.TextColor3, ToggleBtn.Font, ToggleBtn.TextSize = Color3.fromRGB(0, 170, 255), Enum.Font.GothamBlack, 16
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Thickness, ToggleStroke.Color = 2, Color3.fromRGB(0, 170, 255)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 580, 0, 340), UDim2.new(0.5, -290, 0.5, -170)
MainFrame.BackgroundColor3, MainFrame.Visible = Color3.fromRGB(12, 12, 16), true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness, MainStroke.Color = 1, Color3.fromRGB(40, 40, 50)

-- Kéo rê mượt mà cho cả hai nút và menu
local dragging, dragInput, dragStart, startPos
local function addDrag(frame, target)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = target.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
end
addDrag(ToggleBtn, ToggleBtn)
addDrag(MainFrame, MainFrame)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        if dragInput.Target == ToggleBtn then 
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        else 
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) 
        end
    end
end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- SIDEBAR & CONTAINER NỘI DUNG
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3, Sidebar.BorderSizePixel = UDim2.new(0, 160, 1, 0), Color3.fromRGB(8, 8, 11), 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local LogoLabel = Instance.new("TextLabel", Sidebar)
LogoLabel.Size, LogoLabel.Position, LogoLabel.BackgroundTransparency = UDim2.new(1, -20, 0, 50), UDim2.new(0, 15, 0, 0), 1
LogoLabel.Text, LogoLabel.TextColor3 = "NAW HUB V1", Color3.fromRGB(0, 170, 255)
LogoLabel.Font, LogoLabel.TextSize, LogoLabel.TextXAlignment = Enum.Font.SourceSansBold, 18, Enum.TextXAlignment.Left

local Container = Instance.new("Frame", MainFrame)
Container.Size, Container.Position, Container.BackgroundTransparency = UDim2.new(1, -175, 1, -20), UDim2.new(0, 170, 0, 10), 1

-- HỆ THỐNG QUẢN LÝ TAB HOÀN HẢO
local Tabs, TabButtons, TabCount = {}, {}, 0

local function CreateTab(name, icon)
    TabCount = TabCount + 1
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size, TabPage.BackgroundTransparency, TabPage.CanvasSize = UDim2.new(1, 0, 1, 0), 1, UDim2.new(0, 0, 0, 550)
    TabPage.ScrollBarThickness, TabPage.Visible, TabPage.BorderSizePixel = 2, (TabCount == 1), 0
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
    
    local ListLayout = Instance.new("UIListLayout", TabPage)
    ListLayout.Padding, ListLayout.SortOrder = UDim.new(0, 10), Enum.SortOrder.LayoutOrder
    Tabs[name] = TabPage
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size, TabBtn.Position = UDim2.new(0.9, 0, 0, 36), UDim2.new(0.05, 0, 0, 50 + (TabCount - 1) * 42)
    TabBtn.BackgroundColor3 = (TabCount == 1) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(14, 14, 18)
    TabBtn.Text, TabBtn.TextColor3 = "  " .. icon .. "  " .. name, (TabCount == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
    TabBtn.Font, TabBtn.TextSize, TabBtn.TextXAlignment = Enum.Font.GothamSemibold, 12, Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, page in pairs(Tabs) do page.Visible = (tName == name) end
        for bName, btn in pairs(TabButtons) do
            local active = (bName == name)
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(14, 14, 18),
                TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
            }):Play()
        end
    end)
    TabButtons[name] = TabBtn
    return TabPage
end

local function CreateSection(parent, title, sizeY)
    local SectionFrame = Instance.new("Frame", parent)
    SectionFrame.Size, SectionFrame.BackgroundColor3 = UDim2.new(0.96, 0, 0, sizeY), Color3.fromRGB(16, 16, 22)
    Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", SectionFrame).Color = Color3.fromRGB(30, 30, 40)
    
    local SectionTitle = Instance.new("TextLabel", SectionFrame)
    SectionTitle.Size, SectionTitle.Position, SectionTitle.BackgroundTransparency = UDim2.new(1, -20, 0, 30), UDim2.new(0, 12, 0, 3), 1
    SectionTitle.Text, SectionTitle.TextColor3, SectionTitle.Font, SectionTitle.TextSize = title, Color3.fromRGB(0, 170, 255), Enum.Font.GothamBold, 13
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    return SectionFrame
end

-- HÀM SỬA ĐỔI TOGGLE THÀNH HÌNH VUÔNG HIỆN ĐẠI (CHECKBOX)
local function CreateToggle(section, name, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position, Frame.BackgroundTransparency = UDim2.new(0.94, 0, 0, 32), UDim2.new(0.03, 0, 0, yPos), 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(0.7, 0, 1, 0), 1, name
    Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.fromRGB(210, 210, 220), Enum.Font.Gotham, 13, Enum.TextXAlignment.Left

    local ToggleBg = Instance.new("Frame", Frame)
    ToggleBg.Size, ToggleBg.Position, ToggleBg.BackgroundColor3 = UDim2.new(0, 18, 0, 18), UDim2.new(1, -22, 0.5, -9), Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(0, 4) -- Hình vuông bo góc nhẹ thanh lịch
    
    local CheckMark = Instance.new("Frame", ToggleBg)
    CheckMark.Size, CheckMark.Position, CheckMark.BackgroundColor3 = UDim2.new(0, 10, 0, 10), UDim2.new(0.5, -5, 0.5, -5), Color3.fromRGB(0, 170, 255)
    CheckMark.BackgroundTransparency = 1 
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

-- Ô NHẬP TEXTBOX CAO CẤP
local function CreateTextBox(section, placeholder, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position, Frame.BackgroundColor3 = UDim2.new(0.94, 0, 0, 32), UDim2.new(0.03, 0, 0, yPos), Color3.fromRGB(24, 24, 32)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(40, 40, 50)

    local Box = Instance.new("TextBox", Frame)
    Box.Size, Box.Position, Box.BackgroundTransparency = UDim2.new(1, -10, 1, 0), UDim2.new(0, 5, 0, 0), 1
    Box.PlaceholderText, Box.Text, Box.TextColor3 = placeholder, "", Color3.fromRGB(255, 255, 255)
    Box.Font, Box.TextSize, Box.TextXAlignment = Enum.Font.Gotham, 13, Enum.TextXAlignment.Left
    Box.FocusLost:Connect(function() callback(Box.Text) end)
end

-- NÚT CLICK THƯỜNG PREMIUM
local function CreateButton(section, name, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position, Frame.BackgroundColor3 = UDim2.new(0.94, 0, 0, 32), UDim2.new(0.03, 0, 0, yPos), Color3.fromRGB(0, 130, 230)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size, Btn.BackgroundTransparency, Btn.Text = UDim2.new(1, 0, 1, 0), 1, name
    Btn.TextColor3, Btn.Font, Btn.TextSize = Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 13
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================================
-- SẮP XẾP TẤT CẢ TÍNH NĂNG VIP VÀO MENU
-- ==========================================================

-- TAB 1: MAIN FUNCTION
local TabMain = CreateTab("Main", "⚡")
local SecMove = CreateSection(TabMain, "Movement Systems", 150)
CreateToggle(SecMove, "Speed Hack (WalkSpeed 60)", 40, function(v) Speed_Enabled = v end)
CreateToggle(SecMove, "Noclip (Walk Through Walls)", 75, function(v) Noclip_Enabled = v end)
CreateToggle(SecMove, "Fly Premium (Camera Vector)", 110, function(v) Fly_Enabled = v end)

-- TAB 2: VISUALS (ESP)
local TabVis = CreateTab("Visuals", "👁️")
local SecESP = CreateSection(TabVis, "Player Highlighting", 80)
CreateToggle(SecESP, "Player ESP Box (Always On Top)", 40, function(v) ESP_Enabled = v end)

-- TAB 3: TELEPORT & SERVERS (VIP)
local TabTP = CreateTab("Teleport", "🌐")
local SecTP = CreateSection(TabTP, "Player Teleport", 120)
CreateTextBox(SecTP, "Nhập một phần tên người chơi...", 40, function(txt) TeleportTarget = txt end)
CreateButton(SecTP, "Teleport Đến Người Chơi", 80, function() TeleportToPlayer(TeleportTarget) end)

local SecServ = CreateSection(TabTP, "Server Management", 120)
CreateButton(SecServ, "Rejoin Server Hiện Tại", 40, function() RejoinServer() end)
CreateButton(SecServ, "Server Hop (Chuyển Server Khác)", 80, function() ServerHop() end)

-- TAB 4: MISC & PERFORMANCE
local TabMisc = CreateTab("Misc", "⚙️")
local SecPerf = CreateSection(TabMisc, "Optimization & Performance", 110)
CreateButton(SecPerf, "Boost FPS (Tối Ưu Hóa Đồ Họa)", 40, function() OptimizeGame() end)
CreateToggle(SecPerf, "Auto Anti-AFK Bypass Disconnect", 75, function(v) AntiAFK_Enabled = v end)

local SecInfo = CreateSection(TabMisc, "Hub Credits", 80)
local InfoLabel = Instance.new("TextLabel", SecInfo)
InfoLabel.Size, InfoLabel.Position, InfoLabel.BackgroundTransparency = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 38), 1
InfoLabel.Text, InfoLabel.TextColor3 = "Coded by namnguyen57 | NAW HUB V1 VIP", Color3.fromRGB(140, 140, 150)
InfoLabel.Font, InfoLabel.TextSize, InfoLabel.TextXAlignment = Enum.Font.Gotham, 12, Enum.TextXAlignment.Left
