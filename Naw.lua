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
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- 1. TẠO SPLASH SCREEN HIỆN ĐẠI
local SplashGui = Instance.new("ScreenGui", CoreGui)
SplashGui.Name = "NawSplash"
SplashGui.ResetOnSpawn = false

local Background = Instance.new("Frame", SplashGui)
Background.Size, Background.BackgroundColor3 = UDim2.new(1, 0, 1, 0), Color3.fromRGB(10, 10, 15)

local Spinner = Instance.new("Frame", Background)
Spinner.Size, Spinner.Position, Spinner.BackgroundTransparency = UDim2.new(0, 60, 0, 60), UDim2.new(0.5, -30, 0.5, -50), 1
Instance.new("UICorner", Spinner).CornerRadius = UDim.new(1, 0)
local UIStroke = Instance.new("UIStroke", Spinner)
UIStroke.Thickness, UIStroke.Color = 4, Color3.fromRGB(0, 162, 255)

local AuthorLabel = Instance.new("TextLabel", Background)
AuthorLabel.Size, AuthorLabel.Position, AuthorLabel.BackgroundTransparency = UDim2.new(1, 0, 0, 100), UDim2.new(0, 0, 0.5, 30), 1
AuthorLabel.Text, AuthorLabel.TextColor3 = "NAW HUB V3 PREMIUM", Color3.fromRGB(255, 255, 255)
AuthorLabel.Font, AuthorLabel.TextSize = Enum.Font.GothamBold, 24

local SubLabel = Instance.new("TextLabel", Background)
SubLabel.Size, SubLabel.Position, SubLabel.BackgroundTransparency = UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0.5, 60), 1
SubLabel.Text, SubLabel.TextColor3 = "Loading resources...", Color3.fromRGB(150, 150, 170)
SubLabel.Font, SubLabel.TextSize = Enum.Font.Gotham, 14

