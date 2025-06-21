--https://github.com/dawid-scripts/Fluent/blob/master/Example.lua
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Uncharron/Solo/refs/heads/main/MENU/Manager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Uncharron/Solo/refs/heads/main/MENU/InterfaceManager.lua"))()



local Window = Fluent:CreateWindow({
    Title = "Grow a Garden",
    SubTitle = "- CodeX HUB ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Game", Icon = "code" }),
    Sell = Window:AddTab({ Title = "Sell", Icon = "compass" }),
    Buy = Window:AddTab({ Title = "Buy", Icon = "coffee" }),
    --UP = Window:AddTab({ Title = "UP", Icon = "coffee" }),
    Webhook = Window:AddTab({ Title = "Webhook", Icon = "clock" }),
    Server = Window:AddTab({ Title = "Server", Icon = "cherry" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
local AutoCollectHoneysetting = true
local Options = Fluent.Options
local AutoCollectHoney = false
local AutoCollectHoneycontor = true
local AutoHaverfuits = false
local Autosellfruit = false
local PlantSeedEQ = false
local AutoBuyEggEnabled = false
local AutoBuyHonneyEnabled = false
local AutoBuyGearEnabled = false
local AutoBuySeedEnabled = false
local tragetWebhook = false
local Autocraftseed = false
local Autocraftegg = false
local eqqSelectedSeeds = {}
local SelectedSeeds = {}
local SelectedGears = {}
local SelectedHoney = {}
local harvestedPlants = harvestedPlants or {}
local timereseed
local Seedfuitname = {}
local targetEggNames = {}
-- รายชื่อบัฟที่ต้องการตรวจสอบ
local buffsToCheck = Seedfuitname

local Frutsedxc = 20
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuySeedEvent = ReplicatedStorage.GameEvents.BuySeedStock
local BuyGearEvent = ReplicatedStorage.GameEvents.BuyGearStock

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local PlantEvent = ReplicatedStorage.GameEvents.HoneyMachineService_RE

local HarvestEvent = ReplicatedStorage.GameEvents.HarvestRemote



local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")


-- บัฟที่เราต้องการให้ขาย
local allowedBuffs = {}

local farmCFrame = CFrame.new(
    86.5795212, 2.99999976, 0.42678827,
    0.000774302403, -2.61200448e-08, -0.999999702,
    -9.92440505e-13, 1, -2.61200537e-08,
    0.999999702, 2.12172606e-11, 0.000774302403
)

local originalCFrame -- เซฟตำแหน่งเดิม

--// Config
getgenv().whscript = "Code X HUB"
getgenv().webhookexecUrl = ""

--// ฟังก์ชันส่งข้อมูล Webhook
local function sendWebhook()
    local player = game:GetService("Players").LocalPlayer
    local httpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local PlayerData = ReplicatedStorage.Player_Data
    local playerStats = PlayerData:FindFirstChild(player.Name)

    -- ถ้าไม่มี playerStats ให้หยุดและแจ้งเตือน
    if not playerStats then
        warn("ไม่พบข้อมูลผู้เล่น " .. player.Name)
        return
    end

    -- ดึงชื่อเกม
    local gameName = "Unknown Game"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)

    -- ถ้าไม่ได้ตั้ง webhook url ให้หยุด
    if getgenv().webhookexecUrl == "" then
        print("Webhook URL is not set!")
        return
    end

    -- เวลาปัจจุบัน
    local completeTime = os.date("%Y-%m-%d %H:%M:%S")

    -- ตัวละคร player
    local character = player.Character or workspace:FindFirstChild("__Main") and workspace.__Main.__Players:FindFirstChild(player.Name)
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    local health = humanoid and humanoid.Health or "N/A"
    local maxHealth = humanoid and humanoid.MaxHealth or "N/A"
    local position = rootPart and rootPart.Position or "N/A"

    -- ดึงค่าจาก GUI
    local chapterLabel = player.PlayerGui.RewardsUI.Main.LeftSide:WaitForChild("Chapter")
    local DifficultyLabel = player.PlayerGui.RewardsUI.Main.LeftSide:WaitForChild("Difficulty")
    local GameStatusLabel = player.PlayerGui.RewardsUI.Main.LeftSide:WaitForChild("GameStatus")
    local WorldLabel = player.PlayerGui.RewardsUI.Main.LeftSide:WaitForChild("World")
    local ModeLabel = player.PlayerGui.RewardsUI.Main.LeftSide:WaitForChild("Mode")
    local TotalTimeLabel = player.PlayerGui.RewardsUI.Main.LeftSide:WaitForChild("TotalTime")

    -- Rewards Drop
    local Base = ScanRewardsAndPrintAmount()

    -- รายชื่อ items ที่ต้องการเช็ก
    local itemNames = {
        "Dr. Megga Punk",
        "Ranger Crystal",
        "Stats Key",
        "Perfect Stats Key",
        "Cursed Finger",
        "Trait Reroll",
        "Ghoul City Portal I",
        "Ghoul City Portal II",
        "Ghoul City Portal III"
    }

    -- Loop ดึงค่าจาก items
    local itemValuesText = "```"
    for _, itemName in ipairs(itemNames) do
        local item = playerStats.Items:FindFirstChild(itemName)
        if item then
            itemValuesText = itemValuesText .. "\n🔥 " .. itemName .. ": " .. item.Amount.Value
        else
            itemValuesText = itemValuesText .. "\n🔥 " .. itemName .. ": N/A"
        end
    end
    itemValuesText = itemValuesText .. "```"

    -- เตรียม fields สำหรับ webhook
    local fields = {
        {
            ["name"] = "🔍 **Info**",
            ["value"] = "```💻 Script Name: " .. getgenv().whscript .. "\n🆔 Game Name: " .. gameName .. "\n⏰ Executed At: " .. completeTime .. "```",
            ["inline"] = false
        },
        {
            ["name"] = "👤 **Player Info**",
            ["value"] = "```🧸 Username: " .. player.Name .. "\n📝 Display Name: " .. player.DisplayName .. "\n🆔 UserID: " .. player.UserId .. "```",
            ["inline"] = false
        },
        {
            ["name"] = "🎮 **Games Info**",
            ["value"] = "```" ..
                        "\n🌍 World: " .. WorldLabel.Text ..
                        "\n📖 Chapter: " .. chapterLabel.Text ..
                        "\n🔥 Difficulty: " .. DifficultyLabel.Text ..
                        "\n🎮 Mode: " .. ModeLabel.Text ..
                        "\n⏳ Game Status: " .. GameStatusLabel.Text ..
                        "\n⏱ Total Time: " .. TotalTimeLabel.Text .. "```",
            ["inline"] = false
        },
        {
            ["name"] = "🎮 **Games Item**",
            ["value"] = itemValuesText,
            ["inline"] = false
        }
    }

    -- แทรก Base rewards เข้า fields
    for name, value in pairs(Base) do
        table.insert(fields, {
            ["name"] = "🎂 **ITEM Drop**",
            ["value"] = "```" .. name .. ": " .. tostring(value) .. "```",
            ["inline"] = false
        })
    end

    -- เพิ่มตำแหน่ง player
    table.insert(fields, {
        ["name"] = "📍 **Position**",
        ["value"] = "```📍 Position: " .. tostring(position) .. "```",
        ["inline"] = true
    })

    -- สร้าง payload สำหรับ webhook
    local data = {
        ["content"] = "@everyone",
        ["embeds"] = {
            {
                ["title"] = "🐻 ** Code X HUB LOG | Anime RengerX **",
                ["type"] = "rich",
                ["color"] = tonumber(0x34DB98),
                ["fields"] = fields,
                ["footer"] = {
                    ["text"] = "Ⓤ  Code X HUB Log | " .. completeTime,
                }
            }
        }
    }

    -- ส่ง webhook
    local requestData = httpService:JSONEncode(data)
    local headers = {["content-type"] = "application/json"}

    local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    if request then
        request({Url = getgenv().webhookexecUrl, Body = requestData, Method = "POST", Headers = headers})
    else
        warn("HTTP request function not found! Unable to send webhook.")
    end
end
local function AutoBuySeeds()
    for _, seed in ipairs(SelectedSeeds) do
        BuySeedEvent:FireServer(seed)
        task.wait(0.1)
    end
end
-- ฟังก์ชัน Auto Buy Gear ทีละอัน
local function AutoBuyGears()
    for _, gear in ipairs(SelectedGears) do
        local args = {gear}
        BuyGearEvent:FireServer(unpack(args))
        task.wait(0.1) -- กันปิง/กันสแปม
    end
end
-- ฟังก์ชัน Auto Buy Gear ทีละอัน
local function AutoBuyHonneyshop()
    for _, Honny in ipairs(SelectedHoney) do
        local args = {Honny}
        --BuyGearEvent:FireServer(unpack(args))
        game:GetService("ReplicatedStorage").GameEvents.BuyEventShopStock:FireServer(unpack(args))
        task.wait(0.1) -- กันปิง/กันสแปม
    end
end



-- ฟังก์ชัน Equip Shovel
local function EquipShovel()
    for _, item in ipairs(Backpack:GetChildren()) do
        if string.find(item.Name, "Shovel") and string.find(item.Name, "Destroy Plants") then
            LocalPlayer.Character.Humanoid:EquipTool(item)
            print("ใส่ไอเท็ม: " .. item.Name)
            return item
        end
    end
    print("ไม่พบ Shovel [Destroy Plants] ในกระเป๋า")
    return nil
end

-- ฟังก์ชัน Equip Harvest Tool
local function EquipHarvestTool()
    for _, item in ipairs(Backpack:GetChildren()) do
        if string.find(item.Name, "Harvest Tool") then
            LocalPlayer.Character.Humanoid:EquipTool(item)
            print("ใส่ไอเท็ม: " .. item.Name)
            return item
        end
    end
    print("ไม่พบ Harvest Tool ในกระเป๋า")
    return nil
end

local function EquipAndUsePollinatedFruits()
    for _, item in ipairs(Backpack:GetChildren()) do
        if string.find(item.Name, "Pollinated") then
            print("เจอผลไม้ติดเกสร: " .. item.Name)
            
            -- Equip Tool
            LocalPlayer.Character.Humanoid:EquipTool(item)
            task.wait(0.15) -- เว้นหน่อยให้ใส่ทัน

            -- กดใช้ HoneyMachine
            local args = {
                [1] = "MachineInteract"
            }
            PlantEvent:FireServer(unpack(args))

            task.wait(0.15) -- เว้นนิดให้ Event ทำงาน
            local harvestTool = EquipHarvestTool()
        end
    end
end

-- ฟังก์ชันเช็คว่าผลไม้มีบัฟที่กำหนดไหม
local function HasAnyBuff(fruit)
    for _, buffName in ipairs(Seedfuitname) do
        if fruit:GetAttribute(buffName) then
            return true, buffName -- เจอบัฟไหนก็ส่งคืนนั้น
        end
    end
    return false, nil
end


-- ฟังก์ชันดึงชื่อตัวเอง (สมมติ LocalPlayer)
local function getMyName()
    local player = game.Players.LocalPlayer
    if player then
        return player.Name
    else
        return "UnknownPlayer"
    end
end

local myName = getMyName()

-- ฟังก์ชันตรวจสอบฟาร์มของเราใน workspace.Farm
local function FindMyFarms()
    local myFarms = {}

    for _, farm in ipairs(workspace.Farm:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        if important then
            local data = important:FindFirstChild("Data")
            if data then
                local owner = data:FindFirstChild("Owner")
                if owner and owner.Value == myName then
                    print("เจอฟาร์มของเรา: " .. farm.Name)
                    table.insert(myFarms, farm)
                end
            end
        end
    end

    return myFarms
end
local function GetPlantLocations(farm)
    local locations = {}
    local important = farm:FindFirstChild("Important")
    if important then
        local plantLocations = important:FindFirstChild("Plant_Locations")
        if plantLocations then
            for _, part in ipairs(plantLocations:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(locations, part.Position)
                    print("เจอจุดปลูก: " .. tostring(part.Position))
                end
            end
        end
    end
    return locations
end

local function EquipSeed(seedName)
    local Backpack = LocalPlayer.Backpack
    local lowerSeedName = seedName:lower()
    for _, item in ipairs(Backpack:GetChildren()) do
        local itemNameLower = item.Name:lower()
        if string.find(itemNameLower, lowerSeedName) then
            print("เจอเมล็ดใกล้เคียง: " .. item.Name)
            LocalPlayer.Character.Humanoid:EquipTool(item)
            return true
        end
    end
    warn("ไม่เจอเมล็ดใกล้เคียง: " .. seedName)
    return false
end


local function GetPlantSeed(seedName)
    if EquipSeed(seedName) then
        print("สวมใส่เมล็ดเรียบร้อย")
    else
        print("หาเมล็ดไม่เจอ")
        --return -- จะทำต่อหรือไม่ก็ได้
    end

    -- ✅ ใช้งาน
local myFarms = FindMyFarms()

if #myFarms > 0 then
    -- Random เลือกฟาร์มเรา
    local randomFarm = myFarms[math.random(1, #myFarms)]
    --print("เลือกฟาร์ม: " .. randomFarm.Name)

    local locations = GetPlantLocations(randomFarm)

    if #locations > 0 then
        -- Random จุดปลูกในฟาร์ม
        local randomLocation = locations[math.random(1, #locations)]
        --print("เลือกจุดปลูก: " .. tostring(randomLocation))
         -- ตัดคำว่า " Seed" ออก
        local plantName = string.gsub(seedName, " Seed", "")
        -- ส่งปลูก
        local args = {
            [1] = randomLocation,
            [2] = plantName
        }
        game:GetService("ReplicatedStorage").GameEvents.Plant_RE:FireServer(unpack(args))
    else
      --  warn("ไม่เจอจุดปลูกในฟาร์มนี้")
    end
else
   -- warn("ไม่เจอฟาร์มของเรา")
end
end

local function RandomPlantSeed()
    local randomSeed = eqqSelectedSeeds[math.random(1, #eqqSelectedSeeds)]
    GetPlantSeed(randomSeed)
end


-- ฟังก์ชันเช็คว่าผลไม้มีบัฟใน list หรือไม่
local function FruitHasBuff(fruit, buffList)
    for _, buffName in ipairs(buffList) do
        -- เช็ค attribute ตามชื่อบัฟ
        if fruit:GetAttribute(buffName) then
            return true, buffName
        end
    end
    return false, nil
end

-- ฟังก์ชันค้นหาผลไม้ที่มีบัฟในฟาร์มที่ระบุ
local function FindFruitsWithBuffsInFarm(farm, buffList)
    local foundFruits = {}

    local important = farm:FindFirstChild("Important")
    if not important then return foundFruits end
    local plantsFolder = important:FindFirstChild("Plants_Physical")
    if not plantsFolder then return foundFruits end

    for _, plant in ipairs(plantsFolder:GetChildren()) do
        local fruits = plant:FindFirstChild("Fruits")
        if fruits then
            for _, fruit in ipairs(fruits:GetChildren()) do
                local hasBuff, buffName = FruitHasBuff(fruit, buffList)
                if hasBuff then
                    print(string.format("ฟาร์ม: %s | ต้น: %s | ผล: %s | บัฟ: %s",
                        farm.Name, plant.Name, fruit.Name, buffName))
                    table.insert(foundFruits, {
                        farm = farm,
                        plant = plant,
                        fruit = fruit,
                        buff = buffName
                    })
                end
            end
        end
    end

    return foundFruits
end

-- ฟังก์ชันรวมสแกนฟาร์มของเราและหาผลไม้ที่มีบัฟตาม list
local function ScanMyFarmsForBuffedFruits(buffList)
    local myFarms = FindMyFarms()
    local allFoundFruits = {}

    for _, farm in ipairs(myFarms) do
        local fruitsWithBuffs = FindFruitsWithBuffsInFarm(farm, buffList)
        for _, fruitData in ipairs(fruitsWithBuffs) do
            table.insert(allFoundFruits, fruitData)
        end
    end

    return allFoundFruits
end

local function FindAndHarvestPollinated()
    local myFarms = FindMyFarms()
    local myFarm = myFarms[1]
    local randomFarm = myFarms[math.random(1, #myFarms)]
    if not randomFarm then
        warn("ไม่พบฟาร์มของเราใน workspace.Farm")
        return
    end

    local plantsFolder = randomFarm:FindFirstChild("Important")
    if not plantsFolder then return end
    plantsFolder = plantsFolder:FindFirstChild("Plants_Physical")
    if not plantsFolder then return end

    for _, plant in ipairs(plantsFolder:GetChildren()) do
        if not harvestedPlants[plant] then
            local fruits = plant:FindFirstChild("Fruits")
            if fruits then
                for _, fruit in ipairs(fruits:GetChildren()) do
                    local hasBuff, buffName = HasAnyBuff(fruit)
                    if hasBuff then
                       -- print("เจอผลที่มีบัฟ '"..buffName.."' ที่ต้น: " .. plant.Name .. " | ผล: " .. fruit.Name)

                        local shovel = EquipShovel()
                        if shovel then task.wait(0.2) end

                        local harvestTool = EquipHarvestTool()
                        if harvestTool then
                            task.wait(0.2)

                            local args = {
                                [1] = harvestTool,
                                [2] = plant
                            }
                            HarvestEvent:InvokeServer(unpack(args))

                            harvestedPlants[plant] = true
                        end

                        local shovel = EquipShovel()
                        if shovel then task.wait(0.2) end

                        return -- เจออันแรกหยุด
                    end
                end
                harvestedPlants = {}
            end
        end
    end
end



-- เช็คว่ามีผลไม้ที่มีบัฟที่เราไม่เลือกไหม
local function CountNotAllowedBuffFruits()
    local count = 0
    for _, item in ipairs(Backpack:GetChildren()) do
        -- เช็คว่าเป็นผลไม้ (ที่มี [ ในชื่อ)
        if string.find(item.Name, "%[") then
            local isAllowed = false
            for _, buff in ipairs(allowedBuffs) do
                if string.find(item.Name, buff) then
                    isAllowed = true
                    break
                end
            end
            -- ถ้าไม่ใช่บัฟที่อนุญาต เพิ่ม count
            if not isAllowed then
                count = count + 1
            end
        end
    end
    return count
end

-- เทเลพอร์ตไปฟาร์ม
local function TeleportToFarm()
    originalCFrame = HumanoidRootPart.CFrame
    HumanoidRootPart.CFrame = farmCFrame
    print("TP ไปฟาร์ม")
    task.wait(0.5)
end

-- กลับตำแหน่งเดิม
local function ReturnToOriginalPosition()
    if originalCFrame then
        HumanoidRootPart.CFrame = originalCFrame
        print("กลับตำแหน่งเดิม")
    else
        print("ยังไม่ได้เซฟตำแหน่งเดิม")
    end
end

-- ขายผลไม้ที่ไม่มีบัฟที่เราเลือก
local function SellUnwantedFruits()
    for _, item in ipairs(Backpack:GetChildren()) do
        if string.find(item.Name, "%[") then
            local isAllowed = false
            for _, buff in ipairs(allowedBuffs) do
                if string.find(item.Name, buff) then
                    isAllowed = true
                    break
                end
            end

            -- ขายเฉพาะผลไม้ที่ไม่มีบัฟที่อนุญาต
            if not isAllowed then
                Character.Humanoid:EquipTool(item)
                ReplicatedStorage.GameEvents.Sell_Item:FireServer(item)
                print("ขาย: " .. item.Name)
                task.wait(0.5)
            else
                print("ข้าม: " .. item.Name)
            end
        end
    end
end


local function IsTargetEgg(name)
    for _, targetName in ipairs(targetEggNames) do
        if name == targetName then
            return true
        end
    end
    return false
end

local function BuyEggByLocation()
    local eggFolder = workspace.NPCS["Pet Stand"].EggLocations

    for index, model in ipairs(eggFolder:GetChildren()) do
        if IsTargetEgg(model.Name) then
            if index == 4 then
                game:GetService("ReplicatedStorage").GameEvents.BuyPetEgg:FireServer(1)
                print("ซื้อ " .. model.Name .. " ที่ตำแหน่ง 4 (args=1)")
            elseif index == 5 then
                game:GetService("ReplicatedStorage").GameEvents.BuyPetEgg:FireServer(2)
                print("ซื้อ " .. model.Name .. " ที่ตำแหน่ง 5 (args=2)")
            elseif index == 6 then
                game:GetService("ReplicatedStorage").GameEvents.BuyPetEgg:FireServer(3)
                print("ซื้อ " .. model.Name .. " ที่ตำแหน่ง 6 (args=3)")
            end
        end
    end
end

local function getFlowerSeedPackUUID()
    local player = game:GetService("Players").LocalPlayer
    local backpack = player.Backpack

    for _, item in ipairs(backpack:GetChildren()) do
        if string.find(item.Name, "Flower Seed Pack") then
            local uuid = item:GetAttribute("c")
            if uuid then
                print("Found "..item.Name.." - UUID: "..uuid)
                return uuid
            end
        end
    end
    return nil
end

local function getFlowerBeeggUUID()
    local player = game:GetService("Players").LocalPlayer
    local backpack = player.Backpack

    for _, item in ipairs(backpack:GetChildren()) do
        if string.find(item.Name, "Bee Egg") then
            local uuid = item:GetAttribute("c")
            if uuid then
                print("Found "..item.Name.." - UUID: "..uuid)
                return uuid
            end
        end
    end
    return nil
end

local function craftSeed()
    local uuid = getFlowerSeedPackUUID()
    if not uuid then
        warn("ไม่พบ Flower Seed Pack ใน Backpack")
        return
    end

    local args = {
    [1] = "Claim",
    [2] = workspace.Interaction.UpdateItems.NewCrafting.SeedEventCraftingWorkBench,
    [3] = "SeedEventWorkbench",
    [4] = 1
    }

    game:GetService("ReplicatedStorage").GameEvents.CraftingGlobalObjectService:FireServer(unpack(args))
    -- Set Recipe
    local args1 = {
        [1] = "SetRecipe",
        [2] = workspace.Interaction.UpdateItems.NewCrafting.SeedEventCraftingWorkBench,
        [3] = "SeedEventWorkbench",
        [4] = "Crafters Seed Pack"
    }
    game:GetService("ReplicatedStorage").GameEvents.CraftingGlobalObjectService:FireServer(unpack(args1))

    -- Input Item
    local args2 = {
        [1] = "InputItem",
        [2] = workspace.Interaction.UpdateItems.NewCrafting.SeedEventCraftingWorkBench,
        [3] = "SeedEventWorkbench",
        [4] = 1,
        [5] = {
            ["ItemType"] = "Seed Pack",
            ["ItemData"] = {
                ["UUID"] = uuid
            }
        }
    }
    game:GetService("ReplicatedStorage").GameEvents.CraftingGlobalObjectService:FireServer(unpack(args2))

    -- Buffer
    game:GetService("ReplicatedStorage").ByteNetReliable:FireServer(nil)

    -- Craft
    local args4 = {
        [1] = "Craft",
        [2] = workspace.Interaction.UpdateItems.NewCrafting.SeedEventCraftingWorkBench,
        [3] = "SeedEventWorkbench"
    }
    game:GetService("ReplicatedStorage").GameEvents.CraftingGlobalObjectService:FireServer(unpack(args4))
end

local function craftEgg()
    local uuid = getFlowerBeeggUUID()
    if not uuid then
        warn("ไม่พบ Bee Egg ใน Backpack")
        return
    end

    local args = {
    [1] = "Claim",
    [2] = workspace.Interaction.UpdateItems.NewCrafting.EventCraftingWorkBench,
    [3] = "GearEventWorkbench",
    [4] = 1
    }

    game:GetService("ReplicatedStorage").GameEvents.CraftingGlobalObjectService:FireServer(unpack(args))

    
    -- Set Recipe
    local args1 = {
        [1] = "SetRecipe",
        [2] = workspace.Interaction.UpdateItems.NewCrafting.EventCraftingWorkBench,
        [3] = "GearEventWorkbench",
        [4] = "Anti Bee Egg"
    }
    game:GetService("ReplicatedStorage").GameEvents.CraftingGlobalObjectService:FireServer(unpack(args1))

    -- Input Item
    local args2 = {
        [1] = "InputItem",
        [2] = workspace.Interaction.UpdateItems.NewCrafting.EventCraftingWorkBench,
        [3] = "GearEventWorkbench",
        [4] = 1,
        [5] = {
            ["ItemType"] = "PetEgg",
            ["ItemData"] = {
                ["UUID"] = uuid
            }
        }
    }
    game:GetService("ReplicatedStorage").GameEvents.CraftingGlobalObjectService:FireServer(unpack(args2))

    -- Craft
    local args3 = {
        [1] = "Craft",
        [2] = workspace.Interaction.UpdateItems.NewCrafting.EventCraftingWorkBench,
        [3] = "GearEventWorkbench"
    }
    game:GetService("ReplicatedStorage").GameEvents.CraftingGlobalObjectService:FireServer(unpack(args3))
end

local function MainController2()
    --while true do
        if AutoHaverfuits then
            -- เรียกใช้ฟังก์ชันสแกน
            local specialFruits = ScanMyFarmsForBuffedFruits(Seedfuitname)
           -- print("รวมผลไม้ที่มีบัฟทั้งหมด: " .. #specialFruits)
            if not specialFruits and AutoCollectHoneysetting then
                
                --print("เก็บผล Pollinated หมดแล้ว กำลังรอเก็บรอบถัดไปอีก 10 วินาที...")
                harvestedPlants = {} -- ล้างข้อมูลเก็บต้นไม้

                AutoCollectHoneycontor = true
                
                task.wait(timereseed)
                
               
            else
                AutoCollectHoneycontor = false
                FindAndHarvestPollinated()
                AutoCollectHoneycontor = true
                harvestedPlants = {}
                task.wait(1)
            end
        end
        
   -- end
end


function MainController()
    
    while true do
       
        if AutoBuySeedEnabled then
           AutoBuySeeds()
        end
        if AutoBuyGearEnabled then
           AutoBuyGears()
        end
        if AutoBuyHonneyEnabled then
           AutoBuyHonneyshop()
        end
        if AutoBuyEggEnabled then
           BuyEggByLocation()
        end
        if Autocraftegg then
           --craftEgg()
        end
        if Autocraftseed then
           craftSeed()
        end
        if AutoCollectHoney and AutoCollectHoneysetting then
           EquipAndUsePollinatedFruits()
        end
        if PlantSeedEQ and AutoCollectHoneysetting then
           RandomPlantSeed()
        end
        if Autosellfruit then
            local unwantedCount = CountNotAllowedBuffFruits()
            if unwantedCount > 70 then
                AutoCollectHoneysetting = false
                print("ผลไม้ที่ไม่ต้องการเกิน " .. Frutsedxc .. " จำนวน: " .. unwantedCount .. " ชิ้น, ทำการ TP และขาย")
                TeleportToFarm()
                SellUnwantedFruits()
                ReturnToOriginalPosition()
            else
                AutoCollectHoneysetting = true
                print("ผลไม้ที่ไม่ต้องการยังไม่ถึง " .. Frutsedxc .. " ชิ้น, ยังไม่ต้อง TP")
            end
        end

        
        task.wait(0.5)
        --MainController2()
    end
     
end
do

    Fluent:Notify({
        Title = "Notification",
        Content = "This is a notification",
        SubContent = "SubContent", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })

    Tabs.Buy:AddParagraph({
        Title = "Game Play",
        Content = ""
    })
    local SeedDropdown = Tabs.Buy:AddDropdown("SeedDropdown", {
    Title = "Select Seeds",
    Description = "เลือกเมล็ดที่ต้องการซื้อ",
    Values = {
        "Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Tomato Seed", "Cauliflower Seed",
    "Watermelon Seed", "Green Apple Seed", "Avocado Seed", "Banana Seed", "Pineapple Seed",
    "Kiwi Seed", "Bell Pepper Seed", "Prickly Pear Seed", "Loquat Seed", "Feijoa Seed", "Sugar Seed",
    },
    Multi = true,
    Default = {}
    })

    SeedDropdown:OnChanged(function(Value)
    SelectedSeeds = {}
    for SeedName, State in pairs(Value) do
        if State then
            table.insert(SelectedSeeds, SeedName)
        end
    end
    print("Selected Seeds: " .. table.concat(SelectedSeeds, ", "))
    end)


    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Buy:AddToggle("AutoBuySeedToggle", {
    Title = "Enable AutoBuy Seeds",
    Default = false,
    Callback = function(Value)
        AutoBuySeedEnabled = Value
        print("AutoBuy Seeds is now", Value and "Enabled" or "Disabled")
    end
    })

    -- MultiDropdown สำหรับ Gear
    local GearDropdown = Tabs.Buy:AddDropdown("GearDropdown", {
    Title = "Select Gears",
    Description = "เลือก Gear ที่ต้องการซื้อ",
    Values = {
        "Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler",
        "Advanced Sprinkler", "Godly Sprinkler", "Lightning Rod",
        "Master Sprinkler", "Favorite Tool", "Harvest Tool","Friendship Pot",
        "Tanning Mirror", "Cleaning Spray"
    },
    Multi = true,
    Default = {}
    })

    -- อัปเดตค่าเมื่อเลือก/เปลี่ยน Gear
    GearDropdown:OnChanged(function(Value)
    SelectedGears = {}
    for GearName, State in pairs(Value) do
        if State then
            table.insert(SelectedGears, GearName)
        end
    end
    print("Selected Gears: " .. table.concat(SelectedGears, ", "))
    end)

    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Buy:AddToggle("AutoBuyGearToggle", {
    Title = "Enable AutoBuy Gear",
    Default = false,
    Callback = function(Value)
        AutoBuyGearEnabled = Value
        print("AutoBuy Seeds is now", Value and "Enabled" or "Disabled")
    end
    })

    -- MultiDropdown สำหรับ Gear
    local EggDropdown = Tabs.Buy:AddDropdown("EggsDropdowns", {
    Title = "Select Egg",
    Description = "",
    Values = {
        "Common Egg", "Uncommon Egg", "Rare Egg",
        "Legendary Egg", "Mythical Egg", "Bug Egg"
    },
    Multi = true,
    Default = {}
    })

    -- อัปเดตค่าเมื่อเลือก/เปลี่ยน Gear
    EggDropdown:OnChanged(function(Value)
    targetEggNames = {}
    for GearName, State in pairs(Value) do
        if State then
            table.insert(targetEggNames, GearName)
        end
    end
    --print("Selected Gears: " .. table.concat(SelectedHoney, ", "))
    end)

    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Buy:AddToggle("AutoBuyeggToggle", {
    Title = "Enable AutoBuy Egg",
    Default = false,
    Callback = function(Value)
        AutoBuyEggEnabled = Value
        --print("AutoBuy Seeds is now", Value and "Enabled" or "Disabled")
    end
    })
    Tabs.Buy:AddParagraph({
        Title = "Even",
        Content = ""
    })

    -- MultiDropdown สำหรับ Gear
    local HonneyDropdown = Tabs.Buy:AddDropdown("HonneyDropdowns", {
    Title = "Select Honney",
    Description = "เลือก Gear ที่ต้องการซื้อ",
    Values = {
        "Flower Seed Pack", "Lavander", "Nectarshade", "Nectarine", "Hive Fruit",
        "Pollen Radar","Bee Egg", "Honey Sprinkler", "Bee Crates",
        "Honey Torch", "Bee Chair", "Honey Comb","Honey Walkway"
    },
    Multi = true,
    Default = {}
    })

    -- อัปเดตค่าเมื่อเลือก/เปลี่ยน Gear
    HonneyDropdown:OnChanged(function(Value)
    SelectedHoney = {}
    for GearName, State in pairs(Value) do
        if State then
            table.insert(SelectedHoney, GearName)
        end
    end
    --print("Selected Gears: " .. table.concat(SelectedHoney, ", "))
    end)

    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Buy:AddToggle("AutoBuyHonneyToggle", {
    Title = "Enable AutoBuy Honney",
    Default = false,
    Callback = function(Value)
        AutoBuyHonneyEnabled = Value
        --print("AutoBuy Seeds is now", Value and "Enabled" or "Disabled")
    end
    })

    

    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Main:AddToggle("AutoCollectHoneyToggle", {
    Title = "Auto Collect Honey",
    Default = false,
    Callback = function(Value)
        AutoCollectHoney = Value

    end
    })
    -- MultiDropdown สำหรับ Gear
    local FruitDropdown = Tabs.Main:AddDropdown("FruitDropdowns", {
    Title = "Select Fruit",
    Description = "",
    Values = {
        "Pollinated", "Wet", "Chilled",
        "Chocolate", "Moonlit", "Bloodlit",
        "Frozen", "Golden", "Zombified","Rainbow"
        ,"Shocked","Celestial","Disco"
    },
    Multi = true,
    Default = {}
    })

    -- อัปเดตค่าเมื่อเลือก/เปลี่ยน Gear
    FruitDropdown:OnChanged(function(Value)
    Seedfuitname = {}
    for GearName, State in pairs(Value) do
        if State then
            table.insert(Seedfuitname, GearName)
        end
    end
    --print("Selected Gears: " .. table.concat(SelectedHoney, ", "))
    end)

    local FruittimeSlider = Tabs.Main:AddSlider("FruitSlider", {
        Title = "TIME Reset Fuits",
        Description = "",
        Default = 10,
        Min = 1,
        Max = 5000,
        Rounding = 1,
        Callback = function(Value)
             timereseed = Value
        end
    })

    FruittimeSlider:OnChanged(function(Value)
        print("Slider changed:", Value)
        timereseed = Value
    end)

    --FruittimeSlider:SetValue(10)

    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Main:AddToggle("AutoHaverfuitsToggle", {
    Title = "Auto Haver fuits",
    Default = false,
    Callback = function(Value)
        AutoHaverfuits = Value
        while Value do 
          MainController2()
           task.wait(0.25)
        end
         
    end
    })
    Tabs.Main:AddParagraph({
        Title = "PlantSeed",
        Content = ""
    })
    local EqSeedDropdown = Tabs.Main:AddDropdown("eqSeedDropdown", {
    Title = "Select Seeds EQ",
    Description = "เลือกเมล็ดที่จะปลูก",
    Values = {
        "Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Tomato Seed", "Cauliflower Seed",
    "Watermelon Seed", "Green Apple Seed", "Avocado Seed", "Banana Seed", "Pineapple Seed",
    "Kiwi Seed", "Bell Pepper Seed", "Prickly Pear Seed", "Loquat Seed", "Feijoa Seed", "Sugar Seed",
    },
    Multi = true,
    Default = {}
    })

    EqSeedDropdown:OnChanged(function(Value)
    eqqSelectedSeeds = {}
    for SeedName, State in pairs(Value) do
        if State then
            table.insert(eqqSelectedSeeds, SeedName)
        end
    end
    print("Selected Seeds: " .. table.concat(eqqSelectedSeeds, ", "))
    end)

     -- Toggle เปิด/ปิด Auto Buy
    Tabs.Main:AddToggle("AutoPlantSeedToggle", {
    Title = "Auto Plant Seed",
    Default = false,
    Callback = function(Value)
        PlantSeedEQ = Value
    end
    })

    -- MultiDropdown สำหรับ Gear
    local SellFruitDropdown = Tabs.Sell:AddDropdown("FruitDropdowns", {
    Title = "Sell Select BUFF Ignor",
    Description = "",
    Values = {
        "Pollinated", "Wet", "Chilled",
        "Chocolate", "Moonlit", "Bloodlit",
        "Frozen", "Golden", "Zombified","Rainbow"
        ,"Shocked","Celestial","Disco"
    },
    Multi = true,
    Default = {}
    })

    -- อัปเดตค่าเมื่อเลือก/เปลี่ยน Gear
    SellFruitDropdown:OnChanged(function(Value)
    allowedBuffs = {}
    for GearName, State in pairs(Value) do
        if State then
            table.insert(allowedBuffs, GearName)
        end
    end
    --print("Selected Gears: " .. table.concat(SelectedHoney, ", "))
    end)
    local FruitdftimeSlider = Tabs.Sell:AddSlider("FruitttSlider", {
        Title = "Fruits Ignor",
        Description = "",
        Default = 10,
        Min = 1,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            Frutsedxc = Value
        end
    })

    FruitdftimeSlider:OnChanged(function(Value)
        print("Slider changed:", Value)
        Frutsedxc = Value
    end)
    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Sell:AddToggle("AutosellfuitsToggle", {
    Title = "Auto Sell fruits",
    Default = false,
    Callback = function(Value)
        Autosellfruit = Value
    end
    })

    ---------------------carft--------------------
    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Sell:AddToggle("AutocraftsdSeedToggle", {
    Title = "Auto craft Seed",
    Default = false,
    Callback = function(Value)
        Autocraftseed = Value
        if Value then
            --craftSeed()
        end
    end
    })
    -- Toggle เปิด/ปิด Auto Buy
    Tabs.Sell:AddToggle("AutocraftsdEggToggle", {
    Title = "Auto craft Egg",
    Default = false,
    Callback = function(Value)
        craftEgg = Value
       if Value then
            --craftEgg()
        end
    end
    })
    -------------------WED HOOK--------------------
    Tabs.Webhook:AddSection("WEDHOOK")

local InputWED = Tabs.Webhook:AddInput("InputWebhook", {
    Title = "URL WED_HOOK",
    Default = "",
    Placeholder = "URL",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        getgenv().webhookexecUrl = Value
    end
})

InputWED:OnChanged(function()
    getgenv().webhookexecUrl = InputWED.Value
end)

local Webhooktarget = Tabs.Webhook:AddToggle("MyToggleWebhook", {
    Title = "Auto Webhook",
    Default = false,
})
Webhooktarget:OnChanged(function(value)
    tragetWebhook = value
end)

-------------------SERVER----------------------
Tabs.Server:AddSection("Server HOP")

local function getServerID()
    return game.JobId
end

Tabs.Server:AddParagraph({
    Title = "Server ID: " .. getServerID(),
    Content = ""
})

Tabs.Server:AddButton({
    Title = "Copy Server ID",
    Description = "",
    Callback = function()
        setclipboard(tostring(getServerID()))
    end
})

Tabs.Server:AddSection("Teleport Jobid Server")

local targetJobId = ""
local placeId = game.PlaceId

local InputJobId = Tabs.Server:AddInput("InputJobId", {
    Title = "Enter Server JobId",
    Default = "",
    Placeholder = "JobId",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        targetJobId = Value
    end
})

InputJobId:OnChanged(function()
    targetJobId = InputJobId.Value
end)

Tabs.Server:AddButton({
    Title = "Teleport to Server",
    Description = "",
    Callback = function()
        if targetJobId ~= "" then
            local success, err = pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, targetJobId, game.Players.LocalPlayer)
            end)

            if not success then
                warn("Teleport failed: " .. tostring(err))
            else
                print("Teleporting to server with JobId: " .. targetJobId)
            end
        else
            warn("Please enter a valid JobId!")
        end
    end
})

Tabs.Server:AddSection("HOP")
Tabs.Server:AddButton({
    Title = "Auto Rejoin",
    Description = "",
    Callback = function()
        getgenv().hyperlibblock = false
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})
Tabs.Server:AddButton({
    Title = "Hop Server Low",
    Description = "",
    Callback = function()
        local PlaceID = game.PlaceId
         local AllIDs = {}
         local foundAnything = ""
         local actualHour = os.date("!*t").hour
         
         -- ฟังก์ชันหลักสำหรับการค้นหาเซิร์ฟเวอร์
         function TPReturner()
             local sortOrder = math.random(1, 2) == 1 and "Asc" or "Desc"
             local Site
             if foundAnything == "" then
                 Site = game.HttpService:JSONDecode(
                     game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' ..
                     sortOrder .. '&limit=100&excludeFullGames=true'))
             else
                 Site = game.HttpService:JSONDecode(
                     game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' ..
                     sortOrder .. '&limit=100&cursor=' .. foundAnything .. '&excludeFullGames=true'))
             end
         
             if Site.nextPageCursor and Site.nextPageCursor ~= "null" then
                 foundAnything = Site.nextPageCursor
             else
                 foundAnything = ""
             end
         
             local serverList = {}
             for _, v in pairs(Site.data) do
                 if tonumber(v.maxPlayers) > tonumber(v.playing) then
                     table.insert(serverList, tostring(v.id))
                 end
             end
         
             if #serverList > 0 then
                 local randomIndex = math.random(1, #serverList)
                 local randomServerID = serverList[randomIndex]
                 table.insert(AllIDs, randomServerID)
         
                 pcall(function()
                     print("Teleporting to server ID: " .. randomServerID)
                     game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, randomServerID, game.Players.LocalPlayer)
                 end)
             else
                 if foundAnything ~= "" then
                     TPReturner()
                 else
                     print("No available servers found!")
                 end
             end
         end
         
         -- ฟังก์ชันสำหรับการเริ่มกระโดดเซิร์ฟเวอร์
         function Teleport()
             while wait() do
                 pcall(function()
                     TPReturner()
                 end)
             end
         end
         
         -- UI/ข้อความแจ้งสถานะ (สามารถปรับแต่งให้ใช้งานใน GUI ได้)
         spawn(function()
             while true do
                 wait(0.1)
                 print("Teleporting")
                 wait(0.1)
                 print("Teleporting.")
                 wait(0.1)
                 print("Teleporting..")
                 wait(0.1)
                 print("Teleporting...")
             end
         end)
         
         -- เริ่มการกระโดดเซิร์ฟเวอร์
         print("Starting server hopper...")
         Teleport()
    end
})
Tabs.Server:AddButton({
    Title = "Hop Server Full",
    Description = "",
    Callback = function()
        local PlaceID = game.PlaceId
         local AllIDs = {}
         local foundAnything = ""
         local maxRetries = 5 -- จำกัดจำนวนครั้งในการค้นหาเซิร์ฟเวอร์ใหม่
         
         function TPReturner()
             local Site
             if foundAnything == "" then
                 Site = game.HttpService:JSONDecode(
                     game:HttpGet('https://games.roblox.com/v1/games/' ..
                     PlaceID .. '/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true'))
             else
                 Site = game.HttpService:JSONDecode(
                     game:HttpGet('https://games.roblox.com/v1/games/' ..
                     PlaceID .. '/servers/Public?sortOrder=Desc&limit=100&cursor=' .. foundAnything .. '&excludeFullGames=true'))
             end
         
             if Site.nextPageCursor and Site.nextPageCursor ~= "null" then
                 foundAnything = Site.nextPageCursor
             else
                 foundAnything = ""
             end
         
             local serverList = Site.data
             if #serverList > 0 then
                 for _, v in pairs(serverList) do
                     if tonumber(v.maxPlayers) > tonumber(v.playing) then
                         local serverID = tostring(v.id)
                         table.insert(AllIDs, serverID)
         
                         pcall(function()
                             print("Teleporting to server ID: " .. serverID)
                             game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, serverID, game.Players.LocalPlayer)
                         end)
                         return
                     end
                 end
             else
                 print("No servers found on this page.")
                 if foundAnything ~= "" then
                     TPReturner()
                 end
             end
         end
         
         function Teleport()
             local retries = 0
             while retries < maxRetries do
                 pcall(function()
                     TPReturner()
                 end)
                 retries = retries + 1
                 wait(1)
             end
             print("No suitable servers found after " .. maxRetries .. " attempts.")
         end
         
         -- UI/สถานะแจ้งเตือน
         spawn(function()
             while true do
                 getgenv().serverhopperhigher:UpdateButton("Teleporting")
                 wait(0.1)
                 getgenv().serverhopperhigher:UpdateButton("Teleporting.")
                 wait(0.1)
                 getgenv().serverhopperhigher:UpdateButton("Teleporting..")
                 wait(0.1)
                 getgenv().serverhopperhigher:UpdateButton("Teleporting...")
                 wait(0.1)
             end
         end)
         
         -- เริ่มการกระโดดเซิร์ฟเวอร์
         print("Starting server hopper...")
         Teleport()

    end
})
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- GUI Toggle Button เพื่อเปิด/ปิด Fluent Window
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- สร้าง ScreenGui
local menuToggleGui = Instance.new("ScreenGui")
menuToggleGui.Name = "MenuToggleGUI"
menuToggleGui.ResetOnSpawn = false
menuToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
menuToggleGui.Parent = PlayerGui

-- สร้างปุ่มกด
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleFluentWindow"
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "C"
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 14
toggleButton.Parent = menuToggleGui
toggleButton.AutoButtonColor = true
toggleButton.BackgroundTransparency = 0.2
toggleButton.BorderSizePixel = 0
toggleButton.ClipsDescendants = true
toggleButton.AnchorPoint = Vector2.new(0, 0)

-- สร้างตัวแปรเพื่อเช็คสถานะการซ่อนและแสดงหน้าต่าง
local isWindowVisible = true

-- เมื่อกดปุ่ม ให้เปิด/ปิดเมนู
toggleButton.MouseButton1Click:Connect(function()
    if isWindowVisible then
        -- ซ่อนหน้าต่าง (Minimize)
        Window:Minimize(580, 460)  -- ใช้ Minimize เพื่อซ่อนหน้าต่าง
        isWindowVisible = false
    else
        -- แสดงหน้าต่างกลับมา (Maximize) และตั้งขนาดที่กำหนด
        Window:Maximize(580, 460)  -- ใช้ Maximize เพื่อแสดงหน้าต่างกลับมาขนาดเดิม
        isWindowVisible = true
    end
end)

-- ฟังก์ชัน Auto Save ทุกๆ 3 วินาที
local function AutoSaveLoop()
    while true do
        wait(1.5)  -- รอ 3 วินาที
        local success, err = SaveManager:Save("CodeX_Auto_Save")
        if not success then
           -- print("Auto Save failed: " .. err)
        else
           -- print("Auto Save successful")
        end
    end
end

-- เริ่มต้นการทำงานของ Auto Save
task.spawn(AutoSaveLoop)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Code X",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

MainController()
