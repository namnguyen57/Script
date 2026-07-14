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
local Mouse = LocalPlayer:GetMouse()
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- 1. NOTIFICATION INTRO GỌN NHẸ (KHÔNG CHE TẦM NHÌN)
local SplashGui = Instance.new("ScreenGui", CoreGui)
local ToastFrame = Instance.new("Frame", SplashGui)
ToastFrame.Size = UDim2.new(0, 220, 0, 45)
ToastFrame.Position = UDim2.new(0.5, -110, -0.1, 0) -- Xuất phát từ ngoài màn hình phía trên
ToastFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Instance.new("UICorner", ToastFrame).CornerRadius = UDim.new(0, 6)
local ToastStroke = Instance.new("UIStroke", ToastFrame)
ToastStroke.Color = Color3.fromRGB(0, 170, 255)
ToastStroke.Thickness = 1.5

local IntroLabel = Instance.new("TextLabel", ToastFrame)
IntroLabel.Size = UDim2.new(1, 0, 1, 0)
IntroLabel.BackgroundTransparency = 1
IntroLabel.Text = "NAW HUB V1 Loaded!"
IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLabel.Font = Enum.Font.GothamBold
IntroLabel.TextSize = 14

-- Hiệu ứng trượt thông báo xuống và ẩn đi
TweenService:Create(ToastFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -110, 0.05, 0)}):Play()
task.wait(1.5)
TweenService:Create(ToastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -110, -0.1, 0)}):Play()
task.wait(0.3)
SplashGui:Destroy()

-- 2. BIẾN TRẠNG THÁI & LOGIC TÍNH NĂNG TỰ NGHĨA
local AntiAFK_Enabled = false
local Speed_Enabled = false
local Noclip_Enabled = false
local Fly_Enabled = false
local ESP_Enabled = false
local Invis_Enabled = false
local InfJump_Enabled = false
local ClickTP_Enabled = false
local Fullbright_Enabled = false
local TeleportTarget = ""
local FlySpeed = 50

local OriginalTransparencies = {}
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient

-- Chức năng Tàng hình
local function ToggleInvisibility(state)
    Invis_Enabled = state
    local char = LocalPlayer.Character
    if not char then return end
    
    if Invis_Enabled then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                OriginalTransparencies[v] = v.Transparency
                v.Transparency = 1
            elseif v:IsA("Decal") then
                OriginalTransparencies[v] = v.Transparency
                v.Transparency = 1
            elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                OriginalTransparencies[v] = v.Enabled
                v.Enabled = false
            end
        end
    else
        for v, orig in pairs(OriginalTransparencies) do
            pcall(function()
                if v:IsA("BasePart") or v:IsA("Decal") then
                    v.Transparency = orig
                elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                    v.Enabled = orig
                end
            end)
        end
        table.clear(OriginalTransparencies)
    end
end

task.spawn(function()
    while task.wait(0.3) do
        if Invis_Enabled and LocalPlayer.Character then
            pcall(function()
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if (v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Transparency ~= 1) or (v:IsA("Decal") and v.Transparency ~= 1) then
                        v.Transparency = 1
                    elseif (v:IsA("BillboardGui") or v:IsA("SurfaceGui")) and v.Enabled == true then
                        v.Enabled = false
                    end
                end
            end)
        end
    end
end)

-- Nhảy vô hạn (Infinite Jump)
UserInputService.JumpRequest:Connect(function()
    if InfJump_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Click dịch chuyển (Ctrl + Click chuột trái)
Mouse.Button1Down:Connect(function()
    if ClickTP_Enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p) + Vector3.new(0, 3, 0)
        end
    end
end)

-- Sáng bản đồ (Fullbright)
task.spawn(function()
    while task.wait(0.5) do
        if Fullbright_Enabled then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
        end
    end
end)

local function ToggleFullbright(state)
    Fullbright_Enabled = state
    if not state then
        Lighting.Ambient = OriginalAmbient
        Lighting.OutdoorAmbient = OriginalOutdoorAmbient
        Lighting.GlobalShadows = true
    end
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if AntiAFK_Enabled then pcall(function() game:GetService("VirtualUser"):CaptureController() game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0)) end) end
end)

-- Boost FPS
local function OptimizeGame()
    pcall(function()
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
    end)
end

-- Server Utilities
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

