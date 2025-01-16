local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local AceGUI = LibStub("AceGUI-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

function HardcoreChallengeWheel:OpenIconPicker()
    print("Memory usage before loading:", collectgarbage("count"), "KB")

    -- Load icon data
    local talentData = Icons:GetIconData()

    -- Check memory usage after loading data
    print("Memory usage after loading:", collectgarbage("count"), "KB")
    if #talentData == 0 then
        print("No talent icons available!")
        return
    end

    -- Create the main AceGUI frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Icon Picker")
    frame:SetLayout("Fill")
    frame:SetWidth(300)
    frame:SetHeight(300)
    frame.statustext:GetParent():Hide() -- Hide the status bar frame

    -- Create a scrollable frame inside the main frame
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow") -- Flow layout for wrapping icons
    frame:AddChild(scrollFrame)

    -- Add talent icons
    for _, talent in pairs(talentData) do
        local icon = AceGUI:Create("Icon")
        icon:SetImage(talent.iconID)
        icon:SetImageSize(32, 32)
        icon:SetWidth(40)
        icon:SetCallback("OnClick", function()
            print("Selected Talent Icon:", talent.iconID)
            HardcoreChallengeWheel.customChallengeForm.challengeIconID =
                talent.iconID
            AceConfigRegistry:NotifyChange("HardcoreChallengeWheel") -- Refresh options UI
            frame:Hide()
        end)
        scrollFrame:AddChild(icon)
    end

    -- Release memory when closing
    frame:SetCallback("OnClose", function(widget)
        -- Release AceGUI children first
        scrollFrame:ReleaseChildren()

        -- Release the main frame
        AceGUI:Release(widget)
        Icons:Release() -- Release the icons frame
        print("Memory usage after release:", collectgarbage("count"), "KB")

    end)
end

