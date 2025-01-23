local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local challengesModule = HardcoreChallengeWheel:GetModule("Challenges")
local CURRENT_VERSION = "1.1.0"

-- Database defaults
local defaults = {
    profile = {
        wheelSpinDuration = 4,
        challenges = {
            ["TrioMade"] = false,
            ["PartnerUp"] = false,
            ["DuoMade"] = false,
            ["NoHit"] = false,
            ["NightOwl"] = false,
            ["SolitaryStruggle"] = false,
            ["FishingPoleOnly"] = false,
            ["CrusaderOnly"] = false
        },
        defaultDisabledChallenges = {"NoHit"},
        class = UnitClass("player"),
        savedTalents = {},
        customChallenges = {},
        announceChallenge = true,
        announceChannel = "EMOTE",
        showTargetChallenge = true
    },
    char = {cachedTargetChallenges = {}}
}

function HardcoreChallengeWheel:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("HardcoreChallengeWheelDB", defaults,
                                       true)
    self.reminderFrame = nil
    self.targetChallengeFrame = nil
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

            if self.db.char.selectedChallenge then
                SendChatMessage("has completed the level challenge [" ..
                                    self.db.char.selectedChallenge.title .. "]!",
                                "EMOTE")
            end

            HardcoreChallengeWheel:RollChallenge()
        end

    end)

    if HardcoreChallengeWheel.db.char.selectedChallenge then
        HardcoreChallengeWheel:OpenReminderFrame()
        self.reminderFrame:SetChallenge(HardcoreChallengeWheel.db.char
                                            .selectedChallenge)
    end

    HardcoreChallengeWheel:InitTargetFrame()

    local storedVersion = self.db.global.addonVersion or "0.0.0"
    if storedVersion ~= CURRENT_VERSION then
        self:ShowUpdateScreen(storedVersion, CURRENT_VERSION)
        self.db.global.addonVersion = CURRENT_VERSION
    end

end

HardcoreChallengeWheel:RegisterMessage("AddonInitialized", function()

    if HardcoreChallengeWheel.db.profile.showTargetChallenge then
        HardcoreChallengeWheel:HookTargetChanged()
    end

    HardcoreChallengeWheel:BuildOptions()
end)

function HardcoreChallengeWheel:SlashCommand(input)
    if not input or input:trim() == "" then
        self:OpenOptions()
    elseif input == "reroll" then
        HardcoreChallengeWheel:RollChallenge()
    elseif input == "swap" then
        HardcoreChallengeWheel:SwapReminderMode()
    elseif input == "requestchallenge" then
        HardcoreChallengeWheel:RequestChallengeFromTarget()
    elseif input == "receive" then
        local appropriateChallenges =
            HardcoreChallengeWheel:GetAppropriateChallenges();
        local selectedChallengeIndex = math.random(1,
                                                   HardcoreChallengeWheel:GetTablelength(
                                                       appropriateChallenges))
        local selectedChallenge = appropriateChallenges[selectedChallengeIndex]
        local data = {
            name = selectedChallenge.name,
            title = selectedChallenge.title,
            description = selectedChallenge.description,
            icon_path = selectedChallenge.icon_path
        }
        local serializedData = LibStub("AceSerializer-3.0"):Serialize(data)

        HardcoreChallengeWheel:OnCommReceived("HCWHEEL", serializedData,
                                              "WHISPER", UnitName("player"))
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
    local appropriateChallenges = {}
    local allChallenges = challengesModule:GetAllChallenges()

    for name, challenge in pairs(allChallenges) do
        if challenge ~= nil and
            HardcoreChallengeWheel.db.profile.challenges[name] then
            local class = UnitClass("player")

            if challenge.class == "All" or challenge.class == class then

                if challenge.level then
                    local level = UnitLevel("player")
                    if challenge.level <= level then
                        table.insert(appropriateChallenges, challenge)
                    end
                else
                    table.insert(appropriateChallenges, challenge)
                end

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

function HardcoreChallengeWheel:AddCustomChallenge(title, description, iconID)
    local noSpacedTitle = title:gsub(" ", "")
    local challenge = {
        name = "custom_" .. noSpacedTitle,
        title = title,
        description = description,
        icon_path = iconID
    }

end
