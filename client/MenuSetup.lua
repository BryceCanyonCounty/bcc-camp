---------------------- Main Camp Menu Setup -----------------------------------
local cdown = false
-- Main Tent Menu
function MainTentmenu(furntype, model)
    local TentMenuPage = BCCcampMenu:RegisterPage('maintent:page')

    TentMenuPage:RegisterElement('header', {
        value = _U('MenuName'),
        slot = "header",
        style = {}
    })

    TentMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Button to set Tent (Shows only tents)
    TentMenuPage:RegisterElement('button', {
        label = _U('SetTent'),
        slot = "content",
        style = {},
    }, function()
        if Config.Cooldown then
            if not cdown then
                if Config.CampItem.enabled then
                    TriggerServerEvent('bcc-camp:RemoveCampItem')
                end
                cdown = true
                FurnModelMenu('Tent') -- Only shows tent models
            else
                VORPcore.NotifyRightTip(_U('Cdown'), 4000)
            end
        else
            if Config.CampItem.enabled then
                TriggerServerEvent('bcc-camp:RemoveCampItem')
            end
            FurnModelMenu('Tent') -- Only shows tent models
        end
    end)

    TentMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TentMenuPage:RegisterElement('textdisplay', {
        value = _U('SetTent_desc'),
        slot = "footer",
        style = {}
    })

    BCCcampMenu:Open({
        startupPage = TentMenuPage
    })
end

-- Main Camp Menu
function MainCampmenu(furntype)
    local mainCampMenu = BCCcampMenu:RegisterPage('maincamp:page')

    -- Header for the main camp menu
    mainCampMenu:RegisterElement('header', {
        value = _U('MenuName'),
        slot = "header",
        style = {}
    })

    mainCampMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Button for Destroy Camp
    mainCampMenu:RegisterElement('button', {
        label = _U('DestroyCamp'),
        slot = "content",
        style = {},
    }, function()
        BCCcampMenu:Close()

        -- Trigger the client-side deletion function
        delcamp()

        -- Trigger the server-side event to delete the camp from the database
        TriggerServerEvent('bcc-camp:DeleteCamp')
    end)


    -- Button for Furniture Setup (Triggers the FurnitureTypeMenu)
    mainCampMenu:RegisterElement('button', {
        label = _U('FurnitureSetup'),
        slot = "content",
        style = {},
    }, function()
        BCCcampMenu:Close()
        FurnitureTypeMenu() -- Open the menu for furniture types
    end)
    
    -- Ensure you're looking for the FastTravelPost type in the config
    local furntype = 'FastTravelPost'
    
    -- Iterate over the furniture models for FastTravelPost
    if Config.Furniture[furntype] then
        for _, v in pairs(Config.Furniture[furntype]) do
            local modelExists = furnitureExists[furntype] and furnitureExists[furntype][v.hash]
    
            -- If the model already exists, show the "Remove" button
            if modelExists then
                mainCampMenu:RegisterElement('button', {
                    label = _U('Remove') .. " " .. v.name, -- Button label for removing Fast Travel Post
                    slot = "content",
                    style = {},
                }, function()
                    BCCcampMenu:Close()
                    DeleteFurniture(furntype, v.hash) -- Delete the selected Fast Travel Post
                end)
            else
                -- If the model doesn't exist, show the "Set" button to place Fast Travel Post
                mainCampMenu:RegisterElement('button', {
                    label = _U('Set') .. " " .. v.name, -- Button label for setting Fast Travel Post
                    slot = "content",
                    style = {},
                }, function()
                    BCCcampMenu:Close()
                    spawnFastTravelPost(furntype, v.hash) -- Spawn the Fast Travel Post
                end)
            end
        end
    else
        devPrint("No FastTravelPost configuration found in Config.Furniture")
    end


    mainCampMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Back Button to close the Main Camp Menu
    mainCampMenu:RegisterElement('button', {
        label = _U("closeButton"),
        slot = 'footer',
        style = {}
    }, function()
        BCCcampMenu:Close()
    end)

    mainCampMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    local descrText = {
        _U('DestroyCamp_desc'),
        _U('SetupFTravelPost_desc')
    }

    -- Combine all values into a single sentence, separated by commas
    local combinedDescr = table.concat(descrText, ", ")

    -- Use HTML to create a styled text display
    mainCampMenu:RegisterElement("html", {
        value = {
            [[
            <div style="text-align: center; padding: 10px;">
                <p style="font-size: 14px;">]] .. combinedDescr .. [[</p>
            </div>
            ]]
        },
        slot = "footer",
        style = {}
    })

    -- Open the main camp menu
    BCCcampMenu:Open({
        startupPage = mainCampMenu
    })
