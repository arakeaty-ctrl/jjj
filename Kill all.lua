-- ServerScriptService/KillAllServer.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local event = ReplicatedStorage:FindFirstChild("KillAllEvent")
if not event then
	event = Instance.new("RemoteEvent")
	event.Name = "KillAllEvent"
	event.Parent = ReplicatedStorage
end

event.OnServerEvent:Connect(function(playerWhoFired)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("Humanoid") then
			plr.Character.Humanoid.Health = 0
		end
	end
end)
