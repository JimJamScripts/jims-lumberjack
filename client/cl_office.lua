-- =========================================================
--  Lumber Business - Office Build System (Client)
-- =========================================================

local buildingOffice = false
local officeBuilt = false

-- =========================================================
--  Debug Wrapper
-- =========================================================
local function Debug(msg, level)
    if not Config.Debug then return end
    if level > Config.DebugLevel then return end

    print(("^3[Lumber Debug]^7 %s"):format(msg))
end

-- =========================================================
--  Draw 3D Text Helper
-- =========================================================
local function Draw3DText(coords, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if not onScreen then return end

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 255)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), _x, _y)
end

-- =========================================================
--  Office Build Logic
-- =========================================================
local function StartOfficeBuild()
    if buildingOffice then return end
    buildingOffice = true

    local timeLeft = Config.OfficeBuildTime

    Debug("Office build started (" .. timeLeft .. " seconds)", 2)

    CreateThread(function()
        while timeLeft > 0 do
            print(("^2Building office... ^7%d seconds remaining"):format(timeLeft))
            Wait(1000)
            timeLeft -= 1
        end

        buildingOffice = false
        officeBuilt = true

        print("^2Your office has been constructed.")
        Debug("Office build complete", 2)

        -- Phase 1B: This is where we will spawn the office building
        -- and unlock the main business menu.
    end)
end

-- =========================================================
--  Main Loop: Detect Office Location
-- =========================================================
CreateThread(function()
    while true do
        Wait(0)

        -- Must be the owner
        if not LumberBusiness.IsOwner() then goto continue end

        -- Office already built
        if officeBuilt then goto continue end

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.OfficeLocation)

        if dist < 3.0 then
            Draw3DText(Config.OfficeLocation + vector3(0, 0, 1.0), "Press [E] to build your office")

            if IsControlJustPressed(0, 0xCEFD9220) then -- E key
                StartOfficeBuild()
            end
        end

        ::continue::
    end
end)
