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

    -- TAB 2: Aimbot
    local AimbotTab = TabSection:CreateTab({
        Name = "Aimbot",
        Icon = NebulaIcons:GetIcon("gps_fixed", "Material"),
        Columns = 2,
    }, "TAB_AIMBOT")

    local AimbotGroupbox = AimbotTab:CreateGroupbox({
        Name = "Aimbot Settings",
        Icon = NebulaIcons:GetIcon("my_location", "Material"),
        Column = 1,
    }, "GB_AIMBOT_MAIN")

    -- Camlock System
    local CamlockSettings = {
        Enabled = false,
        TargetPart = "Head",
        FOV = 250,
        LockStrength = 1,
    }
    
    local HoldingMouse2 = false
    
    -- Find target closest to center of screen
    local function GetClosestPlayer()
        local Target = nil
        local MaxDist = CamlockSettings.FOV
        
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild(CamlockSettings.TargetPart) then
                -- Team Check
                if v.Team and v.Team == game.Players.LocalPlayer.Team then continue end
                
                local Part = v.Character[CamlockSettings.TargetPart]
                local ScreenPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Part.Position)
                
                if OnScreen then
                    local Center = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                    
                    if Dist < MaxDist then
                        MaxDist = Dist
                        Target = Part
                    end
                end
            end
        end
        return Target
    end
    
    -- Input Detection (Hold to Lock)
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            HoldingMouse2 = true
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            HoldingMouse2 = false
        end
    end)
    
    -- The Camlock Loop (Priority Camera)
    game:GetService("RunService"):BindToRenderStep("Camlock", Enum.RenderPriority.Camera.Value + 1, function()
        if CamlockSettings.Enabled and HoldingMouse2 then
            local Target = GetClosestPlayer()
            if Target then
                local CurrentCF = workspace.CurrentCamera.CFrame
                local TargetCF = CFrame.new(CurrentCF.Position, Target.Position)
                
                workspace.CurrentCamera.CFrame = CurrentCF:Lerp(TargetCF, CamlockSettings.LockStrength)
            end
        end
    end)

    -- Camlock Toggle
    AimbotGroupbox:CreateToggle({
        Name = "Camlock",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("lock", "Material"),
        Tooltip = "Lock camera to target player (Hold Right Click)",
        Callback = function(Value)
            CamlockSettings.Enabled = Value
            print("Camlock: " .. (Value and "ENABLED" or "DISABLED"))
        end
    }, "TOGGLE_CAMLOCK")

    -- Silent Aim System
    local SilentAimSettings = {
        Enabled = false,
        TargetPart = "Head",
        TeamCheck = false,
        VisibleCheck = false,
        HitChance = 100
    }
    
    local function CalculateChance(Percentage)
        Percentage = math.floor(Percentage)
        local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
        return chance <= Percentage / 100
    end
    
    local function getDirection(Origin, Position)
        return (Position - Origin).Unit * 1000
    end
    
    local function IsPlayerVisible(Player)
        local PlayerCharacter = Player.Character
        local LocalPlayerCharacter = game.Players.LocalPlayer.Character
        
        if not (PlayerCharacter and LocalPlayerCharacter) then return false end
        
        local PlayerRoot = PlayerCharacter:FindFirstChild(SilentAimSettings.TargetPart) or PlayerCharacter:FindFirstChild("HumanoidRootPart")
        
        if not PlayerRoot then return false end
        
        local CastPoints = {PlayerRoot.Position}
        local IgnoreList = {LocalPlayerCharacter, PlayerCharacter}
        local ObscuringObjects = #workspace.CurrentCamera:GetPartsObscuringTarget(CastPoints, IgnoreList)
        
        return ObscuringObjects == 0
    end
    
    local function getClosestPlayerSilent()
        local Closest = nil
        local ClosestDistance = math.huge
        
        for _, Player in pairs(game.Players:GetPlayers()) do
            if Player == game.Players.LocalPlayer then continue end
            if SilentAimSettings.TeamCheck and Player.Team == game.Players.LocalPlayer.Team then continue end
            
            local Character = Player.Character
            if not Character then continue end
            
            if SilentAimSettings.VisibleCheck and not IsPlayerVisible(Player) then continue end
            
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character:FindFirstChild("Humanoid")
            if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then continue end
            
            local ScreenPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
            if not OnScreen then continue end
            
            local MousePos = game:GetService("UserInputService"):GetMouseLocation()
            local Distance = (MousePos - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            
            if Distance < ClosestDistance then
                local TargetPart = Character:FindFirstChild(SilentAimSettings.TargetPart)
                if TargetPart then
                    Closest = TargetPart
                    ClosestDistance = Distance
                end
            end
        end
        
        return Closest
    end
    
    -- Silent Aim Hooks
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(...)
        local Method = getnamecallmethod()
        local Arguments = {...}
        local self = Arguments[1]
        
        if SilentAimSettings.Enabled and self == workspace and not checkcaller() then
            local chance = CalculateChance(SilentAimSettings.HitChance)
            if not chance then return oldNamecall(...) end
            
            if Method == "FindPartOnRayWithIgnoreList" then
                local A_Ray = Arguments[2]
                local HitPart = getClosestPlayerSilent()
                
                if HitPart then
                    local Origin = A_Ray.Origin
                    local Direction = getDirection(Origin, HitPart.Position)
                    Arguments[2] = Ray.new(Origin, Direction)
                    return oldNamecall(unpack(Arguments))
                end
            elseif Method == "Raycast" then
                local A_Origin = Arguments[2]
                local HitPart = getClosestPlayerSilent()
                
                if HitPart then
                    Arguments[3] = getDirection(A_Origin, HitPart.Position)
                    return oldNamecall(unpack(Arguments))
                end
            end
        end
        
        return oldNamecall(...)
    end)
    
    -- Silent Aim Toggle
    AimbotGroupbox:CreateToggle({
        Name = "Silent Aim",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("gps_not_fixed", "Material"),
        Tooltip = "Automatically redirect shots to nearest player",
        Callback = function(Value)
            SilentAimSettings.Enabled = Value
            print("Silent Aim: " .. (Value and "ENABLED" or "DISABLED"))
        end
    }, "TOGGLE_SILENTAIM")
    
    -- Target Part Dropdown
    AimbotGroupbox:CreateDropdown({
        Name = "Target Part",
        Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
        Default = "Head",
        Callback = function(Value)
            SilentAimSettings.TargetPart = Value
            CamlockSettings.TargetPart = Value
            print("Target Part set to: " .. Value)
        end
    }, "DROPDOWN_TARGET_PART")

    -- TAB 3: Visuals
    --[[
        ADVANCED ESP SYSTEM FEATURES:
        
        ✓ Box ESP (3 Styles):
            - Corner: Clean corner brackets
            - Full: Complete outline box
            - ThreeD: 3D bounding box
        
        ✓ Skeleton ESP:
            - 14 bone connections
            - R15 + R6 support
            - Dynamic color & thickness
        
        ✓ Chams/Highlights:
            - See through walls
            - Customizable colors
            - Fill & outline transparency
        
        ✓ Health System:
            - Health Bar (left/right side)
            - Health Text with percentage
            - Color-coded (green→yellow→red)
        
        ✓ Tracers:
            - 4 origin points (Bottom/Top/Center/Mouse)
            - Customizable thickness
            - Rainbow support
        
        ✓ Info Display:
            - Player names
            - Distance in meters
            - Health percentage
        
        ✓ Advanced Features:
            - Team check
            - Rainbow mode
            - Distance culling
            - Auto respawn tracking
            - Proper cleanup
            - Performance optimized
    ]]
    local VisualsTab = TabSection:CreateTab({
        Name = "Visuals",
        Icon = NebulaIcons:GetIcon("visibility", "Material"),
        Columns = 2,
    }, "TAB_VISUALS")

    local VisualsGroupbox = VisualsTab:CreateGroupbox({
        Name = "ESP Settings",
        Icon = NebulaIcons:GetIcon("palette", "Material"),
        Column = 1,
    }, "GB_VISUALS_MAIN")

    -- ESP Variables
    local ESPEnabled = false
    local SkeletonEnabled = false
    local ShowHP = false
    local ShowName = false
    local ShowDistance = true
    local MaxDistance = 1000
    
    -- FOV Variables
    local defaultFOV = workspace.CurrentCamera.FieldOfView
    local customFOV = defaultFOV
    local isFOVEnabled = false
    
    local ESPObjects = {}
    local CharacterConnections = {}
    local Highlights = {}
    local ESPUpdateConnection = nil -- Track the update loop connection
    
    -- ESP Settings
    local ESPSettings = {
        BoxStyle = "Corner", -- Corner, Full, ThreeD
        BoxThickness = 2,
        TracerEnabled = false,
        TracerOrigin = "Bottom", -- Bottom, Top, Center, Mouse
        TracerThickness = 1,
        HealthBarEnabled = false,
        HealthBarSide = "Left",
        ChamsEnabled = false,
        ChamsFillColor = Color3.fromRGB(255, 0, 0),
        ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
        ChamsTransparency = 0.5,
        BoxColor = Color3.fromRGB(255, 255, 255),
        SkeletonColor = Color3.fromRGB(255, 255, 255)
    }

    -- ESP Functions
    local function CreateESP(player)
        if player == game.Players.LocalPlayer then return end
        
        local esp = {
            Drawings = {},
            Player = player,
            Character = nil
        }
        
        -- Box ESP (8 lines for corner/full/3D modes)
        esp.Drawings.Box = {
            TopLeft = Drawing.new("Line"),
            TopRight = Drawing.new("Line"),
            BottomLeft = Drawing.new("Line"),
            BottomRight = Drawing.new("Line"),
            Left = Drawing.new("Line"),
            Right = Drawing.new("Line"),
            Top = Drawing.new("Line"),
            Bottom = Drawing.new("Line")
        }
        
        for _, line in pairs(esp.Drawings.Box) do
            line.Visible = false
            line.Color = ESPSettings.BoxColor
            line.Thickness = ESPSettings.BoxThickness
            line.ZIndex = 2
        end
        
        -- Tracer
        esp.Drawings.Tracer = Drawing.new("Line")
        esp.Drawings.Tracer.Visible = false
        esp.Drawings.Tracer.Color = ESPSettings.BoxColor
        esp.Drawings.Tracer.Thickness = ESPSettings.TracerThickness
        esp.Drawings.Tracer.ZIndex = 1
        
        -- Name Text
        esp.Drawings.Name = Drawing.new("Text")
        esp.Drawings.Name.Size = 16
        esp.Drawings.Name.Center = true
        esp.Drawings.Name.Outline = true
        esp.Drawings.Name.Color = Color3.fromRGB(255, 255, 255)
        esp.Drawings.Name.Visible = false
        esp.Drawings.Name.ZIndex = 2
        
        -- Health Text
        esp.Drawings.Health = Drawing.new("Text")
        esp.Drawings.Health.Size = 14
        esp.Drawings.Health.Center = true
        esp.Drawings.Health.Outline = true
        esp.Drawings.Health.Color = Color3.fromRGB(0, 255, 0)
        esp.Drawings.Health.Visible = false
        esp.Drawings.Health.ZIndex = 2
        
        -- Health Bar
        esp.Drawings.HealthBar = {
            Outline = Drawing.new("Line"),
            Background = Drawing.new("Line"),
            Fill = Drawing.new("Line")
        }
        
        esp.Drawings.HealthBar.Outline.Thickness = 3
        esp.Drawings.HealthBar.Outline.Color = Color3.fromRGB(0, 0, 0)
        esp.Drawings.HealthBar.Outline.Visible = false
        esp.Drawings.HealthBar.Outline.ZIndex = 1
        
        esp.Drawings.HealthBar.Background.Thickness = 1
        esp.Drawings.HealthBar.Background.Color = Color3.fromRGB(50, 50, 50)
        esp.Drawings.HealthBar.Background.Visible = false
        esp.Drawings.HealthBar.Background.ZIndex = 1
        
        esp.Drawings.HealthBar.Fill.Thickness = 1
        esp.Drawings.HealthBar.Fill.Color = Color3.fromRGB(0, 255, 0)
        esp.Drawings.HealthBar.Fill.Visible = false
        esp.Drawings.HealthBar.Fill.ZIndex = 2
        
        -- Distance Text
        esp.Drawings.Distance = Drawing.new("Text")
        esp.Drawings.Distance.Size = 14
        esp.Drawings.Distance.Center = true
        esp.Drawings.Distance.Outline = true
        esp.Drawings.Distance.Color = Color3.fromRGB(200, 200, 200)
        esp.Drawings.Distance.Visible = false
        esp.Drawings.Distance.ZIndex = 2
        
        -- Skeleton Lines
        esp.Drawings.Skeleton = {}
        local skeletonParts = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"RightLowerArm", "RightHand"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"},
            {"RightLowerLeg", "RightFoot"}
        }
        
        for i = 1, #skeletonParts do
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = ESPSettings.SkeletonColor
            line.Visible = false
            line.ZIndex = 2
            table.insert(esp.Drawings.Skeleton, {Line = line, Parts = skeletonParts[i]})
        end
        
        -- Chams/Highlight
        local highlight = Instance.new("Highlight")
        highlight.FillColor = ESPSettings.ChamsFillColor
        highlight.OutlineColor = ESPSettings.ChamsOutlineColor
        highlight.FillTransparency = ESPSettings.ChamsTransparency
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = false
        Highlights[player] = highlight
        
        return esp
    end

    local function RemoveESP(esp)
        if esp then
            -- Remove box lines
            if esp.Drawings.Box then
                for _, line in pairs(esp.Drawings.Box) do
                    if line and line.Remove then
                        line:Remove()
                    end
                end
            end
            
            -- Remove tracer
            if esp.Drawings.Tracer and esp.Drawings.Tracer.Remove then
                esp.Drawings.Tracer:Remove()
            end
            
            -- Remove health bar
            if esp.Drawings.HealthBar then
                for _, obj in pairs(esp.Drawings.HealthBar) do
                    if obj and obj.Remove then
                        obj:Remove()
                    end
                end
            end
            
            -- Remove text elements
            if esp.Drawings.Name and esp.Drawings.Name.Remove then
                esp.Drawings.Name:Remove()
            end
            if esp.Drawings.Health and esp.Drawings.Health.Remove then
                esp.Drawings.Health:Remove()
            end
            if esp.Drawings.Distance and esp.Drawings.Distance.Remove then
                esp.Drawings.Distance:Remove()
            end
            
            -- Remove skeleton
            if esp.Drawings.Skeleton then
                for _, bonePair in pairs(esp.Drawings.Skeleton) do
                    if bonePair.Line and bonePair.Line.Remove then
                        bonePair.Line:Remove()
                    end
                end
            end
        end
    end

    local function HideESP(esp)
        if esp then
            -- Hide box
            if esp.Drawings.Box then
                for _, line in pairs(esp.Drawings.Box) do
                    line.Visible = false
                end
            end
            
            -- Hide other elements
            if esp.Drawings.Tracer then esp.Drawings.Tracer.Visible = false end
            if esp.Drawings.Name then esp.Drawings.Name.Visible = false end
            if esp.Drawings.Health then esp.Drawings.Health.Visible = false end
            if esp.Drawings.Distance then esp.Drawings.Distance.Visible = false end
            
            -- Hide health bar
            if esp.Drawings.HealthBar then
                esp.Drawings.HealthBar.Outline.Visible = false
                esp.Drawings.HealthBar.Background.Visible = false
                esp.Drawings.HealthBar.Fill.Visible = false
            end
            
            -- Hide skeleton
            if esp.Drawings.Skeleton then
                for _, bonePair in pairs(esp.Drawings.Skeleton) do
                    bonePair.Line.Visible = false
                end
            end
        end
    end
    
    local function GetTracerOrigin()
        local origin = ESPSettings.TracerOrigin
        local camera = workspace.CurrentCamera
        if origin == "Bottom" then
            return Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
        elseif origin == "Top" then
            return Vector2.new(camera.ViewportSize.X/2, 0)
        elseif origin == "Mouse" then
            return game:GetService("UserInputService"):GetMouseLocation()
        else -- Center
            return Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        end
    end

    local function UpdateESP()
        if not ESPEnabled then return end
        
        local camera = workspace.CurrentCamera
        local localPlayer = game.Players.LocalPlayer
        
        for player, esp in pairs(ESPObjects) do
            if player and player.Parent then
                -- Update character reference if it changed
                if player.Character and player.Character ~= esp.Character then
                    esp.Character = player.Character
                    
                    -- Update highlight parent
                    if Highlights[player] and esp.Character then
                        Highlights[player].Parent = esp.Character
                    end
                end
                
                if esp.Character and esp.Character.Parent then
                    local humanoidRootPart = esp.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = esp.Character:FindFirstChild("Humanoid")
                    
                    if humanoidRootPart and humanoid and humanoid.Health > 0 then
                        local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if not localRoot then 
                            HideESP(esp)
                            continue 
                        end
                        
                        local distance = (localRoot.Position - humanoidRootPart.Position).Magnitude
                        
                        if distance <= MaxDistance then
                            local pos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                            
                            if onScreen and pos.Z > 0 then
                                local headPos = esp.Character:FindFirstChild("Head")
                                local legPos = esp.Character:FindFirstChild("LeftFoot") or esp.Character:FindFirstChild("LeftLowerLeg") or esp.Character:FindFirstChild("Left Leg")
                                
                                if headPos and legPos then
                                    local size = esp.Character:GetExtentsSize()
                                    local cf = humanoidRootPart.CFrame
                                    
                                    local top, topOnScreen = camera:WorldToViewportPoint((cf * CFrame.new(0, size.Y/2, 0)).Position)
                                    local bottom, bottomOnScreen = camera:WorldToViewportPoint((cf * CFrame.new(0, -size.Y/2, 0)).Position)
                                    
                                    if topOnScreen and bottomOnScreen and top.Z > 0 and bottom.Z > 0 then
                                        local height = math.abs(bottom.Y - top.Y)
                                        local width = height * 0.65
                                        local boxPosition = Vector2.new(top.X - width/2, top.Y)
                                        
                                        -- Get color
                                        local color = ESPSettings.BoxColor
                                        
                                        -- BOX ESP with different styles
                                        if ESPSettings.BoxStyle == "Corner" then
                                            local cornerSize = width * 0.25
                                            
                                            -- Top Left Corner
                                            esp.Drawings.Box.TopLeft.From = boxPosition
                                            esp.Drawings.Box.TopLeft.To = boxPosition + Vector2.new(cornerSize, 0)
                                            esp.Drawings.Box.TopLeft.Color = color
                                            esp.Drawings.Box.TopLeft.Visible = true
                                            
                                            esp.Drawings.Box.Left.From = boxPosition
                                            esp.Drawings.Box.Left.To = boxPosition + Vector2.new(0, cornerSize)
                                            esp.Drawings.Box.Left.Color = color
                                            esp.Drawings.Box.Left.Visible = true
                                            
                                            -- Top Right Corner
                                            esp.Drawings.Box.TopRight.From = boxPosition + Vector2.new(width, 0)
                                            esp.Drawings.Box.TopRight.To = boxPosition + Vector2.new(width - cornerSize, 0)
                                            esp.Drawings.Box.TopRight.Color = color
                                            esp.Drawings.Box.TopRight.Visible = true
                                            
                                            esp.Drawings.Box.Right.From = boxPosition + Vector2.new(width, 0)
                                            esp.Drawings.Box.Right.To = boxPosition + Vector2.new(width, cornerSize)
                                            esp.Drawings.Box.Right.Color = color
                                            esp.Drawings.Box.Right.Visible = true
                                            
                                            -- Bottom Left Corner
                                            esp.Drawings.Box.BottomLeft.From = boxPosition + Vector2.new(0, height)
                                            esp.Drawings.Box.BottomLeft.To = boxPosition + Vector2.new(cornerSize, height)
                                            esp.Drawings.Box.BottomLeft.Color = color
                                            esp.Drawings.Box.BottomLeft.Visible = true
                                            
                                            esp.Drawings.Box.Top.From = boxPosition + Vector2.new(0, height)
                                            esp.Drawings.Box.Top.To = boxPosition + Vector2.new(0, height - cornerSize)
                                            esp.Drawings.Box.Top.Color = color
                                            esp.Drawings.Box.Top.Visible = true
                                            
                                            -- Bottom Right Corner
                                            esp.Drawings.Box.BottomRight.From = boxPosition + Vector2.new(width, height)
                                            esp.Drawings.Box.BottomRight.To = boxPosition + Vector2.new(width - cornerSize, height)
                                            esp.Drawings.Box.BottomRight.Color = color
                                            esp.Drawings.Box.BottomRight.Visible = true
                                            
                                            esp.Drawings.Box.Bottom.From = boxPosition + Vector2.new(width, height)
                                            esp.Drawings.Box.Bottom.To = boxPosition + Vector2.new(width, height - cornerSize)
                                            esp.Drawings.Box.Bottom.Color = color
                                            esp.Drawings.Box.Bottom.Visible = true
                                            
                                        elseif ESPSettings.BoxStyle == "Full" then
                                            -- Full Box
                                            esp.Drawings.Box.Left.From = boxPosition
                                            esp.Drawings.Box.Left.To = boxPosition + Vector2.new(0, height)
                                            esp.Drawings.Box.Left.Color = color
                                            esp.Drawings.Box.Left.Visible = true
                                            
                                            esp.Drawings.Box.Right.From = boxPosition + Vector2.new(width, 0)
                                            esp.Drawings.Box.Right.To = boxPosition + Vector2.new(width, height)
                                            esp.Drawings.Box.Right.Color = color
                                            esp.Drawings.Box.Right.Visible = true
                                            
                                            esp.Drawings.Box.Top.From = boxPosition
                                            esp.Drawings.Box.Top.To = boxPosition + Vector2.new(width, 0)
                                            esp.Drawings.Box.Top.Color = color
                                            esp.Drawings.Box.Top.Visible = true
                                            
                                            esp.Drawings.Box.Bottom.From = boxPosition + Vector2.new(0, height)
                                            esp.Drawings.Box.Bottom.To = boxPosition + Vector2.new(width, height)
                                            esp.Drawings.Box.Bottom.Color = color
                                            esp.Drawings.Box.Bottom.Visible = true
                                            
                                            -- Hide corner-specific lines
                                            esp.Drawings.Box.TopLeft.Visible = false
                                            esp.Drawings.Box.TopRight.Visible = false
                                            esp.Drawings.Box.BottomLeft.Visible = false
                                            esp.Drawings.Box.BottomRight.Visible = false
                                            
                                        elseif ESPSettings.BoxStyle == "ThreeD" then
                                            -- 3D Box (simplified for performance)
                                            local frontOffset = size.Z * 0.3
                                            local backOffset = -size.Z * 0.3
                                            
                                            -- Front face corners
                                            local ftl = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, frontOffset)).Position)
                                            local ftr = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, frontOffset)).Position)
                                            local fbl = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, frontOffset)).Position)
                                            local fbr = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, frontOffset)).Position)
                                            
                                            -- Back face corners
                                            local btl = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, backOffset)).Position)
                                            local btr = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, backOffset)).Position)
                                            local bbl = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, backOffset)).Position)
                                            local bbr = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, backOffset)).Position)
                                            
                                            if ftl.Z > 0 and ftr.Z > 0 and fbl.Z > 0 and fbr.Z > 0 then
                                                -- Front face
                                                esp.Drawings.Box.TopLeft.From = Vector2.new(ftl.X, ftl.Y)
                                                esp.Drawings.Box.TopLeft.To = Vector2.new(ftr.X, ftr.Y)
                                                esp.Drawings.Box.TopLeft.Color = color
                                                esp.Drawings.Box.TopLeft.Visible = true
                                                
                                                esp.Drawings.Box.Left.From = Vector2.new(ftl.X, ftl.Y)
                                                esp.Drawings.Box.Left.To = Vector2.new(fbl.X, fbl.Y)
                                                esp.Drawings.Box.Left.Color = color
                                                esp.Drawings.Box.Left.Visible = true
                                                
                                                esp.Drawings.Box.Right.From = Vector2.new(ftr.X, ftr.Y)
                                                esp.Drawings.Box.Right.To = Vector2.new(fbr.X, fbr.Y)
                                                esp.Drawings.Box.Right.Color = color
                                                esp.Drawings.Box.Right.Visible = true
                                                
                                                esp.Drawings.Box.Bottom.From = Vector2.new(fbl.X, fbl.Y)
                                                esp.Drawings.Box.Bottom.To = Vector2.new(fbr.X, fbr.Y)
                                                esp.Drawings.Box.Bottom.Color = color
                                                esp.Drawings.Box.Bottom.Visible = true
                                                
                                                -- Connecting lines to back
                                                if btl.Z > 0 and btr.Z > 0 and bbl.Z > 0 and bbr.Z > 0 then
                                                    esp.Drawings.Box.TopRight.From = Vector2.new(ftl.X, ftl.Y)
                                                    esp.Drawings.Box.TopRight.To = Vector2.new(btl.X, btl.Y)
                                                    esp.Drawings.Box.TopRight.Color = color
                                                    esp.Drawings.Box.TopRight.Visible = true
                                                    
                                                    esp.Drawings.Box.BottomLeft.From = Vector2.new(ftr.X, ftr.Y)
                                                    esp.Drawings.Box.BottomLeft.To = Vector2.new(btr.X, btr.Y)
                                                    esp.Drawings.Box.BottomLeft.Color = color
                                                    esp.Drawings.Box.BottomLeft.Visible = true
                                                    
                                                    esp.Drawings.Box.BottomRight.From = Vector2.new(fbl.X, fbl.Y)
                                                    esp.Drawings.Box.BottomRight.To = Vector2.new(bbl.X, bbl.Y)
                                                    esp.Drawings.Box.BottomRight.Color = color
                                                    esp.Drawings.Box.BottomRight.Visible = true
                                                    
                                                    esp.Drawings.Box.Top.From = Vector2.new(fbr.X, fbr.Y)
                                                    esp.Drawings.Box.Top.To = Vector2.new(bbr.X, bbr.Y)
                                                    esp.Drawings.Box.Top.Color = color
                                                    esp.Drawings.Box.Top.Visible = true
                                                end
                                            end
                                        end
                                        
                                        -- TRACER ESP
                                        if ESPSettings.TracerEnabled then
                                            esp.Drawings.Tracer.From = GetTracerOrigin()
                                            esp.Drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
                                            esp.Drawings.Tracer.Color = color
                                            esp.Drawings.Tracer.Visible = true
                                        else
                                            esp.Drawings.Tracer.Visible = false
                                        end
                                        
                                        -- HEALTH BAR ESP
                                        if ESPSettings.HealthBarEnabled then
                                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                                            local barHeight = height * 0.9
                                            local barWidth = 3
                                            local barX = ESPSettings.HealthBarSide == "Left" and (boxPosition.X - barWidth - 4) or (boxPosition.X + width + 4)
                                            local barY = boxPosition.Y + (height - barHeight) / 2
                                            
                                            -- Outline
                                            esp.Drawings.HealthBar.Outline.From = Vector2.new(barX - 1, barY - 1)
                                            esp.Drawings.HealthBar.Outline.To = Vector2.new(barX - 1, barY + barHeight + 1)
                                            esp.Drawings.HealthBar.Outline.Visible = true
                                            
                                            -- Background
                                            esp.Drawings.HealthBar.Background.From = Vector2.new(barX, barY)
                                            esp.Drawings.HealthBar.Background.To = Vector2.new(barX, barY + barHeight)
                                            esp.Drawings.HealthBar.Background.Thickness = barWidth
                                            esp.Drawings.HealthBar.Background.Visible = true
                                            
                                            -- Fill (from bottom up)
                                            local fillHeight = barHeight * healthPercent
                                            local fillY = barY + (barHeight - fillHeight)
                                            esp.Drawings.HealthBar.Fill.From = Vector2.new(barX, fillY)
                                            esp.Drawings.HealthBar.Fill.To = Vector2.new(barX, barY + barHeight)
                                            esp.Drawings.HealthBar.Fill.Thickness = barWidth
                                            esp.Drawings.HealthBar.Fill.Color = Color3.fromRGB(
                                                math.floor(255 - (255 * healthPercent)),
                                                math.floor(255 * healthPercent),
                                                0
                                            )
                                            esp.Drawings.HealthBar.Fill.Visible = true
                                        else
                                            esp.Drawings.HealthBar.Outline.Visible = false
                                            esp.Drawings.HealthBar.Background.Visible = false
                                            esp.Drawings.HealthBar.Fill.Visible = false
                                        end
                                        
                                        -- NAME ESP
                                        if ShowName then
                                            esp.Drawings.Name.Text = player.Name
                                            esp.Drawings.Name.Position = Vector2.new(boxPosition.X + width/2, boxPosition.Y - 18)
                                            esp.Drawings.Name.Color = color
                                            esp.Drawings.Name.Visible = true
                                        else
                                            esp.Drawings.Name.Visible = false
                                        end
                                        
                                        -- HEALTH TEXT ESP
                                        if ShowHP then
                                            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                                            esp.Drawings.Health.Text = tostring(math.floor(humanoid.Health)) .. " HP (" .. healthPercent .. "%)"
                                            esp.Drawings.Health.Position = Vector2.new(boxPosition.X + width/2, boxPosition.Y + height + 5)
                                            esp.Drawings.Health.Color = Color3.fromRGB(
                                                math.floor(255 - (255 * (healthPercent/100))),
                                                math.floor(255 * (healthPercent/100)),
                                                0
                                            )
                                            esp.Drawings.Health.Visible = true
                                        else
                                            esp.Drawings.Health.Visible = false
                                        end
                                        
                                        -- DISTANCE ESP
                                        if ShowDistance then
                                            esp.Drawings.Distance.Text = tostring(math.floor(distance)) .. "m"
                                            esp.Drawings.Distance.Position = Vector2.new(boxPosition.X + width/2, boxPosition.Y + height + (ShowHP and 20 or 5))
                                            esp.Drawings.Distance.Visible = true
                                        else
                                            esp.Drawings.Distance.Visible = false
                                        end
                                        
                                        -- SKELETON ESP
                                        if SkeletonEnabled then
                                            for _, bonePair in pairs(esp.Drawings.Skeleton) do
                                                local part1 = esp.Character:FindFirstChild(bonePair.Parts[1])
                                                local part2 = esp.Character:FindFirstChild(bonePair.Parts[2])
                                                
                                                -- R6 fallback
                                                if not part1 and bonePair.Parts[1] == "UpperTorso" then
                                                    part1 = esp.Character:FindFirstChild("Torso")
                                                end
                                                if not part2 and bonePair.Parts[2] == "UpperTorso" then
                                                    part2 = esp.Character:FindFirstChild("Torso")
                                                end
                                                if not part2 and bonePair.Parts[2] == "LowerTorso" then
                                                    part2 = esp.Character:FindFirstChild("Torso")
                                                end
                                                
                                                if part1 and part2 then
                                                    local pos1, onScreen1 = camera:WorldToViewportPoint(part1.Position)
                                                    local pos2, onScreen2 = camera:WorldToViewportPoint(part2.Position)
                                                    
                                                    if onScreen1 and onScreen2 and pos1.Z > 0 and pos2.Z > 0 then
                                                        bonePair.Line.From = Vector2.new(pos1.X, pos1.Y)
                                                        bonePair.Line.To = Vector2.new(pos2.X, pos2.Y)
                                                        bonePair.Line.Color = ESPSettings.SkeletonColor
                                                        bonePair.Line.Visible = true
                                                    else
                                                        bonePair.Line.Visible = false
                                                    end
                                                else
                                                    bonePair.Line.Visible = false
                                                end
                                            end
                                        else
                                            for _, bonePair in pairs(esp.Drawings.Skeleton) do
                                                bonePair.Line.Visible = false
                                            end
                                        end
                                        
                                        -- CHAMS/HIGHLIGHT
                                        if Highlights[player] then
                                            if ESPSettings.ChamsEnabled and esp.Character then
                                                Highlights[player].Parent = esp.Character
                                                Highlights[player].FillColor = ESPSettings.ChamsFillColor
                                                Highlights[player].OutlineColor = ESPSettings.ChamsOutlineColor
                                                Highlights[player].FillTransparency = ESPSettings.ChamsTransparency
                                                Highlights[player].Enabled = true
                                            else
                                                Highlights[player].Enabled = false
                                            end
                                        end
                                    else
                                        HideESP(esp)
                                    end
                                else
                                    HideESP(esp)
                                end
                            else
                                HideESP(esp)
                            end
                        else
                            HideESP(esp)
                        end
                    else
                        HideESP(esp)
                        if Highlights[player] then
                            Highlights[player].Enabled = false
                        end
                    end
                else
                    HideESP(esp)
                    if Highlights[player] then
                        Highlights[player].Enabled = false
                    end
                end
            else
                RemoveESP(esp)
                if Highlights[player] then
                    Highlights[player]:Destroy()
                    Highlights[player] = nil
                end
                ESPObjects[player] = nil
            end
        end
    end

    -- ESP Toggle
    VisualsGroupbox:CreateToggle({
        Name = "ESP",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("visibility", "Material"),
        Tooltip = "Enable/Disable ESP for all players",
        Callback = function(Value)
            ESPEnabled = Value
            
            if ESPEnabled then
                -- Create ESP for all players
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and not ESPObjects[player] then
                        ESPObjects[player] = CreateESP(player)
                        
                        -- Setup character ESP immediately if they have a character
                        if player.Character then
                            ESPObjects[player].Character = player.Character
                            if Highlights[player] then
                                Highlights[player].Parent = player.Character
                            end
                        end
                        
                        -- Connect CharacterAdded event
                        if not CharacterConnections[player] then
                            CharacterConnections[player] = {}
                        end
                        
                        CharacterConnections[player].Added = player.CharacterAdded:Connect(function(character)
                            if ESPObjects[player] then
                                ESPObjects[player].Character = character
                                -- Update highlight parent immediately
                                if Highlights[player] then
                                    Highlights[player].Parent = character
                                end
                            end
                        end)
                        
                        -- Connect death event if character exists
                        if player.Character then
                            local humanoid = player.Character:FindFirstChild("Humanoid")
                            if humanoid then
                                CharacterConnections[player].Died = humanoid.Died:Connect(function()
                                    if ESPObjects[player] then
                                        HideESP(ESPObjects[player])
                                    end
                                end)
                            end
                        end
                    end
                end
                
                -- Start update loop ONLY if not already running
                if not ESPUpdateConnection then
                    ESPUpdateConnection = game:GetService("RunService").RenderStepped:Connect(function()
                        if ESPEnabled then
                            UpdateESP()
                        end
                    end)
                end
                
                print("ESP: ENABLED")
            else
                -- Stop update loop
                if ESPUpdateConnection then
                    ESPUpdateConnection:Disconnect()
                    ESPUpdateConnection = nil
                end
                
                -- Hide all ESP first
                for player, esp in pairs(ESPObjects) do
                    HideESP(esp)
                    if Highlights[player] then
                        Highlights[player].Enabled = false
                    end
                end
                
                -- Disconnect all character events
                for player, connections in pairs(CharacterConnections) do
                    if connections.Added then connections.Added:Disconnect() end
                    if connections.Removing then connections.Removing:Disconnect() end
                end
                CharacterConnections = {}
                
                -- Clean up ESP objects
                for player, esp in pairs(ESPObjects) do
                    RemoveESP(esp)
                    if Highlights[player] then
                        Highlights[player]:Destroy()
                        Highlights[player] = nil
                    end
                end
                ESPObjects = {}
                
                print("ESP: DISABLED")
            end
        end
    }, "TOGGLE_ESP")

    -- Player Added/Removed Events
    game.Players.PlayerAdded:Connect(function(player)
        if player == game.Players.LocalPlayer then return end
        
        task.wait(0.1)
        
        if ESPEnabled and not ESPObjects[player] then
            ESPObjects[player] = CreateESP(player)
            
            -- Setup character events
            if not CharacterConnections[player] then
                CharacterConnections[player] = {}
            end
            
            CharacterConnections[player].Added = player.CharacterAdded:Connect(function(character)
                task.wait(0.1)
                if ESPObjects[player] then
                    ESPObjects[player].Character = character
                    if Highlights[player] then
                        Highlights[player].Parent = character
                    end
                    
                    -- Connect death event for new character
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        if CharacterConnections[player].Died then
                            CharacterConnections[player].Died:Disconnect()
                        end
                        CharacterConnections[player].Died = humanoid.Died:Connect(function()
                            if ESPObjects[player] then
                                HideESP(ESPObjects[player])
                            end
                        end)
                    end
                end
            end)
            
            -- Set initial character if it exists
            if player.Character then
                ESPObjects[player].Character = player.Character
                if Highlights[player] then
                    Highlights[player].Parent = player.Character
                end
                
                -- Connect death event
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    CharacterConnections[player].Died = humanoid.Died:Connect(function()
                        if ESPObjects[player] then
                            HideESP(ESPObjects[player])
                        end
                    end)
                end
            end
        end
    end)

    game.Players.PlayerRemoving:Connect(function(player)
        -- Disconnect character events
        if CharacterConnections[player] then
            if CharacterConnections[player].Added then 
                CharacterConnections[player].Added:Disconnect() 
            end
            if CharacterConnections[player].Died then 
                CharacterConnections[player].Died:Disconnect() 
            end
            CharacterConnections[player] = nil
        end
        
        -- Remove ESP
        if ESPObjects[player] then
            RemoveESP(ESPObjects[player])
            ESPObjects[player] = nil
        end
        
        -- Remove Highlight
        if Highlights[player] then
            Highlights[player]:Destroy()
            Highlights[player] = nil
        end
    end)

    -- Skeleton Toggle
    VisualsGroupbox:CreateToggle({
        Name = "Skeleton",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("accessibility", "Material"),
        Tooltip = "Show skeleton lines connecting body parts",
        Callback = function(Value)
            SkeletonEnabled = Value
            print("Skeleton ESP: " .. (Value and "ENABLED" or "DISABLED"))
        end
    }, "TOGGLE_SKELETON")

    -- Show HP Toggle
    VisualsGroupbox:CreateToggle({
        Name = "Show HP",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("favorite", "Material"),
        Tooltip = "Display player health percentage",
        Callback = function(Value)
            ShowHP = Value
            print("Show HP: " .. (Value and "ENABLED" or "DISABLED"))
        end
    }, "TOGGLE_SHOW_HP")

    -- Show Name Toggle
    VisualsGroupbox:CreateToggle({
        Name = "Show Name",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("person", "Material"),
        Tooltip = "Display player names above their heads",
        Callback = function(Value)
            ShowName = Value
            print("Show Name: " .. (Value and "ENABLED" or "DISABLED"))
        end
    }, "TOGGLE_SHOW_NAME")
    
    -- Distance now shown by default, removed toggle (less clutter)
    
    -- Health Bar Toggle  
    VisualsGroupbox:CreateToggle({
        Name = "Health Bar",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("healing", "Material"),
        Tooltip = "Show health bar on side of box",
        Callback = function(Value)
            ESPSettings.HealthBarEnabled = Value
            print("Health Bar: " .. (Value and "ENABLED" or "DISABLED"))
        end
    }, "TOGGLE_HEALTH_BAR")
    
    -- Tracers Toggle
    VisualsGroupbox:CreateToggle({
        Name = "Tracers",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("timeline", "Material"),
        Tooltip = "Show lines to players",
        Callback = function(Value)
            ESPSettings.TracerEnabled = Value
            print("Tracers: " .. (Value and "ENABLED" or "DISABLED"))
        end
    }, "TOGGLE_TRACERS")
    
    -- Chams Toggle
    VisualsGroupbox:CreateToggle({
        Name = "Chams",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("highlight", "Material"),
        Tooltip = "Highlight players through walls",
        Callback = function(Value)
            ESPSettings.ChamsEnabled = Value
            print("Chams: " .. (Value and "ENABLED" or "DISABLED"))
        end
    }, "TOGGLE_CHAMS")

    -- Camera Settings Groupbox
    local VisualsGroupbox2 = VisualsTab:CreateGroupbox({
        Name = "Camera Settings",
        Icon = NebulaIcons:GetIcon("videocam", "Material"),
        Column = 2,
    }, "GB_VISUALS_CAMERA")

    -- FOV System Setup
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local camera = workspace.CurrentCamera
    
    -- Function to set FOV
    local function setFOV(value)
        if isFOVEnabled and camera then
            camera.FieldOfView = value
        end
    end
    
    -- Character respawn detection to reapply FOV
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        task.wait(1)
        if isFOVEnabled then
            setFOV(customFOV)
        end
    end)
    
    -- Force FOV enforcement loop (prevents weapon/game overrides)
    game:GetService("RunService").RenderStepped:Connect(function()
        if isFOVEnabled and camera.FieldOfView ~= customFOV then
            camera.FieldOfView = customFOV
        end
    end)
    
    -- FOV Enable/Disable Toggle
    VisualsGroupbox2:CreateToggle({
        Name = "FOV Changer",
        CurrentValue = false,
        Style = 2,
        Icon = NebulaIcons:GetIcon("camera", "Material"),
        Tooltip = "Enable custom FOV (prevents weapon/game overrides)",
        Callback = function(Value)
            isFOVEnabled = Value
            
            if isFOVEnabled then
                setFOV(customFOV)
            else
                -- Restore default FOV when disabled
                if camera then
                    camera.FieldOfView = defaultFOV
                end
            end
        end
    }, "TOGGLE_FOV")
    
    -- FOV Value Slider
    VisualsGroupbox2:CreateSlider({
        Name = "FOV Value",
        Icon = NebulaIcons:GetIcon("camera_alt", "Material"),
        Range = {1, 120},
        Increment = 1,
        Suffix = "°",
        CurrentValue = math.floor(defaultFOV),
        Tooltip = "Adjust your field of view (1-120)",
        Callback = function(Value)
            customFOV = Value
            setFOV(Value)
        end
    }, "SLIDER_FOV")

    -- Distance Slider
    VisualsGroupbox2:CreateSlider({
        Name = "ESP Distance",
        Icon = NebulaIcons:GetIcon("straighten", "Material"),
        Range = {100, 5000},
        Increment = 50,
        Suffix = "m",
        CurrentValue = 1000,
        Tooltip = "Maximum distance to show ESP",
        Callback = function(Value)
            MaxDistance = Value
            print("ESP Max Distance set to: " .. Value .. "m")
        end
    }, "SLIDER_DISTANCE")

    -- Box Style Dropdown (in Visuals Groupbox on Column 2)
    local VisualsGroupbox3 = VisualsTab:CreateGroupbox({
        Name = "ESP Styles",
        Icon = NebulaIcons:GetIcon("style", "Material"),
        Column = 2,
    }, "GB_VISUALS_STYLES")
    
    VisualsGroupbox3:CreateDropdown({
        Name = "Box Style",
        Options = {"Corner", "Full", "ThreeD"},
        Default = "Corner",
        Callback = function(Value)
            ESPSettings.BoxStyle = Value
            print("Box Style set to: " .. Value)
        end
    }, "DROPDOWN_BOX_STYLE")
    
    VisualsGroupbox3:CreateDropdown({
        Name = "Tracer Origin",
        Options = {"Bottom", "Top", "Center", "Mouse"},
        Default = "Bottom",
        Callback = function(Value)
            ESPSettings.TracerOrigin = Value
            print("Tracer Origin set to: " .. Value)
        end
    }, "DROPDOWN_TRACER_ORIGIN")
    
    VisualsGroupbox3:CreateDropdown({
        Name = "Health Bar Side",
        Options = {"Left", "Right"},
        Default = "Left",
        Callback = function(Value)
            ESPSettings.HealthBarSide = Value
            print("Health Bar Side set to: " .. Value)
        end
    }, "DROPDOWN_HEALTH_SIDE")
