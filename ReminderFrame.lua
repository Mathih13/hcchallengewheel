local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local AceGUI = LibStub("AceGUI-3.0")

function HardcoreChallengeWheel:OpenReminderFrame()

    if HardcoreChallengeWheel.reminderFrame then
        HardcoreChallengeWheel.reminderFrame:Hide()
        HardcoreChallengeWheel.reminderFrame = nil
    end

    if HardcoreChallengeWheel.db.profile.minimalMode then
        HardcoreChallengeWheel.reminderFrame = AceGUI:Create("CurrentChallenge")

        HardcoreChallengeWheel.reminderFrame:SetWidth(255)
        HardcoreChallengeWheel.reminderFrame:SetHeight(125)
    else
        HardcoreChallengeWheel.reminderFrame = AceGUI:Create(
                                                   "CurrentChallengeMinimal")
    end
    HardcoreChallengeWheel.reminderFrame:Show()

    if HardcoreChallengeWheel.db.char.selectedChallenge ~= nil then
        HardcoreChallengeWheel.reminderFrame:SetChallenge(
            HardcoreChallengeWheel.db.char.selectedChallenge)
    end
end

function HardcoreChallengeWheel:SetShowReminderFrame(showReminderFrame)
    if showReminderFrame then
        HardcoreChallengeWheel.db.profile.showReminderFrame = true
        HardcoreChallengeWheel.reminderFrame:Show()
    else
        HardcoreChallengeWheel.db.profile.showReminderFrame = false
        HardcoreChallengeWheel.reminderFrame:Hide()
    end
end

