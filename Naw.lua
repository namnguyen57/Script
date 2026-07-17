-- ==========================================================
-- SCRIPT: NAW HUB V1
-- TÁC GIẢ: namnguyen57 | 
-- ==========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- 1. HỆ THỐNG NGÔN NGỮ (LOCALIZATION SYSTEM)
local CurrentLang = "VN"
local LocalizedTexts = {}

local function RegisterLocale(instance, property, vnText, enText)
    table.insert(LocalizedTexts, {Instance = instance, Property = property, VN = vnText, EN = enText})
    instance[property] = (CurrentLang == "VN") and vnText or enText
end

local function ChangeLanguage(lang)
    CurrentLang = lang
    for _, data in pairs(LocalizedTexts) do
        if data.Instance and data.Instance.Parent then
            pcall(function() data.Instance[data.Property] = data[lang] end)
        end
    end
end

-- 2. HỆ THỐNG KÉO THẢ MENU (DRAGGABLE UI LOGIC)
local function SetupDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- 3. NOTIFICATION INTRO
local SplashGui = Instance.new("ScreenGui", CoreGui)
SplashGui.Name = "NawNotification"

local ToastFrame = Instance.new("Frame", SplashGui)
ToastFrame.Size, ToastFrame.Position = UDim2.new(0, 240, 0, 50), UDim2.new(0.5, -120, 0, -60)
ToastFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", ToastFrame).CornerRadius = UDim.new(0, 6)
local ToastStroke = Instance.new("UIStroke", ToastFrame)
ToastStroke.Thickness, ToastStroke.Color = 1.5, Color3.fromRGB(0, 162, 255)

local ToastLabel = Instance.new("TextLabel", ToastFrame)
ToastLabel.Size, ToastLabel.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
ToastLabel.TextColor3, ToastLabel.Font, ToastLabel.TextSize = Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 13
RegisterLocale(ToastLabel, "Text", "⚡ NAW HUB đã sẵn sàng!", "⚡ NAW HUB is ready!")

TweenService:Create(ToastFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -120, 0, 25)}):Play()
task.wait(1.8)
TweenService:Create(ToastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -120, 0, -60)}):Play()
task.wait(0.3)
SplashGui:Destroy()

-- 4. BIẾN TRẠNG THÁI & LOGIC TÍNH NĂNG CHUNG
local AntiAFK_Enabled = false
local Speed_Enabled = false
local Noclip_Enabled = false
local Fly_Enabled = false
local ESP_Enabled = false
local Invis_Enabled = false
local InfJump_Enabled = false
local ClickTP_Enabled = false
local Fullbright_Enabled = false
local function ExpandHitboxes(sizeValue)
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Thiết lập kích thước
                root.Size = Vector3.new(sizeValue, sizeValue, sizeValue)
                -- Điều chỉnh hiển thị để xác nhận trạng thái
                root.Transparency = 0.8
                root.BrickColor = BrickColor.new("Bright red")
                root.CanCollide = false
            end
        end
    end
end

-- Sử dụng: ExpandHitboxes(10)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local attackRemote = ReplicatedStorage:FindFirstChild("AttackEvent") -- Cần thay thế bằng tên Remote thực tế

local fastAttackEnabled = false

local function StartFastAttack()
    fastAttackEnabled = true
    task.spawn(function()
        while fastAttackEnabled do
            if attackRemote then
                attackRemote:FireServer() -- Gửi yêu cầu liên tục
            end
            task.wait(0.01) -- Độ trễ tối thiểu để tránh Crash do spam quá tải
        end
    end)
end

local function StopFastAttack()
    fastAttackEnabled = false
end

local OriginalTransparencies = {}
local ESP_Folder = Instance.new("Folder", CoreGui)
ESP_Folder.Name = "Naw_ESP_Storage"

-- Logic Tàng hình
local function ToggleInvisibility(state)
    Invis_Enabled = state
    local char = LocalPlayer.Character
    if not char then return end
    if Invis_Enabled then
        for _, v in pairs(char:GetDescendants()) do
            if (v:IsA("BasePart") and v.Name ~= "HumanoidRootPart") or v:IsA("Decal") then
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
                if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = orig
                elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then v.Enabled = orig end
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

