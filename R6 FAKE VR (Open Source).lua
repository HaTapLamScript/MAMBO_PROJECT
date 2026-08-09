-- [MAMBO PROJECT] R6 FAKE VR

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalizationService = game:GetService("LocalizationService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer

-- Tính toán scale và circleSize sớm để dùng cho reset
local viewportSize = Camera.ViewportSize
local scale = math.min(viewportSize.Y / 1080, 1.2)
local circleSize = math.floor(150 * scale)

local guiParent
pcall(function()
    if gethui then guiParent = gethui()
    elseif cloneref then guiParent = cloneref(CoreGui)
    else guiParent = player:WaitForChild("PlayerGui")
    end
end)

local locale = LocalizationService.RobloxLocaleId:lower()
local isViet = string.find(locale, "vi") ~= nil
local Lang = {
    WaitMsg = isViet and "Đợi chút!" or "Wait!",
    R15Error = isViet and "Script này chỉ dành cho R6!" or "This script is only for r6!",
    Loading = isViet and "Đang tải..." or "Loading..."
}

local function notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "[MAMBO PROJECT]",
            Text = text,
            Duration = duration or 3
        })
    end)
end

notify(Lang.WaitMsg, 2)
task.wait(2)

local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

if humanoid.RigType == Enum.HumanoidRigType.R15 then
    notify(Lang.R15Error, 5)
    return
end

notify(Lang.Loading, 3)
task.wait(3)

for _, v in pairs(guiParent:GetChildren()) do
    if v.Name == "MamboProjectGUI" or v.Name == "CircleButtonsGUI" then
        v:Destroy()
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MamboProjectGUI"
screenGui.Parent = guiParent
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function playSound(pitch, soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId or "rbxassetid://2865227271"
    sound.Volume = 0.8
    sound.PlaybackSpeed = pitch or 1
    sound.Parent = screenGui
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

-- === INTRO UI ===
local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(0, 400, 0, 100)
introFrame.Position = UDim2.new(0.5, -200, 0.5, -50)
introFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
introFrame.BackgroundTransparency = 0.4
introFrame.BorderSizePixel = 0
introFrame.Parent = screenGui

local introCorner = Instance.new("UICorner")
introCorner.CornerRadius = UDim.new(0, 6)
introCorner.Parent = introFrame

local introStroke = Instance.new("UIStroke")
introStroke.Color = Color3.fromRGB(0, 255, 0)
introStroke.Thickness = 1.5
introStroke.Parent = introFrame

RunService.RenderStepped:Connect(function()
    if introStroke.Parent then
        introStroke.Transparency = (math.sin(tick() * 5) + 1) / 3
    end
end)

local introTitle = Instance.new("TextLabel")
introTitle.Text = "[MAMBO PROJECT]"
introTitle.Font = Enum.Font.Code
introTitle.TextSize = 28
introTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
introTitle.Position = UDim2.new(0.5, 0, 0.35, 0)
introTitle.AnchorPoint = Vector2.new(0.5, 0.5)
introTitle.BackgroundTransparency = 1
introTitle.Parent = introFrame

local introSub = Instance.new("TextLabel")
introSub.Font = Enum.Font.Code
introSub.TextSize = 22
introSub.TextColor3 = Color3.fromRGB(255, 255, 255)
introSub.Position = UDim2.new(0.5, 0, 0.7, 0)
introSub.AnchorPoint = Vector2.new(0.5, 0.5)
introSub.BackgroundTransparency = 1
introSub.RichText = true
introSub.Text = '<font color="#00FF00">R6 FAKE VR</font>  <font color="#FF0000">FE</font>'
introSub.Parent = introFrame

TweenService:Create(introFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
playSound(1)
task.wait(2.5)

local mainSize = UDim2.new(0, 200, 0, 34)
local mainPos = UDim2.new(0.5, -100, 0.1, 0)
TweenService:Create(introFrame, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {
    Position = mainPos,
    Size = mainSize
}):Play()
playSound(1.2)
task.wait(0.6)

introFrame.Name = "MainFrame"
local mainFrame = introFrame
introTitle:Destroy()
introSub:Destroy()

-- === DRAG DOT NGOÀI ===
local dragDot = Instance.new("TextButton")
dragDot.Size = UDim2.new(0, 14, 0, 14)
dragDot.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 4, 0, mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y/2 - 7)
dragDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
dragDot.Text = ""
dragDot.Parent = screenGui
dragDot.ZIndex = 10
Instance.new("UICorner", dragDot).CornerRadius = UDim.new(1, 0)

dragDot.MouseEnter:Connect(function()
    TweenService:Create(dragDot, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 255, 100)}):Play()
end)
dragDot.MouseLeave:Connect(function()
    TweenService:Create(dragDot, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 0)}):Play()
