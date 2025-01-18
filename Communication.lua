local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")

function HardcoreChallengeWheel:RequestChallengeFromTarget()
    self.targetChallengeFrame:Hide()

    if not UnitIsPlayer("target") then return end
    local targetName = UnitName("target")

    -- if targetName == UnitName("player") then return end

    print("Requesting challenge from", targetName)
    if targetName then
        HardcoreChallengeWheel:SendCommMessage("HCWHEEL", "REQUEST_CHALLENGE",
                                               "WHISPER", targetName)
    end
end

function HardcoreChallengeWheel:OnCommReceived(prefix, message, distribution,
                                               sender)
    if prefix ~= "HCWHEEL" then return end

    if message == "REQUEST_CHALLENGE" then
        print("Received REQUEST_CHALLENGE from", sender)
        if self.db.char.selectedChallenge then
            local data = {
                name = self.db.char.selectedChallenge.name,
                title = self.db.char.selectedChallenge.title,
                description = self.db.char.selectedChallenge.description,
                icon_path = self.db.char.selectedChallenge.icon_path
            }
            local serializedData = LibStub("AceSerializer-3.0"):Serialize(data)
            print("Sending challenge to", sender)
            print(serializedData)
            HardcoreChallengeWheel:SendCommMessage("HCWHEEL", serializedData,
                                                   "WHISPER", sender)
        end
    else
        -- Handle other incoming data (e.g., received challenges)
        local success, data = LibStub("AceSerializer-3.0"):Deserialize(message)
        print("Received data from", sender)
        if success then
            self.db.char.targetChallenge = data
            self.targetChallengeFrame:SetChallenge(data)
            self.targetChallengeFrame:Show()

        end
    end
end

function HardcoreChallengeWheel:HookTargetChanged()

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:SetScript("OnEvent", function() self:RequestChallengeFromTarget() end)
end

HardcoreChallengeWheel:RegisterMessage("AddonInitialized", function()
    HardcoreChallengeWheel:HookTargetChanged()
end)
