local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local challengesModule = HardcoreChallengeWheel:GetModule("Challenges")

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
                args = {}
            },
            customGroup = {
                type = "group",
                name = "Add Custom Challenge",
                inline = false,
                order = 2,
                args = {
                    title = {
                        type = "input",
                        name = "Challenge Title",
                        desc = "",
                        set = function(info, val)
                            HardcoreChallengeWheel.customChallengeForm.title =
                                val
                        end,
                        get = function(info)
                            return HardcoreChallengeWheel.customChallengeForm
                                       .title
                        end
                    },
                    description = {
                        type = "input",
                        name = "Description",
                        desc = "",
                        set = function(info, val)
                            HardcoreChallengeWheel.customChallengeForm
                                .description = val
                        end,
                        get = function(info)
                            return HardcoreChallengeWheel.customChallengeForm
                                       .description
                        end
                    },
                    iconGroup = {
                        type = "group",
                        name = "",
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
                                            print(
                                                HardcoreChallengeWheel.customChallengeForm
                                                    .challengeIconID)
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

    optionsTable.args.enabledChallenges.args["customChallengesHeader"] = {
        type = "header",
        name = "HC Wheel Challenges",
        order = #allChallenges.achievements + 2
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

    -- Register the options table
    AceConfig:RegisterOptionsTable("HardcoreChallengeWheel", optionsTable)
    AceConfigDialog:AddToBlizOptions("HardcoreChallengeWheel",
                                     "Hardcore Challenge Wheel")
end

