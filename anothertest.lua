local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zuqothempos/testt/refs/heads/main/Test.lua"))()
local Window = Library:CreateWindow("Midnight Chasers", true) -- true = demande une clé
local tab1 = Window:AddTab("Farm")
tab1:AddToggle("Auto Farm", "Active le farm", false, function(state)
    print(state)
end)



