--[[-----------------------------------------------------------------------------
Reminder Frame Container
-------------------------------------------------------------------------------]] local 
    Type, Version = "CurrentChallengeMinimal", 30
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Lua APIs
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Frame_OnShow(frame) frame.obj:Fire("OnShow") end

local function Frame_OnClose(frame) frame.obj:Fire("OnClose") end

local function Frame_OnMouseDown(frame) AceGUI:ClearFocus() end

local function Icon_OnMouseDown(frame)
    local parentFrame = frame:GetParent() -- Get the parent frame (main frame)
    if parentFrame:IsMovable() then
        parentFrame:StartMoving() -- Start moving the frame
    end
end

local function SaveFramePosition(self)
    local point, _, relativePoint, xOffset, yOffset = self.frame:GetPoint()
    self.db.profile.position = {
        point = point,
        relativePoint = relativePoint,
        xOffset = xOffset,
        yOffset = yOffset
    }
end

local function RestoreFramePosition(self)
    local pos = self.db.profile.position
    if pos then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOffset,
                            pos.yOffset)
    else
        -- Default position if none exists
        self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

local function MoverSizer_OnMouseUp(frame)
    local parentFrame = frame:GetParent() -- Get the parent frame
    parentFrame:StopMovingOrSizing() -- Stop the frame from moving
    local self = parentFrame.obj
    local status = self.status or self.localstatus
    status.width = parentFrame:GetWidth()
    status.height = parentFrame:GetHeight()
    status.top = parentFrame:GetTop()
    status.left = parentFrame:GetLeft()
    SaveFramePosition(self) -- Save the new position

end

local function WrapText(inputText, maxLength)
    local result = ""
    local currentLine = ""

    for word in inputText:gmatch("%S+") do -- Split by whitespace
        if #currentLine + #word + 1 > maxLength then
            result = result .. currentLine .. "\n" -- Add the current line with a line break
            currentLine = word -- Start a new line with the current word
        else
            if currentLine == "" then
                currentLine = word -- First word of the new line
            else
                currentLine = currentLine .. " " .. word -- Add word to current line
            end
        end
    end

    -- Add the last line (if any)
    if currentLine ~= "" then result = result .. currentLine end

    return result
end

local function ShowRightClickMenu(self)
    local swapModeText = ""

    if HardcoreChallengeWheel.db.profile.minimalMode then
        swapModeText = "Switch to detailed mode"
    else
        swapModeText = "Switch to minimal mode"
    end

    local dropdownItems = {
        {
            text = swapModeText,
            func = function()
                HardcoreChallengeWheel:SwapReminderMode()
            end,
            notCheckable = true
        }, {
            text = "Options",
            func = function()
                AceConfigDialog:Open("HardcoreChallengeWheel")
            end,
            notCheckable = true
        },
        {
            text = "Reroll",
            func = function()
                HardcoreChallengeWheel:RollChallenge()
            end,
            notCheckable = true
        },
        {
            text = "Close",
            notCheckable = true,
            func = function() CloseDropDownMenus() end
        }
    }

    if not EasyMenu then
        function EasyMenu(menuList, menuFrame, anchor, xOffset, yOffset,
                          displayMode)
            if not menuFrame then
                menuFrame = CreateFrame("Frame", "CustomUIDropDownMenu",
                                        UIParent, "UIDropDownMenuTemplate")
            end
            menuFrame.displayMode = displayMode or "MENU"
            menuFrame.initialize = function(self, level)
                for i = 1, #menuList do
                    UIDropDownMenu_AddButton(menuList[i], level)
                end
            end
            ToggleDropDownMenu(1, nil, menuFrame, anchor, xOffset, yOffset)
        end
    end

    EasyMenu(dropdownItems, nil, "cursor", 0, 0, "MENU")

    -- Display the dropdown menu at the cursor position
    EasyMenu(dropdownItems, CreateFrame("Frame", "MyDropdownFrame", UIParent,
                                        "UIDropDownMenuTemplate"), "cursor", 0,
             0, "MENU")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ["OnAcquire"] = function(self)
        self.frame:SetParent(UIParent)
        self.frame:SetFrameStrata("DIALOG")
        self.frame:SetFrameLevel(100)

        self:ApplyStatus() -- Restores size and position
        self:Show()

    end,

    ["OnRelease"] = function(self)
        self.status = nil
        wipe(self.localstatus)
    end,

    ["SetChallenge"] = function(self, challenge)
        self.challenge = challenge
        self.challengeIconTexture:SetTexture(challenge.icon_path)

        self.challengeIcon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR") -- Tooltip follows the mouse
            GameTooltip:SetText(challenge.title)
            GameTooltip:AddLine(WrapText(challenge.description, 50), 1, 1, 1) -- White text
            GameTooltip:Show() -- Show the tooltip
        end)

        self.challengeIcon:SetScript("OnLeave", function(self)
            GameTooltip:Hide() -- Hide the tooltip when the mouse leaves the frame
        end)
    end,

    ["Hide"] = function(self) self.frame:Hide() end,

    ["Show"] = function(self) self.frame:Show() end,

    ["ApplyStatus"] = function(self)
        local status = self.status or self.localstatus
        local frame = self.frame

        RestoreFramePosition(self) -- Restore position

    end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local PaneBackdrop = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Glues\\COMMON\\TextPanel-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {left = 3, right = 3, top = 0, bottom = 3}
}

local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    local challenge = HardcoreChallengeWheel.db.char.selectedChallenge
    frame:Hide()

    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)

    frame:SetSize(50, 50)

    frame:SetToplevel(true)
    frame:SetScript("OnShow", Frame_OnShow)
    frame:SetScript("OnHide", Frame_OnClose)
    frame:SetScript("OnMouseDown", Frame_OnMouseDown)

    -- Container Support
    local content = CreateFrame("Frame", nil, frame)

    local challengeIcon = CreateFrame("Frame", nil, frame)
    challengeIcon:SetSize(48, 48)
    challengeIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)

    challengeIcon:SetScript("OnMouseUp", MoverSizer_OnMouseUp)

    challengeIcon:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            ShowRightClickMenu(self)
        else
            Icon_OnMouseDown(self)
        end
    end)

    local challengeIconTexture = challengeIcon:CreateTexture(nil, "BACKGROUND")
    challengeIconTexture:SetAllPoints(challengeIcon)

    local widget = {
        localstatus = {},
        challengeIcon = challengeIcon,
        challengeIconTexture = challengeIconTexture,
        frame = frame,
        content = content,
        type = Type,
        db = HardcoreChallengeWheel.db,
        challenge = challenge,
        mode = mode
    }

    for method, func in pairs(methods) do widget[method] = func end

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
