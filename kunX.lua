-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Player Info
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoDodgeUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- LOGO
local logo = Instance.new("Frame")
logo.Size = UDim2.fromOffset(50,50)
logo.Position = UDim2.fromScale(0.02,0.02)
logo.BackgroundColor3 = Color3.new(0,0,0)
logo.BorderSizePixel = 0
logo.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.5,0)
corner.Parent = logo

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.fromScale(1,1)
logoText.BackgroundTransparency = 1
logoText.Text = "🦁"
logoText.TextScaled = true
logoText.TextColor3 = Color3.fromRGB(255,0,0)
logoText.Font = Enum.Font.GothamBold
logoText.Parent = logo

-- Buttons OFF / No
local offBtn = Instance.new("TextButton")
offBtn.Size = UDim2.fromOffset(80,30)
offBtn.Position = UDim2.fromScale(0.02,0.12)
offBtn.BackgroundColor3 = Color3.new(0,0,0)
offBtn.TextColor3 = Color3.fromRGB(255,0,0)
offBtn.Text = "OFF"
offBtn.Parent = gui

local noBtn = Instance.new("TextButton")
noBtn.Size = UDim2.fromOffset(80,30)
noBtn.Position = UDim2.fromScale(0.12,0.12)
noBtn.BackgroundColor3 = Color3.new(0,0,0)
noBtn.TextColor3 = Color3.fromRGB(255,0,0)
noBtn.Text = "No"
noBtn.Parent = gui

local autoDodge = false
offBtn.MouseButton1Click:Connect(function()
    autoDodge = true
end)
noBtn.MouseButton1Click:Connect(function()
    autoDodge = false
end)

-- Detect obstacles (walls, animals)
local function detectObstacle(position, distance)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {character}

    -- Raycast in front
    local ray = Workspace:Raycast(position, hrp.CFrame.LookVector * distance, rayParams)
    return ray
end

-- Dodge function
local function dodge()
    local obstacle = detectObstacle(hrp.Position, 10) -- 10 studs ahead
    if obstacle then
        local offset = (math.random() < 0.5 and -5 or 5) -- ซ้ายหรือขวา
        hrp.CFrame = hrp.CFrame + Vector3.new(offset,0,0)
    end
end

-- Auto dodge loop
RunService.RenderStepped:Connect(function()
    if autoDodge then
        dodge()
    end
end)
