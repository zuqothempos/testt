local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zuqothempos/testt/refs/heads/main/Test.lua"))()

Library:CreateWindow("Midnight Chasers", true, function(W)

    local tab1 = W:AddTab("Farm")
    tab1:AddLabel("== Auto Farm ==")
    tab1:AddSeparator("Paramètres")
    tab1:AddSlider("Vitesse", "Vitesse du véhicule", 100, 1000, 300, function(value)
        getfenv().speed = value
    end)
    tab1:AddToggle("Auto Farm", "Active le farm", false, function(state)
        -- ton code
    end)

    local tab2 = W:AddTab("Visuel")
    tab2:AddToggle("Black Screen", "Écran noir", false, function(state)
        -- ton code
    end)

end)


