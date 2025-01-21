local frameWidth = 300 -- Width of the rolling area (to show more icons)
local frameHeight = 100 -- Height of the rolling area
local iconSize = 64 -- Size of each texture
local holdTime = 5
local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")

-- Create the rolling area frame
local frame = CreateFrame("Frame", "RollingTexturesFrame", UIParent)
frame:SetSize(frameWidth, frameHeight)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

-- Function to create the glowing highlight animation
local function CreateGlowAnimation(frame)
    local glowTexture = frame:CreateTexture(nil, "OVERLAY")
    glowTexture:SetSize(iconSize + 32, iconSize + 32)
    glowTexture:SetPoint("CENTER", frame, "CENTER", 0, 0)
    glowTexture:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
    glowTexture:SetBlendMode("ADD") -- Additive blend for a glow effect
    glowTexture:SetAlpha(0)

    local animGroup = glowTexture:CreateAnimationGroup()

    -- Pulse in
    local fadeIn = animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(1.5)
    fadeIn:SetOrder(1)

    -- Pulse out
    local fadeOut = animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(1)
    fadeOut:SetOrder(2)

    animGroup:Play()
end

-- Function to display text below the highlighted texture
local function DisplayTextBelowIcon(parentFrame, message)
    -- Create a new frame for the text
    local textFrame = CreateFrame("Frame", nil, UIParent)
    textFrame:SetSize(200, 50)
    textFrame:SetPoint("TOP", parentFrame, "BOTTOM", 0, -10) -- Position below the icon

    local text = textFrame:CreateFontString(nil, "OVERLAY",
                                            "GameFontNormalLarge")
    text:SetPoint("CENTER")
    text:SetText(message)

    return text
end

-- Function to fade out a frame with a smooth animation
local function FadeOutFrame(frame, duration, startingAlpha)
    local animGroup = frame:CreateAnimationGroup()

    -- Fade-out animation
    local fadeOut = animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(startingAlpha or 1) -- Start fully visible
    fadeOut:SetToAlpha(0) -- Fade to invisible
    fadeOut:SetDuration(duration) -- Duration of the fade-out
    fadeOut:SetSmoothing("OUT")

    animGroup:SetScript("OnFinished", function()
        frame:Hide() -- Optionally hide the frame after fade-out completes
    end)

    animGroup:Play()
end

