--========================================================--
--  JIMS LUMBERJACK - SERVER SHOPFRONT SYSTEM (VORP READY)
--========================================================--

local data = LumberServer.GetData()

-- VORP Core + Inventory
local VORPcore = exports.vorp_core:getCore()
local VORPInv   = exports.vorp_inventory:vorp_inventoryApi()

--========================================================--
--  SAVE + SYNC HELPERS
--========================================================--
local function SaveShopfront()
    Utils.SaveJSON("data/shopfront_data.json", data.shopfront)
end

local function SyncShopfront(src)
    TriggerClientEvent("jims-lumberjack:updateShopfront", src, data.shopfront)
end

--========================================================--
--  OPEN SHOPFRONT
--========================================================--
RegisterNetEvent("jims-lumberjack:openShopfront", function()
    local src = source

    -- Civilians can buy, employees can manage
    local rank = LumberServer.GetRank(src)

    local payload = {
        items = data.shopfront.items or {},
        balance = data.shopfront.balance or 0,
        canManage = Permissions:HasAccess(rank, "ShopfrontManage")
    }

    TriggerClientEvent("jims-lumberjack:openShopfrontUI", src, payload)
end)

--========================================================--
--  SHOPFRONT ACTIONS
--========================================================--
RegisterNetEvent("jims-lumberjack:shopAction", function(dataIn)
    local src = source
    local action = dataIn.action
    local item = dataIn.item
    local amount = tonumber(dataIn.amount) or 0
    local price = tonumber(dataIn.price) or 0

    local rank = LumberServer.GetRank(src)
    local canManage = Permissions:HasAccess(rank, "ShopfrontManage")

    data.shopfront.items = data.shopfront.items or {}
    data.shopfront.balance = data.shopfront.balance or 0

    --========================================================--
    --  CIVILIAN BUY
    --========================================================--
    if action == "buy" then
        if not data.shopfront.items[item] then return end

        local entry = data.shopfront.items[item]
        local cost = entry.price * amount

        if cost <= 0 or amount <= 0 then return end

        -- Check stock
        if entry.stock < amount then
            VORPcore.NotifyRightTip(src, "Not enough stock available.", 3000)
            return
        end

        -- Charge player (cash)
        local user = VORPcore.getUser(src)
        if not user then return end
        local char = user.getUsedCharacter()
        if not char then return end

        local cash = char.money
        if cash < cost then
            VORPcore.NotifyRightTip(src, "You don't have enough money.", 3000)
            return
        end

        char.removeCurrency(0, cost) -- 0 = cash

        -- Give item
        VORPInv.addItem(src, item, amount)

        -- Update stock + balance
        entry.stock = entry.stock - amount
        data.shopfront.balance = data.shopfront.balance + cost

        -- Ledger
        table.insert(data.ledger, {
            time = os.time(),
            player = char.charIdentifier,
            action = "purchase",
            item = item,
            amount = amount,
            total = cost
        })
        Utils.SaveJSON("data/ledger.json", data.ledger)

        SaveShopfront()
        return
    end

    --========================================================--
    --  EMPLOYEE DEPOSIT ITEM INTO SHOP
    --========================================================--
    if action == "deposit" then
        if not canManage then return end
        if amount <= 0 then return end

        -- Check player has item
        local count = VORPInv.getItemCount(src, item)
        if not count or count < amount then
            VORPcore.NotifyRightTip(src, "You don't have enough of that item.", 3000)
            return
        end

        -- Remove from player
        VORPInv.subItem(src, item, amount)

        -- Add to stock
        data.shopfront.items[item] = data.shopfront.items[item] or {price = 0, stock = 0}
        data.shopfront.items[item].stock = data.shopfront.items[item].stock + amount

        SaveShopfront()
        return
    end

    --========================================================--
    --  EMPLOYEE WITHDRAW ITEM FROM SHOP
    --========================================================--
    if action == "withdraw" then
        if not canManage then return end
        if amount <= 0 then return end

        local entry = data.shopfront.items[item]
        if not entry or entry.stock < amount then
            VORPcore.NotifyRightTip(src, "Not enough stock available.", 3000)
            return
        end

        -- Remove from stock
        entry.stock = entry.stock - amount
        if entry.stock <= 0 then
            data.shopfront.items[item] = nil
        end

        -- Give to player
        VORPInv.addItem(src, item, amount)

        SaveShopfront()
        return
    end

    --========================================================--
    --  OWNER/FOREMAN EDIT BUY LIST
    --========================================================--
    if action == "setPrice" then
        if not canManage then return end
        if price < 0 then return end

        data.shopfront.items[item] = data.shopfront.items[item] or {price = 0, stock = 0}
        data.shopfront.items[item].price = price

        SaveShopfront()
        return
    end

    --========================================================--
    --  OWNER/FOREMAN WITHDRAW MONEY
    --========================================================--
    if action == "withdrawMoney" then
        if not canManage then return end
        if amount <= 0 then return end

        if data.shopfront.balance < amount then
            VORPcore.NotifyRightTip(src, "Not enough money in the shop account.", 3000)
            return
        end

        data.shopfront.balance = data.shopfront.balance - amount

        local user = VORPcore.getUser(src)
        if not user then return end
        local char = user.getUsedCharacter()
        if not char then return end

        char.addCurrency(0, amount) -- 0 = cash

        SaveShopfront()
        return
    end
end)

--========================================================--
--  EXPORT FOR OTHER SERVER MODULES
--========================================================--
LumberShopfront = {}

function LumberShopfront.SyncAll(src)
    SyncShopfront(src)
end

return LumberShopfront
