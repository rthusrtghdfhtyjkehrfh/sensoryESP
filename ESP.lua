--[[
  // dacces ESP //
  // v1.0.5 //
  // 16/5/2026 //

  Made with love by Dacces, Gemini 3 flash, Gemini 3.1 high / low, and Claude Sonnet 4.6
  This script is free to use, and could not be sold. if you bought this script, you got scammed.
  If you say that you OWN or MADE this script, id be not happy and be mad. don't do it. please.
  You can easily and freely use it on your own projects. I dont care. Or even paste or skid it.
  Every script that has been usen or taken that is not ai generated, were from all open sources.

  Inspired by:
  https://v3rm.net/threads/chatgpt-esp-by-me.28629/#post-242437 > https://raw.githubusercontent.com/emptyusesdx9/astral.rip/refs/heads/main/esp

  Credits:
  actual people: dacces / finobe / dualesp / nocturnal
  AIs used: gemini 3 flash, gemini 3.1 high / low, claude sonnet 4.6
  font credits
  f1nobe and dual esp guy

  Purpose of this script?
  Proves that no ESP will be unique.
]]

if not LPH_OBFUSCATED then
    LPH_JIT = LPH_JIT or function(...)
        return ...
    end
    LPH_JIT_MAX = LPH_JIT_MAX or function(...)
        return ...
    end
    LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(...)
        return ...
    end
    LPH_NO_UPVALUES = LPH_NO_UPVALUES or function(f)
        return function(...)
            return f(...)
        end
    end
    LPH_ENCSTR = LPH_ENCSTR or function(...)
        return ...
    end
    LPH_ENCNUM = LPH_ENCNUM or function(...)
        return ...
    end
    LPH_ENCFUNC = LPH_ENCFUNC or function(func, key1, key2)
        if key1 ~= key2 then
            return print("LPH_ENCFUNC mismatch")
        end
        return func
    end
    LPH_CRASH = LPH_CRASH or function()
        return print(debug.traceback())
    end
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local WtS = Camera.WorldToViewportPoint
local UIContainer = gethui and gethui() or CoreGui
local BootstrapPlayers = Players
local LPHNoVirtualize = LPH_NO_VIRTUALIZE
local ESP = {}
local ChamsContainer
local MeshChamsFolder
local ScreenGui
local PlayerRemovingConnection
local InputBeganConnection
local CurrentRunId = HttpService:GenerateGUID(false)

if getgenv().SensoryESP_Unload then
    pcall(getgenv().SensoryESP_Unload)
end

local oldChams = UIContainer:FindFirstChild("SensoryESP_Chams")
if oldChams then
    pcall(function() oldChams:Destroy() end)
end

local oldMeshFolder = Workspace:FindFirstChild("SensoryESP_MeshChams")
if oldMeshFolder then
    pcall(function() oldMeshFolder:Destroy() end)
end

local function IsMeshChamArtifact(obj)
    if not obj then
        return false
    end

    if obj:GetAttribute("SensoryESP_MeshCham") == true then
        return true
    end

    if obj:IsA("Model") and obj.Name == "ChamShells" then
        return true
    end

    if obj:IsA("BasePart") and obj.Name:match("^ChamShell_") then
        return true
    end

    if obj:IsA("Highlight") and obj.Name == "ChamShellHighlight" then
        return true
    end

    return false
end

local function CleanupMeshChams(root)
    if not root then
        return
    end

    for _, obj in ipairs(root:GetDescendants()) do
        if IsMeshChamArtifact(obj) then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function CleanupCharacterMeshChams(character)
    if not character then
        return
    end

    for _, child in ipairs(character:GetChildren()) do
        if IsMeshChamArtifact(child) then
            pcall(function() child:Destroy() end)
        end
    end
end

CleanupMeshChams(Workspace)

for _, player in ipairs(BootstrapPlayers:GetPlayers()) do
    CleanupCharacterMeshChams(player.Character)
end

local function EnsureRootInstances()
    if not ChamsContainer or not ChamsContainer.Parent then
        ChamsContainer = Instance.new("Folder")
        ChamsContainer.Name = "SensoryESP_Chams"
        ChamsContainer.Parent = UIContainer
    end

    if not MeshChamsFolder or not MeshChamsFolder.Parent then
        MeshChamsFolder = Instance.new("Folder")
        MeshChamsFolder.Name = "SensoryESP_MeshChams"
        MeshChamsFolder.Parent = Workspace
    end

    if not ScreenGui or not ScreenGui.Parent then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SensoryESP"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.IgnoreGuiInset = true
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        getgenv().SensoryESP_UI = ScreenGui

        local success = pcall(function()
            ScreenGui.Parent = CoreGui
        end)
        if not success then
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
end

local DrawLine = LPHNoVirtualize(function(line, p1, p2, thickness, color)
    local diff = p2 - p1
    local dist = diff.Magnitude
    local angle = math.deg(math.atan2(diff.Y, diff.X))

    line.Size = UDim2.new(0, math.floor(dist + 0.5), 0, thickness)
    line.Position = UDim2.new(0, math.floor(p1.X + diff.X / 2 - dist / 2 + 0.5), 0,
        math.floor(p1.Y + diff.Y / 2 - thickness / 2 + 0.5))
    line.Rotation = angle
    line.BackgroundColor3 = color
    line.Visible = true
end)

