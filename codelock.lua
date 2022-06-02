-- НЕМНОГО перереписанный кодлок marko_ru в модульном стиле
-- by Dancho

local term = require("term")
local component = require("component")
local computer = require("computer")
local event = require("event")
local io = require("io")
local gpu = component.gpu
local red = component.redstone

local input = {}
local password = "0451"
local curAdr
local userList = {}
local userListFile = "trustedUsers.cfg"

local function fileExist(file)
    local f = io.open(file, "r")
    if f then f:close() end
    return f ~= nil
end

local function readConfig(file)
    if not fileExist(file) then 
        f = io.open(file, "w")
        f:write("----TRUSTED USERS----")
        f:close()
        return
    else
        for line in io.lines(file) do
            table.insert(userList, line)
        end
    end
end

local function writeConfig(file, data)
    config = io.open(file, "a")
    config:write("\n" .. data)
    config:close()
end

local function checkUser(_user)
    readConfig(userListFile)
    -- term.setCursor(10, 1)
    for i, k in ipairs(userList) do
        -- print("Проверка ".. k .. " : " .. _user)
        if tostring(k) == tostring(_user) then
            return true
        end
    end
    return nil
end

local function drawScreen(_curAdr)
    if gpu.getScreen() ~= _curAdr then -- если поменялся монитор 
        gpu.bind(_curAdr)
        gpu.setResolution(7, 5)
        gpu.setForeground(0)
    end
    gpu.setBackground(0x444444)
    gpu.fill(1, 1, 7, 1, ' ')
    term.setCursor(1, 1)
    -- print(input[_curAdr])
    local var = tostring(input[_curAdr]):gsub("%d", "*")
    print(var)
end

local clickHandler = {}  

function clickHandler:new()
    newObj = {}
    self.__index = self
    return setmetatable(newObj, self)
end

function clickHandler:buttonPressed(_curAdr)
    computer.beep(440)
    drawScreen(_curAdr)
end

function clickHandler:succes(_curAdr,_user)
    computer.beep(1000)
    red.setOutput(3, 0)
    if not checkUser(_user) then
        writeConfig(userListFile, _user)
        userList = {}
    end
    input[_curAdr] = ""
    drawScreen(_curAdr)
    os.sleep(15)
    red.setOutput(3, 15)
end

function clickHandler:clear(_curAdr)
    input[_curAdr] = ""
    drawScreen(_curAdr)
    computer.beep(650)
end

local _clickHandler = clickHandler:new()

local function clicker(_, curAdr, x, y, _, user)
    if y >= 2 and y <= 4 then input[curAdr] = input[curAdr] .. math.floor((y - 2) * 3 + (x / 2)) _clickHandler:buttonPressed(curAdr) end
    if y == 5 and x == 4 then input[curAdr] = input[curAdr] .. "0" _clickHandler:buttonPressed(curAdr) end
    if y == 5 and x == 2 then _clickHandler:clear(curAdr) end
    if y == 5 and x == 6 then if #input[curAdr] == 0 and checkUser(user) or password == input[curAdr] then _clickHandler:succes(curAdr, user) else _clickHandler:clear(curAdr) end end
    if #input[curAdr] == 7 then _clickHandler:clear(curAdr) end
    --Для отладки
    ---------------------------
    -- term.setCursor(1,8)
    -- print(curAdr.."\n"..x.."\n"..y.."\n"..user.."\n"..input[curAdr])
    -- for i, k in pairs(userList) do
    --     print(k)
    -- end
    ---------------------------
end

local function init()
    for k in component.list("screen") do -- Сохранение адресов мониторов
        input[k] = ""
        gpu.bind(k)
        gpu.setResolution(7, 5)
        gpu.setBackground(0x444444)
        gpu.fill(1, 1, 7, 1, ' ')
        gpu.setForeground(0)
        term.setCursor(1, 2)
        gpu.setBackground(0xEEEEEE)
        print(" 1 2 3 ")
        print(" 4 5 6 ")
        print(" 7 8 9 ")
        io.write(" C 0 E ")
        curAdr = k
    end
    red.setOutput(3, 15)
end

local function run()
    event.listen('touch',clicker)
    while true do 
		os.sleep(globalSleep)
	end
end

init()
run()