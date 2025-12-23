
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- SETTINGS
local NORMAL_ANIMAL = "Lion"
local GOLDEN_ANIMAL = "Golden Lion"

local AUTO_FARM = false
local AUTO_RIDE = true
local AUTO_AVOID = true

local SEARCH_DISTANCE = 150
local JUMP_DISTANCE = 12
local TO_EAT = 3
local eaten = 0

local PATH_SETTINGS = {
    AgentRadius = 3,
    AgentHeight = 6,
    AgentCanJump = true,
    WaypointSpacing = 3
}

-- ================= CREATE GUI ==================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AnimalFarmGUI"

-- ปุ่มเปิดเมนู
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromScale(0.18,0.08)
openBtn.Position = UDim2.fromScale(0.02,0.45)
openBtn.Text = "🦁"
openBtn.TextScaled = true
openBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
openBtn.TextColor3 = Color3.new(1,1,1)

-- เมนู
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.fromScale(0.45,0.55)
menu.Position = UDim2.fromScale(0.2,0.2)
menu.BackgroundColor3 = Color3.fromRGB(20,20,20)
menu.Visible = false
menu.Active = true
menu.Draggable = true

-- โปรไฟล์ / โลโก้ 🦁
local profile = Instance.new("Frame", menu)
profile.Size = UDim2.fromScale(0.25,0.25)
profile.Position = UDim2.fromScale(0.05,0.05)
profile.BackgroundColor3 = Color3.new(0,0,0)

local profileText = Instance.new("TextLabel", profile)
profileText.Size = UDim2.fromScale(1,1)
profileText.Text = "🦁"
profileText.TextScaled = true
profileText.TextColor3 = Color3.fromRGB(200,0,0)
profileText.BackgroundTransparency = 1

-- กล่องคำอธิบาย
local desc = Instance.new("TextLabel", menu)
desc.Size = UDim2.fromScale(0.65,0.2)
desc.Position = UDim2.fromScale(0.3,0.05)
desc.TextWrapped = true
desc.TextScaled = true
desc.Text = "เลือกเมนูเพื่อดูคำอธิบาย"
desc.BackgroundColor3 = Color3.fromRGB(30,30,30)
desc.TextColor3 = Color3.new(1,1,1)

-- ฟังก์ชันสร้างปุ่มเมนู
local function createButton(text, posY, description, callback)
    local btn = Instance.new("TextButton", menu)
    btn.Size = UDim2.fromScale(0.9,0.08)
    btn.Position = UDim2.fromScale(0.05,posY)
    btn.Text = text
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        desc.Text = description
        if callback then callback() end
    end)
end

-- ================= BUTTONS ==================
createButton("AUTO FARM", 0.3, "เปิดระบบอัตโนมัติขี่สัตว์ → กิน → สลับ Golden Lion → รีเซ็ต", function()
    AUTO_FARM = not AUTO_FARM
end)

createButton("AUTO RIDE", 0.45, "กดขี่สัตว์อัตโนมัติ", function()
    AUTO_RIDE = not AUTO_RIDE
end)

createButton("AUTO AVOID", 0.6, "หลบต้นไม้ หิน และสัตว์อื่นแบบอัตโนมัติ", function()
    AUTO_AVOID = not AUTO_AVOID
end)

openBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

--
local function getCharacter()
    local char = player.Character
    if not char then return end
    return char, char:FindFirstChild("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function findNearestAnimal(name, root)
    local nearest, shortest = nil, SEARCH_DISTANCE
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == name and obj:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - obj.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = obj
            end
        end
    end
    return nearest
end

local function moveTo(humanoid, root, target)
    local path = PathfindingService:CreatePath(PATH_SETTINGS)
    path:ComputeAsync(root.Position, target)
    if path.Status ~= Enum.PathStatus.Success then
        humanoid:MoveTo(target)
        return
    end
    for _, wp in ipairs(path:GetWaypoints()) do
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        humanoid:MoveTo(wp.Position)
        humanoid.MoveToFinished:Wait()
    end
end

local function jump(humanoid)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

local function autoRide()
    for _, p in pairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.ActionText:lower():find("ride") then
            fireproximityprompt(p)
        end
    end
end

local function resetCharacter()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = 0
        eaten = 0
    end
end

-- MAIN LOOP 
task.spawn(function()
    while task.wait(0.3) do
        if not AUTO_FARM then continue end
        local char, humanoid, root = getCharacter()
        if not humanoid or not root then continue end

        -- ขี่สัตว์ธรรมดาและกิน
        local animal = findNearestAnimal(NORMAL_ANIMAL, root)
        if animal then
            moveTo(humanoid, root, animal.HumanoidRootPart.Position)
            if (root.Position - animal.HumanoidRootPart.Position).Magnitude < JUMP_DISTANCE then
                jump(humanoid)
                if AUTO_RIDE then autoRide() end
                eaten += 1
            end
        end

        -- ขี่ Golden Lion
        if eaten >= TO_EAT then
            local golden = findNearestAnimal(GOLDEN_ANIMAL, root)
            if golden then
                moveTo(humanoid, root, golden.HumanoidRootPart.Position)
                jump(humanoid)
                if AUTO_RIDE then autoRide() end
            end
        end

        -- Auto Avoid
        if AUTO_AVOID then
            root.CFrame = root.CFrame * CFrame.new(0,0,0.5) * CFrame.Angles(0, math.rad(math.random(-20,20)),0)
        end
    end
end)