local ESPConfig = {
    -- esp checks
    Enabled = true,
    Keybind = {
        Enabled = true,
        Key = Enum.KeyCode.Insert,
    },
    Players = true,
    LocalPlayer = false,
    LimitFPS = 70, -- Set to 0 to disable limit
    DynamicBoxes = true,
    VisibilityCheckRate = 0.3,

    -- boxes
    Boxes = true,
    BoxType = "Normal", -- "Normal", "Corner", or "Circle"
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1,
    Outlines = {
        Enabled = true,
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
    },

    -- boxfill
    BoxFill = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.9,
        Gradient = {
            Enabled = true,
            Color1 = Color3.fromRGB(180, 255, 255),
            Color2 = Color3.fromRGB(0, 255, 255),
            Color3 = Color3.fromRGB(0, 120, 255),
            Rotation = 0,
            Animated = true,
            Speed = 64,          -- degrees per second
            Direction = "Right", -- "Left" or "Right"
        }
    },

    -- healthbar
    HealthBar = {
        Enabled = true,
        Position = "Left", -- "Left", "Right", "Top", "Bottom"
        SideGap = 2,
        Width = 2,
        ShowText = true,
        TextFollowBar = true,
        HideWhenFullHP = true,
        FollowGradientColorText = true,
        Outline = {
            Enabled = true,
            Color = Color3.fromRGB(0, 0, 0),
        },
        Gradient = {
            Enabled = true,
            Color1 = Color3.fromRGB(0, 255, 0),   -- Full health
            Color2 = Color3.fromRGB(255, 255, 0), -- Mid health
            Color3 = Color3.fromRGB(255, 0, 0),   -- Low health
        }
    },

    -- names
    Names = true,
    TextSize = 12,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextOutline = true,
    TextGap = 3,
    Font = "Proggy Clean",
    TeamIndicator = {
        Enabled = true,
        Position = "Right", -- "Left" or "Right"
        UseTeamColor = true,
        Color = Color3.fromRGB(255, 255, 255),
        Compact = true,
        TextSize = 10,
    },
    FriendlyIndicator = {
        Enabled = true,
        Position = "Right", -- "Left" or "Right"
        CheckTeam = true,
        CheckFriends = true,
        Text = "[F]",
        Color = Color3.fromRGB(0, 255, 0),
    },
    Weapon = {
        Enabled = true,
        Gap = 1,
        InventoryPath = "ReplicatedStorage.Players.%NAME%.Inventory",
        UseToolFallback = true,
    },

    -- flags
    Flags = {
        Enabled = true,
        Position = "Right",
        SideGap = 4,
        TextGap = 2,
        Font = "Smallest Pixel-7",
        TextSize = 9,
        Options = {
            Idle = false,
            Moving = true,
            Jumping = true,
            Swimming = true,
        },
        Colors = {
            Idle = Color3.fromRGB(255, 255, 255),
            Moving = Color3.fromRGB(255, 255, 255),
            Jumping = Color3.fromRGB(255, 255, 255),
            Swimming = Color3.fromRGB(65, 65, 255),
        }
    },

    --skeleton
    Skeleton = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
    },

    -- distance
    Distance = {
        Enabled = true,
        Unit = "Meters",
        StudsPerMeter = 3,
        Ending = "",
        Gap = 3,
    },

    -- chams
    Chams = {
        Enabled = true,
        Type = "MeshChams", -- "Highlight", "Adornment", or "MeshChams"

        Highlight = {
            FillColor = Color3.fromRGB(255, 255, 255),
            FillTransparency = 1,
            OutlineColor = Color3.fromRGB(255, 255, 255),
            OutlineTransparency = 0,
            VisibleCheck = false, -- true = Occluded, false = AlwaysOnTop
        },

        Adornment = {
            Color = Color3.fromRGB(59, 144, 204),
            VisibleColor = Color3.fromRGB(59, 204, 90),
            Transparency = 0.7,
            AlwaysOnTop = true,
            VisibleCheck = false,
        },

        -- MeshChams: shell parts welded to each body part with a single Highlight.
        -- Only works on humanoid targets (players / NPCs with a Humanoid).
        MeshChams = {
            FillColor = Color3.fromRGB(59, 144, 204),
            FillTransparency = 0.6,
            OutlineColor = Color3.fromRGB(255, 255, 255),
            OutlineTransparency = 0,
            VisibleCheck = false, -- true = Occluded, false = AlwaysOnTop
        },
    },

    -- directories
    Directories = {
        --[[{
                DisplayName = "Part",
                Path = "workspace.Folder.common3",
                Multiple = true,
                Cheap = true,
                Contains = {},
                Names = {"Part"}
            },
        {
            DisplayName = "Dummy",
            Path = "workspace",
            Multiple = true,
            Cheap = false,
            Contains = {},
            NonHuman = false,
            NoStatus = false,
            Names = { "Dummy", "Rig" }
        },
        {
            DisplayName = "UAZ",
            Path = "workspace",
            Multiple = true,
            Cheap = false,
            NonHuman = true,
            NoStatus = true,
            Contains = {},
            Names = { "UAZ" },
            Config = {
                -- Box Settings
                Boxes = true,
                BoxColor = Color3.fromRGB(255, 150, 0),
                BoxThickness = 1.5,


                BoxFill = {
                    Enabled = true,
                    Color = Color3.fromRGB(255, 150, 0),
                    Transparency = 0.8,
                    Gradient = {
                        Enabled = true,
                        Color1 = Color3.fromRGB(255, 150, 0),
                        Color2 = Color3.fromRGB(255, 255, 255),
                        Color3 = Color3.fromRGB(255, 150, 0),
                        Rotation = 0,
                        Animated = true,
                        Speed = 90,
                        Direction = "Left",
                    }
                },

                -- Text Settings
                TextColor = Color3.fromRGB(255, 200, 50),
                TextSize = 12,
                TextOutline = true,
                TextGap = 4,
                Font = "Proggy Clean",

                -- Distance Settings
                Distance = {
                    Enabled = true,
                    Unit = "Meters",
                    Ending = "m",
                    Gap = 5,
                },

                -- Chams Settings
                Chams = {
                    Enabled = true,
                    Type = "Highlight",
                    Highlight = {
                        FillColor = Color3.fromRGB(255, 150, 0),
                        FillTransparency = 0.7,
                        OutlineColor = Color3.fromRGB(255, 255, 255),
                        OutlineTransparency = 1,
                        VisibleCheck = false,
                    },
                    Adornment = {
                        Color = Color3.fromRGB(255, 150, 0),
                        VisibleColor = Color3.fromRGB(0, 255, 0),
                        Transparency = 0.5,
                        AlwaysOnTop = true,
                        VisibleCheck = true,
                    }
                },

                -- Flags Settings
                Flags = {
                    Enabled = true,
                    Position = "Left",
                    SideGap = 4,
                    TextGap = 2,
                    Font = "Smallest Pixel-7",
                    TextSize = 9,
                    Options = {
                        Idle = true,
                        Moving = true,
                    },
                    Colors = {
                        Idle = Color3.fromRGB(255, 255, 255),
                        Moving = Color3.fromRGB(255, 150, 0),
                    }
                },

                -- HealthBar Settings
                HealthBar = {
                    Enabled = true,
                    Position = "Bottom",
                    SideGap = 2,
                    Width = 2,
                    ShowText = true,
                    TextFollowBar = true,
                    HideWhenFullHP = false,
                    FollowGradientColorText = true,
                    Outline = {
                        Enabled = true,
                        Color = Color3.fromRGB(0, 0, 0),
                    },
                    Gradient = {
                        Enabled = true,
                        Color1 = Color3.fromRGB(0, 255, 0),
                        Color2 = Color3.fromRGB(255, 255, 0),
                        Color3 = Color3.fromRGB(255, 0, 0),
                    }
                },

                -- Skeleton Settings (Template only, usually for players)
                Skeleton = {
                    Enabled = false,
                    Color = Color3.fromRGB(255, 255, 255),
                    Outline = true,
                    OutlineColor = Color3.fromRGB(0, 0, 0),
                    Thickness = 1,
                }
            }
        },
        {
            DisplayName = "FPV Drone",
            Path = "workspace",
            Multiple = true,
            Cheap = false,
            NonHuman = true,
            NoStatus = true,
            Contains = {},
            Names = { "FPVDrone" }
        },
        {
            DisplayName = "",
            Path = "workspace.AiZones",
            Multiple = true,
            Cheap = false,
            NonHuman = false,
            NoStatus = true,
            Recursive = true,
            Contains = {},
            BlockNames = { "OutpostClaymores", "OutpostLandmines", "ElectricityAnomaly" },
            Names = { "" }
        },
        --[[
            {
                DisplayName = "CashRegister",
                Path = "workspace",
                Multiple = true,
                Cheap = true,
                Contains = {},
                Names = {"CashRegister"}
            },
        ]]
    }
}

local function DeepCopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end

    local copy = {}
    for key, value in pairs(tbl) do
        copy[key] = DeepCopy(value)
    end
    return copy
end

local function DeepMerge(base, override)
    if type(override) ~= "table" then
        return base
    end

    for key, value in pairs(override) do
        if type(value) == "table" and type(base[key]) == "table" then
            DeepMerge(base[key], value)
        else
            base[key] = value
        end
    end

    return base
end

local DefaultESPConfig = DeepCopy(ESPConfig)

local function CompactTeamName(teamName)
    if type(teamName) ~= "string" or teamName == "" then
        return ""
    end

    local parts = {}
    for part in teamName:gmatch("[^%s%-_]+") do
        if part ~= "" then
            table.insert(parts, part)
        end
    end

    if #parts == 0 then
        return teamName
    end

    if #parts == 1 then
        local single = parts[1]
        if #single <= 4 then
            return single:upper()
        end
        return single:sub(1, 1):upper()
    end

    local compact = {}
    for _, part in ipairs(parts) do
        table.insert(compact, part:sub(1, 1):upper())
    end
    return table.concat(compact)
end

local function ColorToHex(color)
    local r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255)
    local g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255)
    local b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    return string.format("#%02X%02X%02X", r, g, b)
end
--

--// fonts
local _fontMap = {
    ["Proggy Clean"] = Enum.Font.Code,
    ["Smallest Pixel-7"] = Enum.Font.Legacy,
    ["Tahoma"] = Enum.Font.Arial,
    ["Minecraftia"] = Enum.Font.SourceSans,
    ["Tahoma Modern Bold"] = Enum.Font.ArialBold,
}

local FontsToDownload = {
    ["Tahoma"] = { Link = "https://github.com/LuckyHub1/LuckyHub/raw/main/zekton_rg.ttf" },
    ["Minecraftia"] = { Link = "https://github.com/LuckyHub1/LuckyHub/raw/refs/heads/main/Minecraftia.ttf" },
    ["Smallest Pixel-7"] = { Link = "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/smallest_pixel-7.ttf" },
    ["Proggy Clean"] = { Link = "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyClean.ttf" },
    ["Tahoma Modern Bold"] = { Link = "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Tahoma-Modern-Bold.ttf" },
}

local ESPFonts = { Loaded = {} }
local CIRCLE_BOX_SEGMENTS = 36

local SKELETON_BONE_DEFS = {
    { "Head",                                    "UpperTorso|Torso" },
    { "UpperTorso|Torso",                        "LowerTorso|Torso" },

    -- Arms
    { "UpperTorso|Torso",                        "LeftUpperArm|Left Arm|LeftArm" },
    { "LeftUpperArm|Left Arm|LeftArm",           "LeftLowerArm|Left Lower Arm|LeftHand" },
    { "LeftLowerArm|Left Lower Arm|LeftHand",    "LeftHand" },

    { "UpperTorso|Torso",                        "RightUpperArm|Right Arm|RightArm" },
    { "RightUpperArm|Right Arm|RightArm",        "RightLowerArm|Right Lower Arm|RightHand" },
    { "RightLowerArm|Right Lower Arm|RightHand", "RightHand" },

    -- Legs
    { "LowerTorso|Torso",                        "LeftUpperLeg|Left Leg|LeftLeg" },
    { "LeftUpperLeg|Left Leg|LeftLeg",           "LeftLowerLeg|Left Lower Leg|LeftFoot" },
    { "LeftLowerLeg|Left Lower Leg|LeftFoot",    "LeftFoot" },

    { "LowerTorso|Torso",                        "RightUpperLeg|Right Leg|RightLeg" },
    { "RightUpperLeg|Right Leg|RightLeg",        "RightLowerLeg|Right Lower Leg|RightFoot" },
    { "RightLowerLeg|Right Lower Leg|RightFoot", "RightFoot" }
}

local function FindPartByPatterns(Character, Pattern)
    local Patterns = Pattern:split("|")
    for _, pName in ipairs(Patterns) do
        local found = Character:FindFirstChild(pName)
        if found and found:IsA("BasePart") then
            return found
        end
    end
    return nil
