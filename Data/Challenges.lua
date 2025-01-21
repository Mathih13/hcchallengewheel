local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local Challenges = HardcoreChallengeWheel:NewModule("Challenges")

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

function Challenges:OnInitialize()
    self.HCWheelChallenges = {
        {
            name = "OneHandOnly",
            title = "One Armed",
            class = "All",
            points = 10,
            iconPath = 132343,
            blText = "Starting Achievement",
            description = "Only allowed to wear a single one-handed melee weapon. You cannot wear two-handed weapons, shields or off-hand items.\n\n\124cff00ccffOptional:\124r No two-handed ranged weapons allowed either."
        }, {
            name = "TwoBagsOnly",
            title = "Travel Light",
            class = "All",
            points = 15,
            iconPath = 133637,
            blText = "Bag Limit",
            description = "You can only use two bag slots. All other bags must remain empty or unequipped."
        }, {
            name = "Vegetarian",
            title = "Herbivore",
            class = "All",
            points = 10,
            iconPath = 134191,
            blText = "Starting Achievement",
            description = "You are not allowed to eat any meat-based food or use meat-related items. Stick to vegetarian consumables like bread, fruit, and water."
        }, {
            name = "NightOwl",
            title = "Nightowl",
            class = "All",
            points = 10,
            iconPath = 136057,
            blText = "Starting Achievement",
            description = "You can only play during the in-game night. Wait for dusk to continue your journey."
        }, {
            name = "BareKnuckleBrawler",
            title = "Bare Knuckled",
            class = "All",
            points = 25,
            iconPath = 236314,
            blText = "Combat Restriction",
            description = "You may not equip weapons. Fight with your fists only!"
        }, {
            name = "FishingPoleOnly",
            title = "Master Angler",
            class = "All",
            points = 10,
            iconPath = 132932,
            blText = "Starting Achievement",
            description = "Only allowed to use a fishing pole type weapon. You cannot use any other type of weapon."
        }, {
            name = "BloodForTheBloodGod",
            title = "Bloodthirsty",
            class = "Warrior",
            points = 20,
            iconPath = 136218,
            blText = "Rage Restriction",
            description = "You may only use abilities that cost Rage. Abilities or items that don’t consume Rage are forbidden."
        }, {
            name = "AuraSpecialist",
            title = "Divine Presence",
            class = "Paladin",
            points = 10,
            iconPath = 236256,
            blText = "Aura Restriction",
            description = "Choose one Aura and keep it active for the entire level. You cannot switch Auras."
        }, {
            name = "ShieldOfValor",
            title = "Shield of Valor",
            class = "Paladin",
            points = 15,
            iconPath = 134952,
            blText = "Equipment Restriction",
            description = "You must always equip a shield and use it during combat. Two-handed weapons are not allowed."
        }, {
            name = "CrusaderOnly",
            title = "The Crusader’s Path",
            class = "Paladin",
            points = 15,
            iconPath = 135924,
            blText = "Seal Restriction",
            description = "You must only use Seal of the Crusader and Judgement of the Crusader during combat."
        }, {
            name = "SingleTotemType",
            title = "Totemic Specialist",
            class = "Shaman",
            points = 10,
            iconPath = 135861,
            blText = "Totem Restriction",
            description = "Choose one totem element. You may only summon totems of that element."
        }, {
            name = "MeleeEnhancement",
            title = "Spirit of the Storm",
            class = "Shaman",
            points = 15,
            iconPath = 136024,
            blText = "Combat Style",
            description = "You must engage in melee combat using Enhancement abilities. Ranged spells are forbidden."
        }, {
            name = "ShamanCastOnly",
            title = "Elemental Communion",
            class = "Shaman",
            points = 20,
            iconPath = 136048,
            blText = "Specialization Lock",
            description = "You may only use spells with cast times. Instant cast spells are forbidden."
        }, {
            name = "ShamanNoCast",
            title = "Elemental Fury",
            class = "Shaman",
            points = 15,
            iconPath = 136024,
            blText = "Combat Style",
            description = "You may only use instant cast spells. Spells with cast times are forbidden."
        }, {
            name = "NoPoisons",
            title = "Clean Blade",
            class = "Rogue",
            points = 10,
            iconPath = 132273,
            blText = "Combat Restriction",
            description = "You may not use poisons on your weapons."
        }, {
            name = "NoLifeTap",
            title = "Frail",
            class = "Warlock",
            points = 10,
            iconPath = 136188,
            blText = "Combat Restriction",
            description = "You may not use Life Tap."
        }, {
            name = "NoManaRecovery",
            title = "Inner Focus",
            class = "Mage",
            points = 10,
            iconPath = 135863,
            blText = "Mana Restriction",
            description = "You cannot recover mana by drinking.\n\n\124cff00ccffMana gems, mana potions and Evocation are allowed.\124r"
        }, {
            name = "OnlyBows",
            title = "Longbeard",
            class = "Hunter",
            points = 10,
            iconPath = 135491,
            blText = "Starting Achievement",
            description = "You may only use Bows and crossbows as your ranged weapons."
        }, {
            name = "OnlyGuns",
            title = "Gunslinger",
            class = "Hunter",
            points = 10,
            iconPath = 135616,
            description = "You may only use Guns as your ranged weapons."
        }

    }
end

function Challenges:GetChallengeByName(name)
    for key, challenge in ipairs(_G.achievements) do
        if key == name then return challenge end
    end

    for _, challenge in ipairs(self.HCWheelChallenges) do
        if challenge.name == name then return challenge end
    end

    return nil
end

