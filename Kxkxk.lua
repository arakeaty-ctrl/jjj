local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent
local ResetEvent = ReplicatedStorage:WaitForChild("ResetAllPlayers")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KillAllUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- LOGO (Black Solid)
local logo = Instance.new("Frame")
logo.Size = UDim2.fromScale(0.18,0.18)
logo.Position = UDim2.fromScale(0.05,0.05)
logo.BackgroundColor3 = Color3.new(0,0,0)
logo.BorderSizePixel = 0
logo.Parent = gui

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.fromScale(1,1)
logoText.BackgroundTransparency = 1
logoText.Text = "🦁"
logoText.TextScaled = true
logoText.TextColor3 = Color3.fromRGB(200,0,0)
logoText.Parent = logo

-- KILL ALL BUTTON
local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.fromScale(0.25,0.08)
killBtn.Position = UDim2.fromScale(0.05,0.28)
killBtn.BackgroundColor3 = Color3.new(0,0,0)
killBtn.BorderSizePixel = 0
killBtn.Text = "KILL ALL"
killBtn.TextScaled = true
killBtn.TextColor3 = Color3.fromRGB(255,0,0)
killBtn.Font = Enum.Font.GothamBold
killBtn.Parent = gui

killBtn.MouseButton1Click:Connect(function()
    ResetEvent:FireServer()
end)