end
pcall(function()
    for Name, Table in pairs(FontsToDownload) do
        local fn = Name:gsub("%s+", "")
        if isfile and not isfile(fn .. ".ttf") and writefile and game.HttpGet then
            writefile(fn .. ".ttf", game:HttpGet(Table.Link))
        end
        if isfile and not isfile(fn .. ".font") and writefile then
            local config = { name = fn, faces = {{ name = "Regular", weight = 400, style = "normal", assetId = getcustomasset(fn .. ".ttf") }}}
            writefile(fn .. ".font", HttpService:JSONEncode(config))
        end
        if isfile and getcustomasset and isfile(fn .. ".font") then
            local ok, asset = pcall(getcustomasset, fn .. ".font")
            if ok then
                local ok2, font = pcall(Font.new, asset, Enum.FontWeight.Regular)
                if ok2 and font then
                    ESPFonts.Loaded[Name] = font
                end
            end
        end
    end
end)
--

--// variables
local TrackedInstances = {}

--// functions
local function GetInstanceFromPath(path)
    local parts = string.split(path, ".")
    local current = game
    for _, partName in ipairs(parts) do
        if current == game and (partName == "Workspace" or partName == "workspace") then
            current = Workspace
        elseif current == game and partName == "Players" then
            current = Players
        else
            local found = current:FindFirstChild(partName)
            if found then
                current = found
            else
                return nil
            end
        end
    end
    return current ~= game and current or nil
end

local function CreateLine(parent)
    local line = Instance.new("Frame")
    line.BorderSizePixel = 0
    line.BackgroundColor3 = ESPConfig.BoxColor
    line.Parent = parent

    local outline = Instance.new("Frame")
    outline.BorderSizePixel = 0
    outline.BackgroundColor3 = ESPConfig.Outlines.Color
    outline.ZIndex = 0
    outline.Parent = line

    return line, outline
end

local CreateESPObj = LPHNoVirtualize(function(name)
    local espObj = {
        Visible = false,
        Lines = {},
        Outlines = {},
        CornerLines = {},
        CornerOutlines = {},
        CircleLines = {},
        CircleOutlines = {},
        FlagLabels = {},
        LastVisCheck = 0,
        CachedModelVisible = true
    }

    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Name = "ESPObj"
    container.Parent = ScreenGui
    espObj.Container = container

    local boxFill = Instance.new("Frame")
    boxFill.BorderSizePixel = 0
    boxFill.ZIndex = 0
    boxFill.Visible = false
    boxFill.Parent = container
    espObj.BoxFill = boxFill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Parent = boxFill
    espObj.BoxFillGradient = fillGradient

    for i = 1, 4 do
        local line, outline = CreateLine(container)
        espObj.Lines[i] = line
        espObj.Outlines[i] = outline
    end

    for i = 1, 8 do
        local line, outline = CreateLine(container)
        line.Visible = false
        outline.Visible = false
        espObj.CornerLines[i] = line
        espObj.CornerOutlines[i] = outline
    end

    for i = 1, CIRCLE_BOX_SEGMENTS do
        local line = Drawing.new("Line")
        line.Visible = false
        line.ZIndex = 2
        espObj.CircleLines[i] = line

        local outline = Drawing.new("Line")
        outline.Visible = false
        outline.ZIndex = 1
        espObj.CircleOutlines[i] = outline
    end

    local function SetupLabel(label)
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 100, 0, ESPConfig.TextSize)
        label.Font = _fontMap[ESPConfig.Font] or Enum.Font.Code
        if ESPFonts.Loaded[ESPConfig.Font] then
            label.FontFace = ESPFonts.Loaded[ESPConfig.Font]
        end
        label.TextSize = ESPConfig.TextSize
        label.TextColor3 = ESPConfig.TextColor
        label.TextStrokeTransparency = 1
        label.ZIndex = 2
        label.Parent = container

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = ESPConfig.TextOutlineColor or ESPConfig.Outlines.Color
        stroke.LineJoinMode = Enum.LineJoinMode.Miter
        stroke.Enabled = ESPConfig.TextOutline
        stroke.Parent = label
    end

    local nameText = Instance.new("TextLabel")
    SetupLabel(nameText)
    nameText.TextYAlignment = Enum.TextYAlignment.Bottom
    nameText.RichText = true
    nameText.Text = name
    nameText.Visible = ESPConfig.Names
    espObj.Text = nameText

    espObj.TeamText = nil
    espObj.TeamTextStroke = nil
    espObj.FriendlyText = nil
    espObj.FriendlyTextStroke = nil

    local distText = Instance.new("TextLabel")
    SetupLabel(distText)
    distText.TextYAlignment = Enum.TextYAlignment.Top
    distText.Visible = false
    espObj.DistanceText = distText

    local weaponText = Instance.new("TextLabel")
    SetupLabel(weaponText)
    weaponText.TextYAlignment = Enum.TextYAlignment.Top
    weaponText.Visible = false
    espObj.WeaponText = weaponText

    local healthBarOutline = Instance.new("Frame")
    healthBarOutline.BackgroundColor3 = ESPConfig.Outlines.Color
    healthBarOutline.BorderSizePixel = 0
    healthBarOutline.Visible = false
    healthBarOutline.ZIndex = 1
    healthBarOutline.Parent = container
    espObj.HealthBarOutline = healthBarOutline

    local healthBarContainer = Instance.new("Frame")
    healthBarContainer.BackgroundTransparency = 1
    healthBarContainer.ClipsDescendants = true
    healthBarContainer.BorderSizePixel = 0
    healthBarContainer.ZIndex = 2
    healthBarContainer.Parent = healthBarOutline
    espObj.HealthBarContainer = healthBarContainer

    local healthBar = Instance.new("Frame")
    healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    healthBar.BorderSizePixel = 0
    healthBar.ZIndex = 2
    healthBar.Parent = healthBarContainer
    espObj.HealthBar = healthBar

    local healthGradient = Instance.new("UIGradient")
    healthGradient.Enabled = ESPConfig.HealthBar.Gradient.Enabled
    healthGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ESPConfig.HealthBar.Gradient.Color1),
        ColorSequenceKeypoint.new(0.5, ESPConfig.HealthBar.Gradient.Color2),
        ColorSequenceKeypoint.new(1, ESPConfig.HealthBar.Gradient.Color3)
    })
    healthGradient.Parent = healthBar
    espObj.HealthGradient = healthGradient

    local healthText = Instance.new("TextLabel")
    SetupLabel(healthText)
    healthText.TextYAlignment = Enum.TextYAlignment.Center
    healthText.ZIndex = 3
    healthText.Visible = false
    espObj.HealthText = healthText

    for i = 1, 5 do -- Max 5 flags
        local flag = Instance.new("TextLabel")
        SetupLabel(flag)
        flag.TextSize = ESPConfig.Flags.TextSize
        flag.Font = _fontMap[ESPConfig.Flags.Font] or Enum.Font.Code
        if ESPFonts.Loaded[ESPConfig.Flags.Font] then
            flag.FontFace = ESPFonts.Loaded[ESPConfig.Flags.Font]
        end
        flag.Visible = false
        espObj.FlagLabels[i] = flag
    end

    espObj.Bones = {}
    espObj.BoneOutlines = {}
    for i = 1, #SKELETON_BONE_DEFS do
        local outline = Instance.new("Frame")
        outline.BorderSizePixel = 0
        outline.Visible = false
        outline.ZIndex = 1
        outline.Parent = container
        espObj.BoneOutlines[i] = outline

        local bone = Instance.new("Frame")
        bone.BorderSizePixel = 0
        bone.Visible = false
        bone.ZIndex = 2
        bone.Parent = container
        espObj.Bones[i] = bone
    end

    espObj.Adornments = {}
    espObj.Highlight = nil

    espObj.Destroy = function()
        container:Destroy()
        if espObj.Highlight then espObj.Highlight:Destroy() end
        if espObj.MeshShell then espObj.MeshShell:Destroy() end
        for _, a in pairs(espObj.Adornments) do a:Destroy() end
        for _, line in ipairs(espObj.CircleLines) do line:Remove() end
        for _, outline in ipairs(espObj.CircleOutlines) do outline:Remove() end
    end

    return espObj
end)

