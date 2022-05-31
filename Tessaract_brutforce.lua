-- Идея заимствована у игрока Noki
-- Реализованно игроком Dancho
-- DREAMFINITY 2022

ocal component = require('component')
local term = require('term')
local tessaract = component.tile_thermalexpansion_ender_tesseract_name
local capasitor = component.capacitor_bank

local i = 1

while true do
    
    while i <= 999 do

        if i == 228 then
            i = i + 1
        end

        tessaract.setFrequency(i)

        print("Установлена частота: "..i)

        local energy_before = capasitor.getEnergyStored()

        os.sleep(1)

        local energy_after = capasitor.getEnergyStored()

        print(tostring(energy_before) .. " энергии было и " .. tostring(energy_after) .." стало")

        if energy_after > energy_before then
            print("Обнаружено поступление энергии!")
            os.sleep(10)
            i = i - 1
        end

        i = i + 1

        if i == 1000 then
            i = 1
        end

        term.clear()

    end
end