-- Fly Loop
local flyBv, flyBg
RunService.RenderStepped:Connect(function()
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local cam = workspace.CurrentCamera
            
            hum.PlatformStand = true
            if not flyBv or flyBv.Parent ~= hrp then flyBv = Instance.new("BodyVelocity", hrp) flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9) end
            if not flyBg or flyBg.Parent ~= hrp then flyBg = Instance.new("BodyGyro", hrp) flyBg.MaxForce = Vector3.new(9e9, 9e9, 9e9) flyBg.P = 9e4 end
            
            flyBg.CFrame = cam.CFrame
            local moveDir = hum.MoveDirection
            
            if moveDir.Magnitude > 0 then
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

-- ESP Player
local function ManageESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("NAW_Highlight")
            if ESP_Enabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "NAW_Highlight"
                    hl.FillColor = Color3.fromRGB(255, 43, 43)
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
task.spawn(function() while task.wait(1) do ManageESP() end end)

-- Teleport Hàm
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

-- 3. GIAO DIỆN CHÍNH (SIDEBAR TRÁI QUEN THUỘC)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NawHubV1Classic"
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -27)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
ToggleBtn.Text = "NAW"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 13
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", ToggleBtn)
BtnStroke.Color = Color3.fromRGB(0, 170, 255)
BtnStroke.Thickness = 2

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 560, 0, 350) -- Tăng nhẹ chiều cao để chứa thêm nút
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(35, 35, 45)

-- Xử lý kéo thả mượt
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

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, -25)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local LogoLabel = Instance.new("TextLabel", Sidebar)
LogoLabel.Size = UDim2.new(1, 0, 0, 45)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "  🔵 NAW HUB"
LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextSize = 15
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left

local Footer = Instance.new("Frame", MainFrame)
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
Footer.BorderSizePixel = 0

local FooterText = Instance.new("TextLabel", Footer)
FooterText.Size = UDim2.new(1, -20, 1, 0)
FooterText.Position = UDim2.new(0, 12, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "Edition v1.2 | By namnguyen57"
FooterText.TextColor3 = Color3.fromRGB(110, 110, 120)
FooterText.Font = Enum.Font.Gotham
FooterText.TextSize = 11
FooterText.TextXAlignment = Enum.TextXAlignment.Left

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -165, 1, -40)
Container.Position = UDim2.new(0, 155, 0, 10)
Container.BackgroundTransparency = 1

-- Quản lý Tab
local Tabs, TabButtons, TabCount = {}, {}, 0

local function CreateTab(name)
    TabCount = TabCount + 1
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 550)
    TabPage.ScrollBarThickness = 2
    TabPage.Visible = (TabCount == 1)
    TabPage.BorderSizePixel = 0
    
    local ListLayout = Instance.new("UIListLayout", TabPage)
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Tabs[name] = TabPage
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 34)
    TabBtn.Position = UDim2.new(0.05, 0, 0, 45 + (TabCount - 1) * 38)
    TabBtn.BackgroundColor3 = (TabCount == 1) and Color3.fromRGB(20, 20, 26) or Color3.fromRGB(10, 10, 13)
    TabBtn.Text = "   " .. name
    TabBtn.TextColor3 = (TabCount == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, page in pairs(Tabs) do page.Visible = (tName == name) end
        for bName, btn in pairs(TabButtons) do
            local isCurrent = (bName == name)
            btn.BackgroundColor3 = isCurrent and Color3.fromRGB(20, 20, 26) or Color3.fromRGB(10, 10, 13)
            btn.TextColor3 = isCurrent and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
        end
    end)
    TabButtons[name] = TabBtn
    return TabPage
end

local function CreateSection(parent, title, sizeY)
    local SectionFrame = Instance.new("Frame", parent)
    SectionFrame.Size = UDim2.new(0.96, 0, 0, sizeY)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    SectionFrame.BorderSizePixel = 0
    Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
    
    local SectionTitle = Instance.new("TextLabel", SectionFrame)
    SectionTitle.Size = UDim2.new(1, -20, 0, 28)
    SectionTitle.Position = UDim2.new(0, 10, 0, 2)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextSize = 13
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    return SectionFrame
end

