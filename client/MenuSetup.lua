---------------------- Main Camp Menu Setup -----------------------------------
local cdown = false
function MainTentmenu()
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
                FurnMenu('tent')
            else
                VORPcore.NotifyRightTip(_U('Cdown'), 4000)
            end
        else
            if Config.CampItem.enabled then
                TriggerServerEvent('bcc-camp:RemoveCampItem')
            end
            FurnMenu('tent')
        end
    end)

    TentMenuPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    TextDisplay = TentMenuPage:RegisterElement('textdisplay', {
        value = _U('SetTent_desc'),
        slot = "footer",
        style = {}
    })

    BCCcampMenu:Open({
        startupPage = TentMenuPage
    })
end

function MainCampmenu()
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
        delcamp()
    end)

    -- Button for Furniture Setup
    mainCampMenu:RegisterElement('button', {
        label = "Furniture",
        slot = "content",
        style = {},
    }, function()
        BCCcampMenu:Close()
        FurnitureSetupMenu()
    end)

    -- Button for Setup Fast Travel Post
    mainCampMenu:RegisterElement('button', {
        label = _U('SetupFTravelPost'),
        slot = "content",
        style = {},
    }, function()
        BCCcampMenu:Close()
        if Config.FastTravel.enabled then
            spawnFastTravelPost()
        else
            VORPcore.NotifyRightTip(_U('FTravelDisabled'), 4000)
        end
    end)

    mainCampMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Back Button to return to the Main Camp Menu
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

function FurnitureSetupMenu()
    local furnitureMenu = BCCcampMenu:RegisterPage('furniture:page')

    -- Header for the furniture setup menu
    furnitureMenu:RegisterElement('header', {
        value = _U('furnitureMenu'),
        slot = "header",
        style = {}
    })

    furnitureMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- Button for Campfire
    if campfireExists then
        furnitureMenu:RegisterElement('button', {
            label = _U('RemoveFire'),
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            extinguishedCampfire()
        end)
    else
        furnitureMenu:RegisterElement('button', {
            label = _U('SetFire'),
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            FurnMenu('campfire')
        end)
    end

    -- Button for Bench
    if benchExists then
        furnitureMenu:RegisterElement('button', {
            label = _U('RemoveBench'),
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            deleteBench() -- You need to implement the logic to remove the bench
        end)
    else
        furnitureMenu:RegisterElement('button', {
            label = _U('SetBench'),
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            FurnMenu('bench')
        end)
    end

    -- Button for Storage Chest
    if storagechestExists then
        furnitureMenu:RegisterElement('button', {
            label = _U('RemoveStorageChest'),
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            deleteStorageChest() -- Implement the removal of the storage chest
        end)
    else
        furnitureMenu:RegisterElement('button', {
            label = _U('SetStorageChest'),
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            FurnMenu('storagechest')
        end)
    end

    -- Button for Hitching Post
    if hitchingpostExists then
        furnitureMenu:RegisterElement('button', {
            label = _U('RemoveHitchPost'),
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            deleteHitchPost() -- Implement the removal of the hitching post
        end)
    else
        furnitureMenu:RegisterElement('button', {
            label = _U('SetHitchPost'),
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            FurnMenu('hitchingpost')
        end)
    end

    -- Footer Line
    furnitureMenu:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Back Button to return to the Main Camp Menu
    furnitureMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {}
    }, function()
        MainCampmenu()
    end)

    -- Open the furniture setup menu
    BCCcampMenu:Open({
        startupPage = furnitureMenu
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

function FurnMenu(furntype)
    local FurnMenuPage = BCCcampMenu:RegisterPage('furnmenu:page')

    FurnMenuPage:RegisterElement('header', {
        value = _U('FurnMenu'),
        slot = "header",
        style = {}
    })

    FurnMenuPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    -- For tents
    if furntype == 'tent' then
        for _, v in pairs(Config.Furniture.Tent) do
            FurnMenuPage:RegisterElement('button', {
                label = v.name,
                slot = "content",
                style = {},
            }, function()
                BCCcampMenu:Close()
                spawnTent(v.hash)
            end)
        end

        -- For benches
    elseif furntype == 'bench' then
        for _, v in pairs(Config.Furniture.Benchs) do
            FurnMenuPage:RegisterElement('button', {
                label = v.name,
                slot = "content",
                style = {},
            }, function()
                BCCcampMenu:Close()
                spawnItem('bench', v.hash)
            end)
        end

        -- For hitching posts
    elseif furntype == 'hitchingpost' then
        for _, v in pairs(Config.Furniture.HitchingPost) do
            FurnMenuPage:RegisterElement('button', {
                label = v.name,
                slot = "content",
                style = {},
            }, function()
                BCCcampMenu:Close()
                spawnItem('hitchingpost', v.hash)
            end)
        end

        -- For campfires
    elseif furntype == 'campfire' then
        for _, v in pairs(Config.Furniture.Campfires) do
            FurnMenuPage:RegisterElement('button', {
                label = v.name,
                slot = "content",
                style = {},
            }, function()
                BCCcampMenu:Close()
                spawnItem('campfire', v.hash)
            end)
        end

        -- For storage chests
    elseif furntype == 'storagechest' then
        for _, v in pairs(Config.Furniture.StorageChest) do
            FurnMenuPage:RegisterElement('button', {
                label = v.name,
                slot = "content",
                style = {},
            }, function()
                BCCcampMenu:Close()
                spawnStorageChest(v.hash)
            end)
        end
    end

    FurnMenuPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    BCCcampMenu:Open({
        startupPage = FurnMenuPage
    })
end