function Challenges:GetAllChallenges()
    -- Create a new table to store the merged data
    local mergedChallenges = {}

    -- Copy data from _G.achievements into the new table
    for key, value in pairs(_G.achievements) do mergedChallenges[key] = value end

    -- Add transformed HCWheelChallenges into the new table
    for _, challenge in pairs(self.HCWheelChallenges) do
        -- Transform challenge to match _G.achievements structure
        local newEntry = {
            title = challenge.title,
            description = challenge.description,
            icon_path = challenge.iconPath,
            class = challenge.class,
            bl_text = challenge.blText,
            name = challenge.name,
            origin = "built-in"
        }

        -- Use the `name` field as the key
        local key = challenge.name
        mergedChallenges[key] = newEntry
    end

    for _, challenge in
        pairs(HardcoreChallengeWheel.db.profile.customChallenges) do
        local newEntry = {
            title = challenge.title,
            description = challenge.description,
            icon_path = challenge.iconPath,
            class = challenge.class,
            bl_text = "",
            name = challenge.name,
            origin = challenge.origin
        }

        local key = challenge.name
        mergedChallenges[key] = challenge
    end

    -- Return the new merged table without modifying _G.achievements
    return mergedChallenges
end

function Challenges:GetOptionsData()
    -- Separate challenges by origin
    local achievementsList = {}
    local builtInChallenges = {}
    local customChallenges = {}

    -- Add data from _G.achievements
    for key, value in pairs(_G.achievements) do
        table.insert(achievementsList, {key = key, data = value})
    end

    -- Add data from HCWheelChallenges
    for _, challenge in ipairs(self.HCWheelChallenges) do
        local newEntry = {
            title = challenge.title,
            description = challenge.description,
            icon_path = challenge.iconPath,
            class = challenge.class,
            bl_text = challenge.blText,
            name = challenge.name,
            origin = "built-in"
        }
        table.insert(builtInChallenges, {key = challenge.name, data = newEntry})
    end

    if HardcoreChallengeWheel.db.profile.customChallenges then
        -- Add data from customChallenges
        for key, challenge in pairs(HardcoreChallengeWheel.db.profile
                                        .customChallenges) do

            local newEntry = {
                title = challenge.title,
                description = challenge.description,
                icon_path = challenge.icon_path,
                class = challenge.class,
                name = challenge.name,
                origin = "custom"
            }
            table.insert(customChallenges, {key = key, data = newEntry})
        end
    end

    -- Sort both lists alphabetically by their keys
    table.sort(achievementsList, function(a, b) return a.key < b.key end)
    table.sort(builtInChallenges, function(a, b) return a.key < b.key end)
    table.sort(customChallenges, function(a, b) return a.key < b.key end)

    return {
        achievements = achievementsList,
        builtInChallenges = builtInChallenges,
        customChallenges = customChallenges
    }
end

function Challenges:AddCustomChallenge(title, description, iconID, class)
    local noSpacedTitle = title:gsub(" ", "")
    local challenge = {
        name = "CUSTOM" .. noSpacedTitle,
        title = title,
        description = description,
        icon_path = iconID,
        origin = "custom",
        class = class
    }

    HardcoreChallengeWheel.db.profile.customChallenges[challenge.name] =
        challenge

    -- Add the challenge to the "add custom challenge" group
    HardcoreChallengeWheel.optionsTable.args.customGroup.args.customChallenges
        .args[challenge.name] = {
        type = "group",
        inline = true,
        name = "",
        args = {
            description = {
                order = 1,
                type = "description",
                name = "|T" .. challenge.icon_path .. ":24:24:0:0|t " ..
                    challenge.title,
                fontSize = "medium",
                width = 1.5
            },
            action1 = {
                order = 2,
                type = "execute",
                name = "Edit",
                func = function()
                    HardcoreChallengeWheel.customChallengeForm.title = title
                    HardcoreChallengeWheel.customChallengeForm.description =
                        description
                    HardcoreChallengeWheel.customChallengeForm.challengeIconID =
                        iconID
                    HardcoreChallengeWheel.customChallengeForm.class = class
                    HardcoreChallengeWheel.customChallengeForm.key = key
                    AceConfigRegistry:NotifyChange("HardcoreChallengeWheel")
                end,
                width = 0.5
            },
            action2 = {
                order = 3,
                type = "execute",
                name = "Delete",
                func = function()
                    Challenges:RemoveCustomChallenge(key)
                end,
                width = 0.5
            }
        }
    }

    -- Add the challenge to the "enabled challenges" group
    HardcoreChallengeWheel.optionsTable.args.enabledChallenges.args[challenge.name] =
        {
            type = "toggle",
            name = "|T" .. challenge.icon_path .. ":24:24:0:0|t " ..
                challenge.title,
            desc = description,
            width = "normal",
            set = function(info, val)
                HardcoreChallengeWheel.db.profile.challenges[challenge.name] =
                    val
            end,
            get = function(info)
                return
                    HardcoreChallengeWheel.db.profile.challenges[challenge.name]
            end,
            order = 999
        }

    HardcoreChallengeWheel.db.profile.challenges[challenge.name] = true

    AceConfigRegistry:NotifyChange("HardcoreChallengeWheel")
end

function Challenges:RemoveCustomChallenge(name)
    HardcoreChallengeWheel.db.profile.customChallenges[name] = nil

    -- Rebuild the options for the custom challenges group
    local customChallengesGroup = HardcoreChallengeWheel.optionsTable.args
                                      .customGroup.args.customChallenges.args
    customChallengesGroup[name] = nil -- Remove the entry for the deleted challenge

    -- Remove the entry for the deleted challenge from the "enabled challenges" group
    HardcoreChallengeWheel.optionsTable.args.enabledChallenges.args[name] = nil

    AceConfigRegistry:NotifyChange("HardcoreChallengeWheel")
end
