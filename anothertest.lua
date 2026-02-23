local Library = loadstring(game:HttpGet("LIEN_DE_TA_LIB"))()

local Window = Library:CreateWindow("Mon Script")

local tab1 = Window:AddTab("Farm")
local tab2 = Window:AddTab("Visuel")

tab1:AddLabel("== Auto Farm ==")
tab1:AddSeparator("Paramètres")

local speedSlider = tab1:AddSlider("Vitesse", "Vitesse du véhicule", 100, 1000, 300, function(value)
    getfenv().speed = value
end)

tab1:AddToggle("Auto Farm", "Active le farm automatique", false, function(state)
    -- ton code ici
end)

tab1:AddDropdown("Mode", {"Normal", "Rapide", "Turbo"}, function(option)
    print("Mode sélectionné : " .. option)
end)

tab2:AddToggle("Black Screen", "Écran noir", false, function(state)
    -- ton code ici
end)