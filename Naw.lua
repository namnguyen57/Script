-- ==========================================================
-- SCRIPT: NAW HUB V1 
-- TÁC GIẢ: namnguyen57
-- ==========================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 1. TẠO SPLASH SCREEN XỊN XÒ (XOAY VÒNG)
local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "NawSplash"
SplashGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Background = Instance.new("Frame", SplashGui)
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(15, 15, 20)

-- Vòng tròn xoay (The Spinner)
local Spinner = Instance.new("Frame", Background)
Spinner.Size = UDim2.new(0, 80, 0, 80)
Spinner.Position = UDim2.new(0.5, -40, 0.5, -40)
Spinner.BackgroundTransparency = 1

local UIStroke = Instance.new("UIStroke", Spinner)
UIStroke.Thickness = 6
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local UICorner = Instance.new("UICorner", Spinner)
UICorner.CornerRadius = UDim.new(1, 0)

-- Chữ tác giả
local Title = Instance.new("TextLabel", Background)
Title.Size = UDim2.new(1, 0, 0, 100)
Title.Position = UDim2.new(0, 0, 0.5, 50)
Title.BackgroundTransparency = 1
Title.Text = "NAW HUB V1\nLoading by namnguyen57..."
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22

-- HIỆU ỨNG XOAY (SPINNING ANIMATION)
local spinTween = TweenService:Create(Spinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
spinTween:Play()

task.wait(3.5) -- Thời gian load

-- HIỆU ỨNG MỜ DẦN (FADE OUT)
TweenService:Create(Background, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(Spinner, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
task.wait(0.5)
SplashGui:Destroy()

-- 2. TÍNH NĂNG (Anti-AFK & FPS Boost)
local AntiAFK_Enabled = false
local FPS_Boost_Enabled = false

LocalPlayer.Idled:Connect(function()
    if AntiAFK_Enabled then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new(0, 0))
    end
end)

local function OptimizeGame()
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").FogEnd = 9e9
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
    end
end

-- 3. GIAO DIỆN CHÍNH (MAIN MENU)
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "NawHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).Radius = UDim.new(0, 10)

-- Tiêu đề Menu
local MenuTitle = Instance.new("TextLabel", MainFrame)
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.Text = "NAW HUB V1"
MenuTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
MenuTitle.Font = Enum.Font.SourceSansBold
MenuTitle.TextSize = 20
MenuTitle.BackgroundTransparency = 1

-- NÚT BẤM NỔI (TOGGLE BUTTON)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Text = "NAW"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
Instance.new("UICorner", ToggleBtn).Radius = UDim.new(0, 25)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Hàm tạo nút gạt
local function CreateToggle(name, yPos, callback)
    local Frame = Instance.new("Frame", MainFrame)
    Frame.Size = UDim2.new(0.9, 0, 0, 40)
    Frame.Position = UDim2.new(0.05, 0, 0, yPos)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

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
    
    local active = false
    local Click = Instance.new("TextButton", ToggleBg)
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.BackgroundTransparency = 1
    Click.Text = ""
    Click.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 50)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
    end)
end

CreateToggle("Anti-AFK", 60, function(v) AntiAFK_Enabled = v end)
CreateToggle("Boost FPS", 110, function(v) if v then OptimizeGame() end end)