-- Nhảy vô hạn
UserInputService.JumpRequest:Connect(function()
    if InfJump_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Click dịch chuyển 
Mouse.Button1Down:Connect(function()
    if ClickTP_Enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if Mouse.Target then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Sáng bản đồ
task.spawn(function()
    while task.wait(0.5) do
        if Fullbright_Enabled then
            Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.GlobalShadows = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255), false
        end
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if AntiAFK_Enabled then pcall(function() game:GetService("VirtualUser"):CaptureController() game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0)) end) end
end)

-- Vòng lặp Tốc độ
task.spawn(function()
    while task.wait(0.1) do
        if Speed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 60
        elseif not Speed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.WalkSpeed == 60 then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
        end
    end
end)

-- Xuyên tường
RunService.Stepped:Connect(function()
    if Noclip_Enabled and LocalPlayer.Character then
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end)
    end
end)

-- Chế độ bay
local flyBv, flyBg
RunService.RenderStepped:Connect(function()
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local cam = workspace.CurrentCamera
            if not flyBv or flyBv.Parent ~= hrp then flyBv = Instance.new("BodyVelocity", hrp) flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9) end
            if not flyBg or flyBg.Parent ~= hrp then flyBg = Instance.new("BodyGyro", hrp) flyBg.MaxForce = Vector3.new(9e9, 9e9, 9e9) flyBg.P = 9e4 end
            flyBg.CFrame = cam.CFrame
            hum:ChangeState(Enum.HumanoidStateType.Flying)
            local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
            local moveVec = controlModule:GetMoveVector()
            if moveVec.Magnitude > 0 then flyBv.Velocity = (cam.CFrame.RightVector * moveVec.X + cam.CFrame.LookVector * -moveVec.Z) * 60
            else flyBv.Velocity = Vector3.new(0, 0, 0) end
        end)
    else
        if flyBv then pcall(function() flyBv:Destroy() flyBv = nil end) end
        if flyBg then pcall(function() flyBg:Destroy() flyBg = nil end) end
    end
end)

-- ESP Định vị
task.spawn(function()
    while task.wait(0.5) do
        if ESP_Enabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hl = ESP_Folder:FindFirstChild(p.Name)
                    if not hl then
                        hl = Instance.new("Highlight", ESP_Folder)
                        hl.Name = p.Name
                        hl.FillColor, hl.OutlineColor = Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency, hl.OutlineTransparency = 0.5, 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    hl.Adornee = p.Character
                end
            end
        else ESP_Folder:ClearAllChildren() end
    end
end)

-- Tiện ích tối ưu hóa đồ họa
local function OptimizeGame()
    pcall(function()
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Material, v.Reflectance = Enum.Material.SmoothPlastic, 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end
    end)
end

-- 5. THIẾT KẾ ĐỒ HỌA CHÍNH (V3 GLOSS INTERFACE)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NawHubMainUI"
ScreenGui.ResetOnSpawn = false

-- NÚT FLOATING BUTTON KHỞI ĐỘNG (CÓ HỖ TRỢ KÉO THẢ)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size, ToggleBtn.Position = UDim2.new(0, 46, 0, 46), UDim2.new(0, 20, 0.5, -23)
ToggleBtn.BackgroundColor3, ToggleBtn.Text = Color3.fromRGB(15, 15, 20), "N"
ToggleBtn.TextColor3, ToggleBtn.Font, ToggleBtn.TextSize = Color3.fromRGB(0, 162, 255), Enum.Font.GothamBlack, 22
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Thickness, ToggleStroke.Color = 2, Color3.fromRGB(0, 162, 255)

-- BẢNG ĐIỀU KHIỂN TRUNG TÂM (CÓ HỖ TRỢ KÉO THẢ)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 580, 0, 360), UDim2.new(0.5, -290, 0.5, -180)
MainFrame.BackgroundColor3, MainFrame.Visible = Color3.fromRGB(15, 15, 20), true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness, MainStroke.Color = 1, Color3.fromRGB(40, 40, 50)

-- Kích hoạt tính năng di chuyển cho cả Nút mở và Khung chính
SetupDraggable(ToggleBtn)
SetupDraggable(MainFrame)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- THANH SIDEBAR TRÁI
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size, Sidebar.BackgroundColor3, Sidebar.BorderSizePixel = UDim2.new(0, 160, 1, 0), Color3.fromRGB(10, 10, 14), 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local LogoLabel = Instance.new("TextLabel", Sidebar)
LogoLabel.Size, LogoLabel.Position, LogoLabel.BackgroundTransparency = UDim2.new(1, -30, 0, 50), UDim2.new(0, 30, 0, 0), 1
LogoLabel.Text, LogoLabel.TextColor3 = " Naw Hub", Color3.fromRGB(0, 162, 255)
LogoLabel.Font, LogoLabel.TextSize, LogoLabel.TextXAlignment = Enum.Font.GothamBold, 16, Enum.TextXAlignment.Left

