local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):NewAddon(
                                   "HardcoreChallengeWheel", "AceConsole-3.0",
                                   "AceEvent-3.0", "AceComm-3.0")

function HardcoreChallengeWheel:OnEnable() 
    self:RegisterComm("HCWHEEL") -- "HCWHEEL" is the prefix for your addon communication
    self:SendMessage("AddonInitialized") 
end