local spinTween = TweenService:Create(Spinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
spinTween:Play()

task.wait(1.5)
pcall(function()
    TweenService:Create(Background, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(AuthorLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(SubLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
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
    if AntiAFK_Enabled then pcall(function() game:GetService("VirtualUser"):CaptureController() game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0)) end) end
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

-- Fly Loop (Sử dụng PlayerModule cho di chuyển Camera đa hướng hoàn hảo)
local flyBv, flyBg
RunService.RenderStepped:Connect(function()
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local cam = workspace.CurrentCamera
            
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
            hum:ChangeState(Enum.HumanoidStateType.Flying)

            -- Đọc trực tiếp input của người chơi thay vì MoveDirection thế giới
            local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
            local moveVec = controlModule:GetMoveVector()

            if moveVec.Magnitude > 0 then
                -- Bay mượt theo hướng Camera
                flyBv.Velocity = (cam.CFrame.RightVector * moveVec.X + cam.CFrame.LookVector * -moveVec.Z) * 60
            else
                flyBv.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if flyBv then pcall(function() flyBv:Destroy() flyBv = nil end) end
        if flyBg then pcall(function() flyBg:Destroy() flyBg = nil end) end
    end
end)

-- ESP Xuyên Tường (Dùng Folder lưu trữ riêng biệt để chống lỗi)
local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "Naw_ESP"
ESP_Folder.Parent = CoreGui

task.spawn(function()
    while task.wait(0.5) do
        if ESP_Enabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hl = ESP_Folder:FindFirstChild(p.Name)
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = p.Name
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Chìa khóa để nhìn xuyên tường
                        hl.Parent = ESP_Folder
                    end
                    hl.Adornee = p.Character
                end
            end
        else
            ESP_Folder:ClearAllChildren()
        end
    end
end)

-- 3. KHỞI TẠO GIAO DIỆN CHÍNH (THIẾT KẾ MỚI)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NawHubV1"
ScreenGui.ResetOnSpawn = false

-- FLOATING BUTTON (NÚT LOGO XỊN)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size, ToggleBtn.Position = UDim2.new(0, 46, 0, 46), UDim2.new(0, 20, 0.5, -23)
ToggleBtn.BackgroundColor3, ToggleBtn.Text = Color3.fromRGB(15, 15, 20), "N"
ToggleBtn.TextColor3, ToggleBtn.Font, ToggleBtn.TextSize = Color3.fromRGB(0, 162, 255), Enum.Font.GothamBlack, 22
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Thickness, ToggleStroke.Color = 2, Color3.fromRGB(0, 162, 255)
ToggleStroke.Transparency = 0.2

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 580, 0, 340), UDim2.new(0.5, -290, 0.5, -170)
MainFrame.BackgroundColor3, MainFrame.Visible = Color3.fromRGB(15, 15, 20), true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness, MainStroke.Color = 1, Color3.fromRGB(40, 40, 50)

-- Drag Logic
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
        if dragging then
            if dragInput.Target == ToggleBtn then ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            else MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end
        end
    end
end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- SIDEBAR & TOPBAR
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3, Sidebar.BorderSizePixel = UDim2.new(0, 160, 1, 0), Color3.fromRGB(10, 10, 14), 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local LogoLabel = Instance.new("TextLabel", Sidebar)
LogoLabel.Size, LogoLabel.BackgroundTransparency, LogoLabel.Text = UDim2.new(1, 0, 0, 50), 1, " Naw Hub V3"
LogoLabel.TextColor3, LogoLabel.Font, LogoLabel.TextSize = Color3.fromRGB(0, 162, 255), Enum.Font.GothamBold, 16
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
local IconLabel = Instance.new("TextLabel", LogoLabel)
IconLabel.Size, IconLabel.Position, IconLabel.BackgroundTransparency, IconLabel.Text = UDim2.new(0, 30, 1, 0), UDim2.new(0, 10, 0, 0), 1, "⚡"
IconLabel.TextColor3, IconLabel.Font, IconLabel.TextSize = Color3.fromRGB(255, 255, 255), Enum.Font.Gotham, 16
LogoLabel.Position = UDim2.new(0, 30, 0, 0)

local Container = Instance.new("Frame", MainFrame)
Container.Size, Container.Position, Container.BackgroundTransparency = UDim2.new(1, -170, 1, -20), UDim2.new(0, 170, 0, 10), 1

-- HỆ THỐNG TAB UI
local Tabs, TabButtons, TabCount = {}, {}, 0

local function CreateTab(name, icon)
    TabCount = TabCount + 1
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size, TabPage.BackgroundTransparency, TabPage.CanvasSize = UDim2.new(1, 0, 1, 0), 1, UDim2.new(0, 0, 0, 600)
    TabPage.ScrollBarThickness, TabPage.Visible, TabPage.BorderSizePixel = 2, (TabCount == 1), 0
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
    
    local ListLayout = Instance.new("UIListLayout", TabPage)
    ListLayout.Padding, ListLayout.SortOrder = UDim.new(0, 10), Enum.SortOrder.LayoutOrder
    Tabs[name] = TabPage
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size, TabBtn.Position = UDim2.new(0.9, 0, 0, 38), UDim2.new(0.05, 0, 0, 55 + (TabCount - 1) * 45)
    TabBtn.BackgroundColor3 = (TabCount == 1) and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(15, 15, 20)
    TabBtn.Text, TabBtn.TextColor3 = "  " .. icon .. "  " .. name, (TabCount == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
    TabBtn.Font, TabBtn.TextSize, TabBtn.TextXAlignment = Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, page in pairs(Tabs) do page.Visible = (tName == name) end
        for bName, btn in pairs(TabButtons) do
            local active = (bName == name)
            TweenService:Create(btn, TweenInfo.new(0.3), {
                BackgroundColor3 = active and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(15, 15, 20),
                TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
            }):Play()
        end
    end)
    TabButtons[name] = TabBtn
    return TabPage
end

local function CreateSection(parent, title, sizeY)
    local SectionFrame = Instance.new("Frame", parent)
    SectionFrame.Size, SectionFrame.BackgroundColor3 = UDim2.new(0.96, 0, 0, sizeY), Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", SectionFrame).Color = Color3.fromRGB(35, 35, 45)
    
    local SectionTitle = Instance.new("TextLabel", SectionFrame)
    SectionTitle.Size, SectionTitle.Position, SectionTitle.BackgroundTransparency = UDim2.new(1, -20, 0, 30), UDim2.new(0, 12, 0, 5), 1
    SectionTitle.Text, SectionTitle.TextColor3, SectionTitle.Font, SectionTitle.TextSize = title, Color3.fromRGB(0, 162, 255), Enum.Font.GothamBold, 14
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    return SectionFrame
end

-- HÀM TOGGLE: GIAO DIỆN CÔNG TẮC ĐẸP MẮT (STYLE IOS)
local function CreateToggle(section, name, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position, Frame.BackgroundTransparency = UDim2.new(0.94, 0, 0, 36), UDim2.new(0.03, 0, 0, yPos), 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size, Label.BackgroundTransparency, Label.Text = UDim2.new(0.7, 0, 1, 0), 1, name
    Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.fromRGB(220, 220, 230), Enum.Font.Gotham, 13, Enum.TextXAlignment.Left

    local ToggleBg = Instance.new("Frame", Frame)
    ToggleBg.Size, ToggleBg.Position, ToggleBg.BackgroundColor3 = UDim2.new(0, 42, 0, 22), UDim2.new(1, -42, 0.5, -11), Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", ToggleBg)
    Circle.Size, Circle.Position, Circle.BackgroundColor3 = UDim2.new(0, 16, 0, 16), UDim2.new(0, 3, 0.5, -8), Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local active = false
    local Click = Instance.new("TextButton", ToggleBg)
    Click.Size, Click.BackgroundTransparency, Click.Text = UDim2.new(1, 0, 1, 0), 1, ""

    Click.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        TweenService:Create(ToggleBg, TweenInfo.new(0.3), {BackgroundColor3 = active and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(35, 35, 45)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
    end)
end

-- ==========================================================
-- SETUP TÍNH NĂNG VÀO MENU
-- ==========================================================

local TabMain = CreateTab("Main", "🏠")
local SecMove = CreateSection(TabMain, "Movement Settings", 150)
CreateToggle(SecMove, "Speed Hack (Fast)", 40, function(v) Speed_Enabled = v end)
CreateToggle(SecMove, "Noclip (Walk through walls)", 75, function(v) Noclip_Enabled = v end)
CreateToggle(SecMove, "Fly (Look & Move)", 110, function(v) Fly_Enabled = v end)

local TabVis = CreateTab("Visuals", "👁️")
local SecESP = CreateSection(TabVis, "ESP & Highlighting", 80)
CreateToggle(SecESP, "Player ESP (Xuyên tường đỏ)", 40, function(v) ESP_Enabled = v end)

local TabMisc = CreateTab("Misc", "⚙️")
local SecPerf = CreateSection(TabMisc, "Performance", 80)
CreateToggle(SecPerf, "Auto Anti-AFK", 40, function(v) AntiAFK_Enabled = v end)

local SecInfo = CreateSection(TabMisc, "Information", 80)
local InfoLabel = Instance.new("TextLabel", SecInfo)
InfoLabel.Size, InfoLabel.Position, InfoLabel.BackgroundTransparency = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 35), 1
InfoLabel.Text, InfoLabel.TextColor3 = "Script by namnguyen57 - V3 Premium", Color3.fromRGB(150, 150, 160)
InfoLabel.Font, InfoLabel.TextSize, InfoLabel.TextXAlignment = Enum.Font.Gotham, 13, Enum.TextXAlignment.Left
