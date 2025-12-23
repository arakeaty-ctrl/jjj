
    --==================================================
-- KUN AUTO LION FARM FULL SCRIPT
-- GUI + AUTO FARM + AUTO RIDE + AUTO AVOID (ตรวจจับสิ่งกีดขวาง)
--==================================================

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

--================= ตั้งค่า =================
local LION = "Lion"
local GOLDEN_LION = "Golden Lion"

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

--================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "KUN_MENU"
gui.Parent = game.CoreGui

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromScale(0.18,0.08)
openBtn.Position = UDim2.fromScale(0.02,0.45)
openBtn.Text = "🦁 KUN"
openBtn.TextScaled = true
openBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
openBtn.TextColor3 = Color3.new(1,1,1)

local menu = Instance.new("Frame", gui)
menu.Size = UDim2.fromScale(0.6,0.6)
menu.Position = UDim2.fromScale(0.2,0.2)
menu.BackgroundColor3 = Color3.fromRGB(20,20,20)
menu.Visible = false
menu.Active = true
menu.Draggable = true

local profile = Instance.new("Frame", menu)
profile.Size = UDim2.fromScale(0.25,0.3)
profile.Position = UDim2.fromScale(0.05,0.05)
profile.BackgroundColor3 = Color3.new(0,0,0)

local profileText = Instance.new("TextLabel", profile)
profileText.Size = UDim2.fromScale(1,1)
profileText.Text = "🦁 KUN"
profileText.TextScaled = true
profileText.TextColor3 = Color3.fromRGB(200,0,0)
profileText.BackgroundTransparency = 1

local desc = Instance.new("TextLabel", menu)
desc.Size = UDim2.fromScale(0.6,0.3)
desc.Position = UDim2.fromScale(0.35,0.05)
desc.TextWrapped = true
desc.TextScaled = true
desc.Text = "เลือกเมนูเพื่อดูคำอธิบาย"
desc.BackgroundColor3 = Color3.fromRGB(30,30,30)
desc.TextColor3 = Color3.new(1,1,1)

-- ฟังก์ชันสร้างปุ่ม
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

-- ปุ่มเปิด/ปิดแต่ละฟังก์ชัน
createButton("AUTO FARM", 0.4, "เปิดระบบอัตโนมัติทั้งหมด\nขี่สิงโต → กิน → อัปเกรด → รีเซ็ต", function()
    AUTO_FARM = not AUTO_FARM
end)

createButton("AUTO RIDE", 0.7, "กดขี่สัตว์ให้อัตโนมัติ", function()
    AUTO_RIDE = not AUTO_RIDE
end)

createButton("AUTO AVOID", 0.8, "หลบต้นไม้ หิน และสัตว์อื่น\nเลี้ยวซ้ายขวาอัตโนมัติ", function()
    AUTO_AVOID = not AUTO_AVOID
end)

openBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

--================= ฟังก์ชัน =================

-- ดึงตัวละคร
local function getCharacter()
    local char = player.Character
    if not char then return end
    return char, char:FindFirstChild("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

-- หาเป้าหมายใกล้สุด
local function findNearest(name, root)
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

-- เดินด้วย Pathfinding
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

-- ฟังก์ชัน Auto Ride
local function autoRide()
    for _, p in pairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.ActionText:lower():find("ride") then
            fireproximityprompt(p)
        end
    end
end

-- ฟังก์ชันกระโดด
local function jump(humanoid)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

-- ฟังก์ชันตรวจจับสิ่งกีดขวาง
local function ตรวจจับสิ่งกีดขวาง(root, ระยะ)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {root.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local rayResult = workspace:Raycast(root.Position, root.CFrame.LookVector * ระยะ, rayParams)
    if rayResult then
        return true, rayResult.Instance
    end
    return false, nil
end

-- ฟังก์ชันหลบสิ่งกีดขวาง
local function หลบสิ่งกีดขวาง(root)
    local มุม = math.random(30,60)
    local เลี้ยวซ้าย = math.random(0,1) == 0
    if เลี้ยวซ้าย then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(-มุม), 0)
    else
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(มุม), 0)
    end
end

--================= MAIN LOOP =================
task.spawn(function()
    while task.wait(0.3) do
        local char, humanoid, root = getCharacter()
        if not humanoid or not root then continue end

        -- AUTO FARM
        if AUTO_FARM then
            local lion = findNearest(LION, root)
            if lion then
                moveTo(humanoid, root, lion.HumanoidRootPart.Position)
                if (root.Position - lion.HumanoidRootPart.Position).Magnitude < JUMP_DISTANCE then
                    jump(humanoid)
                    if AUTO_RIDE then autoRide() end
                end
            end
        end

        -- AUTO AVOID
        if AUTO_AVOID then
            local พบ = ตรวจจับสิ่งกีดขวาง(root, 10)
            if พบ then
                หลบสิ่งกีดขวาง(root)
            end
        end
    end
end)
