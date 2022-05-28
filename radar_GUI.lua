--Кое-какая часть Быдлокода была нагло спизжена у N1nt3nd0 и надеюсь бить меня за это не будут :3
local component = require('componentponent')
local event = require('event')
local term = require('term')
local table = require('table')
local unicode = require('unicode')
local computer = require('computer')
local gpu = component.gpu
local floor = math.floor
local prefix = '§6§l[РЛС-ЗЯБРИК 3У]§r'
local colors = {orange = 0xFF4500, gray = 0x808080, red = 0xFF0000}
local color = gpu.setForeground
gpu.setResolution(60, 30)
local rep = string.rep
local work,r_chat,switch_scan,maxRadarList,chatDelay,chat_isAV = true,false,false,25,1,false

function drawBox(x,y,width,height,col,txt,align)
    color(col)
    gpu.fill(x,y,1,height,'│')
    gpu.fill(x+width-1,y,1,height,'│')
    gpu.set(x,y,'┌'..rep('─',width-2)..'┐')
    gpu.set(x,y+height-1,'└'..rep('─',width-2)..'┘')
    if txt then
        gpu.set(x+align,y+1,txt)
    end
end

function clearArea(x,y,width,height)
    gpu.fill(x,y,width,height,' ')
end

function setText(x,y,text,col)
    color(col)
    gpu.set(x,y,text)
end

function clicker(_,_,curX,curY,_,touchNick)
	--setText(45,2,'x:'..curX..','..curY..'  ',colors.gray) -- для теста позиции курсора
	if curX == 60 and curY == 1 then work = false click(60, 1, 'x',colors.gray)
	elseif curX >= 2 and curX <= 15 and curY >= 16 and curY <= 19 and not switch_scan then switch_scan = true whiteScan = touchNick scanTimer = event.timer(1,scan,math.huge) drawGui()
	elseif curX >= 2 and curX <= 15 and curY >= 16 and curY <= 19 and switch_scan then switch_scan = false event.cancel(scanTimer) drawGui()
	elseif curX >= 2 and curX <= 8 and curY == 5 then toScan = 'ИГРОКИ' click(2,5,'ИГРОКИ',colors.gray) drawGui()
	elseif curX >= 2 and curX <= 6 and curY == 8 then toScan = 'МОБЫ' click(2,8,'МОБЫ',colors.gray) drawGui() 
	elseif curX >= 2 and curX <= 10 and curY == 11 then toScan = 'ПРЕДМЕТЫ' click(2,11,'ПРЕДМЕТЫ',colors.gray) drawGui()
	elseif curX >= 19 and curX <= 24 and curY >= 29 and not r_chat and chat_isAV then r_chat = true whiteScan = touchNick radarChatting('ОПОВЕЩЕНИЯ В ЧАТ ВКЛЮЧЕНЫ!') setText(19,29,'[ВКЛ] ',colors.red)
	elseif curX >= 19 and curX <= 24 and curY >= 29 and r_chat and chat_isAV then r_chat = false radarChatting('ОПОВЕЩЕНИЯ В ЧАТ ВЫКЛЮЧЕНЫ!') setText(19,29,'[ВЫКЛ]',colors.gray)
	end
end

function click(cX,cY,text,color) 
	setText(cX,cY,text,colors.red)
	os.sleep(0.1)
    setText(cX,cY,text,color)
end

function exit()
    event.ignore('touch',clicker)
    term.clear()
	os.sleep(globalSleep)
    computer.beep(1500)
    if scanTimer then 
    	event.cancel(scanTimer)
    end
end

function scan()
	chatDelay = chatDelay + 1
    if chatDelay > 5 then
        sayTable = {  }
        chatDelay = 1
    end
	if toScan == 'ИГРОКИ' then 
		find = r.getPlayers()
	elseif toScan == 'МОБЫ' then
		find = r.getMobs()
	elseif toScan == 'ПРЕДМЕТЫ' then
		find = r.getItems()
	end
	if switch_scan then
		clearArea(32,5,28,25)
	end
	for i=1, #find do
		if toScan == 'ПРЕДМЕТЫ' then
			name = find[i].label
		else
			name = find[i].name
		end
		dist = '['..math.floor(find[i].distance)..' m ]'
		y=i+5
		if name == whiteScan then
            setText(32,y,'ВЫ > '..dist,colors.gray)
        else
            local str = unicode.sub(name,1,21)..' '
            setText(32,y,str,colors.gray)
            setText(32+unicode.len(str),y,dist,colors.gray)
        end
        if r_chat and chatDelay == 5 and name ~= whiteScan then
            table.insert(sayTable,'§7§r'..name..' §r§l§6'..dist..'§r')
        end
        if i >= maxRadarList then
            break
        end
	end
	if #sayTable > 0 then
        local frase = '§r§b'..toScan..': '..table.concat(sayTable,', ')
        radarChatting(frase)
    end
end

function radarChatting(frase)
    chatb.setName(prefix)
    chatb.say(frase)
end

function drawGui()
	term.clear()
	setText(28, 2, 'РЛС-ЗЯБРИК 3У', colors.orange)
	setText(60, 1, 'x',colors.gray)
	setText(2,5,'ИГРОКИ',colors.gray)
	setText(2,8,'МОБЫ',colors.gray)
	setText(2,11,'ПРЕДМЕТЫ',colors.gray)
	gpu.setForeground(colors.gray)
	gpu.fill(30,4,1,27,"░")
	if toScan == 'ИГРОКИ' then
		gpu.set(9,5,'◄')
	elseif toScan == 'МОБЫ' then
		gpu.set(7,8,'◄')
	elseif toScan == 'ПРЕДМЕТЫ' then
		gpu.set(11,11,'◄')
	end		
	if switch_scan then
		drawBox(2,16,13,3,colors.red,'СКАНИРОВАТЬ',1)
	else
		drawBox(2,16,13,3,colors.gray,'СКАНИРОВАТЬ',1)
	end		
	if chat_isAV then
		setText(2, 29, 'ОПОВЕЩЕНИЯ В ЧАТ', colors.gray)
		if r_chat then
			setText(19,29,'[ВКЛ] ',colors.red)
		else
			setText(19,29,'[ВЫКЛ]',colors.gray)
		end
	end
end

function run()
	event.listen('touch',clicker)
	drawGui()
	while work do 
		os.sleep(globalSleep)
	end
	exit()
end

function start()
	if component.isAvailable('radar') then
		r = component.radar
	else
		term.clear()		
		setText(1,1,'ПОДКЛЮЧИ РАДАР СУКА!',colors.red)
		os.sleep(1)
		exit()
	end
	if component.isAvailable('chat') then
		chatb = component.chat
		chat_isAV = true
	elseif component.isAvailable('chat_box') then
		chatb = component.chat_box
		chat_isAV = true
	else
		term.clear()
		setText(1,1,'ПОДКЛЮЧИ ЧАТ-БОКС СУКА!',colors.red)
		os.sleep(1)
		term.clear()
		chat_isAV = false
	end
	run()
end

start()
