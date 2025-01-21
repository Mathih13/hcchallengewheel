local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")

local eventFrame

function HardcoreChallengeWheel:RequestChallengeFromTarget()
    local targetName = UnitName("target")
    self.targetChallengeFrame:Hide()

    if targetName == UnitName("player") then return end

    if self.db.char.cachedTargetChallenges[targetName] then
        self.targetChallengeFrame:SetChallenge(self.db.char
                                                   .cachedTargetChallenges[targetName])
        self.targetChallengeFrame:Show()
    end

    if not UnitIsPlayer("target") then return end

    if targetName then
        HardcoreChallengeWheel:SendCommMessage("HCWHEEL", "REQUEST_CHALLENGE",
                                               "WHISPER", targetName)
    end
end

function HardcoreChallengeWheel:OnCommReceived(prefix, message, distribution,
                                               sender)
    if prefix ~= "HCWHEEL" then return end

    if message == "REQUEST_CHALLENGE" then
        if self.db.char.selectedChallenge then
            local data = {
                name = self.db.char.selectedChallenge.name,
                title = self.db.char.selectedChallenge.title,
                description = self.db.char.selectedChallenge.description,
                icon_path = self.db.char.selectedChallenge.icon_path
            }
            local serializedData = LibStub("AceSerializer-3.0"):Serialize(data)
            HardcoreChallengeWheel:SendCommMessage("HCWHEEL", serializedData,
                                                   "WHISPER", sender)
        end
    else

        -- Handle other incoming data (e.g., received challenges)
        local success, data = LibStub("AceSerializer-3.0"):Deserialize(message)
        if success then
            self.db.char.cachedTargetChallenges[sender] = data
        end
    end
end

function HardcoreChallengeWheel:HookTargetChanged()

    eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:SetScript("OnEvent",
                         function() self:RequestChallengeFromTarget() end)
end

function HardcoreChallengeWheel:UnhookTargetChanged()
    eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:SetScript("OnEvent", nil)
end
