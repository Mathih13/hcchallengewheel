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

function HardcoreChallengeWheel:SwapReminderMode()
    if HardcoreChallengeWheel.db.profile.minimalMode then
        HardcoreChallengeWheel.db.profile.minimalMode = false
    else
        HardcoreChallengeWheel.db.profile.minimalMode = true
    end

    HardcoreChallengeWheel:OpenReminderFrame()
end

function HardcoreChallengeWheel:InitTargetFrame()
    if HardcoreChallengeWheel.targetChallengeFrame then
        HardcoreChallengeWheel.targetChallengeFrame:Hide()
        HardcoreChallengeWheel.targetChallengeFrame = nil
    end

    HardcoreChallengeWheel.targetChallengeFrame = AceGUI:Create(
                                                      "TargetChallenge")
end

function HardcoreChallengeWheel:ToggleTargetFrame()
    if HardcoreChallengeWheel.db.profile.showTargetChallenge then
        HardcoreChallengeWheel:HookTargetChanged()
    else
        HardcoreChallengeWheel:UnhookTargetChanged()
        
    end
end