-- Function to create and animate the rolling textures
function HardcoreChallengeWheel:CreateRollingTextures(challengeData,
                                                      highlightIndex, challenge,
                                                      rollDuration)
    local iconsToShow = math.floor(frameWidth / iconSize) -- Number of icons to fit inside the rolling area
    local paddingIcons = iconsToShow * 2 -- Show more icons for smooth entry and exit
    local totalIcons = #challengeData + (paddingIcons * 2) -- Total icons including decorations

    -- Create a new list with decorations (duplicate icons for decoration)
    local fullList = {}
    for i = 1, paddingIcons do
        table.insert(fullList, challengeData[#challengeData]) -- Add last icon as decoration on the left
    end
    for _, tex in ipairs(challengeData) do
        table.insert(fullList, tex) -- Add original list
    end
    for i = 1, paddingIcons do
        table.insert(fullList, challengeData[1]) -- Add first icon as decoration on the right
    end

    -- Store texture frames
    local textureFrames = {}

    -- Position icons and add frames
    for i = 1, totalIcons do
        local texturePath = fullList[i].icon_path

        local texFrame = CreateFrame("Frame", nil, frame)

        if fullList[i].origin ~= nil then
            texFrame:SetSize(iconSize * 0.7, iconSize * 0.7)
        else
            texFrame:SetSize(iconSize, iconSize)
        end

        -- Calculate initial position to line up icons horizontally
        local offsetX = (i - 1 - paddingIcons) * iconSize
        texFrame:SetPoint("CENTER", frame, "CENTER", offsetX, 0)

        -- Main texture
        local texture = texFrame:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints(texFrame)
        texture:SetTexture(texturePath)

        if fullList[i].origin ~= nil then
            -- Create a circular mask
            local mask = texFrame:CreateMaskTexture()
            mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
                            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Built-in circular mask
            mask:SetAllPoints()

            -- Apply the mask to the texture
            texture:AddMaskTexture(mask)

            local border = texFrame:CreateTexture(nil, "OVERLAY")
            border:SetTexture(
                "Interface\\AddOns\\HardcoreChallengeWheel\\Textures\\CovenantRenownRing")
            border:SetPoint("CENTER", texture, "CENTER", 0, 0)
            border:SetDrawLayer("OVERLAY", 2)
            border:SetHeight(iconSize * 0.85)
            border:SetWidth(iconSize * 0.85)

        end

        -- Store frame details
        table.insert(textureFrames, {frame = texFrame, startX = offsetX})
        texFrame:Show()
    end

    -- Variables to track animation
    local elapsedTime = 0
    local totalDistance = (highlightIndex - 1) * iconSize -- Move the highlight icon to the center
    local speed = totalDistance / rollDuration -- Pixels to move per second

    -- Variables to track the last tick sound played
    local lastTickDistance = 0
    local tickInterval = iconSize -- Play tick sound after moving by one icon size

    -- Frame update function for manual per-frame animation
    frame:SetScript("OnUpdate", function(self, deltaTime)
        elapsedTime = elapsedTime + deltaTime
        local t = elapsedTime / rollDuration
        if t > 1 then t = 1 end -- Clamp between 0 and 1 for smoother transition

        local easedDistance = totalDistance * (1 - (1 - t) * (1 - t)) -- Simple ease-out function

        for _, data in ipairs(textureFrames) do
            local texFrame = data.frame
            local currentX = data.startX - easedDistance
            texFrame:SetPoint("CENTER", frame, "CENTER", currentX, 0)

            -- Calculate alpha based on distance to center
            local frameCenterX = frame:GetCenter()
            local iconX = texFrame:GetCenter()
            if iconX then
                local distanceFromCenter = math.abs(frameCenterX - iconX)
                local maxDistance = frameWidth / 2

                local alpha = 1 - (distanceFromCenter / maxDistance)
                if alpha < 0 then alpha = 0 end -- Ensure it doesn’t go negative
                texFrame:SetAlpha(alpha)
            end
        end

        -- Play a tick sound every time the distance moved surpasses `tickInterval`
        if easedDistance - lastTickDistance >= tickInterval then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) -- Classic checkbox "tick".
            lastTickDistance = easedDistance -- Update last tick distance
        end

        -- Stop animation after duration
        if elapsedTime >= rollDuration then
            frame:SetScript("OnUpdate", nil) -- Stop updating
            local highlightFrame = textureFrames[paddingIcons + highlightIndex]
                                       .frame
            local highlightText = DisplayTextBelowIcon(highlightFrame,
                                                       "New Challenge: " ..
                                                           challenge.title)

            highlightFrame:SetAlpha(1) -- Ensure highlight is fully visible
            PlaySound(602);

            -- Create glow animation on the highlight frame
            CreateGlowAnimation(highlightFrame)
            HardcoreChallengeWheel.reminderFrame:SetChallenge(challenge)

            local serializedData = LibStub("AceSerializer-3.0"):Serialize(data)
            HardcoreChallengeWheel:SendCommMessage("HCWHEEL",
                                                   serializedData,
                                                   "SAY")

            if HardcoreChallengeWheel.db.profile.announceChallenge then

                if HardcoreChallengeWheel.db.profile.announceChannel == "EMOTE" then

                    SendChatMessage("has rolled a new challenge: " .. "[" ..
                                        challenge.title .. "]", "EMOTE")
                else
                    SendChatMessage("I just rolled a new challenge: " .. "[" ..
                                        challenge.title .. "]",
                                    HardcoreChallengeWheel.db.profile
                                        .announceChannel)
                end

            end

            -- Fade out surrounding textures after the highlight
            C_Timer.After(holdTime, function()

                for i, data in ipairs(textureFrames) do
                    if data.frame ~= highlightFrame then
                        local alpha = data.frame:GetAlpha();
                        if alpha > 0 then
                            FadeOutFrame(data.frame, .5, alpha)
                        else
                            data.frame:SetAlpha(0)
                        end
                    end
                end

                FadeOutFrame(highlightFrame, 1.25) -- 1 second fade-out
                FadeOutFrame(highlightText, 1.25) -- 1 second fade-out for the text
            end)
        end
    end)
end
