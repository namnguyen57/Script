-- ==========================================================
-- SCRIPT: NAW ANTI AFK V1 
-- ==========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Các biến trạng thái Bật/Tắt
local AntiAFK_Enabled = true
local FPS_Boost_Enabled = false

-- 1. HỆ THỐNG XỬ LÝ ANTI-AFK NGẦM
if LocalPlayer then
    LocalPlayer.Idled:Connect(function()
        if AntiAFK_Enabled then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
    end)
end

-- 2. HỆ THỐNG TỐI ƯU HÓA ĐỒ HỌA (TĂNG FPS)
local function OptimizeGame()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") then
                v.Enabled = false
            end
        end
        
        if workspace:FindFirstChildOfClass("Terrain") then
            local terrain = workspace.Terrain
            terrain.Decoration = false
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
    end)
end

-- 3. KHỞI TẠO GIAO DIỆN HUB CHUYÊN NGHIỆP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NawAntiAFKV1"
ScreenGui.ResetOnSpawn = false
local TargetParent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = TargetParent

-- Khung Menu Chính (Main Window)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.Radius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Thanh Tiêu Đề (Top Bar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.Radius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 10)
TopBarCover.Position = UDim2.new(0, 0, 1, -10)
TopBarCover.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "★ NAW ANTI AFK V1 ★"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150) -- Màu xanh Neon xịn sò
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.Radius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Thanh Điều Hướng Trái (Left Navigation Bar)
local NavBar = Instance.new("Frame")
NavBar.Size = UDim2.new(0, 120, 1, -40)
NavBar.Position = UDim2.new(0, 0, 0, 40)
NavBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
NavBar.BorderSizePixel = 0
NavBar.Parent = MainFrame

local NavBarCorner = Instance.new("UICorner")
NavBarCorner.Radius = UDim.new(0, 10)
NavBarCorner.Parent = NavBar

-- Khu vực chứa nội dung các Tab
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -130, 1, -50)
ContentFrame.Position = UDim2.new(0, 125, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- NỘI DUNG TAB MAIN (MẶC ĐỊNH)
local MainTab = Instance.new("Frame")
MainTab.Size = UDim2.new(1, 0, 1, 0)
MainTab.BackgroundTransparency = 1
MainTab.Parent = ContentFrame

-- Nút bấm bật/tắt Anti-AFK
local AntiAFKButton = Instance.new("TextButton")
AntiAFKButton.Size = UDim2.new(1, 0, 0, 45)
AntiAFKButton.Position = UDim2.new(0, 0, 0, 10)
AntiAFKButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
AntiAFKButton.Text = "Anti-AFK: ĐANG BẬT"
AntiAFKButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiAFKButton.Font = Enum.Font.GothamBold
AntiAFKButton.TextSize = 14
AntiAFKButton.Parent = MainTab

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.Radius = UDim.new(0, 8)
BtnCorner1.Parent = AntiAFKButton

AntiAFKButton.MouseButton1Click:Connect(function()
    AntiAFK_Enabled = not AntiAFK_Enabled
    if AntiAFK_Enabled then
        AntiAFKButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        AntiAFKButton.Text = "Anti-AFK: ĐANG BẬT"
    else
        AntiAFKButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        AntiAFKButton.Text = "Anti-AFK: ĐANG TẮT"
    end
end)

-- Nút bấm bật/tắt Tăng FPS
local FPSButton = Instance.new("TextButton")
FPSButton.Size = UDim2.new(1, 0, 0, 45)
FPSButton.Position = UDim2.new(0, 0, 0, 70)
FPSButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
FPSButton.Text = "Giảm Lag (FPS Boost): ĐANG TẮT"
FPSButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSButton.Font = Enum.Font.GothamBold
FPSButton.TextSize = 14
FPSButton.Parent = MainTab

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.Radius = UDim.new(0, 8)
BtnCorner2.Parent = FPSButton

FPSButton.MouseButton1Click:Connect(function()
    FPS_Boost_Enabled = not FPS_Boost_Enabled
    if FPS_Boost_Enabled then
        FPSButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        FPSButton.Text = "Giảm Lag (FPS Boost): ĐANG BẬT"
        OptimizeGame()
    else
        FPSButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        FPSButton.Text = "Giảm Lag (FPS Boost): ĐANG TẮT"
    end
end)

-- Nhãn thông tin tác giả
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, 0, 0, 30)
CreditLabel.Position = UDim2.new(0, 0, 1, -30)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Tạo bởi BaoNam-utc | An toàn 100%"
CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.TextSize = 12
CreditLabel.Parent = MainTab

-- CÁC NÚT TAB Ở THANH ĐIỀU HƯỚNG (ĐỂ HIỂN THỊ)
local Tab1 = Instance.new("TextButton")
Tab1.Size = UDim2.new(1, -10, 0, 35)
Tab1.Position = UDim2.new(0, 5, 0, 10)
Tab1.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Tab1.Text = "Trang Chủ"
Tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1.Font = Enum.Font.Gotham
Tab1.TextSize = 12
Tab1.Parent = NavBar
Instance.new("UICorner", Tab1).Radius = UDim.new(0, 6)

local Tab2 = Instance.new("TextButton")
Tab2.Size = UDim2.new(1, -10, 0, 35)
Tab2.Position = UDim2.new(0, 5, 0, 50)
Tab2.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Tab2.Text = "Người Chơi"
Tab2.TextColor3 = Color3.fromRGB(150, 150, 150)
Tab2.Font = Enum.Font.Gotham
Tab2.TextSize = 12
Tab2.Parent = NavBar
Instance.new("UICorner", Tab2).Radius = UDim.new(0, 6)

local Tab3 = Instance.new("TextButton")
Tab3.Size = UDim2.new(1, -10, 0, 35)
Tab3.Position = UDim2.new(0, 5, 0, 90)
Tab3.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Tab3.Text = "Cài Đặt"
Tab3.TextColor3 = Color3.fromRGB(150, 150, 150)
Tab3.Font = Enum.Font.Gotham
Tab3.TextSize = 12
Tab3.Parent = NavBar
Instance.new("UICorner", Tab3).Radius = UDim.new(0, 6)
