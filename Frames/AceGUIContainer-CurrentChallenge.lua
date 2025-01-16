--[[-----------------------------------------------------------------------------
Reminder Frame Container
-------------------------------------------------------------------------------]] local 
    Type, Version = "CurrentChallenge", 30
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon("HardcoreChallengeWheel")


-- Lua APIs
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(frame)
    PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
    frame.obj:Hide()
end

local function Frame_OnShow(frame) frame.obj:Fire("OnShow") end

local function Frame_OnClose(frame) frame.obj:Fire("OnClose") end

local function Frame_OnMouseDown(frame) AceGUI:ClearFocus() end

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
    assert(self.db, "RestoreFramePosition: db is nil!") -- Debug check
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

local function SizerSE_OnMouseDown(frame)
    frame:GetParent():StartSizing("BOTTOMRIGHT")
    AceGUI:ClearFocus()
end

local function SizerS_OnMouseDown(frame)
    frame:GetParent():StartSizing("BOTTOM")
    AceGUI:ClearFocus()
end

local function SizerE_OnMouseDown(frame)
    frame:GetParent():StartSizing("RIGHT")
    AceGUI:ClearFocus()
end

local function ShowRightClickMenu(parentFrame)
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
        }, {
            text = "Reroll",
            func = function() HardcoreChallengeWheel:RollChallenge() end,
            notCheckable = true
        }, {
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
        self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
        self.frame:SetFrameLevel(100)

        self:SetTitle("Current Challenge")
        self:ApplyStatus() -- Restores size and position
        self:Show()
        self:EnableResize(true)
    end,

    ["OnRelease"] = function(self)
        self.status = nil
        wipe(self.localstatus)
    end,

    ["SetChallenge"] = function(self, challenge)
        self.challenge = challenge
        self.titletext:SetText(challenge.title)
        self.challengeIconTexture:SetTexture(challenge.icon_path)

        self.multiLineText:SetText(challenge.description)
        local textHeight = self.multiLineText:GetStringHeight()
        self.frame:SetHeight(textHeight + 45)

    end,

    ["SetTitle"] = function(self, title) self.titletext:SetText(title) end,

    ["Hide"] = function(self) self.frame:Hide() end,

    ["Minimize"] = function(self)
        self.frame:Hide()
        is_minimized = true
    end,

    ["IsMinimized"] = function(self) return is_minimized end,

    ["Maximize"] = function(self)
        self.frame:Show()
        is_minimized = false
    end,

    ["Show"] = function(self) self.frame:Show() end,

    ["EnableResize"] = function(self, state)
        local func = state and "Show" or "Hide"
    end,

    -- called to set an external table to store status in
    ["SetStatusTable"] = function(self, status)
        assert(type(status) == "table")
        self.status = status
        self:ApplyStatus()
    end,

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
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(100)
    frame:SetBackdrop(PaneBackdrop)
    frame:SetBackdropColor(0, 0, 0, .6)
    frame:SetBackdropBorderColor(1, 1, 1, 1)
    frame:SetSize(250, 150)

    if frame.SetResizeBounds then -- WoW 10.0
        frame:SetResizeBounds(150, 100)
    else
        frame:SetMinResize(150, 100)
    end
    frame:SetToplevel(true)
    frame:SetScript("OnShow", Frame_OnShow)
    frame:SetScript("OnHide", Frame_OnClose)
    frame:SetScript("OnMouseDown", Frame_OnMouseDown)

    local titlebg = frame:CreateTexture(nil, "OVERLAY")
    titlebg:SetTexture(
        "Interface\\ClassTrainerFrame\\UI-ClassTrainer-DetailHeaderLeft")
    titlebg:SetTexCoord(0, 1, 0, 1)
    titlebg:SetPoint("TOP", 0, 12)
    titlebg:SetWidth(100)
    titlebg:SetHeight(40)
    titlebg:Hide()

    local title = CreateFrame("Frame", nil, frame)
    title:EnableMouse(true)

    title:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            ShowRightClickMenu(self)
        else
            if frame:IsMovable() then
                frame:StartMoving() -- Start moving the frame
            end
        end
    end)

    title:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
    title:SetAllPoints(titlebg)

    local titletext = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titletext:SetFont("Interface\\Addons\\Hardcore\\Media\\BreatheFire.ttf", 18,
                      "")
    titletext:SetPoint("LEFT", frame, "TOPLEFT", 35, -15)

    local challengeIcon = CreateFrame("Frame", nil, frame)
    challengeIcon:SetSize(48, 48)

    challengeIcon:SetPoint("LEFT", frame, "TOPLEFT", -15, -10)

    local challengeIconTexture = challengeIcon:CreateTexture(nil, "BACKGROUND")
    challengeIconTexture:SetAllPoints(challengeIcon)

    -- Container Support
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 3, -33)
    content:SetPoint("BOTTOMRIGHT", 15, 6)

    -- Create a multi-line text widget
    local multiLineText = content:CreateFontString(nil, "OVERLAY",
                                                   "GameFontHighlightSmall")
    multiLineText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Font size and style
    multiLineText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, 0)
    multiLineText:SetJustifyH("LEFT") -- Align the text to the left
    multiLineText:SetJustifyV("TOP") -- Align the text to the top
    multiLineText:SetWidth(frame:GetWidth() - 20) -- Constrain the text width

    multiLineText:SetWordWrap(true) -- Enable word wrapping

    local widget = {
        localstatus = {},
        titletext = titletext,
        challengeIcon = challengeIcon,
        challengeIconTexture = challengeIconTexture,
        titlebg = titlebg,

        content = content,
        multiLineText = multiLineText,
        frame = frame,
        type = Type,
        db = HardcoreChallengeWheel.db,
        challenge = challenge
    }

    for method, func in pairs(methods) do widget[method] = func end

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
