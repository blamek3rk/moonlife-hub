    local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
    local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

    -- Create Window
    local Window = Starlight:CreateWindow({
        Name = "Moonlife",
        Subtitle = "v1.0",
        Icon = "rbxassetid://118696459653898",

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
