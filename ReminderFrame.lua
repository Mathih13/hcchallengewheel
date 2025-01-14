-- GUI.lua
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create and display the GUI frame
local function CreateMainFrame()
    local reminder_frame = AceGUI:Create("CurrentChallenge")

    -- reminder_frame:SetLayout("Fill")
    reminder_frame:SetWidth(255)
    reminder_frame:SetHeight(125)

    return reminder_frame
end

local function CreateMinimalFrame()

    return AceGUI:Create("CurrentChallengeMinimal")
end


-- Expose the function to be accessible from other files
HardcoreChallengeWheel_CreateReminderFrame = CreateMainFrame
HardcoreChallengeWheel_CreateReminderFrameMinimal = CreateMinimalFrame