local IconLabel = Instance.new("TextLabel", Sidebar)
IconLabel.Size, IconLabel.Position, IconLabel.BackgroundTransparency, IconLabel.Text = UDim2.new(0, 30, 0, 50), UDim2.new(0, 10, 0, 0), 1, "⚡"
IconLabel.TextColor3, IconLabel.Font, IconLabel.TextSize = Color3.fromRGB(255, 255, 255), Enum.Font.Gotham, 16

local Container = Instance.new("Frame", MainFrame)
Container.Size, Container.Position, Container.BackgroundTransparency = UDim2.new(1, -175, 1, -20), UDim2.new(0, 170, 0, 10), 1

-- BỘ ĐIỀU HƯỚNG TAB UI
local Tabs, TabButtons, TabCount = {}, {}, 0

local function CreateTab(vnName, enName, icon)
    TabCount = TabCount + 1
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size, TabPage.BackgroundTransparency, TabPage.CanvasSize = UDim2.new(1, 0, 1, 0), 1, UDim2.new(0, 0, 0, 550)
    TabPage.ScrollBarThickness, TabPage.Visible, TabPage.BorderSizePixel = 2, (TabCount == 1), 0
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
    
    local ListLayout = Instance.new("UIListLayout", TabPage)
    ListLayout.Padding, ListLayout.SortOrder = UDim.new(0, 10), Enum.SortOrder.LayoutOrder
    Tabs[vnName] = TabPage
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size, TabBtn.Position = UDim2.new(0.9, 0, 0, 38), UDim2.new(0.05, 0, 0, 55 + (TabCount - 1) * 45)
    TabBtn.BackgroundColor3 = (TabCount == 1) and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(15, 15, 20)
    TabBtn.Font, TabBtn.TextSize, TabBtn.TextXAlignment = Enum.Font.GothamSemibold, 13, Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    RegisterLocale(TabBtn, "Text", "  " .. icon .. "  " .. vnName, "  " .. icon .. "  " .. enName)
    TabBtn.TextColor3 = (TabCount == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
    
    TabBtn.MouseButton1Click:Connect(function()
        for tName, page in pairs(Tabs) do page.Visible = (tName == vnName) end
        for bName, btn in pairs(TabButtons) do
            local active = (bName == vnName)
            TweenService:Create(btn, TweenInfo.new(0.25), {
                BackgroundColor3 = active and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(15, 15, 20),
                TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
            }):Play()
        end
    end)
    TabButtons[vnName] = TabBtn
    return TabPage
end

local function CreateSection(parent, vnTitle, enTitle, sizeY)
    local SectionFrame = Instance.new("Frame", parent)
    SectionFrame.Size, SectionFrame.BackgroundColor3 = UDim2.new(0.96, 0, 0, sizeY), Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", SectionFrame).Color = Color3.fromRGB(35, 35, 45)
    
    local SectionTitle = Instance.new("TextLabel", SectionFrame)
    SectionTitle.Size, SectionTitle.Position, SectionTitle.BackgroundTransparency = UDim2.new(1, -20, 0, 30), UDim2.new(0, 12, 0, 5), 1
    SectionTitle.TextColor3, SectionTitle.Font, SectionTitle.TextSize = Color3.fromRGB(0, 162, 255), Enum.Font.GothamBold, 13
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    RegisterLocale(SectionTitle, "Text", vnTitle, enTitle)
    return SectionFrame
end

local function CreateToggle(section, vnName, enName, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position, Frame.BackgroundTransparency = UDim2.new(0.94, 0, 0, 34), UDim2.new(0.03, 0, 0, yPos), 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size, Label.BackgroundTransparency = UDim2.new(0.7, 0, 1, 0), 1
    Label.TextColor3, Label.Font, Label.TextSize, Label.TextXAlignment = Color3.fromRGB(220, 220, 230), Enum.Font.Gotham, 12, Enum.TextXAlignment.Left
    RegisterLocale(Label, "Text", vnName, enName)

    local ToggleBg = Instance.new("Frame", Frame)
    ToggleBg.Size, ToggleBg.Position, ToggleBg.BackgroundColor3 = UDim2.new(0, 40, 0, 20), UDim2.new(1, -40, 0.5, -10), Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", ToggleBg)
    Circle.Size, Circle.Position, Circle.BackgroundColor3 = UDim2.new(0, 14, 0, 14), UDim2.new(0, 3, 0.5, -7), Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local active = false
    local Click = Instance.new("TextButton", ToggleBg)
    Click.Size, Click.BackgroundTransparency, Click.Text = UDim2.new(1, 0, 1, 0), 1, ""

    Click.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        TweenService:Create(ToggleBg, TweenInfo.new(0.25), {BackgroundColor3 = active and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(35, 35, 45)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = active and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
    end)
end

local function CreateButton(section, vnName, enName, yPos, callback)
    local Frame = Instance.new("Frame", section)
    Frame.Size, Frame.Position = UDim2.new(0.94, 0, 0, 32), UDim2.new(0.03, 0, 0, yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color, Stroke.Thickness = Color3.fromRGB(50, 50, 60), 1

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size, Btn.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
    Btn.TextColor3, Btn.Font, Btn.TextSize = Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 12
    RegisterLocale(Btn, "Text", vnName, enName)
    
    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 162, 255)}):Play()
        callback()
        task.wait(0.1)
        TweenService:Create(Frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
    end)
end

-- ==========================================================
-- ĐĂNG KÝ CÁC TAB CHỨC NĂNG VÀO HỆ THỐNG GIAO DIỆN
-- ==========================================================

-- TAB 1: DI CHUYỂN
local TabMain = CreateTab("Di Chuyển", "Movement", "🏠")
local SecMove = CreateSection(TabMain, "Hệ Thống Di Chuyển", "Movement Settings", 250)
CreateToggle(SecMove, "Tốc độ chạy nhảy (Speed Hack)", "WalkSpeed Hack", 35, function(v) Speed_Enabled = v end)
CreateToggle(SecMove, "Đi xuyên tường (Noclip)", "Noclip Bypass", 70, function(v) Noclip_Enabled = v end)
CreateToggle(SecMove, "Chế độ bay (Fly Mode)", "Fly Mode Control", 105, function(v) Fly_Enabled = v end)
CreateToggle(SecMove, "Nhảy vô hạn (Infinite Jump)", "Infinite Jump Request", 140, function(v) InfJump_Enabled = v end)
CreateToggle(SecMove, "Dịch chuyển bằng chuột (Ctrl + Click)", "Click Teleport (Ctrl + Click)", 175, function(v) ClickTP_Enabled = v end)
CreateToggle(SecMove, "Tàng hình nhân vật (Invisibility)", "Invisibility Exploit", 210, function(v) ToggleInvisibility(v) end)

-- TAB 2: HIỂN THỊ
local TabVis = CreateTab("Hiển Thị", "Visuals", "👁️")
local SecESP = CreateSection(TabVis, "Định Vị & Bản Đồ", "ESP & Map Rendering", 115)
CreateToggle(SecESP, "Bật định vị người chơi (Player ESP)", "Player Highlight ESP", 35, function(v) ESP_Enabled = v end)
CreateToggle(SecESP, "Bật sáng toàn bộ bản đồ (Fullbright)", "Fullbright Lighting", 75, function(v) Fullbright_Enabled = v end)

-- TAB 3: HỆ THỐNG CÀI ĐẶT
local TabMisc = CreateTab("Hệ Thống", "System", "⚙️")
local SecPerf = CreateSection(TabMisc, "Tiện Ích Hiệu Năng", "Performance & Utilities", 115)
CreateToggle(SecPerf, "Chống treo máy (Auto Anti-AFK)", "Anti-AFK Verification", 35, function(v) AntiAFK_Enabled = v end)
CreateButton(SecPerf, "Tối ưu hóa & Tăng tốc trò chơi", "Optimize & Boost FPS", 75, function() OptimizeGame() end)

local SecLang = CreateSection(TabMisc, "Cài Đặt Ngôn Ngữ", "Language Settings", 115)
CreateButton(SecLang, "Chuyển sang Tiếng Việt", "Switch to Vietnamese", 35, function() ChangeLanguage("VN") end)
CreateButton(SecLang, "Chuyển sang Tiếng Anh", "Switch to English", 75, function() ChangeLanguage("EN") end)
