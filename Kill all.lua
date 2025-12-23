-- ServerScriptService/KillAllServer.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create RemoteEvent
local resetEvent = Instance.new("RemoteEvent")
resetEvent.Name = "ResetAllPlayers"
resetEvent.Parent = ReplicatedStorage

resetEvent.OnServerEvent:Connect(function(player)
	-- Optional: allow only game owner
	if player.UserId ~= game.CreatorId then
		return
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("Humanoid") then
			plr.Character.Humanoid.Health = 0
		end
	end
end)
-- Kill All UI (Client)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local ResetEvent = ReplicatedStorage:WaitForChild("ResetAllPlayers")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KillAllUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- LOGO (Black Solid)
local logo = Instance.new("Frame")
logo.Size = UDim2.fromScale(0.15, 0.15)
logo.Position = UDim2.fromScale(0.05, 0.05)
logo.BackgroundColor3 = Color3.new(0,0,0)
logo.BorderSizePixel = 0
logo.Parent = gui
logo.Active = true
logo.Draggable = true

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.fromScale(1,1)
logoText.BackgroundTransparency = 1
logoText.Text = "🦁"
logoText.TextScaled = true
logoText.TextColor3 = Color3.fromRGB(255, 0, 0)
logoText.Font = Enum.Font.GothamBlack
logoText.Parent = logo

-- KILL ALL BUTTON
local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.fromScale(0.25, 0.08)
killBtn.Position = UDim2.fromScale(0.05, 0.25)
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
