local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")

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
        class = UnitClass("player"),
        savedTalents = {}
    }
}

function HardcoreChallengeWheel:OnInitialize()
    -- Load the database
    self.db = LibStub("AceDB-3.0"):New("HardcoreChallengeWheelDB", defaults,
                                       true)
    self.reminderFrame = nil
    self.customChallengeForm = {}

    if not IsAddOnLoaded("Blizzard_ClassicUIResources") then
        LoadAddOn("Blizzard_ClassicUIResources") -- Ensures dropdown functionality is available
    end

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
        self.reminderFrame:SetChallenge(HardcoreChallengeWheel.db.char
                                            .selectedChallenge)
    end
    self:SendMessage("AddonInitialized")
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

    if self.reminderFrame == nil then
        HardcoreChallengeWheel:OpenReminderFrame()
    end
    HardcoreChallengeWheel.db.char.selectedChallenge = selectedChallenge
    HardcoreChallengeWheel:CreateRollingTextures(appropriateChallenges,
                                                 selectedChallengeIndex,
                                                 selectedChallenge,
                                                 HardcoreChallengeWheel.db
                                                     .profile.wheelSpinDuration)
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
