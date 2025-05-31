-- Multi-Executor Compatibility
local Fluent = nil

local function loadFluent()
    local success = nil
    
    -- Try multiple methods to load the UI library
    local methods = {
        function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
        end,
        function()
            return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
        end,
        function()
            return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        end,
        function()
            return loadstring(game:HttpGetAsync("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        end
    }
    
    -- Try each method until one works
    for _, method in ipairs(methods) do
        success, Fluent = pcall(method)
        if success and Fluent then
            break
        end
        wait(0.1) -- Small delay between attempts
    end
    
    if not success or not Fluent then
        warn("Failed to load UI library. Please check your executor compatibility.")
        return false
    end
    
    return true
end

-- Try to load the UI
if not loadFluent() then
    return
end

-- Global variables to track feature states
_G.AutoSellActive = false
_G.AutoSellDelay = 0.1
_G.PlayerESPActive = false
_G.InfiniteJumpActive = false
_G.SpeedValue = 16
_G.JumpPowerValue = 50

-- UI Colors
local Colors = {
    Primary = Color3.fromRGB(33, 150, 243),
    Accent = Color3.fromRGB(255, 0, 86),
    Background = Color3.fromRGB(21, 21, 30),
    Text = Color3.fromRGB(240, 240, 240)
}

-- Create UI Window
local Window = Fluent:CreateWindow({
    Title = "VyenX Hub",
    SubTitle = "by Aham",
    TabWidth = 120,
    Size = UDim2.fromOffset(480, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Notification on load
Fluent:Notify({
    Title = "Script Loaded",
    Content = "VyenX Hub successfully initialized!",
    Duration = 3
})

-- Create tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://10723407389" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Main section
local MainSection = Tabs.Main:AddSection("Features")

MainSection:AddParagraph({
    Title = "VyenX Hub",
    Content = "Script with infinite money features."
})

MainSection:AddParagraph({
    Title = "How to Use Infinite Money",
    Content = "Instructions:\n1. Have a friend or someone in the server\n2. They must be holding a Porcupine, Mole, or Exclusive Pet in their hands\n3. Enable Auto Sell feature\n4. Profit!"
})

-- Function to start auto sell
local function startAutoSell()
    if _G.AutoSellActive then return end
    _G.AutoSellActive = true
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local plr = Players.LocalPlayer
    
    -- Create a new thread for auto selling
    spawn(function()
        while _G.AutoSellActive do
            for _, v in ipairs(Players:GetChildren()) do
                if v == plr then continue end

                if v.Character then
                    local tool = v.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("SellPet_RE"):FireServer(tool)
                    end
                end
            end
            task.wait(_G.AutoSellDelay)
        end
    end)
    
    Fluent:Notify({
        Title = "Auto Sell",
        Content = "Auto Sell enabled!",
        Duration = 3
    })
    
    return function()
        _G.AutoSellActive = false
        Fluent:Notify({
            Title = "Auto Sell",
            Content = "Auto Sell disabled!",
            Duration = 3
        })
    end
end

-- Function to start player ESP
local function startPlayerESP()
    if _G.PlayerESPActive then return end
    _G.PlayerESPActive = true
    
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    
    -- Create ESP folder
    local ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ESPFolder"
    ESPFolder.Parent = game.CoreGui
    
    local function createESP(player)
        if player == LocalPlayer then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "_ESP"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = ESPFolder
        
        local function updateESP()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                highlight.Adornee = player.Character
            end
        end
        
        updateESP()
        player.CharacterAdded:Connect(updateESP)
    end
    
    -- Create ESP for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    -- Create ESP for new players
    Players.PlayerAdded:Connect(createESP)
    
    return function()
        _G.PlayerESPActive = false
        ESPFolder:Destroy()
    end
end

-- Function to enable infinite jump
local function enableInfiniteJump()
    if _G.InfiniteJumpActive then return end
    _G.InfiniteJumpActive = true
    
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local function onJumpRequest()
        if not _G.InfiniteJumpActive then return end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    UserInputService.JumpRequest:Connect(onJumpRequest)
    
    return function()
        _G.InfiniteJumpActive = false
    end
end

-- Auto Sell section
local AutoSellSection = Tabs.Main:AddSection("Auto Sell")

local AutoSellToggle = Tabs.Main:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Description = "Activates automatic selling for infinite money",
    Default = false,
    Callback = function(state)
        if state then
            _G.DisableAutoSell = startAutoSell()
        else
            if _G.DisableAutoSell then
                _G.DisableAutoSell()
                _G.DisableAutoSell = nil
            end
        end
    end
})

local AutoSellDelaySlider = Tabs.Main:AddSlider("AutoSellDelay", {
    Title = "Auto Sell Delay",
    Description = "Adjusts the interval between automatic sales",
    Default = 0.1,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        _G.AutoSellDelay = value
    end
})

-- Player Modifications section
local PlayerSection = Tabs.Player:AddSection("Player Modifications")

local SpeedSlider = Tabs.Player:AddSlider("Speed", {
    Title = "Speed",
    Description = "Adjusts player movement speed",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        _G.SpeedValue = value
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

local JumpPowerSlider = Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjusts player jump power",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        _G.JumpPowerValue = value
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end
})

local InfiniteJumpToggle = Tabs.Player:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Description = "Enables infinite jumping",
    Default = false,
    Callback = function(state)
        if state then
            _G.DisableInfiniteJump = enableInfiniteJump()
        else
            if _G.DisableInfiniteJump then
                _G.DisableInfiniteJump()
                _G.DisableInfiniteJump = nil
            end
        end
    end
})

-- Visual section
local VisualSection = Tabs.Visual:AddSection("ESP")

local PlayerESPToggle = Tabs.Visual:AddToggle("PlayerESP", {
    Title = "Player ESP",
    Description = "Shows players through walls",
    Default = false,
    Callback = function(state)
        if state then
            _G.DisablePlayerESP = startPlayerESP()
        else
            if _G.DisablePlayerESP then
                _G.DisablePlayerESP()
                _G.DisablePlayerESP = nil
            end
        end
    end
})

-- Game Info section
local InfoSection = Tabs.Main:AddSection("Game Information")

local GameInfoParagraph = InfoSection:AddParagraph({
    Title = "Status",
    Content = "Loading information..."
})

-- Update game info periodically
spawn(function()
    while wait(1) do
        local playerCount = #game:GetService("Players"):GetPlayers()
        local time = os.date("%H:%M:%S")
        
        if GameInfoParagraph and GameInfoParagraph.SetDesc then
            pcall(function()
                GameInfoParagraph:SetDesc(string.format(
                    "Players: %d\nTime: %s",
                    playerCount, time
                ))
            end)
        end
    end
end)

-- Auto-apply player modifications when character spawns
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5) -- Wait for character to fully load
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = _G.SpeedValue
    humanoid.JumpPower = _G.JumpPowerValue
end)

-- Settings section for credits
local CreditsSection = Tabs.Settings:AddSection("Credits")

CreditsSection:AddParagraph({
    Title = "Credits",
    Content = "Script made by Aham"
}) 
