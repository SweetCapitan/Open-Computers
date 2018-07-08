--Кое-какая часть Быдлокода была нагло спизжена у N1nt3nd0 и надеюсь бить меня за это не будут :3
local com = require('component')
local ev = require('event')
local term = require('term')
local table = require('table')
local u = require('unicode')
local comp = require('computer')
local g = com.gpu
local floor = math.floor
local pref = '§6§l[J.A.R.V.I.S.]§r'
local colors = {orange = 0xFF4500, gray = 0x808080, red = 0xFF0000}
local color = g.setForeground
g.setResolution(60, 30)
local rep = string.rep
local work,r_chat,switch_scan,maxRadarList,chatDelay,chat_isAV = true,false,false,25,1,false

function drawBox(x,y,width,height,col,txt,align)
    color(col)
    g.fill(x,y,1,height,'│')
    g.fill(x+width-1,y,1,height,'│')
    g.set(x,y,'┌'..rep('─',width-2)..'┐')
    g.set(x,y+height-1,'└'..rep('─',width-2)..'┘')
    if txt then
        g.set(x+align,y+1,txt)
    end
end

function clearArea(x,y,width,height)
    g.fill(x,y,width,height,' ')
end

function setText(x,y,text,col)
    color(col)
    g.set(x,y,text)
end

function clicker(_,_,curX,curY,_,touchNick)
	--setText(45,2,'x:'..curX..','..curY..'  ',colors.gray) -- для теста позиции курсора
	if curX == 60 and curY == 1 then work = false click(60, 1, 'x',colors.gray)
	elseif curX >= 2 and curX <= 15 and curY >= 16 and curY <= 19 and not switch_scan then switch_scan = true whiteScan = touchNick scanTimer = ev.timer(1,scan,math.huge) drawGui()
	elseif curX >= 2 and curX <= 15 and curY >= 16 and curY <= 19 and switch_scan then switch_scan = false ev.cancel(scanTimer) drawGui()
	elseif curX >= 2 and curX <= 8 and curY == 5 then toScan = 'игроки' click(2,5,'игроки',colors.gray) drawGui()
	elseif curX >= 2 and curX <= 6 and curY == 8 then toScan = 'мобы' click(2,8,'мобы',colors.gray) drawGui() 
	elseif curX >= 2 and curX <= 10 and curY == 11 then toScan = 'предметы' click(2,11,'предметы',colors.gray) drawGui()
	elseif curX >= 19 and curX <= 24 and curY >= 29 and not r_chat and chat_isAV then r_chat = true whiteScan = touchNick radarChatting('Оповещения в чат включены!') setText(19,29,'[ВКЛ] ',colors.red)
	elseif curX >= 19 and curX <= 24 and curY >= 29 and r_chat and chat_isAV then r_chat = false radarChatting('Оповещения в чат выключены...') setText(19,29,'[ВЫКЛ]',colors.gray)
	end
end

function click(cX,cY,text,color) 
	setText(cX,cY,text,colors.red)
	os.sleep(0.1)
    setText(cX,cY,text,color)
end

function exit()
    ev.ignore('touch',clicker)
    term.clear()
	os.sleep(globalSleep)
    comp.beep(1500)
    if scanTimer then 
    	ev.cancel(scanTimer)
    end
end

function scan()
	chatDelay = chatDelay + 1
    if chatDelay > 5 then
        sayTable = {  }
        chatDelay = 1
    end
	if toScan == 'игроки' then 
		find = r.getPlayers()
	elseif toScan == 'мобы' then
		find = r.getMobs()
	elseif toScan == 'предметы' then
		find = r.getItems()
	end
	if switch_scan then
		clearArea(32,5,28,25)
	end
	for i=1, #find do
		if toScan == 'предметы' then
			name = find[i].label
		else
			name = find[i].name
		end
		dist = '['..math.floor(find[i].distance)..' m ]'
		y=i+5
		if name == whiteScan then
            setText(32,y,'ВЫ > '..dist,colors.gray)
        else
            local str = u.sub(name,1,21)..' '
            setText(32,y,str,colors.gray)
            setText(32+u.len(str),y,dist,colors.gray)
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
    chatb.setName(pref)
    chatb.say(frase)
end

function drawGui()
	term.clear()
	setText(28, 2, 'ПРЕМАЛИ', colors.orange)
	setText(60, 1, 'x',colors.gray)
	setText(2,5,'игроки',colors.gray)
	setText(2,8,'мобы',colors.gray)
	setText(2,11,'предметы',colors.gray)
	g.setForeground(colors.gray)
	g.fill(30,4,1,27,"░")
	if toScan == 'игроки' then
		g.set(9,5,'◄')
	elseif toScan == 'мобы' then
		g.set(7,8,'◄')
	elseif toScan == 'предметы' then
		g.set(11,11,'◄')
	end		
	if switch_scan then
		drawBox(2,16,13,3,colors.red,'сканировать',1)
	else
		drawBox(2,16,13,3,colors.gray,'сканировать',1)
	end		
	if chat_isAV then
		setText(2, 29, 'Оповещения в чат', colors.gray)
		if r_chat then
			setText(19,29,'[ВКЛ] ',colors.red)
		else
			setText(19,29,'[ВЫКЛ]',colors.gray)
		end
	end
end

function run()
	ev.listen('touch',clicker)
	drawGui()
	while work do 
		os.sleep(globalSleep)
	end
	exit()
end

function start()
	if com.isAvailable('radar') then
		r = com.radar
	else
		term.clear()		
		setText(1,1,'ПОДКЛЮЧИ РАДАР СУКА!',colors.red)
		os.sleep(1)
		exit()
	end
	if com.isAvailable('chat') then
		chatb = com.chat
		chat_isAV = true
	elseif com.isAvailable('chat_box') then
		chatb = com.chat_box
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
