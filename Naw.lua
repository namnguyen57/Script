-- ==========================================================
-- SCRIPT: NAW HUB V1 
-- ==========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 1. SPLASH SCREEN (HIỆN TÊN TÁC GIẢ 3 GIÂY)
local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "Splash"
SplashGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local SplashFrame = Instance.new("Frame", SplashGui)
SplashFrame.Size = UDim2.new(1, 0, 1, 0)
SplashFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)

local AuthorLabel = Instance.new("TextLabel", SplashFrame)
AuthorLabel.Size = UDim2.new(1, 0, 1, 0)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "NAW HUB V1\nCreated by namnguyen57"
AuthorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthorLabel.Font = Enum.Font.GothamBold
AuthorLabel.TextSize = 24

task.wait(3) -- Hiện tên 3 giây
TweenService:Create(SplashFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
TweenService:Create(AuthorLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
task.wait(0.5)
SplashGui:Destroy()

-- 2. LOGIC TÍNH NĂNG
local AntiAFK_Enabled = true
local FPS_Boost_Enabled = false

LocalPlayer.Idled:Connect(function()
    if AntiAFK_Enabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

local function OptimizeGame()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
    end
end

-- 3. GIAO DIỆN CHÍNH (POLLUTED STYLE)
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", MainFrame).Radius = UDim.new(0, 10)

-- Tiêu đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "NAW HUB V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

-- Hàm tạo Nút Gạt (Toggle)
local function CreateToggle(name, yPos, callback)
    local Frame = Instance.new("Frame", MainFrame)
    Frame.Size = UDim2.new(0.9, 0, 0, 40)
    Frame.Position = UDim2.new(0.05, 0, 0, yPos)
    Frame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleBg = Instance.new("Frame", Frame)
    ToggleBg.Size = UDim2.new(0, 40, 0, 20)
    ToggleBg.Position = UDim2.new(1, -40, 0.25, 0)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", ToggleBg).Radius = UDim.new(0, 10)

    local Circle = Instance.new("Frame", ToggleBg)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0, 2)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Circle).Radius = UDim.new(0, 8)

    local isToggled = false
    local Btn = Instance.new("TextButton", ToggleBg)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        callback(isToggled)
        TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = isToggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 50)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = isToggled and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
    end)
end

-- Thêm tính năng vào menu
CreateToggle("Anti-AFK", 60, function(val) AntiAFK_Enabled = val end)
CreateToggle("Boost FPS", 110, function(val) 
    FPS_Boost_Enabled = val 
    if val then OptimizeGame() end
end)
