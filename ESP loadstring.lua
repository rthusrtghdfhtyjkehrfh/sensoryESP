local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/rthusrtghdfhtyjkehrfh/sensoryESP/main/ESP.lua"))()

esp:Load({
    -- checks
    Enabled = true,

    Keybind = {
        Enabled = true,
        Key = Enum.KeyCode.Insert,
    },

    Players = true,
    LocalPlayer = false,

    LimitFPS = 70,
    DynamicBoxes = true,
    VisibilityCheckRate = 0.3,

	-- kd
	FriendlyIndicator = {
    	Enabled = true,
    	CheckTeam = true,
    	CheckFriends = true,
    	Text = "[F]",
    	Color = Color3.fromRGB(0, 255, 0),
	},
		
    -- boxes
    Boxes = true,
    BoxType = "Corner",

    BoxColor = Color3.fromRGB(255,255,255),
    BoxThickness = 1,

    Outlines = {
        Enabled = true,
        Color = Color3.fromRGB(0,0,0),
        Thickness = 1,
    },

    -- fill
    BoxFill = {
        Enabled = true,

        Color = Color3.fromRGB(255,255,255),
        Transparency = 0.9,

        Gradient = {
            Enabled = true,

            Color1 = Color3.fromRGB(180,255,255),
            Color2 = Color3.fromRGB(0,255,255),
            Color3 = Color3.fromRGB(0,120,255),

            Rotation = 0,

            Animated = true,
            Speed = 64,
            Direction = "Right",
        }
    },

    -- health
    HealthBar = {
        Enabled = true,

        Position = "Left",
        SideGap = 2,
        Width = 2,

        ShowText = true,
        TextFollowBar = true,

        HideWhenFullHP = true,
        FollowGradientColorText = true,

        Outline = {
            Enabled = true,
            Color = Color3.fromRGB(0,0,0),
        },

        Gradient = {
            Enabled = true,

            Color1 = Color3.fromRGB(0,255,0),
            Color2 = Color3.fromRGB(255,255,0),
            Color3 = Color3.fromRGB(255,0,0),
        }
    },

    -- text
    TextSize = 12,
    TextColor = Color3.fromRGB(255,255,255),
    TextOutline = true,
    TextGap = 3,
    Font = "Proggy Clean",

    -- weapon
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
            Idle = Color3.fromRGB(255,255,255),
            Moving = Color3.fromRGB(255,255,255),
            Jumping = Color3.fromRGB(255,255,255),
            Swimming = Color3.fromRGB(65,65,255),
        }
    },

    -- skeleton
    Skeleton = {
        Enabled = false,

        Color = Color3.fromRGB(255,255,255),

        Outline = true,
        OutlineColor = Color3.fromRGB(0,0,0),

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

        Type = "Highlight",

        Highlight = {
            FillColor = Color3.fromRGB(255,255,255),
            FillTransparency = 1,

            OutlineColor = Color3.fromRGB(255,255,255),
            OutlineTransparency = 0,

            VisibleCheck = false,
        },

        Adornment = {
            Color = Color3.fromRGB(59,144,204),
            VisibleColor = Color3.fromRGB(59,204,90),

            Transparency = 0.7,

            AlwaysOnTop = true,
            VisibleCheck = false,
        },

        MeshChams = {
            FillColor = Color3.fromRGB(59,144,204),
            FillTransparency = 0.6,

            OutlineColor = Color3.fromRGB(255,255,255),
            OutlineTransparency = 0,

            VisibleCheck = false,
        },
    },

    -- directories
    Directories = {
        {
        --example
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
		BoxType = "Corner",
                BoxColor = Color3.fromRGB(255, 150, 0),
                BoxThickness = 1,


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

                -- Skeleton 
                Skeleton = {
                    Enabled = false,
                    Color = Color3.fromRGB(255, 255, 255),
                    Outline = true,
                    OutlineColor = Color3.fromRGB(0, 0, 0),
                    Thickness = 1,
                }
            }
        }
    }
})
