local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ROTATION_SPEED = 80
local TARGET_UI_NAME = "WindUI"
local TARGET_FRAME_NAME = "Main"
local SECOND_UI_NAME = "Window"
local SECOND_FRAME_NAME = "Frame"
local activeGradients = {}
local colorSequences = {
    ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("#DDA0DD")), ColorSequenceKeypoint.new(0.4, Color3.fromHex("#FFB6C1")), ColorSequenceKeypoint.new(1, Color3.fromHex("#FFF8DC"))}),
    ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("#E6E6FA")), ColorSequenceKeypoint.new(0.5, Color3.fromHex("#6495ED")), ColorSequenceKeypoint.new(1, Color3.fromHex("#6A5ACD"))}),
    ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("#AEEEEE")), ColorSequenceKeypoint.new(0.5, Color3.fromHex("#B0C4DE")), ColorSequenceKeypoint.new(1, Color3.fromHex("#F5F5DC"))}),
    ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("#e6bafb")), ColorSequenceKeypoint.new(0.5, Color3.fromHex("#a1a9e1")), ColorSequenceKeypoint.new(1, Color3.fromHex("#8ac9f2"))}),
    ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("#DDA0DD")), ColorSequenceKeypoint.new(0.5, Color3.fromHex("#5F9EA0")), ColorSequenceKeypoint.new(1, Color3.fromHex("#E6E6FA"))}),
}
local function getRandomColorSequence()
    return colorSequences[math.random(1, #colorSequences)]
end

RunService.RenderStepped:Connect(function(dt)
    for i = #activeGradients, 1, -1 do
        local grad = activeGradients[i]
        if grad and grad.Parent then
            grad.Rotation = (grad.Rotation + ROTATION_SPEED * dt) % 360
        else
            table.remove(activeGradients, i)
        end
    end
end)

local function injectMarquee(targetFrame)
    if targetFrame:FindFirstChild("MarqueeStroke") then return end
    local stroke = Instance.new("UIStroke")
    stroke.Name = "MarqueeStroke"
    stroke.Thickness = 2.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Parent = targetFrame
    local gradient = Instance.new("UIGradient")
    gradient.Name = "MarqueeGradient"
    gradient.Color = getRandomColorSequence()
    gradient.Parent = stroke
    table.insert(activeGradients, gradient)
end

task.spawn(function()
    while true do
        local windUI = CoreGui:FindFirstChild(TARGET_UI_NAME) or (game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.PlayerGui:FindFirstChild(TARGET_UI_NAME))
        if windUI then
            local mainFrame = windUI:FindFirstChild(TARGET_FRAME_NAME, true)
            if mainFrame and mainFrame:IsA("Frame") then
                injectMarquee(mainFrame)
            end
            for _, desc in pairs(windUI:GetDescendants()) do
                if desc.Name == "Blur" then continue end
                if desc:IsA("UIStroke") then
                    local grad = desc:FindFirstChildOfClass("UIGradient")
                    if grad and not table.find(activeGradients, grad) then
                        table.insert(activeGradients, grad)
                    end
                end
            end
        end

        local robloxGui = CoreGui:FindFirstChild("RobloxGui")
        if robloxGui then
            local windowFrame = robloxGui:FindFirstChild("WindUI") and robloxGui.WindUI:FindFirstChild(SECOND_UI_NAME) and robloxGui.WindUI[SECOND_UI_NAME]:FindFirstChild(SECOND_FRAME_NAME)
            if windowFrame and windowFrame:IsA("Frame") then
                injectMarquee(windowFrame)
            end
        end

        task.wait(2)
    end
end)
