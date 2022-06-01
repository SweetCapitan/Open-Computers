-- Идея заимствована у игрока Noki
-- Реализованно игроком Dancho
-- DREAMFINITY 2022

local component = require('component')
local term = require('term')
local tessaract = component.tile_thermalexpansion_ender_tesseract_name
local capasitor = component.capacitor_bank

local i = 1
local dev = false -- для отладки включить true в остальное время false, чтобы не получить по жопе

term.clear()
term.write("ЮморФМ вещает!")

while true do
    
    while i <= 999 do

        if i == 228 then
            i = i + 1
        end

        tessaract.setFrequency(i)

        if not dev then
            print("Установлена частота: "..i)
        end

        local energy_before = capasitor.getEnergyStored()

        os.sleep(1)

        local energy_after = capasitor.getEnergyStored()

        if not dev then
            print(tostring(energy_before) .. " энергии было и " .. tostring(energy_after) .." стало")
        end

        if energy_after > energy_before then
            if not dev then
                print("Обнаружено поступление энергии!")
            end
            os.sleep(10)
            i = i - 1
        end

        i = i + 1

        if i == 1000 then
            i = 1
        end

        if not dev then
            term.clear()
        end
        
    end
end