local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local Challenges = HardcoreChallengeWheel:NewModule("Challenges")

function Challenges:OnInitialize()
    self.HCWheelChallenges = {
        {
            name = "OneHandOnly",
            title = "One Armed Bandit",
            class = "All",
            points = 10,
            iconPath = 132147,
            blText = "Starting Achievement",
            description = "This is a test"
        }
    }
    print("Challenges:OnInitialize")
end


function Challenges:GetChallenges()
    return self.HCWheelChallenges
end