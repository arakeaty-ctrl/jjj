
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

-- ตั้งค่า 
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

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RaiseAnimalsGUI"
gui.Parent = game.CoreGui

-- โลโก้สิงโต
local lionButton = Instance.new("TextButton", gui)
lionButton.Size = UDim2.new(0,100,0,100)
lionButton.Position = UDim2.new(0,20,0,20)
lionButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
lionButton.Text = "🦁"
lionButton.TextScaled = true
lionButton.TextColor3 = Color3.fromRGB(255,0,0)

-- เมนูหลัก
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0.4,0,0.6,0)
menu.Position = UDim2.new(0.3,0,0.2,0)
menu.BackgroundColor3 = Color3.fromRGB(20,20,20)
menu.Visible = false
menu.Active = true
menu.Draggable = true

-- คำอธิบาย
local desc = Instance.new("TextLabel", menu)
desc.Size = UDim2.fromScale(0.9,0.2)
desc.Position = UDim2.fromScale(0.05,0.05)
desc.TextWrapped = true
desc.TextScaled = true
desc.Text = "เลือกเมนูเพื่อดูคำอธิบาย"
desc.BackgroundColor3 = Color3.fromRGB(30,30,30)
desc.TextColor3 = Color3.new(1,1,1)

-- ฟังก์ชันสร้างปุ่ม
local function createButton(text,posY,description,callback)
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

-- ปุ่มเมนู
createButton("ออโต้ฟาร์ม",0.3,"เปิดระบบฟาร์มอัตโนมัติ\nขี่สิงโต → กิน → รีเซ็ตอัตโนมัติ", function()
    AUTO_FARM = not AUTO_FARM
end)

createButton("ขี่อัตโนมัติ",0.45,"กดขี่สัตว์ให้อัตโนมัติ ไม่ต้องกดเอง", function()
    AUTO_RIDE = not AUTO_RIDE
end)

createButton("หลบสิ่งกีดขวาง",0.6,"หลบต้นไม้ หิน และสัตว์อื่น\nเลี้ยวซ้ายขวาอัตโนมัติ", function()
    AUTO_AVOID = not AUTO_AVOID
end)

-- กดโลโก้เปิด/ปิดเมนู
lionButton.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

--================= ฟังก์ชันหลัก =================
local function getCharacter()
    local char = player.Character
    if not char then return end
    return char, char:FindFirstChild("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function findNearest(name, root)
    local nearest, shortest = nil, SEARCH_DISTANCE
    for _,obj in pairs(workspace:GetChildren()) do
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
    path:ComputeAsync(root.Position,target)
    if path.Status ~= Enum.PathStatus.Success then
        humanoid:MoveTo(target)
        return
    end
    for _,wp in ipairs(path:GetWaypoints()) do
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        humanoid:MoveTo(wp.Position)
        humanoid.MoveToFinished:Wait()
    end
end

local function autoRide()
    for _,p in pairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.ActionText:lower():find("ride") then
            fireproximityprompt(p)
        end
    end
end

local function jump(humanoid)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

--================= Loop หลัก =================
task.spawn(function()
    while task.wait(0.3) do
        if not AUTO_FARM then continue end
        local char, humanoid, root = getCharacter()
        if not humanoid or not root then continue end

        -- กินสิงโตธรรมดา
        local lion = findNearest(LION, root)
        if lion then
            moveTo(humanoid, root, lion.HumanoidRootPart.Position)
            if (root.Position - lion.HumanoidRootPart.Position).Magnitude < JUMP_DISTANCE then
                jump(humanoid)
                eaten += 1
                if AUTO_RIDE then autoRide() end
            end
        end

        -- ถ้าได้ 3 ตัว → ขี่สิงโตทอง
        if eaten >= TO_EAT then
            local goldLion = findNearest(GOLDEN_LION, root)
            if goldLion then
                moveTo(humanoid, root, goldLion.HumanoidRootPart.Position)
                if (root.Position - goldLion.HumanoidRootPart.Position).Magnitude < JUMP_DISTANCE then
                    jump(humanoid)
                    if AUTO_RIDE then autoRide() end
                end
            end
        end

        -- Auto Avoid
        if AUTO_AVOID then
            root.CFrame = root.CFrame * CFrame.new(0,0,0.5) * CFrame.Angles(0, math.rad(math.random(-20,20)),0)
        end
    end
end)
