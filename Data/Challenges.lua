local HardcoreChallengeWheel = LibStub("AceAddon-3.0"):GetAddon(
                                   "HardcoreChallengeWheel")
local Challenges = HardcoreChallengeWheel:NewModule("Challenges")

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
        }
    }
end

function Challenges:GetChallengeByName(name)
    for key, challenge in ipairs(_G.achievements) do
        if key == name then
            print("Found challenge:", challenge.title)
            return challenge
        end
    end

    for _, challenge in ipairs(self.HCWheelChallenges) do
        if challenge.name == name then
            print("Found challenge:", challenge.title)
            return challenge
        end
    end

    print("Challenge not found:", name)
    return nil
end

function Challenges:GetAllChallenges()
    -- Create a new table to store the merged data
    local mergedChallenges = {}

    -- Copy data from _G.achievements into the new table
    for key, value in pairs(_G.achievements) do mergedChallenges[key] = value end

    -- Add transformed HCWheelChallenges into the new table
    for _, challenge in ipairs(self.HCWheelChallenges) do
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

    -- Return the new merged table without modifying _G.achievements
    return mergedChallenges
end

function Challenges:GetOptionsData()
    -- Separate challenges by origin
    local achievementsList = {}
    local customChallengesList = {}

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
        table.insert(customChallengesList,
                     {key = challenge.name, data = newEntry})
    end

    -- Sort both lists alphabetically by their keys
    table.sort(achievementsList, function(a, b) return a.key < b.key end)
    table.sort(customChallengesList, function(a, b) return a.key < b.key end)

    return {
        achievements = achievementsList,
        customChallenges = customChallengesList
    }
end
