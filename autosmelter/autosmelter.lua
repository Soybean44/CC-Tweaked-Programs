local peripherals = peripheral.getNames()
local furnaces = {}
local drawer = peripheral.find("storagedrawers:standard_drawers_1")

function balance_coal()
  local drawerItem = drawer.getItemDetail(2)
  local totalCoal = 0
  if drawerItem ~= nil then
    totalCoal = drawerItem.count
  end
  local avgCoal = math.floor(totalCoal / #furnaces)
  for _, furnace in ipairs(furnaces) do
    furnace.pullItems(peripheral.getName(drawer), 2, avgCoal, 2)
  end
end

function update_furnaces()
  for _, furnace in ipairs(peripherals) do
    if string.find(furnace, "furnace") then
      local furnacePeripheral = peripheral.wrap(furnace)
      table.insert(furnaces, furnacePeripheral)
    end
  end
  for _, furnace in ipairs(furnaces) do
    furnace.pushItems(peripheral.getName(drawer), 2)
  end
  balance_coal()
end

local smeltingItem = nil
function distribute_items(chest)
  local items = {}
  local count = 0
  local isSmelting = false
  for _, furnace in ipairs(furnaces) do
    local furnaceItem = furnace.getItemDetail(1)
    if furnaceItem ~= nil then
      isSmelting = true
      if furnaceItem.name ~= smeltingItem then
        return
      end
      break
    end
  end

  if not isSnelting then
    smeltingItem = nil
  end

  for slot, item in pairs(chest.list()) do
    if smeltingItem == nil then
      smeltingItem = item.name
    end
    if smeltingItem == item.name then
      count = count + item.count
      table.insert(items, { peripheral = chest, slot = slot })
    end
  end

  if count == 0 then
    return
  end

  local avgCount = count / #furnaces
  if avgCount < 1 and avgCount > 0 then
    avgCount = 1
  end
  local idx = 1
  for _, furnace in ipairs(furnaces) do
    local currItem = items[idx].peripheral.getItemDetail(items[idx].slot)
    if currItem == nil then
      if idx == #items then
        break
      else
        idx = idx + 1
        currItem = items[idx].peripheral.getItemDetail(items[idx].slot)
      end
    end
    furnace.pullItems(peripheral.getName(chest), items[idx].slot, avgCount, 1)
  end
end

function get_items(chest)
  for _, furnace in ipairs(furnaces) do
    furnace.pushItems(peripheral.getName(chest), 3)
  end
end

print("Welcome to Autosmelter\n")

-- read cfg
local cfg = fs.open("autosmelter.cfg")
local inputChest = peripheral.wrap(cfg.readLine())
local outputChest = peripheral.wrap(cfg.readLine())

update_furnaces()
print("\nRunning Autosmelter")
while true do
  balance_coal()
  distribute_items(inputChest)
  get_items(outputChest)
end
