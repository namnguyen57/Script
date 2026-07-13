-- ==========================================================
-- NAW HUB V1
-- Tác giả: namnguyen57
-- ==========================================================

repeat task.wait() until game:IsLoaded()

local Players, TweenService, UserInputService, RunService = game:GetService("Players"), game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local SpeedVal, FlyVal = 60, 60
local Speed_Enabled, Fly_Enabled = false, false

-- 1. GIAO DIỆN CHÍNH
local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "NawHubPremium"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position, MainFrame.BackgroundColor3 = UDim2.new(0, 560, 0, 320), UDim2.new(0.5, -280, 0.5, -160), Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel, MainFrame.Active, MainFrame.Visible = 0, true, true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- 2. NÚT MỞ MENU (HÌNH VUÔNG BO GÓC + ICON)
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size, ToggleBtn.Position = UDim2.new(0, 50, 0, 50), UDim2.new(0, 10, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.Image = "rbxassetid://6034287929"
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(0, 170, 255)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 3. FOOTER TÁC GIẢ
local Footer = Instance.new("Frame", MainFrame)
Footer.Size, Footer.Position = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30)
Footer.BackgroundColor3, Footer.BorderSizePixel = Color3.fromRGB(10, 10, 12), 0
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 8)
local AuthorText = Instance.new("TextLabel", Footer)
AuthorText.Size, AuthorText.BackgroundTransparency, AuthorText.Text = UDim2.new(1, 0, 1, 0), 1, "NAW HUB V1 | Developed by namnguyen57"
AuthorText.TextColor3, AuthorText.Font, AuthorText.TextSize = Color3.fromRGB(150, 150, 150), Enum.Font.SourceSansItalic, 14

-- 4. LOGIC TÍNH NĂNG
RunService.RenderStepped:Connect(function()
    if Speed_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = SpeedVal end
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
    end
end)

-- 5. HÀM TẠO UI (TAB, TOGGLE, SLIDER)
local Container = Instance.new("Frame", MainFrame)
Container.Size, Container.Position, Container.BackgroundTransparency = UDim2.new(1, -20, 1, -80), UDim2.new(0, 10, 0, 10), 1

local function CreateTab(name)
    local TabPage = Instance.new("ScrollingFrame", Container)
    TabPage.Size, TabPage.BackgroundTransparency, TabPage.CanvasSize = UDim2.new(1, 0, 1, 0), 1, UDim2.new(0, 0, 0, 500)
    Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 10)
    return TabPage
end

local function CreateToggle(parent, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size, btn.BackgroundColor3, btn.Text = UDim2.new(1, 0, 0, 30), Color3.fromRGB(45, 45, 55), name
    btn.TextColor3, btn.Font = Color3.new(1,1,1), Enum.Font.SourceSans
    local active = false
    btn.MouseButton1Click:Connect(function() active = not active; btn.BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55); callback(active) end)
    Instance.new("UICorner", btn)
end

-- TẠO NỘI DUNG
local TabFPS = CreateTab("Boost FPS")
local StatsLabel = Instance.new("TextLabel", TabFPS)
StatsLabel.Size, StatsLabel.TextColor3, StatsLabel.Text = UDim2.new(1,0,0,30), Color3.new(1,1,1), "FPS: -- | Ping: --"
task.spawn(function()
    while task.wait(0.5) do
        StatsLabel.Text = "FPS: " .. math.floor(workspace:GetRealPhysicsFPS()) .. " | Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
    end
end)
CreateToggle(TabFPS, "Boost FPS (Optimize Graphics)", function(v) if v then game:GetService("Lighting").GlobalShadows = false end end)

local TabMove = CreateTab("Movement")
CreateToggle(TabMove, "Speed Hack", function(v) Speed_Enabled = v end)
CreateToggle(TabMove, "Fly Hack", function(v) Fly_Enabled = v end)
