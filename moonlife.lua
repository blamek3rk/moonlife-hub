    local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
    local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

    -- Create Window
    local Window = Starlight:CreateWindow({
        Name = "Moonlife",
        Subtitle = "v1.0",
        Icon = 118696459653898,

        InterfaceAdvertisingPrompts = false,

        LoadingSettings = {
            Title = "My Script Hub",
            Subtitle = "Welcome to My Script Hub",
        },

        FileSettings = {
            ConfigFolder = "MyScript",
        },
    })

    -- Create Tab Section
    local TabSection = Window:CreateTabSection("Main")

    -- TAB 1: Home
    local HomeTab = TabSection:CreateTab({
        Name = "Home",
        Icon = NebulaIcons:GetIcon("home", "Material"),
        Columns = 2,
    }, "TAB_HOME")

    local HomeGroupbox = HomeTab:CreateGroupbox({
        Name = "Main Features",
        Icon = NebulaIcons:GetIcon("star", "Material"),
        Column = 1,
    }, "GB_HOME_MAIN")

    -- TAB 2: Scripts
    local ScriptsTab = TabSection:CreateTab({
        Name = "Scripts",
        Icon = NebulaIcons:GetIcon("code", "Material"),
        Columns = 2,
    }, "TAB_SCRIPTS")

    local ScriptsGroupbox = ScriptsTab:CreateGroupbox({
        Name = "Script Options",
        Icon = NebulaIcons:GetIcon("tune", "Material"),
        Column = 1,
    }, "GB_SCRIPTS_MAIN")

    local fastClickerToggle = false
    local fastClickerConnection
    local buildStrengthToggle = false
    local buildStrengthConnection

    ScriptsGroupbox:CreateButton({
        Name = "Fast Clicker",
        Callback = function()
            fastClickerToggle = not fastClickerToggle
            local player = game.Players.LocalPlayer
            
            if fastClickerToggle then
                -- Start rapid clicking
                fastClickerConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not fastClickerToggle then return end
                    
                    if player:FindFirstChild("Setting") then
                        local isAutoClick = player.Setting:FindFirstChild("isAutoClick")
                        if isAutoClick then
                            isAutoClick.Value = 1
                        end
                    end
                    
                    -- Fire clicks rapidly
                    if game.ReplicatedStorage:FindFirstChild("Msg") then
                        local Click = game.ReplicatedStorage.Msg:FindFirstChild("Click")
                        local LocalClick = game.ReplicatedStorage:FindFirstChild("LocalMsg") and game.ReplicatedStorage.LocalMsg:FindFirstChild("Click")
                        if Click then
                            Click:FireServer()
                        end
                        if LocalClick then
                            LocalClick:Fire()
                        end
                    end
                end)
                print("Fast Clicker: ENABLED")
            else
                -- Stop clicking
                if fastClickerConnection then
                    fastClickerConnection:Disconnect()
                end
                if player:FindFirstChild("Setting") then
                    local isAutoClick = player.Setting:FindFirstChild("isAutoClick")
                    if isAutoClick then
                        isAutoClick.Value = 0
                    end
                end
                print("Fast Clicker: DISABLED")
            end
        end
    }, "BTN_FAST_CLICKER")

    ScriptsGroupbox:CreateButton({
        Name = "Auto Build Strength (Equip Max Weight)",
        Callback = function()
            buildStrengthToggle = not buildStrengthToggle
            local player = game.Players.LocalPlayer
            
            if buildStrengthToggle then
                print("Building strength... equipping lightest weight first")
                local equipment = player:FindFirstChild("TrainEquipment")
                if equipment then
                    equipment.Value = 0  -- Start with 1LB
                end
                
                buildStrengthConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not buildStrengthToggle then return end
                    
                    -- Auto click to build strength
                    if game.ReplicatedStorage:FindFirstChild("Msg") then
                        local Click = game.ReplicatedStorage.Msg:FindFirstChild("Click")
                        local LocalClick = game.ReplicatedStorage:FindFirstChild("LocalMsg") and game.ReplicatedStorage.LocalMsg:FindFirstChild("Click")
                        if Click then
                            Click:FireServer()
                        end
                        if LocalClick then
                            LocalClick:Fire()
                        end
                    end
                    
                    -- Check if we can equip heavier weights
                    local equipment = player:FindFirstChild("TrainEquipment")
                    if equipment and equipment.Value < 5 then
                        -- Try to upgrade weight every 100 frames
                        if math.random(1, 100) == 1 then
                            equipment.Value = equipment.Value + 1
                            print("Upgraded to weight level: " .. equipment.Value)
                        end
                    elseif equipment and equipment.Value < 5 then
                        -- Try to equip 100LB
                        equipment.Value = 5
                        buildStrengthToggle = false
                        if buildStrengthConnection then
                            buildStrengthConnection:Disconnect()
                        end
                        print("Equipped max weight (100LB)!")
                    end
                end)
            else
                -- Stop building strength
                if buildStrengthConnection then
                    buildStrengthConnection:Disconnect()
                end
                print("Stopped building strength")
            end
        end
    }, "BTN_BUILD_STRENGTH")

    -- TAB 3: Visuals
    local VisualsTab = TabSection:CreateTab({
        Name = "Visuals",
        Icon = NebulaIcons:GetIcon("visibility", "Material"),
        Columns = 2,
    }, "TAB_VISUALS")

    local VisualsGroupbox = VisualsTab:CreateGroupbox({
        Name = "Visual Settings",
        Icon = NebulaIcons:GetIcon("palette", "Material"),
        Column = 1,
    }, "GB_VISUALS_MAIN")

    -- TAB 4: Settings
    local SettingsTab = TabSection:CreateTab({
        Name = "Settings",
        Icon = NebulaIcons:GetIcon("settings", "Material"),
        Columns = 2,
    }, "TAB_SETTINGS")

    local SettingsGroupbox = SettingsTab:CreateGroupbox({
        Name = "Configuration",
        Icon = NebulaIcons:GetIcon("build", "Material"),
        Column = 1,
    }, "GB_SETTINGS_MAIN")

    -- TAB 5: Misc
    local MiscTab = TabSection:CreateTab({
        Name = "Misc",
        Icon = NebulaIcons:GetIcon("extension", "Material"),
        Columns = 2,
    }, "TAB_MISC")

    local MiscGroupbox = MiscTab:CreateGroupbox({
        Name = "Utilities",
        Icon = NebulaIcons:GetIcon("bolt", "Material"),
        Column = 1,
    }, "GB_MISC_MAIN")
