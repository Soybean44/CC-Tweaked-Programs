local peripherals = peripheral.getNames()
local furnaces = {}
local drawer = peripheral.find("storagedrawers:standard_drawers_1")

for _, furnace in ipairs(peripherals) do
  if string.find(furnace, "furnace") then
    table.insert(furnaces, peripheral.wrap(furnace))
  end
end


function balance_coal()
  local drawerItem = drawer.getItemDetail(2)
  local totalCoal = 0
  if drawerItem ~= nil then
    totalCoal = drawerItem.count
  end
  local avgCoal = totalCoal / #furnaces
  for _, furnace in ipairs(furnaces) do
    furnace.pullItems(peripheral.getName(drawer), 2, avgCoal, 2)
  end
end

local smeltingItem = nil
function distribute_items(chest)
  local items = {}
  local count = 0
  for _, furnace in ipairs(furnaces) do
    local furnaceItem = furnace.getItemDetail(1)
    if furnaceItem ~= nil then
      if furnaceItem.name ~= smeltingItem then
        return
      end
      break
    end
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
  local idx = 1
  local currItem = items[idx].peripheral.getItemDetail(items[idx].slot)
  for _, furnace in ipairs(furnaces) do
    if currItem.count <= avgCount and idx == #items then
      local delta = avgCount - currItem.count
      idx = idx + 1
      currItem = items[idx].peripheral.getItemDetail(items[idx].slot)
      furnace.pullItems(peripheral.getName(chest), items[idx].slot, delta, 1)
    end
  end
end

function get_items(chest)
  for _, furnace in ipairs(furnaces) do
    furnace.pushItems(peripheral.getName(chest), 3)
  end
end

print("Welcome to Autosmelter\n")
print("Enter input chest name: ")
local inputChest = peripheral.wrap(io.input(io.stdin):read())
print("\nEnter output chest name: ")
local outputChest = peripheral.wrap(io.input(io.stdin):read())
while true do
  balance_coal()
  distribute_items(inputChest)
  get_items(outputChest)
end