local UpdateESPObj = LPHNoVirtualize(function(espObj, position, size, name, distanceStuds, instance, isCheap, nonHuman,
                                              noStatus,
                                              configOverride, onScreen)
    local function GetCfg(path)
        local keys = path:split(".")
        local current = configOverride
        local default = ESPConfig

        local foundOverride = true
        for _, key in ipairs(keys) do
            if type(current) == "table" and current[key] ~= nil then
                current = current[key]
            else
                foundOverride = false
                break
            end
        end

        if foundOverride then return current end

        local currentDefault = default
        for _, key in ipairs(keys) do
            currentDefault = currentDefault[key]
        end
        return currentDefault
    end

    local humanoid = not nonHuman and instance:FindFirstChild("Humanoid") or nil

    -- Chams logic
    local isDead = (humanoid and humanoid.Health <= 0)
    local chamsEnabled = GetCfg("Chams.Enabled")
    if chamsEnabled and not isDead then
        local chamType = GetCfg("Chams.Type")
        if chamType == "Highlight" and (instance:IsA("Model") or instance:IsA("BasePart")) then
            -- Clean up MeshChams
            if espObj.MeshShell then
                espObj.MeshShell:Destroy()
                espObj.MeshShell = nil
                espObj.MeshHighlight = nil
            end
            if not espObj.Highlight then
                espObj.Highlight = Instance.new("Highlight")
            end
            local h = espObj.Highlight
            h.Parent = ChamsContainer
            h.Adornee = instance
            h.FillColor = GetCfg("Chams.Highlight.FillColor")
            h.FillTransparency = GetCfg("Chams.Highlight.FillTransparency")
            h.OutlineColor = GetCfg("Chams.Highlight.OutlineColor")
            h.OutlineTransparency = GetCfg("Chams.Highlight.OutlineTransparency")
            h.DepthMode = GetCfg("Chams.Highlight.VisibleCheck") and Enum.HighlightDepthMode.Occluded or
                Enum.HighlightDepthMode.AlwaysOnTop
            h.Enabled = true

            -- Hide adornments if they exist
            if espObj.Adornments then
                for _, a in pairs(espObj.Adornments) do a.Visible = false end
            end
        elseif chamType == "Adornment" then
            if espObj.Highlight then
                espObj.Highlight:Destroy()
                espObj.Highlight = nil
            end
            -- Clean up MeshChams
            if espObj.MeshShell then
                espObj.MeshShell:Destroy()
                espObj.MeshShell = nil
                espObj.MeshHighlight = nil
            end

            local parts = instance:IsA("Model") and instance:GetChildren() or { instance }
            local idx = 0

            local visCheck = GetCfg("Chams.Adornment.VisibleCheck")
            local visRate = GetCfg("VisibilityCheckRate") or 0.1
            local now = tick()
            local last = espObj.LastVisCheck or 0
            local shouldUpdate = (now - last) > visRate

            if visCheck and shouldUpdate then
                espObj.LastVisCheck = now
                local ignore = { UIContainer }
                if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
                if instance:IsA("Model") then
                    for _, v in ipairs(instance:GetDescendants()) do table.insert(ignore, v) end
                else
                    table.insert(ignore, instance)
                end

                local root = instance:IsA("Model") and
                    (instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChildWhichIsA("BasePart")) or
                    instance
                if root and root:IsA("BasePart") then
                    local obscuring = Camera:GetPartsObscuringTarget({ root.Position }, ignore)
                    espObj.CachedModelVisible = (#obscuring == 0)
                end
            end

            local occludedColor = GetCfg("Chams.Adornment.Color")
            local visibleColor = GetCfg("Chams.Adornment.VisibleColor")
            local finalColor = (visCheck and espObj.CachedModelVisible) and visibleColor or occludedColor

            for _, p in ipairs(parts) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    idx = idx + 1
                    local a = espObj.Adornments[idx]
                    if not a then
                        a = Instance.new("BoxHandleAdornment")
                        a.Name = "Cham"
                        a.Parent = ChamsContainer
                        espObj.Adornments[idx] = a
                    end

                    a.Adornee = p
                    a.Size = p.Size
                    a.Color3 = finalColor
                    a.Transparency = GetCfg("Chams.Adornment.Transparency")
                    a.AlwaysOnTop = GetCfg("Chams.Adornment.AlwaysOnTop")
                    a.ZIndex = 10
                    a.Visible = true
                end
            end
            -- Hide excess adornments beyond what the current part count needs
            for i = idx + 1, #espObj.Adornments do
                espObj.Adornments[i].Visible = false
            end
        elseif chamType == "MeshChams" then
            -- MeshChams only creates on actual player characters (including LocalPlayer if enabled).
            -- Directory entries, NPCs, and objects are all rejected even if they have a Humanoid.
            local playerOwner = Players:GetPlayerFromCharacter(instance)
            if not playerOwner then
                if espObj.MeshShell then
                    espObj.MeshShell:Destroy()
                    espObj.MeshShell = nil
                    espObj.MeshHighlight = nil
                end
            else
                -- Hide unneeded cham types
                if espObj.Highlight then
                    espObj.Highlight:Destroy()
                    espObj.Highlight = nil
                end
                if espObj.Adornments then
                    for _, a in pairs(espObj.Adornments) do a.Visible = false end
                end

                -- Build the shell model if it doesn't exist yet (or was parented away)
                if not espObj.MeshShell or not espObj.MeshShell.Parent then
                    if espObj.MeshShell then
                        espObj.MeshShell:Destroy()
                        espObj.MeshShell = nil
                        espObj.MeshHighlight = nil
                    end

                    CleanupCharacterMeshChams(instance)

                    local r6Parts      = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
                    local r15Parts     = {
                        "Head", "UpperTorso", "LowerTorso",
                        "LeftUpperArm", "LeftLowerArm", "LeftHand",
                        "RightUpperArm", "RightLowerArm", "RightHand",
                        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
                        "RightUpperLeg", "RightLowerLeg", "RightFoot",
                    }
                    local humanoidInst = instance:FindFirstChild("Humanoid")
                    local isR15        = humanoidInst and (humanoidInst.RigType == Enum.HumanoidRigType.R15)
                    local bodyParts    = isR15 and r15Parts or r6Parts

                    local shellModel   = Instance.new("Model")
                    shellModel.Name    = "ChamShells"
                    shellModel:SetAttribute("SensoryESP_MeshCham", true)
                    shellModel:SetAttribute("SensoryESP_RunId", CurrentRunId)
                    shellModel.Parent = instance

                    for _, partName in ipairs(bodyParts) do
                        local realPart = instance:FindFirstChild(partName)
                        if realPart and realPart:IsA("BasePart") then
                            local shell = Instance.new("Part")
                            shell.Name  = "ChamShell_" .. partName
                            shell:SetAttribute("SensoryESP_MeshCham", true)
                            shell:SetAttribute("SensoryESP_RunId", CurrentRunId)
                            shell.Size         = realPart.Size * 1.015
                            shell.Transparency = 0.9999999
                            shell.CastShadow   = false
                            shell.CanCollide   = false
                            shell.CanQuery     = false
                            shell.CanTouch     = false
                            shell.Anchored     = false
                            shell.Massless     = true
                            shell.CFrame       = realPart.CFrame
                            shell.Parent       = shellModel

                            local weld         = Instance.new("Weld")
                            weld.Part0         = shell
                            weld.Part1         = realPart
                            weld.C0            = CFrame.new()
                            weld.C1            = CFrame.new()
                            weld.Parent        = shell
                        end
                    end

                    -- Single Highlight covers the whole shell model, giving a mesh-like silhouette
                    local hl = Instance.new("Highlight")
                    hl.Name  = "ChamShellHighlight"
                    hl:SetAttribute("SensoryESP_MeshCham", true)
                    hl:SetAttribute("SensoryESP_RunId", CurrentRunId)
                    hl.Adornee           = shellModel
                    hl.Parent            = shellModel
                    espObj.MeshShell     = shellModel
                    espObj.MeshHighlight = hl
                end

                -- Update Highlight properties every frame
                if espObj.MeshHighlight then
                    local hl               = espObj.MeshHighlight
                    hl.FillColor           = GetCfg("Chams.MeshChams.FillColor")
                    hl.FillTransparency    = GetCfg("Chams.MeshChams.FillTransparency")
                    hl.OutlineColor        = GetCfg("Chams.MeshChams.OutlineColor")
                    hl.OutlineTransparency = GetCfg("Chams.MeshChams.OutlineTransparency")
                    hl.DepthMode           = GetCfg("Chams.MeshChams.VisibleCheck")
                        and Enum.HighlightDepthMode.Occluded
                        or Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Enabled             = true
                end
            end
        end
    else
        -- Chams disabled or dead, hide all
        if espObj.Highlight then
            espObj.Highlight:Destroy()
            espObj.Highlight = nil
        end
        if espObj.Adornments then
            for _, a in pairs(espObj.Adornments) do a.Visible = false end
        end
        if espObj.MeshShell then
            espObj.MeshShell:Destroy()
            espObj.MeshShell = nil
            espObj.MeshHighlight = nil
        end
    end

    -- Exit early if not on screen for 2D elements
    if not onScreen or not position or not size then
        espObj.Container.Visible = false
        for i = 1, #espObj.CircleLines do
            espObj.CircleLines[i].Visible = false
            espObj.CircleOutlines[i].Visible = false
        end
        return
    end

    espObj.Container.Visible = true
    espObj.Container.ZIndex = nonHuman and 1 or 10
    if GetCfg("Names") then
        espObj.Text.Text = name
    end

    local t = GetCfg("BoxThickness")
    local o = GetCfg("Outlines.Thickness")
    local textSize = GetCfg("TextSize")
    local textColor = GetCfg("TextColor")
    -- Update Label Properties
    espObj.Text.TextSize = textSize
    espObj.Text.TextColor3 = textColor
    espObj.Text.Font = _fontMap[GetCfg("Font")] or Enum.Font.Code
    if ESPFonts.Loaded[GetCfg("Font")] then
        espObj.Text.FontFace = ESPFonts.Loaded[GetCfg("Font")]
    end

    local _s = espObj.Text:FindFirstChildOfClass("UIStroke")
    if _s then
        _s.Color = GetCfg("TextOutlineColor") or GetCfg("Outlines.Color")
        _s.Enabled = GetCfg("TextOutline")
    end

    espObj.DistanceText.TextSize = textSize
    espObj.DistanceText.TextColor3 = textColor
    espObj.DistanceText.Font = _fontMap[GetCfg("Font")] or Enum.Font.Code
    if ESPFonts.Loaded[GetCfg("Font")] then
        espObj.DistanceText.FontFace = ESPFonts.Loaded[GetCfg("Font")]
    end

    espObj.WeaponText.TextSize = textSize
    espObj.WeaponText.TextColor3 = textColor
    espObj.WeaponText.Font = _fontMap[GetCfg("Font")] or Enum.Font.Code
    if ESPFonts.Loaded[GetCfg("Font")] then
        espObj.WeaponText.FontFace = ESPFonts.Loaded[GetCfg("Font")]
    end

    local px, py = math.floor(position.X), math.floor(position.Y)
    local sx, sy = math.floor(size.X), math.floor(size.Y)
    local x, y = math.floor(px - sx / 2), math.floor(py - sy / 2)

    -- Get Health Early for Layout Offsets
    local health, maxHealth, healthPercent = 100, 100, 1
    local humanoid = not nonHuman and instance:FindFirstChild("Humanoid") or nil
    if humanoid then
        health = humanoid.Health
        maxHealth = humanoid.MaxHealth
        healthPercent = math.clamp(health / maxHealth, 0, 1)
    end

    -- Offsets for HealthBar
    local topOffset = 0
    local bottomOffset = 0
    local leftOffset = 0
    local rightOffset = 0
    if GetCfg("HealthBar.Enabled") and instance:IsA("Model") and humanoid then
        local hpPos = GetCfg("HealthBar.Position")
        local thickness = GetCfg("HealthBar.Width") + 2 + GetCfg("HealthBar.SideGap")
        local isRight = GetCfg("Flags.Position") == "Right"
        local textExtra = (GetCfg("HealthBar.ShowText") and health < maxHealth) and 20 or 0

        if hpPos == "Top" then
            topOffset = thickness
        elseif hpPos == "Bottom" then
            bottomOffset = thickness
        elseif hpPos == "Left" then
            leftOffset = thickness + textExtra
        elseif hpPos == "Right" then
            rightOffset = thickness + textExtra
        end
    end

    if isCheap then
        for i = 1, 4 do
            espObj.Lines[i].Visible = false
            espObj.Outlines[i].Visible = false
        end
        for i = 1, #espObj.CircleLines do
            espObj.CircleLines[i].Visible = false
            espObj.CircleOutlines[i].Visible = false
        end
        espObj.HealthBarOutline.Visible = false
        espObj.HealthText.Visible = false
        espObj.WeaponText.Visible = false
        for _, l in ipairs(espObj.FlagLabels) do l.Visible = false end

        local distVal = distanceStuds
        if GetCfg("Distance.Unit") == "Meters" then
            distVal = math.floor(distanceStuds / GetCfg("Distance.StudsPerMeter"))
        else
            distVal = math.floor(distanceStuds)
        end

        espObj.Text.Text = name .. " " .. distVal .. GetCfg("Distance.Ending")
        espObj.Text.Position = UDim2.new(0, px - 50, 0, py - (textSize / 2))
        espObj.Text.Visible = GetCfg("Names")
        espObj.DistanceText.Visible = false
        return
    end

    -- Top
    espObj.Lines[1].Position = UDim2.new(0, x, 0, y)
    espObj.Lines[1].Size = UDim2.new(0, sx, 0, t)
    -- Bottom
    espObj.Lines[2].Position = UDim2.new(0, x, 0, y + sy)
    espObj.Lines[2].Size = UDim2.new(0, sx + t, 0, t)
    -- Left
    espObj.Lines[3].Position = UDim2.new(0, x, 0, y)
    espObj.Lines[3].Size = UDim2.new(0, t, 0, sy)
    -- Right
    espObj.Lines[4].Position = UDim2.new(0, x + sx, 0, y)
    espObj.Lines[4].Size = UDim2.new(0, t, 0, sy + t)

    local boxesEnabled = GetCfg("Boxes")
    local boxType = GetCfg("BoxType") or "Normal"
    local useCornerBoxes = boxType == "Corner"
    local useCircleBoxes = boxType == "Circle"
    local outlinesEnabled = GetCfg("Outlines.Enabled")
    local outlineColor = GetCfg("Outlines.Color")
    local outlineThickness = GetCfg("Outlines.Thickness")

    if useCornerBoxes then
        local cornerWidth = math.max(math.floor(sx * 0.25), t * 3)
        local cornerHeight = math.max(math.floor(sy * 0.25), t * 3)

        local cornerData = {
            { x,                        y,                         cornerWidth, t },
            { x,                        y,                         t,           cornerHeight },
            { x + sx - cornerWidth + t, y,                         cornerWidth, t },
            { x + sx,                   y,                         t,           cornerHeight },
            { x,                        y + sy,                    cornerWidth, t },
            { x,                        y + sy - cornerHeight + t, t,           cornerHeight },
            { x + sx - cornerWidth + t, y + sy,                    cornerWidth, t },
            { x + sx,                   y + sy - cornerHeight + t, t,           cornerHeight },
        }

        for i = 1, 8 do
            local data = cornerData[i]
            espObj.CornerLines[i].Position = UDim2.new(0, data[1], 0, data[2])
            espObj.CornerLines[i].Size = UDim2.new(0, data[3], 0, data[4])
        end
    elseif useCircleBoxes then
        local segments = CIRCLE_BOX_SEGMENTS
        local center = Vector2.new(x + (sx / 2), y + (sy / 2))
        local radiusInset = math.max(t + outlineThickness, 1)
        local rx = math.max((sx / 2) - radiusInset, t * 2)
        local ry = math.max((sy / 2) - radiusInset, t * 2)

        local angleStep = (math.pi * 2) / segments
        for i = 1, #espObj.CircleLines do
            local line = espObj.CircleLines[i]
            local outline = espObj.CircleOutlines[i]
            if i <= segments then
                local a1 = (i - 1) * angleStep
                local a2 = i * angleStep
                local p1 = center + Vector2.new(math.cos(a1) * rx, math.sin(a1) * ry)
                local p2 = center + Vector2.new(math.cos(a2) * rx, math.sin(a2) * ry)
                line.From = p1
                line.To = p2
                line.Color = GetCfg("BoxColor")
                line.Thickness = t
                line.Visible = boxesEnabled and useCircleBoxes

                outline.From = p1
                outline.To = p2
                outline.Color = outlineColor
                outline.Thickness = t + (outlineThickness * 2)
                outline.Visible = boxesEnabled and outlinesEnabled and useCircleBoxes
            else
                line.Visible = false
                outline.Visible = false
            end
        end
    end

    for i = 1, 4 do
        espObj.Lines[i].Visible = boxesEnabled and not useCornerBoxes and not useCircleBoxes
        espObj.Outlines[i].Visible = boxesEnabled and outlinesEnabled and not useCornerBoxes and not useCircleBoxes

        espObj.Outlines[i].Position = UDim2.new(0, -outlineThickness, 0, -outlineThickness)
        espObj.Outlines[i].Size = UDim2.new(1, outlineThickness * 2, 1, outlineThickness * 2)
        espObj.Lines[i].BackgroundColor3 = GetCfg("BoxColor")
        espObj.Outlines[i].BackgroundColor3 = outlineColor
    end

    for i = 1, 8 do
        espObj.CornerLines[i].Visible = boxesEnabled and useCornerBoxes
        espObj.CornerOutlines[i].Visible = boxesEnabled and outlinesEnabled and useCornerBoxes

        espObj.CornerOutlines[i].Position = UDim2.new(0, -outlineThickness, 0, -outlineThickness)
        espObj.CornerOutlines[i].Size = UDim2.new(1, outlineThickness * 2, 1, outlineThickness * 2)
        espObj.CornerLines[i].BackgroundColor3 = GetCfg("BoxColor")
        espObj.CornerOutlines[i].BackgroundColor3 = outlineColor
    end

    if not useCircleBoxes or not boxesEnabled then
        for i = 1, #espObj.CircleLines do
            espObj.CircleLines[i].Visible = false
            espObj.CircleOutlines[i].Visible = false
        end
    end

    -- BoxFill logic
    local fill = espObj.BoxFill
    local grad = espObj.BoxFillGradient
    if GetCfg("BoxFill.Enabled") and boxesEnabled and not useCircleBoxes then
        fill.Visible = true
        fill.Position = UDim2.new(0, x, 0, y)
        fill.Size = UDim2.new(0, sx, 0, sy)
        fill.BackgroundTransparency = GetCfg("BoxFill.Transparency")

        if GetCfg("BoxFill.Gradient.Enabled") then
            grad.Enabled = true
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, GetCfg("BoxFill.Gradient.Color1")),
                ColorSequenceKeypoint.new(0.5, GetCfg("BoxFill.Gradient.Color2")),
                ColorSequenceKeypoint.new(1, GetCfg("BoxFill.Gradient.Color3"))
            })

            local rot = GetCfg("BoxFill.Gradient.Rotation")
            if GetCfg("BoxFill.Gradient.Animated") then
                local speed = GetCfg("BoxFill.Gradient.Speed")
                local dir = GetCfg("BoxFill.Gradient.Direction") == "Left" and -1 or 1
                rot = (rot + (tick() * speed * dir)) % 360
            end
            grad.Rotation = rot
            fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            grad.Enabled = false
            fill.BackgroundColor3 = GetCfg("BoxFill.Color")
        end
    else
        fill.Visible = false
    end

    local nameY = y - textSize - (GetCfg("TextGap") or 0) - topOffset
    local teamOwner = instance:IsA("Model") and Players:GetPlayerFromCharacter(instance) or nil
    local leftTags = {}
    local rightTags = {}

    if GetCfg("TeamIndicator.Enabled") and teamOwner and teamOwner.Team then
        local teamColor = GetCfg("TeamIndicator.UseTeamColor") and teamOwner.TeamColor.Color or GetCfg("TeamIndicator.Color")
        local teamName = teamOwner.Team.Name
        local compactTeam = GetCfg("TeamIndicator.Compact") and CompactTeamName(teamName) or teamName
        local teamTag = string.format('<font color="%s">[%s]</font>', ColorToHex(teamColor), compactTeam)
        if GetCfg("TeamIndicator.Position") == "Left" then
            table.insert(leftTags, teamTag)
        else
            table.insert(rightTags, teamTag)
        end
    end

    local isFriendly = false
    if teamOwner and GetCfg("FriendlyIndicator.Enabled") then
        if GetCfg("FriendlyIndicator.CheckTeam") and LocalPlayer.Team ~= nil and teamOwner.Team == LocalPlayer.Team then
            isFriendly = true
        end
        if not isFriendly and GetCfg("FriendlyIndicator.CheckFriends") then
            local ok, result = pcall(function()
                return LocalPlayer:IsFriendsWith(teamOwner.UserId)
            end)
            if ok and result then
                isFriendly = true
            end
        end
    end

    if isFriendly then
        local friendlyTag = string.format('<font color="%s">%s</font>', ColorToHex(GetCfg("FriendlyIndicator.Color")), GetCfg("FriendlyIndicator.Text"))
        if GetCfg("FriendlyIndicator.Position") == "Left" then
            table.insert(leftTags, friendlyTag)
        else
            table.insert(rightTags, friendlyTag)
        end
    end

    local finalNameText = name
    if #leftTags > 0 then
        finalNameText = table.concat(leftTags, " ") .. " " .. finalNameText
    end
    if #rightTags > 0 then
        finalNameText = finalNameText .. " " .. table.concat(rightTags, " ")
    end

    if GetCfg("Names") then
        espObj.Text.Text = finalNameText
        espObj.Text.Position = UDim2.new(0, px - 50, 0, nameY)
        espObj.Text.Visible = true
    else
        espObj.Text.Visible = false
    end

    local currentBottomY = y + sy + (GetCfg("Distance.Gap") or 0) + bottomOffset
    if GetCfg("Distance.Enabled") then
        espObj.DistanceText.Visible = true
        espObj.DistanceText.Position = UDim2.new(0, px - 50, 0, currentBottomY)

        local distVal = distanceStuds
        if GetCfg("Distance.Unit") == "Meters" then
            distVal = math.floor(distanceStuds / GetCfg("Distance.StudsPerMeter"))
        else
            distVal = math.floor(distanceStuds)
        end
        espObj.DistanceText.Text = distVal .. GetCfg("Distance.Ending")
        currentBottomY = currentBottomY + GetCfg("TextSize") + (GetCfg("Weapon.Gap") or 0)
    else
        espObj.DistanceText.Visible = false
    end

    -- Weapon logic
    if GetCfg("Weapon.Enabled") then
        local weaponName = nil

        -- Simple 'Holding' check
        local holding = instance:FindFirstChild("Holding")
        if holding then
            if holding:IsA("ValueBase") then
                if holding.Value then
                    weaponName = tostring(holding.Value)
                end
            else
                weaponName = holding.Name
            end
        end

        -- Fallback
        if (not weaponName or weaponName == "" or weaponName == "nil") and GetCfg("Weapon.UseToolFallback") then
            local tool = instance:FindFirstChildWhichIsA("Tool")
            if tool then weaponName = tool.Name end
        end

        if weaponName and weaponName ~= "" and weaponName ~= "nil" then
            espObj.WeaponText.Visible = true
            espObj.WeaponText.Text = weaponName
            espObj.WeaponText.Position = UDim2.new(0, px - 50, 0, currentBottomY)
        else
            espObj.WeaponText.Visible = false
        end
    else
        espObj.WeaponText.Visible = false
    end

    -- HealthBar logic
    if GetCfg("HealthBar.Enabled") and instance:IsA("Model") and humanoid then
        -- Positioning
        local hpPos = GetCfg("HealthBar.Position")
        local isHorizontal = (hpPos == "Top" or hpPos == "Bottom")

        espObj.HealthBarOutline.Visible = true
        espObj.HealthBarOutline.BackgroundTransparency = GetCfg("HealthBar.Outline.Enabled") and 0 or 1
        espObj.HealthBarOutline.BackgroundColor3 = GetCfg("HealthBar.Outline.Color")

        if isHorizontal then
            local barWidth = math.floor((sx + 1) * healthPercent)
            espObj.HealthBarOutline.Size = UDim2.new(0, sx + 3, 0, GetCfg("HealthBar.Width") + 2)

            if hpPos == "Top" then
                espObj.HealthBarOutline.Position = UDim2.new(0, x - 1, 0,
                    y - o - GetCfg("HealthBar.SideGap") - GetCfg("HealthBar.Width") - 1)
            else -- Bottom
                espObj.HealthBarOutline.Position = UDim2.new(0, x - 1, 0, y + sy + o + GetCfg("HealthBar.SideGap"))
            end

            espObj.HealthBarContainer.Size = UDim2.new(0, barWidth, 0, GetCfg("HealthBar.Width"))
            espObj.HealthBarContainer.Position = UDim2.new(0, 1, 0, 1)

            -- Fixed Size Bar for static gradient
            espObj.HealthBar.Size = UDim2.new(0, sx + 1, 0, GetCfg("HealthBar.Width"))
            espObj.HealthBar.Position = UDim2.new(0, 0, 0, 0)
        else -- Vertical
            local barHeight = math.floor((sy + 1) * healthPercent)
            espObj.HealthBarOutline.Size = UDim2.new(0, GetCfg("HealthBar.Width") + 2, 0, sy + 3)

            if hpPos == "Left" then
                espObj.HealthBarOutline.Position = UDim2.new(0,
                    x - o - GetCfg("HealthBar.SideGap") - GetCfg("HealthBar.Width") - 1, 0, y - 1)
            else -- Right
                espObj.HealthBarOutline.Position = UDim2.new(0, x + sx + o + GetCfg("HealthBar.SideGap"), 0, y - 1)
            end

            espObj.HealthBarContainer.Size = UDim2.new(0, GetCfg("HealthBar.Width"), 0, barHeight)
            espObj.HealthBarContainer.Position = UDim2.new(0, 1, 0, (sy + 1) - barHeight + 1)

            -- Fixed Size Bar for static gradient
            espObj.HealthBar.Size = UDim2.new(0, GetCfg("HealthBar.Width"), 0, sy + 1)
            espObj.HealthBar.Position = UDim2.new(0, 0, 0, -(sy + 1 - barHeight))
        end

        -- Color & Gradient
        local healthColor = Color3.fromHSV(healthPercent * 0.3, 1, 1)
        if GetCfg("HealthBar.Gradient.Enabled") then
            espObj.HealthGradient.Rotation = isHorizontal and 0 or 90
            espObj.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            -- 3-Color Lerp Logic
            if healthPercent > 0.5 then
                -- Interpolate between Full (Color1) and Mid (Color2)
                local ratio = (1 - healthPercent) * 2
                healthColor = GetCfg("HealthBar.Gradient.Color1"):Lerp(GetCfg("HealthBar.Gradient.Color2"), ratio)
            else
                -- Interpolate between Mid (Color2) and Low (Color3)
                local ratio = (0.5 - healthPercent) * 2
                healthColor = GetCfg("HealthBar.Gradient.Color2"):Lerp(GetCfg("HealthBar.Gradient.Color3"), ratio)
            end
        else
            espObj.HealthBar.BackgroundColor3 = healthColor
        end

        local showText = GetCfg("HealthBar.ShowText")
        if GetCfg("HealthBar.HideWhenFullHP") and health >= maxHealth then
            showText = false
        end

        if showText then
            espObj.HealthText.Visible = true
            espObj.HealthText.Text = math.floor(health)
            espObj.HealthText.TextColor3 = GetCfg("HealthBar.FollowGradientColorText") and healthColor or
                GetCfg("TextColor")

            if isHorizontal then
                local barWidth = math.floor((sx + 1) * healthPercent)
                local barLeftX = x + barWidth - 1
                local textY = espObj.HealthBarOutline.Position.Y.Offset

                espObj.HealthText.TextXAlignment = Enum.TextXAlignment.Center
                espObj.HealthText.Size = UDim2.new(0, 0, 0, 0)

                if GetCfg("HealthBar.TextFollowBar") then
                    espObj.HealthText.Position = UDim2.new(0, barLeftX, 0, textY + (GetCfg("HealthBar.Width") / 2) + 1)
                else
                    espObj.HealthText.Position = UDim2.new(0, x + sx, 0, textY + (GetCfg("HealthBar.Width") / 2) + 1)
                end
            else
                local barHeight = math.floor((sy + 1) * healthPercent)
                local barOutlineX = espObj.HealthBarOutline.Position.X.Offset
                local barTopY = y + (sy + 1) - barHeight

                espObj.HealthText.TextXAlignment = hpPos == "Left" and Enum.TextXAlignment.Right or
                    Enum.TextXAlignment.Left
                espObj.HealthText.Size = UDim2.new(0, 0, 0, 0)

                local textX = hpPos == "Left" and (barOutlineX - 2) or (barOutlineX + GetCfg("HealthBar.Width") + 4)
                local textY = GetCfg("HealthBar.TextFollowBar") and barTopY or y
                espObj.HealthText.Position = UDim2.new(0, textX, 0, textY)
            end
        else
            espObj.HealthText.Visible = false
        end
    else
        espObj.HealthBarOutline.Visible = false
        espObj.HealthText.Visible = false
    end

    -- Flags logic
    for _, label in ipairs(espObj.FlagLabels) do label.Visible = false end
    if GetCfg("Flags.Enabled") and instance:IsA("Model") and not noStatus then
        local humanoid = instance:FindFirstChild("Humanoid")
        if humanoid then
            local flags = {}

            local state = humanoid:GetState()
            local isMoving = humanoid.MoveDirection.Magnitude > 0
            local isJumping = (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Freefall)
            local isSwimming = state == Enum.HumanoidStateType.Swimming

            if isMoving and isJumping and GetCfg("Flags.Options.Moving") and GetCfg("Flags.Options.Jumping") then
                table.insert(flags, { text = "Moving & Jumping", color = GetCfg("Flags.Colors.Moving") })
            elseif isJumping and GetCfg("Flags.Options.Jumping") then
                table.insert(flags, { text = "Jumping", color = GetCfg("Flags.Colors.Jumping") })
            elseif isMoving and GetCfg("Flags.Options.Moving") then
                table.insert(flags, { text = "Moving", color = GetCfg("Flags.Colors.Moving") })
            elseif isSwimming and GetCfg("Flags.Options.Swimming") then
                table.insert(flags, { text = "Swimming", color = GetCfg("Flags.Colors.Swimming") })
            elseif GetCfg("Flags.Options.Idle") then
                table.insert(flags, { text = "Idle", color = GetCfg("Flags.Colors.Idle") })
            end

            local isRight = GetCfg("Flags.Position") == "Right"
            local fx = isRight and (x + sx + GetCfg("Flags.SideGap") + rightOffset) or
                (x - 100 - GetCfg("Flags.SideGap") - leftOffset)
            local fy = y - 2

            if GetCfg("Flags.Font") == "Smallest Pixel-7" then
                fy = fy - 3
            end

            for i, data in ipairs(flags) do
                local label = espObj.FlagLabels[i]
                if label then
                    label.Visible = true
                    label.Text = data.text
                    label.TextColor3 = data.color
                    label.Font = _fontMap[GetCfg("Flags.Font")] or Enum.Font.Code
                    if ESPFonts.Loaded[GetCfg("Flags.Font")] then
                        label.FontFace = ESPFonts.Loaded[GetCfg("Flags.Font")]
                    end
                    label.TextSize = GetCfg("Flags.TextSize")
                    label.TextXAlignment = isRight and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                    label.Position = UDim2.new(0, fx, 0,
                        fy + (i - 1) * (GetCfg("Flags.TextSize") + GetCfg("Flags.TextGap")))
                end
            end
        end
    end

    -- Skeleton logic
    if GetCfg("Skeleton.Enabled") and instance:IsA("Model") then
        for i, def in ipairs(SKELETON_BONE_DEFS) do
            local boneFrame = espObj.Bones[i]
            local outlineFrame = espObj.BoneOutlines[i]

            local partA = FindPartByPatterns(instance, def[1])
            local partB = FindPartByPatterns(instance, def[2])

            if partA and partB then
                local posA, onA = WtS(Camera, partA.Position)
                local posB, onB = WtS(Camera, partB.Position)

                if onA or onB then
                    local pA = Vector2.new(posA.X, posA.Y)
                    local pB = Vector2.new(posB.X, posB.Y)

                    if GetCfg("Skeleton.Outline") then
                        DrawLine(outlineFrame, pA, pB, GetCfg("Skeleton.Thickness") + 2, GetCfg("Skeleton.OutlineColor"))
                    else
                        outlineFrame.Visible = false
                    end
                    DrawLine(boneFrame, pA, pB, GetCfg("Skeleton.Thickness"), GetCfg("Skeleton.Color"))
                else
                    boneFrame.Visible = false
                    outlineFrame.Visible = false
                end
            else
                boneFrame.Visible = false
                outlineFrame.Visible = false
            end
        end
    else
        if espObj.Bones then
            for _, b in ipairs(espObj.Bones) do b.Visible = false end
            for _, b in ipairs(espObj.BoneOutlines) do b.Visible = false end
        end
    end
