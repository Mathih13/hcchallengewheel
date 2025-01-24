local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local challengesModule = HardcoreChallengeWheel:GetModule("Challenges")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

function HardcoreChallengeWheel:BuildOptions()
    local optionsTable = {
        type = "group",
        name = "Hardcore Challenge Wheel",
        args = {
            introText = {
                type = "description",
                name = "Welcome to the Hardcore Challenge Wheel settings! Below, you can enable or disable challenges to customize your experience.\n\nYou can also access settings quickly by right-clicking the icon of your current challenge.",
                fontSize = "medium", -- Options: "small", "medium", "large"
                order = 1 -- Order determines the display order
            },
            settingsHeader = {type = "header", name = "Settings", order = 2},
            generalSettings = {
                type = "group",
                order = 1,
                name = "General Settings",
                desc = "Settings related to general features.",
                inline = false, -- Makes it collapsible if false
                args = {
                    minimalMode = {
                        type = "toggle",
                        name = "Minimal Mode",
                        desc = "Toggle between the minimal and detailed display for the current challenge.",
                        set = function(info, val)
                            HardcoreChallengeWheel.db.profile.minimalMode = val
                            HardcoreChallengeWheel:OpenReminderFrame()
                        end,
                        get = function(info)
                            return HardcoreChallengeWheel.db.profile.minimalMode
                        end
                    },
                    wheelSpinDuration = {
                        type = "range",
                        name = "Wheel Spin Duration",
                        desc = "Adjust the time it takes for the wheel to reach the decided challenge.",
                        min = 1,
                        max = 10,
                        step = 1,
                        set = function(info, val)
                            HardcoreChallengeWheel.db.profile.wheelSpinDuration =
                                val
                        end,
                        get = function(info)
                            return HardcoreChallengeWheel.db.profile
                                       .wheelSpinDuration
                        end
                    }
                }
            },
            enabledChallenges = {
                type = "group",
                name = "Enabled Challenges",
                desc = "Select which challenges are enabled.",
                inline = false,
                width = "full",
                order = 2,
                args = {}
            },
            customGroup = {
                type = "group",
                name = "Add Custom Challenge",
                inline = false,
                order = 3,
                args = {
                    header = {type = "header", name = "Experimental", order = 1},
                    firstRow = {
                        order = 1,
                        type = "group",
                        name = "",
                        inline = true,
                        args = {
                            title = {
                                type = "input",
                                name = "Challenge Title",
                                desc = "",
                                order = 3,
                                set = function(info, val)
                                    HardcoreChallengeWheel.customChallengeForm
                                        .title = val
                                end,
                                get = function(info)
                                    return
                                        HardcoreChallengeWheel.customChallengeForm
                                            .title
                                end
                            },
                            classSelect = {
                                type = "select",
                                name = "Class",
                                desc = "Select the class this challenge is for.",
                                order = 4,
                                width = 1,
                                values = {
                                    ["All"] = "All",
                                    ["Warrior"] = "Warrior",
                                    ["Druid"] = "Druid",
                                    ["Shaman"] = "Shaman",
                                    ["Priest"] = "Priest",
                                    ["Rogue"] = "Rogue",
                                    ["Hunter"] = "Hunter",
                                    ["Paladin"] = "Paladin",
                                    ["Mage"] = "Mage"
                                },
                                get = function(info)
                                    return
                                        HardcoreChallengeWheel.customChallengeForm
                                            .class
                                end,
                                set = function(info, val)
                                    HardcoreChallengeWheel.customChallengeForm
                                        .class = val
                                end
                            },
                            resetButton = {
                                type = "execute",
                                name = "Reset",
                                order = 5,
                                func = function()
                                    HardcoreChallengeWheel.customChallengeForm =
                                        {}
                                    AceConfigRegistry:NotifyChange(
                                        "HardcoreChallengeWheel")
                                end,
                                width = 0.5
                            }
                        }
                    },
                    description = {
                        type = "input",
                        name = "Description",
                        desc = "",
                        width = "full", -- Adjust the width (e.g., "full" spans the entire options panel width)
                        order = 5,
                        multiline = true,
                        set = function(info, val)
                            HardcoreChallengeWheel.customChallengeForm
                                .description = val
                        end,
                        get = function(info)
                            return HardcoreChallengeWheel.customChallengeForm
                                       .description
                        end
                    },
                    saveButton = {
                        type = "execute",
                        name = "Save challenge",
                        order = 7,
                        func = function()
                            local challengesModule =
                                HardcoreChallengeWheel:GetModule("Challenges")
                            challengesModule:AddCustomChallenge(
                                HardcoreChallengeWheel.customChallengeForm.title,
                                HardcoreChallengeWheel.customChallengeForm
                                    .description,
                                HardcoreChallengeWheel.customChallengeForm
                                    .challengeIconID,
                                HardcoreChallengeWheel.customChallengeForm.class)

                            HardcoreChallengeWheel.customChallengeForm = {}
                            HardcoreChallengeWheel:Print("Challenge saved!")
                        end,
                        width = "full"
                    },
                    iconGroup = {
                        type = "group",
                        name = "",
                        order = 6,
                        inline = true, -- Makes everything appear in the same section
                        args = {
                            row1 = {
                                type = "group",
                                name = "",
                                inline = true, -- Keep the items aligned in one row
                                args = {
                                    label = {
                                        type = "description",
                                        name = "Challenge Icon",
                                        fontSize = "medium",
                                        width = "normal" -- Takes remaining space in the row
                                    },
                                    selectedIconPreview = {
                                        type = "description",
                                        name = "",
                                        image = function()
                                            if HardcoreChallengeWheel.customChallengeForm
                                                .challengeIconID ~= nil then
                                                return
                                                    HardcoreChallengeWheel.customChallengeForm
                                                        .challengeIconID
                                            end
                                            return
                                                "Interface\\Icons\\INV_Misc_QuestionMark"
                                        end,
                                        imageWidth = 32,
                                        imageHeight = 32,
                                        width = 0.33 -- Adjust the width of the icon
                                    },
                                    button = {
                                        type = "execute",
                                        name = "Select Icon",
                                        func = function()
                                            HardcoreChallengeWheel:OpenIconPicker()
                                        end,
                                        width = "normal" -- Normal button width
                                    }
                                }
                            }

                        }
                    },
                    customChallenges = {
                        type = "group",
                        name = "My Custom Challenges",
                        desc = "",
                        inline = true,
                        width = "full",
                        args = {},
                        order = 8
                    }

                }
            },
            communication = {
                order = 4,
                inline = false,
                type = "group",
                name = "Communication",
                desc = "Experimental features for communicating with other players, seeing other players challenges, and more.",
                args = {
                    header = {
                        type = "header",
                        name = "Experimental features",
                        order = 1
                    },
                    description = {
                        type = "description",
                        name = "These features are still exprimental and may not work as expected.",
                        fontSize = "medium",
                        order = 2
                    },
                    spacer = {type = "description", name = "", order = 3},
                    announceLevelUp = {
                        type = "toggle",
                        name = "Announce Challenge",
                        desc = "Display a message to other players when you recieve a new challenge.",
                        order = 4,
                        set = function(info, val)
                            HardcoreChallengeWheel.db.profile.announceChallenge =
                                val
                        end,
                        get = function(info)
                            return HardcoreChallengeWheel.db.profile
                                       .announceChallenge
                        end
                    },
                    announceChannel = {
                        type = "select",
                        name = "Announce Channel",
                        desc = "Select the channel to send the announce message to.",
                        order = 5,
                        values = {
                            ["EMOTE"] = "Emote",
                            ["PARTY"] = "Party",
                            ["SAY"] = "Say"
                        },
                        get = function(info)
                            return HardcoreChallengeWheel.db.profile
                                       .announceChannel
                        end,
                        set = function(info, val)
                            HardcoreChallengeWheel.db.profile.announceChannel =
                                val
                        end
                    },
                    showTargetChallenge = {
                        type = "toggle",
                        name = "Show Target Challenge",
                        order = 7,
                        desc = "Show another players challenge when targeted.",
                        set = function(info, val)
                            HardcoreChallengeWheel.db.profile
                                .showTargetChallenge = val
                            HardcoreChallengeWheel:ToggleTargetFrame()

                            if val == false then
                                HardcoreChallengeWheel.targetChallengeFrame:Hide()
                            end
                        end,
                        get = function(info)
                            return HardcoreChallengeWheel.db.profile
                                       .showTargetChallenge
                        end,
                        width = "full"
                    },
                    explanation = {
                        type = "description",
                        name = "",
                        image = "Interface\\AddOns\\HardcoreChallengeWheel\\Textures\\targetchallengeexample",
                        imageWidth = 256, -- Adjust as needed
                        imageHeight = 128, -- Adjust as needed
                        width = "full", -- Ensures the image spans the full width of the options panel
                        order = 8
                    }

                }
            }
        }
    }

    local allChallenges = challengesModule:GetOptionsData()

    optionsTable.args.enabledChallenges.args["achievementsHeader"] = {
        type = "header",
        name = "Hardcore Achievements",
        order = 1
    }

    for index, entry in ipairs(allChallenges.achievements) do
        local key = entry.key
        local challenge = entry.data
        local description = challenge.description

        local width = "normal"

        if challenge.class ~= "All" and challenge.class ~=
            HardcoreChallengeWheel.db.profile.class then
            challenge.title = "|cFF808080" .. challenge.title .. "|r"
            description = "|cFFFFD100[" .. challenge.class .. "]|r\n\n" ..
                              description ..
                              "\n\n|cFF808080This challenge is not available for your class.|r"
        end

        if HardcoreChallengeWheel.db.profile.challenges[challenge.name] == nil then
            HardcoreChallengeWheel.db.profile.challenges[challenge.name] = true
        end

        optionsTable.args.enabledChallenges.args["achievement_" .. key] = {
            type = "toggle",
            name = "|T" .. challenge.icon_path .. ":24:24:0:0|t " ..
                challenge.title,
            desc = description,
            width = width,

            set = function(info, val)
                HardcoreChallengeWheel.db.profile.challenges[key] = val
            end,
            get = function(info)
                return HardcoreChallengeWheel.db.profile.challenges[key]
            end,
            order = index + 1
        }
    end

    optionsTable.args.enabledChallenges.args["builtInChallengesHeader"] = {
        type = "header",
        name = "HC Wheel Challenges",
        order = #allChallenges.achievements + 2
    }

    for index, entry in ipairs(allChallenges.builtInChallenges) do
        local key = entry.key
        local challenge = entry.data
        local description

        if challenge.level then
            description = "|cFFC79C6ERequires Level " .. challenge.level ..
                              "|r\n" .. challenge.description
        else
            description = challenge.description
        end

        local width = "normal"

        if challenge.class ~= "All" and challenge.class ~=
            HardcoreChallengeWheel.db.profile.class then
            challenge.title = "|cFF808080" .. challenge.title .. "|r"
            description = "|cFFFFD100[" .. challenge.class .. "]|r\n" ..
                              description ..
                              "\n\n|cFF808080This challenge is not available for your class.|r"
        else
            description = "|cFFFFD100[" .. challenge.class .. "]|r\n" ..
                              description
        end

        if HardcoreChallengeWheel.db.profile.challenges[challenge.name] == nil then
            HardcoreChallengeWheel.db.profile.challenges[challenge.name] = true
        end

        optionsTable.args.enabledChallenges.args["custom_" .. key] = {
            type = "toggle",
            name = "|T" .. challenge.icon_path .. ":24:24:0:0|t " ..
                challenge.title,
            desc = description,
            width = width,
            set = function(info, val)
                HardcoreChallengeWheel.db.profile.challenges[key] = val
            end,
            get = function(info)
                return HardcoreChallengeWheel.db.profile.challenges[key]
            end,
            order = #allChallenges.achievements + 2 + index
        }
    end

    optionsTable.args.enabledChallenges.args["customChallengesHeader"] = {
        type = "header",
        name = "My Custom Challenges",
        order = #allChallenges.builtInChallenges + #allChallenges.achievements +
            3
    }

    for index, entry in ipairs(allChallenges.customChallenges) do
        local key = entry.key
        local challenge = entry.data
        local description = challenge.description

        local width = "normal"

        if challenge.class ~= "All" and challenge.class ~=
            HardcoreChallengeWheel.db.profile.class then
            challenge.title = "|cFF808080" .. challenge.title .. "|r"
            description = "|cFFFFD100[" .. challenge.class .. "]|r\n\n" ..
                              description ..
                              "\n\n|cFF808080This challenge is not available for your class.|r"
        end

        if HardcoreChallengeWheel.db.profile.challenges[challenge.name] == nil then
            HardcoreChallengeWheel.db.profile.challenges[challenge.name] = true
        end

        optionsTable.args.enabledChallenges.args[key] = {
            type = "toggle",
            name = "|T" .. challenge.icon_path .. ":24:24:0:0|t " ..
                challenge.title,
            desc = description,
            width = width,
            set = function(info, val)
                HardcoreChallengeWheel.db.profile.challenges[key] = val
            end,
            get = function(info)
                return HardcoreChallengeWheel.db.profile.challenges[key]
            end,
            order = #allChallenges.achievements +
                #allChallenges.builtInChallenges + index + 2
        }
    end

    for index, entry in ipairs(allChallenges.customChallenges) do
        local key = entry.key
        local challenge = entry.data
        local description = challenge.description

        local width = "normal"

        optionsTable.args.customGroup.args.customChallenges.args[key] = {
            type = "group",
            inline = true, -- Ensures it appears as a single line
            name = "",
            args = {
                description = {
                    order = 1,
                    type = "description",
                    name = "|T" .. challenge.icon_path .. ":24:24:0:0|t " ..
                        challenge.title,
                    fontSize = "medium",
                    width = 1.5
                },
                action1 = {
                    order = 2,
                    type = "execute",
                    name = "Edit",
                    func = function()
                        self.customChallengeForm.title = challenge.title
                        self.customChallengeForm.description =
                            challenge.description
                        self.customChallengeForm.challengeIconID =
                            challenge.icon_path
                        self.customChallengeForm.class = challenge.class
                        self.customChallengeForm.key = key
                        AceConfigRegistry:NotifyChange("HardcoreChallengeWheel")
                    end,
                    width = 0.5
                },
                action2 = {
                    order = 3,
                    type = "execute",
                    name = "Delete",
                    func = function()
                        challengesModule:RemoveCustomChallenge(key)
                    end,
                    width = 0.5
                }
            }
        }
    end

    -- Register the options table
    HardcoreChallengeWheel.optionsTable = optionsTable
    AceConfig:RegisterOptionsTable("HardcoreChallengeWheel", optionsTable)
    AceConfigDialog:AddToBlizOptions("HardcoreChallengeWheel",
                                     "Hardcore Challenge Wheel")
end