end

function Tpmenu()
    local TpMenuPage = BCCcampMenu:RegisterPage('tp:page')

    TpMenuPage:RegisterElement('header', {
        value = _U('FastTravelMenuName'),
        slot = "header",
        style = {}
    })

    TpMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    local elements, elementindex = {}, 1
    Wait(100) -- Waits 100ms

    for k, v in pairs(Config.FastTravel.Locations) do
        elements[elementindex] = {
            label = v.name,
            value = 'tp' .. tostring(elementindex),
            info = v.coords
        }
        elementindex = elementindex + 1
    end

    for _, element in ipairs(elements) do
        TpMenuPage:RegisterElement('button', {
            label = element.label,
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()

            local coords = element.info
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
        end)
    end

    TpMenuPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    BCCcampMenu:Open({
        startupPage = TpMenuPage
    })
end

-- Menu to select furniture types (triggered from MainCampmenu)
function FurnitureTypeMenu()
    local FurnitureTypePage = BCCcampMenu:RegisterPage('furnituretype:page')

    FurnitureTypePage:RegisterElement('header', {
        value = _U('FurnitureTypes'),
        slot = "header",
        style = {}
    })

    FurnitureTypePage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

-- Get all furniture types from the config, excluding tents and travel posts
local furnitureTypes = {}

-- Collect furniture types into a table, excluding Tent and FastTravelPost
for furnType, _ in pairs(Config.Furniture) do
    if furnType ~= 'Tent' and furnType ~= 'FastTravelPost' then
        table.insert(furnitureTypes, furnType)
    end
end

-- Sort the furniture types alphabetically (or you can apply any other sorting logic)
table.sort(furnitureTypes)

-- Register the elements in the sorted order
for _, furnType in ipairs(furnitureTypes) do
    FurnitureTypePage:RegisterElement('button', {
        label = _U(furnType),                               -- Use the type as the label
        slot = "content",
        style = {},
    }, function()
        BCCcampMenu:Close()
        -- Open the menu for specific models in the selected furniture type
        FurnModelMenu(furnType)
    end)
end

    FurnitureTypePage:RegisterElement('line', {
        slot = "footer",
    })

    -- Back button to close the menu
    FurnitureTypePage:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {}
    }, function()
        BCCcampMenu:Close()
        MainCampmenu() -- Return to the main camp menu
    end)

    FurnitureTypePage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCcampMenu:Open({
        startupPage = FurnitureTypePage
    })
end

function FurnModelMenu(furntype)
    local FurnModelPage = BCCcampMenu:RegisterPage('furnmodel:page')

    FurnModelPage:RegisterElement('header', {
        value = _U('SelectModel'),
        slot = "header",
        style = {}
    })

    FurnModelPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Iterate over the models for the selected furniture type
    for _, v in pairs(Config.Furniture[furntype]) do
        local modelExists = furnitureExists[furntype] and furnitureExists[furntype][v.hash]

        -- If the model already exists, show the "Remove" button
        if modelExists then
            FurnModelPage:RegisterElement('button', {
                label = _U('Remove') .. " " .. v.name, -- Button label for removing furniture
                slot = "content",
                style = {},
            }, function()
                BCCcampMenu:Close()
                DeleteFurniture(furntype, v.hash) -- Delete the selected furniture
                FurnitureTypeMenu()
            end)
        else
            -- If the model doesn't exist, show the "Set" button to place furniture
            FurnModelPage:RegisterElement('button', {
                label = _U('Set') .. " " .. v.name, -- Button label for setting furniture
                slot = "content",
                style = {},
            }, function()
                BCCcampMenu:Close()
                if furntype == 'Tent' then
                    spawnTent(v.hash)           -- Spawn the tent specifically
                else
                    spawnItem(furntype, v.hash) -- Spawn other furniture items
                end
            end)
        end
    end

    -- Footer elements
    FurnModelPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Back button to return to the furniture type selection menu
    FurnModelPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {}
    }, function()
        BCCcampMenu:Close()
        FurnitureTypeMenu()
    end)

    FurnModelPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    BCCcampMenu:Open({
        startupPage = FurnModelPage
    })
end