end)
--

--// logic
local Get2DBoundingBox = LPHNoVirtualize(function(instance)
    local rootPart
    if instance:IsA("Model") then
        rootPart = instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChild("Torso") or
            instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
    elseif instance:IsA("BasePart") then
        rootPart = instance
    end

    if not rootPart then return false, nil, nil end

    local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then return false, nil, nil end

    if not ESPConfig.DynamicBoxes then
        -- STATIC BOX (No Jitter)
        local humanoid = instance:IsA("Model") and instance:FindFirstChild("Humanoid")
        if humanoid then
            -- Specialized player math for perfect stability
            local isR6 = humanoid.RigType == Enum.HumanoidRigType.R6
            local topOffset = isR6 and 2.8 or 3.0
            local bottomOffset = isR6 and 3.0 or 3.5

            local topPos = rootPart.Position + Vector3.new(0, topOffset, 0)
            local bottomPos = rootPart.Position - Vector3.new(0, bottomOffset, 0)
            local top2D = Camera:WorldToViewportPoint(topPos)
            local bottom2D = Camera:WorldToViewportPoint(bottomPos)
            local height = math.abs(top2D.Y - bottom2D.Y)
            return true, Vector2.new(position.X, (top2D.Y + bottom2D.Y) / 2), Vector2.new(height * 0.65, height)
        end

        -- Standard Static Object projection
        local cf, size
        if instance:IsA("Model") then
            cf, size = instance:GetBoundingBox()
        else
            cf, size = instance.CFrame, instance.Size
        end

        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local corners = {
            cf * Vector3.new(size.X / 2, size.Y / 2, size.Z / 2),
            cf * Vector3.new(-size.X / 2, size.Y / 2, size.Z / 2),
            cf * Vector3.new(size.X / 2, -size.Y / 2, size.Z / 2),
            cf * Vector3.new(-size.X / 2, -size.Y / 2, size.Z / 2),
            cf * Vector3.new(size.X / 2, size.Y / 2, -size.Z / 2),
            cf * Vector3.new(-size.X / 2, size.Y / 2, -size.Z / 2),
            cf * Vector3.new(size.X / 2, -size.Y / 2, -size.Z / 2),
            cf * Vector3.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
        }
        for _, corner in ipairs(corners) do
            local screenPos = Camera:WorldToViewportPoint(corner)
            if screenPos.X < minX then minX = screenPos.X end
            if screenPos.X > maxX then maxX = screenPos.X end
            if screenPos.Y < minY then minY = screenPos.Y end
            if screenPos.Y > maxY then maxY = screenPos.Y end
        end
        return true, Vector2.new((minX + maxX) / 2, (minY + maxY) / 2), Vector2.new(maxX - minX, maxY - minY)
    else
        -- DYNAMIC BOX (Wraps every moving part)
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local parts = {}
        if instance:IsA("Model") then
            for _, v in ipairs(instance:GetChildren()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Transparency ~= 1 then
                    table.insert(parts, v)
                end
            end
        else
            table.insert(parts, instance)
        end

        if #parts == 0 then return false, nil, nil end

        for _, part in ipairs(parts) do
            local cf, size = part.CFrame, part.Size
            local corners = {
                cf * Vector3.new(size.X / 2, size.Y / 2, size.Z / 2),
                cf * Vector3.new(-size.X / 2, size.Y / 2, size.Z / 2),
                cf * Vector3.new(size.X / 2, -size.Y / 2, size.Z / 2),
                cf * Vector3.new(-size.X / 2, -size.Y / 2, size.Z / 2),
                cf * Vector3.new(size.X / 2, size.Y / 2, -size.Z / 2),
                cf * Vector3.new(-size.X / 2, size.Y / 2, -size.Z / 2),
                cf * Vector3.new(size.X / 2, -size.Y / 2, -size.Z / 2),
                cf * Vector3.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
            }
            for _, corner in ipairs(corners) do
                local screenPos = Camera:WorldToViewportPoint(corner)
                if screenPos.X < minX then minX = screenPos.X end
                if screenPos.X > maxX then maxX = screenPos.X end
                if screenPos.Y < minY then minY = screenPos.Y end
                if screenPos.Y > maxY then maxY = screenPos.Y end
            end
        end
        return true, Vector2.new((minX + maxX) / 2, (minY + maxY) / 2), Vector2.new(maxX - minX, maxY - minY)
    end
end)
--

--// custom functions logic
local function CheckContains(instance, containsList)
    if type(containsList) ~= "table" or #containsList == 0 then return true end
    if #containsList == 1 and containsList[1] == "" then return true end
    for _, containName in ipairs(containsList) do
        local found = false
        for _, child in ipairs(instance:GetChildren()) do
            if child.Name == containName then
                found = true
                break
            end
        end
        if not found then return false end
    end
    return true
end

local function CheckNames(instance, namesList)
    if type(namesList) ~= "table" or #namesList == 0 then return true end
    if #namesList == 1 and namesList[1] == "" then return true end
    for _, name in ipairs(namesList) do
        if instance.Name == name then
            return true
        end
    end
    return false
end

local function CheckBlockNames(inst, blockList)
    if not blockList or #blockList == 0 then return false end
    local current = inst
    while current and current ~= game do
        for _, name in ipairs(blockList) do
            if name ~= "" and current.Name:find(name) then
                return true
            end
        end
        current = current.Parent
    end
    return false
end

local ScanDirectories = LPHNoVirtualize(function()
    local newTracked = {}

    if ESPConfig.Players then
        for _, player in ipairs(Players:GetPlayers()) do
            if not ESPConfig.LocalPlayer and player == LocalPlayer then continue end
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    newTracked[player.Character] = { name = player.Name, Cheap = false }
                end
            end
        end
    end

    for key, config in pairs(ESPConfig.Directories) do
        local displayName = nil
        if type(config) == "table" and config.DisplayName and config.DisplayName ~= "" then
            displayName = config.DisplayName
        elseif type(key) == "string" then
            displayName = key
        end

        if type(config) == "string" then
            local inst = GetInstanceFromPath(config)
            if inst then
                newTracked[inst] = { name = displayName or inst.Name, Cheap = false }
            end
        elseif type(config) == "table" then
            local path = config.Path
            if not path then continue end
            local inst = GetInstanceFromPath(path)
            if not inst then continue end

            local isCheap = config.Cheap or false
            local nonHuman = config.NonHuman or false
            local noStatus = config.NoStatus or false
            local customConfig = config.Config or {}
            local isRecursive = config.Recursive or false

            if config.Multiple then
                local children = isRecursive and inst:GetDescendants() or inst:GetChildren()
                for _, child in ipairs(children) do
                    if (child:IsA("Model") or child:IsA("BasePart")) then
                        -- Optimization: If we already tracked an ancestor of this object in this scan, skip it
                        local hasTrackedAncestor = false
                        local p = child.Parent
                        while p and p ~= inst and p ~= game do
                            if newTracked[p] then
                                hasTrackedAncestor = true
                                break
                            end
                            p = p.Parent
                        end

                        if not hasTrackedAncestor and CheckNames(child, config.Names) and CheckContains(child, config.Contains) and not CheckBlockNames(child, config.BlockNames) then
                            local humanoid = child:FindFirstChild("Humanoid")
                            if nonHuman or (not humanoid or humanoid.Health > 0) then
                                local actualName = (displayName and displayName ~= "") and displayName or child.Name
                                newTracked[child] = {
                                    name = actualName,
                                    Cheap = isCheap,
                                    NonHuman = nonHuman,
                                    NoStatus = noStatus,
                                    Config = customConfig
                                }
                            end
                        end
                    end
                end
            else
                if CheckNames(inst, config.Names) and CheckContains(inst, config.Contains) and not CheckBlockNames(inst, config.BlockNames) then
                    local humanoid = inst:FindFirstChild("Humanoid")
                    if nonHuman or (not humanoid or humanoid.Health > 0) then
                        local actualName = (displayName and displayName ~= "") and displayName or inst.Name
                        newTracked[inst] = {
                            name = actualName,
                            Cheap = isCheap,
                            NonHuman = nonHuman,
                            NoStatus = noStatus,
                            Config = customConfig
                        }
                    end
                end
            end
        end
    end

    for inst, data in pairs(newTracked) do
        if not TrackedInstances[inst] then
            TrackedInstances[inst] = {
                espObj = CreateESPObj(data.name),
                name = data.name,
                Cheap = data.Cheap,
                NonHuman = data.NonHuman,
                NoStatus = data.NoStatus,
                Config = data.Config
            }
        else
            TrackedInstances[inst].name = data.name
            TrackedInstances[inst].Cheap = data.Cheap
            TrackedInstances[inst].NonHuman = data.NonHuman
            TrackedInstances[inst].NoStatus = data.NoStatus
            TrackedInstances[inst].Config = data.Config
        end
    end

    for inst, data in pairs(TrackedInstances) do
        if not newTracked[inst] or not inst.Parent then
            data.espObj:Destroy()
            TrackedInstances[inst] = nil
        end
    end
end)

local lastScan = 0
local lastRender = 0
local function RuntimeStep()
    if not ESPConfig.Enabled then
        for inst, data in pairs(TrackedInstances) do
            if data.espObj then
                local disabledConfig = DeepCopy(data.Config or {})
                disabledConfig.Chams = disabledConfig.Chams or {}
                disabledConfig.Chams.Enabled = false
                UpdateESPObj(data.espObj, nil, nil, "", 0, inst, data.Cheap, data.NonHuman, data.NoStatus, disabledConfig, false)
            end
        end
        return
    end

    local now = tick()

    if ESPConfig.LimitFPS and ESPConfig.LimitFPS > 0 then
        if now - lastRender < (1 / ESPConfig.LimitFPS) then return end
        lastRender = now
    end

    if now - lastScan > 1 then
        lastScan = now
        ScanDirectories()
    end

    for inst, data in pairs(TrackedInstances) do
        if not inst or not inst.Parent then
            data.espObj:Destroy()
            TrackedInstances[inst] = nil
            continue
        end

        local humanoid = not data.NonHuman and inst:FindFirstChild("Humanoid") or nil
        if humanoid and humanoid.Health <= 0 then
            data.espObj:Destroy()
            TrackedInstances[inst] = nil
            continue
        end

        local rootPart = inst:IsA("Model") and
            (inst.PrimaryPart or inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChildWhichIsA("BasePart")) or
            (inst:IsA("BasePart") and inst)

        if rootPart then
            local onscreen, pos2d, size2d = Get2DBoundingBox(inst)
            local distanceStuds = (Camera.CFrame.Position - rootPart.Position).Magnitude
            UpdateESPObj(data.espObj, pos2d, size2d, data.name, distanceStuds, inst, data.Cheap, data.NonHuman,
                data.NoStatus, data.Config, onscreen)
        else
            UpdateESPObj(data.espObj, nil, nil, data.name, 0, inst, data.Cheap, data.NonHuman, data.NoStatus, data
                .Config, false)
        end
    end
end

function ESP:Unload()
    for inst, data in pairs(TrackedInstances) do
        if data.espObj then
            data.espObj:Destroy()
        end
        TrackedInstances[inst] = nil
    end

    if PlayerRemovingConnection then
        PlayerRemovingConnection:Disconnect()
        PlayerRemovingConnection = nil
    end
    if InputBeganConnection then
        InputBeganConnection:Disconnect()
        InputBeganConnection = nil
    end
    if getgenv().SensoryESP_Loop then
        getgenv().SensoryESP_Loop:Disconnect()
        getgenv().SensoryESP_Loop = nil
    end
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
    if ChamsContainer then
        ChamsContainer:Destroy()
        ChamsContainer = nil
    end
    if MeshChamsFolder then
        MeshChamsFolder:Destroy()
        MeshChamsFolder = nil
    end

    CleanupMeshChams(Workspace)
    for _, player in ipairs(BootstrapPlayers:GetPlayers()) do
        CleanupCharacterMeshChams(player.Character)
    end

    getgenv().SensoryESP_UI = nil
end

function ESP:Load(config)
    self:Unload()

    ESPConfig = DeepMerge(DeepCopy(DefaultESPConfig), config or {})
    EnsureRootInstances()
    CurrentRunId = HttpService:GenerateGUID(false)
    lastScan = 0
    lastRender = 0

    PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        for inst, data in pairs(TrackedInstances) do
            if Players:GetPlayerFromCharacter(inst) == player then
                data.espObj:Destroy()
                TrackedInstances[inst] = nil
            end
        end
    end)

    InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and ESPConfig.Keybind.Enabled and input.KeyCode == ESPConfig.Keybind.Key then
            ESPConfig.Enabled = not ESPConfig.Enabled
        end
    end)

    getgenv().SensoryESP_Loop = RunService.RenderStepped:Connect(RuntimeStep)
    ScanDirectories()
    return self
end

function ESP:GetConfig()
    return ESPConfig
end

getgenv().SensoryESP_Unload = function()
    ESP:Unload()
end

return ESP
