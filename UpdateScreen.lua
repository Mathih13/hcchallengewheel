local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local AceGUI = LibStub("AceGUI-3.0")

function HardcoreChallengeWheel:ShowUpdateScreen(oldVersion, newVersion)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Hardcore Challenge Wheel: v" .. newVersion)

    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Fill")
    frame:SetWidth(550)
    frame:SetHeight(300)

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    frame:AddChild(scroll)

    local label = AceGUI:Create("Label")
    label:SetText(
        "Thank you for using Hardcore Challenge Wheel.\n\nWhat's new in version " ..
            newVersion .. ":|cFFC79C6E\n\n" .. "- Added more challenges. Check options for full list.\n" ..
            "- Visual changes to match new features\n" ..
            "\n-Addon announces in chat when you are given a new challenge. Consider leaving this on to share the joy with others :)\n\n" ..
            "- (Experimental) Custom challenges can be created in the options\n" ..
            "- (Experimental) See other players challenges when targeting them\n\n" ..
            "- General improvements and bug fixes\n|r" ..
            "\nAll of these changes can be tweaked to your liking in the options.")

    label:SetFullWidth(true)

    local font, size, flags = label.label:GetFont()
    label.label:SetFont(font, 14, flags) -- Increase the font size to 16

    scroll:AddChild(label)

    frame.statustext:GetParent():Hide()
end
