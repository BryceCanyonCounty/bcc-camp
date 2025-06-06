---------------------- Main Camp Menu Setup -----------------------------------

local Core = exports.vorp_core:GetCore()

-- Main Camp Menu
function MainCampmenu(furntype)
    local condition = Core.Callback.TriggerAwait('bcc-camp:GetCampCondition', source)
    Wait(500)
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

    mainCampMenu:RegisterElement('textdisplay', {
        value = "Camp Condition: " .. condition .. '%',
        style = {}
    })

    mainCampMenu:RegisterElement('textdisplay', {
        value = "Camp Condition must be above 25% on tax day",
        style = {}
    })

    mainCampMenu:RegisterElement('textdisplay', {
        value = "Tax Day is on day " .. Config.TaxDay .. " of the month",
        style = {}
    })

    mainCampMenu:RegisterElement('line', {
        slot = "content",
        style = {}
    })

    -- Button for Camp Condition
    mainCampMenu:RegisterElement('button', {
        label = "Upkeep Camp",
        slot = "content",
        style = {},
    }, function()
        BCCcampMenu:Close()
        Wait(500)
        CampUpkeepMenu()
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

    mainCampMenu:RegisterElement('button', {
        label = "Add Camp Members",
        slot = "content",
        style = {},
    }, function()
        BCCcampMenu:Close()
        AddCampMemberMenu() -- Open the menu for furniture types
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
    -- Button for Destroy Camp
    mainCampMenu:RegisterElement('button', {
        label = _U('DestroyCamp'),
        slot = "content",
        style = {},
    }, function()
        BCCcampMenu:Close()

        -- Trigger the client-side deletion function

        -- Trigger the server-side event to delete the camp from the database
        TriggerServerEvent('bcc-camp:DeleteCamp')
    end)

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
    }
    if Config.Furniture[furntype] then
        table.insert(descrText, _U('SetupFTravelPost_desc'))
    end

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

    local furncatgories = {
        { value = 'Utilities',   label = "Camp Utilities" },
        { value = 'Furniture',   label = "Camp Furniture" },
        { value = 'Decorations', label = "Camp Decorations" },
        -- { value = 'Items',       label = "Personal Items" },
        -- { value = 'Sets',        label = "Prop Sets" },
        -- { value = 'Native',      label = "Native Furniture" },
        -- { value = 'Misc',        label = "Misc Items" },


    }
    table.sort(furncatgories, function(a, b)
        return a.label < b.label
    end)
    for _, furnType in pairs(furncatgories) do
        FurnitureTypePage:RegisterElement('button', {
            label = furnType.label, -- Use the type as the label
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            -- Open the menu for specific models in the selected furniture type
            ChooseFurnitureMenu(furnType.value)
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

function ChooseFurnitureMenu(furncatg)
    local FurnitureTypePage = BCCcampMenu:RegisterPage('furniturecatg:page')

    FurnitureTypePage:RegisterElement('header', {
        value = _U('FurnitureTypes'),
        slot = "header",
        style = {}
    })

    FurnitureTypePage:RegisterElement('line', {
        slot = "header",
        style = {}
    })
    local furniturelist = Config.Furniture[furncatg]
    table.sort(furniturelist)

    -- Register the elements in the sorted order
    for _, furnType in pairs(furniturelist) do
        FurnitureTypePage:RegisterElement('button', {
            label = _, -- Use the type as the label
            slot = "content",
            style = {},
        }, function()
            BCCcampMenu:Close()
            FurnModelMenu(furncatg, _)
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

function FurnModelMenu(category, type)
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
    if Config.Furniture[category] then
        -- Iterate over the models in the selected category
        for _, v in ipairs(Config.Furniture[category][type]) do
            local modelExists = furnitureExists[category] and furnitureExists[category][v.hash]
            -- If the model exists, show the "Remove" button
            if modelExists then
                FurnModelPage:RegisterElement('button', {
                    label = _U('Remove') .. " " .. v.name, -- Button label for removing furniture
                    slot = "content",
                    style = {},
                }, function()
                    BCCcampMenu:Close()
                    DeleteFurniture(category, v.hash, v.price) -- Delete the selected furniture
                    FurnitureTypeMenu()                        -- Go back to the furniture type menu
                end)
                PriceDispaly = FurnModelPage:RegisterElement('textdisplay', {
                    value = "Cost $" .. v.price,
                    style = {}
                })
                FurnModelPage:RegisterElement('line', {
                    -- slot = "header",
                    -- style = {}
                })
            else
                -- If the model doesn't exist, show the "Set" button to place furniture
                FurnModelPage:RegisterElement('button', {
                    label = _U('Set') .. " " .. v.name, -- Button label for setting furniture
                    slot = "content",
                    style = {},
                }, function()
                    BCCcampMenu:Close()
                    local moneyresult = Core.Callback.TriggerAwait('bcc-camp:CheckMoney', v.price)
                    if moneyresult then
                        spawnItem(category, v.hash, v.category, v.price) -- Spawn other furniture items
                    else
                        Core.NotifyRightTip("You do not have enough money", 4000)
                    end
                end)
                PriceDispaly = FurnModelPage:RegisterElement('textdisplay', {
                    value = "Cost $" .. v.price,
                    style = {}
                })
                FurnModelPage:RegisterElement('line', {
                    -- slot = "header",
                    -- style = {}
                })
            end

            -- Check if the model exists in the "furnitureExists" table for this category
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

function CampUpkeepMenu()
    local CampUpkeepPage = BCCcampMenu:RegisterPage('campupkeep:page')

    CampUpkeepPage:RegisterElement('header', {
        value = "Upkeep Camp",
        slot = "header",
        style = {}
    })

    CampUpkeepPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    CampUpkeepPage:RegisterElement('button', {
        label = "Donate Items",
        slot = 'content',
        stlye = {}
    }, function()
        BCCcampMenu:Close()
        DonateItemMenu()
    end)

    CampUpkeepPage:RegisterElement('textdisplay', {
        value = "Takes things like Leather, Nails, Wood, Rope, Coal, etc",
        slot = "content",
        style = {}
    })

    CampUpkeepPage:RegisterElement('line', {
        slot = "footer",
    })

    -- Back button to close the menu
    CampUpkeepPage:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {}
    }, function()
        BCCcampMenu:Close()
        MainCampmenu() -- Return to the main camp menu
    end)

    CampUpkeepPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })
    BCCcampMenu:Open({
        startupPage = CampUpkeepPage
    })