end)

-- === MAIN MENU LAYOUT ===
local buttonY = 5
local buttonSize = 24

local function createButton(parent, width, xPos, bgColor, text, textColor, fontSize)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width, 0, buttonSize)
    btn.Position = UDim2.new(0, xPos, 0, buttonY)
    btn.BackgroundColor3 = bgColor
    btn.Text = text
    btn.TextColor3 = textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = fontSize
    btn.Parent = parent
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 4)
    return btn
end

local function addSyncIcon(btn, symbol)
    local rect1 = Instance.new("Frame", btn)
    rect1.Size = UDim2.new(0, 5, 0, 10)
    rect1.Position = UDim2.new(0, 4, 0.5, -5)
    rect1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rect1.BorderSizePixel = 0

    local rect2 = Instance.new("Frame", btn)
    rect2.Size = UDim2.new(0, 5, 0, 10)
    rect2.Position = UDim2.new(0, 11, 0.5, -5)
    rect2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rect2.BorderSizePixel = 0

    local sym = Instance.new("TextLabel", btn)
    sym.Size = UDim2.new(0, 12, 1, 0)
    sym.Position = UDim2.new(0, 18, 0, 0)
    sym.BackgroundTransparency = 1
    sym.Text = symbol
    sym.TextColor3 = Color3.fromRGB(255, 255, 255)
    sym.Font = Enum.Font.GothamBold
    sym.TextSize = 10
end

local sync1Btn = createButton(mainFrame, 36, 5, Color3.fromRGB(60, 60, 60), "", Color3.fromRGB(255, 255, 255), 14)
addSyncIcon(sync1Btn, "\\/")

local sync2Btn = createButton(mainFrame, 36, 45, Color3.fromRGB(60, 60, 60), "", Color3.fromRGB(255, 255, 255), 14)
addSyncIcon(sync2Btn, "//")

local resetBtn = createButton(mainFrame, 40, 85, Color3.fromRGB(60, 60, 60), "Reset", Color3.fromRGB(255, 255, 255), 11)

local killBtn = createButton(mainFrame, 24, 129, Color3.fromRGB(40, 40, 10), "!", Color3.fromRGB(255, 255, 0), 14)
local killConfirmActive = false

local function resetKillButton()
    if not killBtn or not killBtn.Parent then return end
    killConfirmActive = false
    killBtn.Text = "!"
    killBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
    killBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 10)
end

local function activateKillConfirm()
    killConfirmActive = true
    killBtn.Text = "X"
    killBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    killBtn.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
    task.delay(5, function()
        if killConfirmActive then resetKillButton() end
    end)
end

local function fullCleanup()
    pcall(function() RunService:UnbindFromRenderStep("CircleUpdate") end)
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
    if guiParent then
        local circleGui = guiParent:FindFirstChild("CircleButtonsGUI")
        if circleGui then circleGui:Destroy() end
    end
end

killBtn.MouseButton1Click:Connect(function()
    if killConfirmActive then
        fullCleanup()
    else
        activateKillConfirm()
    end
end)

local collapseBtn = createButton(mainFrame, 24, 157, Color3.fromRGB(30, 30, 30), ">", Color3.fromRGB(0, 255, 0), 16)

local function updateDragDotPosition()
    local absPos = mainFrame.AbsolutePosition
    local absSize = mainFrame.AbsoluteSize
    dragDot.Position = UDim2.new(0, absPos.X + absSize.X + 4, 0, absPos.Y + absSize.Y/2 - 7)
end

mainFrame.Changed:Connect(function(prop)
    if prop == "AbsolutePosition" or prop == "AbsoluteSize" then
        updateDragDotPosition()
    end
end)
updateDragDotPosition()

local draggingMain, dragTouch, dragOffset = false, nil, Vector2.new()
dragDot.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMain = true
        dragTouch = input
        dragOffset = Vector2.new(input.Position.X - mainFrame.AbsolutePosition.X, input.Position.Y - mainFrame.AbsolutePosition.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMain and (input == dragTouch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local newX = math.round(input.Position.X - dragOffset.X)
        local newY = math.round(input.Position.Y - dragOffset.Y)
        mainFrame.Position = UDim2.new(0, newX, 0, newY)
        updateDragDotPosition()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == dragTouch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMain = false
        dragTouch = nil
    end
end)

local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        sync1Btn.Visible = false; sync2Btn.Visible = false; resetBtn.Visible = false; killBtn.Visible = false
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 34, 0, 34)}):Play()
        collapseBtn.Position = UDim2.new(0, 5, 0, buttonY)
        collapseBtn.Text = "<"
    else
        sync1Btn.Visible = true; sync2Btn.Visible = true; resetBtn.Visible = true; killBtn.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = mainSize}):Play()
        collapseBtn.Position = UDim2.new(0, 157, 0, buttonY)
        collapseBtn.Text = ">"
    end
    task.delay(0.5, updateDragDotPosition)
