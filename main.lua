-- Declare your addon as an AceAddon
HardcoreChallengeWheel = LibStub("AceAddon-3.0"):NewAddon(
                             "HardcoreChallengeWheel", "AceConsole-3.0",
                             "AceEvent-3.0")

-- Database defaults
local defaults = {
    profile = {
        wheelSpinDuration = 4,
        challenges = {
            ["TrioMade"] = false,
            ["PartnerUp"] = false,
            ["DuoMade"] = false,
            ["NoHit"] = false
        },
        defaultDisabledChallenges = {"NoHit"},
        class = UnitClass("player")
    }
}

local reminderFrame

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- OnInitialize function (runs when the add-on is loaded)
function HardcoreChallengeWheel:OnInitialize()
    -- Load the database
    self.db = LibStub("AceDB-3.0"):New("HardcoreChallengeWheelDB", defaults,
                                       true)

    if not IsAddOnLoaded("Blizzard_ClassicUIResources") then
        LoadAddOn("Blizzard_ClassicUIResources") -- Ensures dropdown functionality is available
    end

    local optionsTable = {
        type = "group",
        name = "Hardcore Challenge Wheel",
        args = {
            introText = {
                type = "description",
                name = "Welcome to the Hardcore Challenge Wheel settings! Below, you can enable or disable challenges to customize your experience.\n\nYou can also access settings quickly by right-clicking the title or icon of your current challenge.",
                fontSize = "medium", -- Options: "small", "medium", "large"
                order = 1 -- Order determines the display order
            },
            settingsHeader = {type = "header", name = "Settings", order = 2},
            generalSettings = {
                type = "group",
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
            itemListGroup = {
                type = "group",
                name = "Enabled Challenges",
                desc = "Select which challenges are enabled.",
                inline = false,
                args = {}
            }
        }
    }

    for name, challenge in pairs(_G.achievements) do
        local name = challenge.title
        local description = challenge.description

        if challenge.class ~= "All" and challenge.class ~=
            HardcoreChallengeWheel.db.profile.class then
            name = "|cFF808080" .. name .. "|r"
            description = description ..
                              "\n\n|cFF808080This challenge is not available for your class.|r"

        end

        if HardcoreChallengeWheel.db.profile.challenges[challenge.name] == nil then
            HardcoreChallengeWheel.db.profile.challenges[challenge.name] = true
        end

        optionsTable.args.itemListGroup.args[challenge.name] = {
            type = "toggle",
            name = "|T" .. challenge.icon_path .. ":24:24:0:0|t " .. name,
            desc = description,
            set = function(info, val)
                HardcoreChallengeWheel.db.profile.challenges[challenge.name] =
                    val
            end,
            get = function(info)
                return
                    HardcoreChallengeWheel.db.profile.challenges[challenge.name]
            end
        }

    end

    -- Register the options table
    AceConfig:RegisterOptionsTable("HardcoreChallengeWheel", optionsTable)
    AceConfigDialog:AddToBlizOptions("HardcoreChallengeWheel",
                                     "Hardcore Challenge Wheel")

    -- Register chat commands
    self:RegisterChatCommand("hcwheel", "SlashCommand")
    local levelUpFrame = CreateFrame("Frame")

    levelUpFrame:RegisterEvent("PLAYER_LEVEL_UP")
    levelUpFrame:RegisterEvent("PLAYER_LEVEL_CHANGED")

    levelUpFrame:SetScript("OnEvent", function(self, event, newLevel, ...)
        if event == "PLAYER_LEVEL_UP" then
            HardcoreChallengeWheel:RollChallenge()
        end

        print(event)
    end)

    if HardcoreChallengeWheel.db.char.selectedChallenge then
        HardcoreChallengeWheel:OpenReminderFrame()
        reminderFrame:SetChallenge(HardcoreChallengeWheel.db.char
                                       .selectedChallenge)
    end

end

function HardcoreChallengeWheel:SwapReminderMode()
    if HardcoreChallengeWheel.db.profile.minimalMode then
        HardcoreChallengeWheel.db.profile.minimalMode = false
    else
        HardcoreChallengeWheel.db.profile.minimalMode = true
    end

    HardcoreChallengeWheel:OpenReminderFrame()
end

function HardcoreChallengeWheel:SlashCommand(input)
    if not input or input:trim() == "" then
        self:OpenOptions()
    elseif input == "reroll" then
        HardcoreChallengeWheel:RollChallenge()
    elseif input == "swap" then
        HardcoreChallengeWheel:SwapReminderMode()

    else
        self:Print("Invalid command. Use `/hcwheel` to open the interface.")
    end
end

function HardcoreChallengeWheel:RollChallenge()
    local appropriateChallenges =
        HardcoreChallengeWheel:GetAppropriateChallenges()
    local selectedChallengeIndex = math.random(1,
                                               HardcoreChallengeWheel:GetTablelength(
                                                   appropriateChallenges))
    local selectedChallenge = appropriateChallenges[selectedChallengeIndex]

    HardcoreChallengeWheel:ShuffleList(appropriateChallenges)

    for i, challenge in ipairs(appropriateChallenges) do
        if challenge == selectedChallenge then
            selectedChallengeIndex = i
            break
        end
    end

    -- Move the selected challenge to the middle
    local middleIndex = math.floor(#appropriateChallenges / 2) + 1
    table.remove(appropriateChallenges, selectedChallengeIndex)
    table.insert(appropriateChallenges, middleIndex, selectedChallenge)
    selectedChallengeIndex = middleIndex -- Update the index to the new middle

    if reminderFrame == nil then HardcoreChallengeWheel:OpenReminderFrame() end
    HardcoreChallengeWheel.db.char.selectedChallenge = selectedChallenge
    HardcoreChallengeWheel_CreateRollingTextures(appropriateChallenges,
                                                 selectedChallengeIndex,
                                                 selectedChallenge,
                                                 HardcoreChallengeWheel.db
                                                     .profile.wheelSpinDuration,
                                                 reminderFrame)
end

function HardcoreChallengeWheel:GetAppropriateChallenges()
    local finished = false;
    local appropriateChallenges = {}

    for name, challenge in pairs(_G.achievements) do
        if challenge ~= nil and
            HardcoreChallengeWheel.db.profile.challenges[name] then
            local class = UnitClass("player")

            if challenge.class == "All" or challenge.class == class then

                table.insert(appropriateChallenges, challenge)

            end
        end
    end

    return appropriateChallenges;
end

function HardcoreChallengeWheel:ShuffleList(list)
    for i = #list, 2, -1 do
        local j = math.random(1, i)
        list[i], list[j] = list[j], list[i] -- Swap elements
    end
end

function HardcoreChallengeWheel:GetTablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function HardcoreChallengeWheel:OpenReminderFrame()

    if reminderFrame then
        reminderFrame:Hide()
        reminderFrame = nil
    end

    if HardcoreChallengeWheel.db.profile.minimalMode then
        reminderFrame = HardcoreChallengeWheel_CreateReminderFrameMinimal()
    else
        reminderFrame = HardcoreChallengeWheel_CreateReminderFrame()
    end
    reminderFrame:Show()

    if HardcoreChallengeWheel.db.char.selectedChallenge ~= nil then
        reminderFrame:SetChallenge(HardcoreChallengeWheel.db.char
                                       .selectedChallenge)
    end
end