end

function DonateItemMenu()
    local DonateItemsPage = BCCcampMenu:RegisterPage('donateitems:page')
    local founditems = {}
    local ItemAmounts = {}

    local itemresult = Core.Callback.TriggerAwait('bcc-camp:GetPlayerItems', source)
    if itemresult then
        founditems = itemresult
        DonateItemsPage:RegisterElement('textdisplay', {
            value = 'Select the amount to donate below',
            slot = "content",
            style = {}
        })
        for key, item in ipairs(founditems) do
            for k, value in pairs(item) do
                DonateItemsPage:RegisterElement('slider', {
                    label = value.label,
                    start = 0,
                    min = 0,
                    max = value.count or 25,
                    steps = 1,
                }, function(data)
                    ItemAmounts[k] = data.value
                end)
            end
        end
        DonateItemsPage:RegisterElement('header', {
            value = "Upkeep Camp",
            slot = "header",
            style = {}
        })

        DonateItemsPage:RegisterElement('line', {
            slot = "header",
            style = {}
        })


        DonateItemsPage:RegisterElement('button', {
            label = "Donate",
            slot = 'content',
            stlye = {}
        }, function()
            BCCcampMenu:Close()
            TriggerServerEvent('bcc-camp:DonateCampItems', ItemAmounts)
            Core.NotifyRightTip("Items Donated", 4000)
        end)

        DonateItemsPage:RegisterElement('line', {
            slot = "footer",
        })

        -- Back button to close the menu
        DonateItemsPage:RegisterElement('button', {
            label = _U("backButton"),
            slot = 'footer',
            style = {}
        }, function()
            BCCcampMenu:Close()
            MainCampmenu()     -- Return to the main camp menu
        end)

        DonateItemsPage:RegisterElement('bottomline', {
            slot = "footer",
            style = {}
        })
        BCCcampMenu:Open({
            startupPage = DonateItemsPage
        })
    else
        Core.NotifyRightTip("You do not have the needed items", 4000)
        do return end
    end
end

function AddCampMemberMenu()
    local CampMemberMenu = BCCcampMenu:RegisterPage('campmember:page')

    CampMemberMenu:RegisterElement('header', {
        value = "Upkeep Camp",
        slot = "header",
        style = {}
    })

    CampMemberMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    CampMemberMenu:RegisterElement('button', {
        label = "Add Member",
        slot = 'content',
        style = {}
    }, function()
        BCCcampMenu:Close()
        FeatherMenuInput() -- Return to the main camp menu
    end)

    CampMemberMenu:RegisterElement('line', {
        slot = "footer",
    })

    -- Back button to close the menu
    CampMemberMenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {}
    }, function()
        BCCcampMenu:Close()
        MainCampmenu() -- Return to the main camp menu
    end)

    CampMemberMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })
    BCCcampMenu:Open({
        startupPage = CampMemberMenu
    })
end

function FeatherMenuInput()
    local Inputmenu = BCCcampMenu:RegisterPage('inputmenu:page')

    Inputmenu:RegisterElement('header', {
        value = "Input Member ID",
        slot = "header",
        style = {}
    })

    Inputmenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    local inputValue = ''
    Inputmenu:RegisterElement('input', {
        label = "Player ID",
        placeholder = "Type something!",
        style = {

        }
    }, function(data)
        -- This gets triggered whenever the input value changes
        inputValue = data.value
    end)

    -- Back button to close the menu
    Inputmenu:RegisterElement('button', {
        label = "Submit ID",
        slot = 'footer',
        style = {}
    }, function()
        BCCcampMenu:Close()
        TriggerServerEvent('bcc-camp:AddCampMember', inputValue)
    end)

    Inputmenu:RegisterElement('line', {
        slot = "footer",
    })

    -- Back button to close the menu
    Inputmenu:RegisterElement('button', {
        label = _U("backButton"),
        slot = 'footer',
        style = {}
    }, function()
        BCCcampMenu:Close()
        MainCampmenu() -- Return to the main camp menu
    end)

    Inputmenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })
    BCCcampMenu:Open({
        startupPage = Inputmenu
    })
end

function SelectPosseMemberMenu(members)
    local PosseMemberPage = BCCcampMenu:RegisterPage('selectmember:page')

    PosseMemberPage:RegisterElement('header', {
        value = "Select Member",
        slot = "header",
        style = {}
    })

    PosseMemberPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })
    local options = {}
    for key, v in pairs(members) do
        table.insert(options, { text = v.name, value = v.id })
    end
    PosseMemberPage:RegisterElement('dropdown', {
        label = 'Select a Member',
        slot = "content",
        options = options
    }, function(data)
        -- This gets triggered whenever the dropdown selected value changes
        print(data.value)
    end)
end