end)

local syncMode = 0

local function updateSyncColors()
    sync1Btn.BackgroundColor3 = (syncMode == 1) and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    sync2Btn.BackgroundColor3 = (syncMode == 2) and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
end

-- === DRAG CIRCLES (VR ARMS) ===
local circleGui = Instance.new("ScreenGui", guiParent)
circleGui.Name = "CircleButtonsGUI"
circleGui.ResetOnSpawn = false
local armAngles = { left = { pitch = 0, roll = 0 }, right = { pitch = 0, roll = 0 } }
local leftBtnFrame, rightBtnFrame

local function calculatePitch(posY)
    local centerY = 0.7
    return (posY <= centerY) and (((centerY - posY) / (centerY - 0.03)) * 180) or (-((posY - centerY) / (0.97 - centerY)) * 60)
end

local function updateArmAngles(side, posX, posY)
    local normX = (side == "left") and math.clamp((posX - 0.03) / 0.44, 0, 1) or math.clamp((posX - 0.53) / 0.44, 0, 1)
    if side == "left" then
        armAngles.left.roll = math.floor((1 - normX) * (-90) + normX * 60 + 0.5)
        armAngles.left.pitch = math.floor(calculatePitch(posY) + 0.5)
    else
        armAngles.right.roll = math.floor((1 - normX) * (-60) + normX * 90 + 0.5)
        armAngles.right.pitch = math.floor(calculatePitch(posY) + 0.5)
    end
end

local function syncOtherSide(side, posX, posY)
    if syncMode == 0 then return end
    local otherFrame = (side == "left") and rightBtnFrame or leftBtnFrame
    if not otherFrame then return end
    
    local normX = (side == "left") and math.clamp((posX - 0.03) / 0.44, 0, 1) or math.clamp((posX - 0.53) / 0.44, 0, 1)
    local newX
    
    if syncMode == 1 then
        if side == "left" then newX = 0.97 - normX * 0.44 else newX = 0.47 - normX * 0.44 end
    elseif syncMode == 2 then
        if side == "left" then newX = 0.53 + normX * 0.44 else newX = 0.03 + normX * 0.44 end
    end
    
    otherFrame.Position = UDim2.new(newX, 0, posY, -math.floor(circleSize/2))
    updateArmAngles((side == "left") and "right" or "left", newX, posY)
end

local function createDraggableCircle(posX, posY, text, side)
    local frame = Instance.new("Frame", circleGui)
    frame.Size = UDim2.new(0, circleSize, 0, circleSize)
    frame.Position = UDim2.new(posX, 0, posY, -math.floor(circleSize/2))
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 255, 0)
    stroke.Thickness = math.max(3, math.floor(4 * scale))

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1
    btn.Text = text; btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = math.floor(48 * scale)

    local isDragging, isDraggingActive, activeTouch = false, false, nil
    local dragStartPos, frameStartPos = Vector2.new(), UDim2.new()
    updateArmAngles(side, posX, posY)

    btn.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not isDragging then
            isDragging = true; isDraggingActive = false; activeTouch = input
            dragStartPos = input.Position; frameStartPos = frame.Position
            frame.BackgroundTransparency = 0.1; frame.Size = UDim2.new(0, math.floor(circleSize * 1.1), 0, math.floor(circleSize * 1.1))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input == activeTouch then
            if not isDraggingActive and (input.Position - dragStartPos).Magnitude >= 20 then isDraggingActive = true end
            if isDraggingActive then
                local delta = input.Position - dragStartPos
                local newX = frameStartPos.X.Scale + (delta.X / circleGui.AbsoluteSize.X)
                local newY = math.clamp(frameStartPos.Y.Scale + (delta.Y / circleGui.AbsoluteSize.Y), 0.03, 0.97)
                newX = (side == "left") and math.clamp(newX, 0.03, 0.47) or math.clamp(newX, 0.53, 0.97)
                frame.Position = UDim2.new(newX, 0, newY, -math.floor(circleSize/2))
                updateArmAngles(side, newX, newY)
                syncOtherSide(side, newX, newY)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == activeTouch then
            isDragging = false; isDraggingActive = false; activeTouch = nil
            frame.BackgroundTransparency = 0.25; frame.Size = UDim2.new(0, circleSize, 0, circleSize)
        end
    end)

    if side == "left" then leftBtnFrame = frame else rightBtnFrame = frame end
end

createDraggableCircle(0.294, 0.7, "L", "left")
createDraggableCircle(0.706, 0.7, "R", "right")

