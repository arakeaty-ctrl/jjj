repeat wait() until game:IsLoaded() and game:FindFirstChild("CoreGui") and pcall(function() return game.CoreGui end)

getgenv().jinkX = getgenv().jinkX or {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- =======================================
-- ฟังก์ชันตรวจสอบ executor / game
-- =======================================
local _function = {
    block_executor = function()
        local blockedExecutors = {"Syno","Solara","Krnl"}
        if identifyexecutor then
            local current = identifyexecutor():lower()
            for _,name in ipairs(blockedExecutors) do
                if current:find(name) then return true end
            end
        end
        return false
    end,
    getid = function()
        local g = game.GameId
        if getgenv().jinkX and getgenv().jinkX["Fish It"] and getgenv().jinkX["Fish It"]["Enabled"] then
            return "0708c0109bad431c5513f6d2dcc9b9e5"
        end
        if g == 8009328211 then return "bf9e3c7d3db39fba6940d81c8eddedf8" end -- Raise Animal
    end,
    gamename = function()
        local g = game.GameId
        if g == 8009328211 then return "Raise Animal" end
    end
}

local script_id, game_name, block_executor = _function.getid(), _function.gamename(), _function.block_executor()

if block_executor then
    player:Kick("JinkX\nExecutor not supported")
    return
end

if script_id then
    game.StarterGui:SetCore("SendNotification", {
        Title = "JinkX Loaded!",
        Text = (game_name or "Global") .. " script loaded!",
        Icon = "rbxassetid://79605757154544",
        Duration = 5
    })
    local auth_module = loadstring(game:HttpGet("https://raw.githubusercontent.com/PThitipat/master/main/keysystem.lua"))()
    local auth_status = auth_module(script_id)
    repeat task.wait() until auth_status.validated
else
    warn("JinkX: Game not supported")
    return
end

-- =======================================
-- UI + โลโก้สิงโต 🦁
-- =======================================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "JinkX_GUI"

-- ปุ่มเปิด/ปิดเมนู
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromScale(0.15,0.08)
openBtn.Position = UDim2.fromScale(0.02,0.45)
openBtn.Text = "🦁"
openBtn.TextScaled = true
openBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
openBtn.TextColor3 = Color3.new(1,1,1)

local menu = Instance.new("Frame", gui)
menu.Size = UDim2.fromScale(0.5,0.6)
menu.Position = UDim2.fromScale(0.25,0.2)
menu.BackgroundColor3 = Color3.fromRGB(25,25,25)
menu.Visible = false
menu.Active = true
menu.Draggable = true

-- โลโก้ในเมนู
local logo = Instance.new("TextLabel", menu)
logo.Size = UDim2.fromScale(0.3,0.3)
logo.Position = UDim2.fromScale(0.05,0.05)
logo.Text = "🦁 JinkX"
logo.TextScaled = true
logo.TextColor3 = Color3.fromRGB(255,200,0)
logo.BackgroundTransparency = 1

-- กล่องคำอธิบาย
local desc = Instance.new("TextLabel", menu)
desc.Size = UDim2.fromScale(0.6,0.2)
desc.Position = UDim2.fromScale(0.35,0.05)
desc.TextWrapped = true
desc.TextScaled = true
desc.Text = "เลือกเมนูเพื่อดูคำอธิบาย"
desc.BackgroundColor3 = Color3.fromRGB(30,30,30)
desc.TextColor3 = Color3.new(1,1,1)

-- ฟังก์ชันสร้างปุ่ม
local function createButton(text,posY,descText,callback)
    local btn = Instance.new("TextButton", menu)
    btn.Size = UDim2.fromScale(0.9,0.08)
    btn.Position = UDim2.fromScale(0.05,posY)
    btn.Text = text
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        desc.Text = descText
        if callback then callback() end
    end)
end

-- สร้างปุ่ม Auto Farm / Auto Ride / Auto Avoid
local AUTO_FARM, AUTO_RIDE, AUTO_AVOID = false,true,true

createButton("AUTO FARM",0.35,"เปิดระบบอัตโนมัติทั้งหมด",function() AUTO_FARM = not AUTO_FARM end)
createButton("AUTO RIDE",0.55,"กดขี่สัตว์อัตโนมัติ",function() AUTO_RIDE = not AUTO_RIDE end)
createButton("AUTO AVOID",0.75,"หลบสิ่งกีดขวางอัตโนมัติ",function() AUTO_AVOID = not AUTO_AVOID end)

openBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

-- =======================================
-- ตัวอย่าง Loop Auto Farm + Avoid
-- =======================================
local LION = "Lion"
local GOLDEN_LION = "Golden Lion"
local SEARCH_DIST, JUMP_DIST = 150, 12
local PATH_SETTINGS = {AgentRadius=3,AgentHeight=6,AgentCanJump=true,WaypointSpacing=3}

local PathfindingService = game:GetService("PathfindingService")

local function getCharacter()
    local char = player.Character
    if not char then return end
    return char,char:FindFirstChild("Humanoid"),char:FindFirstChild("HumanoidRootPart")
end

local function findNearest(name,root)
    local nearest,shortest = nil,SEARCH_DIST
    for _,obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name==name and obj:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - obj.HumanoidRootPart.Position).Magnitude
            if d<shortest then
                shortest=d
                nearest=obj
            end
        end
    end
    return nearest
end

local function moveTo(humanoid,root,target)
    local path = PathfindingService:CreatePath(PATH_SETTINGS)
    path:ComputeAsync(root.Position,target)
    if path.Status ~= Enum.PathStatus.Success then
        humanoid:MoveTo(target)
        return
    end
    for _,wp in ipairs(path:GetWaypoints()) do
        if wp.Action==Enum.PathWaypointAction.Jump then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
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

task.spawn(function()
    while task.wait(0.3) do
        if not AUTO_FARM then continue end
        local char,humanoid,root = getCharacter()
        if not humanoid or not root then continue end

        local lion = findNearest(LION,root)
        if lion then
            moveTo(humanoid,root,lion.HumanoidRootPart.Position)
            if (root.Position-lion.HumanoidRootPart.Position).Magnitude<JUMP_DIST then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                if AUTO_RIDE then autoRide() end
            end
        end

        if AUTO_AVOID then
            -- ตัวอย่างการหลบแบบ zig-zag
            root.CFrame = root.CFrame * CFrame.new(0,0,0.5) * CFrame.Angles(0,math.rad(math.random(-20,20)),0)
        end
    end
end)