-- Ô vuông Checkbox cổ điển
local function CreateToggle(section, name, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size = UDim2.new(0.94, 0, 0, 30)
    Frame.Position = UDim2.new(0.03, 0, 0, yPos)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(215, 215, 225)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleBg = Instance.new("Frame", Frame)
    ToggleBg.Size = UDim2.new(0, 18, 0, 18)
    ToggleBg.Position = UDim2.new(1, -22, 0.5, -9)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(0, 4)
    
    local CheckMark = Instance.new("Frame", ToggleBg)
    CheckMark.Size = UDim2.new(0, 10, 0, 10)
    CheckMark.Position = UDim2.new(0.5, -5, 0.5, -5)
    CheckMark.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    CheckMark.BackgroundTransparency = 1 
    Instance.new("UICorner", CheckMark).CornerRadius = UDim.new(0, 2)
    
    local active = false
    local Click = Instance.new("TextButton", ToggleBg)
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.BackgroundTransparency = 1
    Click.Text = ""

    Click.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        TweenService:Create(CheckMark, TweenInfo.new(0.15), {BackgroundTransparency = active and 0 or 1}):Play()
    end)
end

local function CreateTextBox(section, placeholder, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size = UDim2.new(0.94, 0, 0, 30)
    Frame.Position = UDim2.new(0.03, 0, 0, yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(1, -10, 1, 0)
    Box.Position = UDim2.new(0, 5, 0, 0)
    Box.BackgroundTransparency = 1
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 12
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.FocusLost:Connect(function() callback(Box.Text) end)
end

local function CreateButton(section, name, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size = UDim2.new(0.94, 0, 0, 30)
    Frame.Position = UDim2.new(0.03, 0, 0, yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 130, 230)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================================
-- PHÂN CHIA MENU & CÁC TÍNH NĂNG MỚI THÊM
-- ==========================================================

-- TAB MAIN
local TabMain = CreateTab("Trang Chính")
local SecMove = CreateSection(TabMain, "Hệ Thống Di Chuyển", 245) -- Mở rộng khung để thêm tính năng
CreateToggle(SecMove, "Tốc độ chạy nhảy (Speed Hack)", 35, function(v) Speed_Enabled = v end)
CreateToggle(SecMove, "Đi xuyên tường (Noclip)", 70, function(v) Noclip_Enabled = v end)
CreateToggle(SecMove, "Chế độ bay (Fly Mode)", 105, function(v) Fly_Enabled = v end)
CreateToggle(SecMove, "Nhảy vô hạn (Infinite Jump)", 140, function(v) InfJump_Enabled = v end)
CreateToggle(SecMove, "Dịch chuyển bằng chuột (Ctrl + Click)", 175, function(v) ClickTP_Enabled = v end)
CreateToggle(SecMove, "Tàng hình nhân vật (Invisibility)", 210, function(v) ToggleInvisibility(v) end)

-- TAB VISUALS
local TabVis = CreateTab("Hiển Thị")
local SecESP = CreateSection(TabVis, "Nhìn Xuyên Tường & Bản Đồ", 115)
CreateToggle(SecESP, "Bật định vị người chơi (ESP Box)", 35, function(v) ESP_Enabled = v end)
CreateToggle(SecESP, "Bật sáng bản đồ (Fullbright)", 75, function(v) ToggleFullbright(v) end)

-- TAB TELEPORT
local TabTP = CreateTab("Dịch Chuyển")
local SecTP = CreateSection(TabTP, "Teleport Người Chơi", 115)
CreateTextBox(SecTP, "Nhập tên người chơi cần tìm...", 35, function(txt) TeleportTarget = txt end)
CreateButton(SecTP, "Dịch chuyển tức thời", 75, function() TeleportToPlayer(TeleportTarget) end)

local SecServ = CreateSection(TabTP, "Quản Lý Máy Châu", 115)
CreateButton(SecServ, "Vào lại Server này (Rejoin)", 35, function() RejoinServer() end)
CreateButton(SecServ, "Chuyển Server ngẫu nhiên (Hop)", 75, function() ServerHop() end)

-- TAB MISC
local TabMisc = CreateTab("Hệ Thống")
local SecPerf = CreateSection(TabMisc, "Tối Ưu & Tiện Ích", 115)
CreateButton(SecPerf, "Tăng Tốc Trò Chơi (Boost FPS)", 35, function() OptimizeGame() end)
CreateToggle(SecPerf, "Chống treo máy (Auto Anti-AFK)", 75, function(v) AntiAFK_Enabled = v end)