-- Hàm reset vị trí hai nút (đã có circleSize)
local function resetArmPositions()
    if leftBtnFrame then
        leftBtnFrame.Position = UDim2.new(0.294, 0, 0.7, -math.floor(circleSize/2))
        updateArmAngles("left", 0.294, 0.7)
    end
    if rightBtnFrame then
        rightBtnFrame.Position = UDim2.new(0.706, 0, 0.7, -math.floor(circleSize/2))
        updateArmAngles("right", 0.706, 0.7)
    end
end

-- Gán sự kiện cho các nút sync và reset
sync1Btn.MouseButton1Click:Connect(function()
    if syncMode == 1 then syncMode = 0 else syncMode = 1 end
    updateSyncColors()
    resetArmPositions()
end)

sync2Btn.MouseButton1Click:Connect(function()
    if syncMode == 2 then syncMode = 0 else syncMode = 2 end
    updateSyncColors()
    resetArmPositions()
end)

resetBtn.MouseButton1Click:Connect(function()
    resetArmPositions()
end)

-- === CHARACTER RIGGING ===
local torso, leftArm, rightArm, L_Att0, L_Att1, R_Att0, R_Att1, isArmed = nil, nil, nil, nil, nil, nil, nil, false
local partsToShow = {}

local function setupNetlessLimb(torsoPart, limb, side)
    local motorName = (side == "left") and "Left Shoulder" or "Right Shoulder"
    if torsoPart:FindFirstChild(motorName) then torsoPart[motorName]:Destroy() end
    for _, obj in ipairs(limb:GetChildren()) do if obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") then obj:Destroy() end end
    local offsetX = (torsoPart.Size.X / 2) + (limb.Size.X / 2)
    local att0 = Instance.new("Attachment", torsoPart); att0.Position = Vector3.new((side == "left") and -offsetX or offsetX, 0.5, 0)
    local att1 = Instance.new("Attachment", limb); att1.Position = Vector3.new(0, 0.5, 0)
    
    local ap = Instance.new("AlignPosition", limb); ap.Attachment0 = att1; ap.Attachment1 = att0; ap.RigidityEnabled = true
    local ao = Instance.new("AlignOrientation", limb); ao.Attachment0 = att1; ao.Attachment1 = att0; ao.RigidityEnabled = true
    limb.Massless = true; limb.CanCollide = false
    return att0, att1
end

local function armCharacter(c)
    partsToShow = {}
    if c:FindFirstChild("Torso") then
        for _, n in ipairs({"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
            if c:FindFirstChild(n) then table.insert(partsToShow, c[n]) end
        end
        torso = c.Torso; leftArm = c:WaitForChild("Left Arm"); rightArm = c:WaitForChild("Right Arm")
        L_Att0, L_Att1 = setupNetlessLimb(torso, leftArm, "left")
        R_Att0, R_Att1 = setupNetlessLimb(torso, rightArm, "right")
        isArmed = true
    else
        isArmed = false
    end
end

local function disarmCharacter()
    for _, obj in ipairs({L_Att0, L_Att1, R_Att0, R_Att1}) do if obj then obj:Destroy() end end
    L_Att0, L_Att1, R_Att0, R_Att1, torso, leftArm, rightArm, isArmed = nil, nil, nil, nil, nil, nil, nil, false
end

armCharacter(char)

RunService.Heartbeat:Connect(function()
    if leftArm and rightArm then leftArm.AssemblyLinearVelocity = Vector3.new(0, -25.05, 0); rightArm.AssemblyLinearVelocity = Vector3.new(0, -25.05, 0) end
end)

RunService:BindToRenderStep("CircleUpdate", Enum.RenderPriority.Camera.Value + 1, function()
    if not isArmed or not torso or not torso.Parent then return end
    if L_Att0 then L_Att0.CFrame = CFrame.new(L_Att0.Position) * CFrame.Angles(math.rad(armAngles.left.pitch), 0, math.rad(armAngles.left.roll)) * CFrame.Angles(0, -math.pi/2, 0) end
    if R_Att0 then R_Att0.CFrame = CFrame.new(R_Att0.Position) * CFrame.Angles(math.rad(armAngles.right.pitch), 0, math.rad(armAngles.right.roll)) * CFrame.Angles(0, math.pi/2, 0) end
    for _, part in ipairs(partsToShow) do
        if part and part.Parent then pcall(function() part.LocalTransparencyModifier = 0 end); part.Transparency = 0 end
    end
end)

local function onDied() disarmCharacter() end
humanoid.Died:Connect(onDied)

player.CharacterAdded:Connect(function(newChar)
    char = newChar; humanoid = char:WaitForChild("Humanoid")
    disarmCharacter(); task.wait(1); armCharacter(char)
    humanoid.Died:Connect(onDied)
end)