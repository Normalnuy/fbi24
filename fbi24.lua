---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local, different-requires, undefined-field

script_name("FBI Helper")
script_author("Joe Davidson")
script_version("0.1.0")
script_description('Multifunctional FBI helper for Arizona Wednesday')

-- Основные подключения
require 'lib.moonloader'
require 'lib.sampfuncs'
local sampev = require 'lib.samp.events'

-- Кодировка
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

--============================================== Чат =======================================--

local blue_color = "{5A90CE}"
local white_color = "{FFFFFF}"
local red_color = "{F34336}"
local green_color = "{66FF4D}"

local tag = blue_color.."[ FBI Helper | "..red_color.."Joe Davidson "..blue_color.."]: "..white_color

--=================================== Переменные для скриптов ===============================================--

local updateScript = {
    json_url = 'https://raw.githubusercontent.com/Normalnuy/fbi24/refs/heads/main/update.json',
}

local autofind = {
    playerId = -1,
    playerNick = '',
    inta = false,
    process = false
}

local org_checker = {
    playerId = -1,
    playerNick = '',
    index = 1,
    color = '',
    name = '',
    phone = false,
    find_organizations = {},
    all_organizations = {
        {name = "ТРБ",            index = 32,       color = 'CFAF46'},
        {name = "LSPD",           index = 1,        color = '0049FF'},
        {name = "RCSD",           index = 2,        color = '0049FF'},
        {name = "SFPD",           index = 3,        color = '004EFF'},
        {name = "LSMC",           index = 4,        color = 'FF7E7E'},
        {name = "LVMC",           index = 5,        color = 'FF7E7E'},
        {name = "Пра-во",         index = 6,        color = 'CCFF00'},
        {name = "ТСР",            index = 7,        color = 'BDBDBD'},
        {name = "SFMC",           index = 8,        color = 'FF7E7E'},
        {name = "Лицензеры",      index = 9,        color = 'FF6633'},
        {name = "СМИ ЛС",         index = 10,       color = 'FF8000'},
        {name = "Армия ЛС",       index = 11,       color = '996633'},
        {name = "LVMPD",          index = 12,       color = '0049FF'},
        {name = "СМИ ЛВ",         index = 13,       color = 'FF8000'},
        {name = "СМИ СФ",         index = 14,       color = 'FF8000'},
        {name = "Армия СФ",       index = 15,       color = '996633'},
        {name = "Грув",           index = 16,       color = '009327'},
        {name = "Вагос",          index = 17,       color = 'D1DB1C'},
        {name = "Баллас",         index = 18,       color = 'CC00CC'},
        {name = "Ацтек",          index = 19,       color = '00FFE2'},
        {name = "Рифа",           index = 20,       color = '6666FF'},
        {name = "РМ",             index = 21,       color = '336699'},
        {name = "Якудза",         index = 22,       color = '960202'},
        {name = "ЛКН",            index = 23,       color = '993366'},
        {name = "Варлок",         index = 24,       color = 'BA541D'},
        {name = "Ночные волки",   index = 25,       color = 'A87878'},
        {name = "СТК",            index = 31,       color = '084F6B'},
        {name = "Jefferson MC",   index = 33,       color = 'FF7E7E'},
        {name = "Пожарный деп.",  index = 34,       color = 'FF4500'},
    },
    rangs_number = {
        {name = 'LSPD',             rangs = {'Кадет Полиции', 'Офицер Полиции I', 'Офицер Полиции II', 'Офицер Полиции II', 'Офицер Полиции III', 'Сержант', 'Лейтенант', 'Капитан', 'Командир', 'Заместитель Шефа Департамента', 'Шеф Департамента'}},
        {name = 'RCSD',             rangs = {'Кадет Шерифа', 'Младший Патрульный Шериф', 'Патрульный Шериф', 'Старший Патрульный Шериф', 'Сержант', 'Лейтенант', 'Капитан', 'Командор', 'Заместитель Шерифа Департамента', 'Шериф Департамента'}},
        {name = 'SFPD',             rangs = {'Курсант SWAT','Академик SWAT', 'Стажёр SWAT', 'Старший курсант SWAT', 'Академик SWAT', 'Оперативник SWAT', 'Лейтенант SWAT', 'Инструктор SWAT', 'Заместитель директора SWAT', 'Директор SWAT'}},
        {name = 'LVMPD',            rangs = {'Кадет Шериф I','Помощник Шерифа II', 'Помощник Шерифа III', 'Помощник Шерифа IV', 'Сержант', 'Лейтенант', 'Капитан', 'Командор', 'Заместитель Шерифа Департамента', 'Шериф Департамента'}},
        {name = 'LSMC',             rangs = {'Санитар', 'Фельдшер', 'Травмотолог', 'Участковый врач', 'Терапевт', 'Педиатр', 'Хирург', 'Заведующий Отделением', 'Зам.Глав.Врача', 'Глав.Врач'}},
        {name = 'LVMC',             rangs = {'Интерн', 'Участковый Врач', 'Терапевт', 'Нарколог', 'Окулист', 'Хирург', 'Психолог', 'Заведующий Отделением', 'Зам.Глав.Врача', 'Глав.Врач'}},
        {name = 'Пожарный деп.',    rangs = {'Стажер', 'Пожарный', 'Старший Пожарный', 'Лейтенант', 'Супервайзер', 'Капитан', 'Зам. командира', 'Командир', 'Зам. Шефа Департамента', 'Шеф Пожарного Департамента'}},
        {name = 'Пра-во',           rangs = {'Стажер Юрист', 'Юрист', 'Стажер Адвокат', 'Государственный Адвокат', 'Специалист -', 'Налоговый', 'секрет', 'Государственный советник', 'Вице-губернатор', 'Губернатор штата'}},
        {name = "ТСР",              rangs = {'Охранник', 'Надзиратель', 'Старший надзиратель', 'Дежурный', 'Инспектор', 'Начальник инспекции', 'Заместитель нач. блока', 'Начальник блока', 'Зам. начальника тюрьмы', 'Начальник тюрьмы'}},
        {name = "Лицензеры",        rangs = {'Практикант', 'Консультант', 'Инструктор I категории', 'Инструктор II категории', 'Инструктор III категории', 'Ассистент менеджера', 'Менеджер', 'Куратор Отдела', 'Зам.Директора', 'Директор'}},
        {name = 'СМИ ЛС',           rangs = {'Стажёр', 'Корреспондент', 'Редактор', 'Журналист', 'Арт-Журналист', 'Репортёр', 'Веб-Дизайнер', 'SMM-менеджер', 'Зам. Директора', 'Директор'}},
        {name = 'Армия ЛС',         rangs = {'Рядовой', 'Капрал', 'Сержант', 'Мастер-сержант', 'Лейтенант', 'Капитан', 'Майор', 'Подполковник', 'Полковник', 'Генерал'}},
        {name = 'Армия СФ',         rangs = {'Матрос', 'Старший матрос', 'Мичман', 'Старший мичман', 'Лейтенант', 'Капитан-лейтенант', 'Капитан 1-ого ранга', 'Контр-адмирал', 'Вице-адмирал', 'Адмирал'}},
    }
}

--=================================== ПРОГРАММА =============================================================--

function main()
    checkSampLoaded()
    autoupdate(updateScript.json_url)

    sampRegisterChatCommands()
    sampAddChatMessage(tag.."Скрипт запущен!",-1)

    while true do wait(0)
        afindUpdate()      -- autofind
        findUpdate()       -- org_checker
    end
end

--===================================== Функции бесконечного цикла ==========================================--

function afindUpdate()
    if autofind.process then
        sampSendChat("/find "..autofind.playerId)
        wait(2.1 * 1000)
    end
end

function findUpdate()
    if org_checker.phone and not org_checker.process then
        openPhoneApp(32)
        org_checker.process = true
    end
end

--===================================== Зарегистрированные команды ==========================================--

function cmd_afind(arg)
    local id = arg:match('(.+)')
    local nick = ''
    if id then nick = checkPlayerOnline(id) end

    if (not id and autofind.process) or (id == autofind.playerId and autofind.process) then 
        sampAddChatMessage(tag.."Слежка за игроком "..autofind.playerNick.."["..autofind.playerId.."] "..red_color.."остановлена",-1)
        afindDefaultParams()
        return 
    end


    if     not id   then    sampAddChatMessage(tag.."Вы не указали ID!",-1); return
    elseif not nick then    sampAddChatMessage(tag..'Игрок с ID: \"'..id..'\" не в сети!',-1); return
    elseif id ~= autofind.playerId and autofind.process then autofind.inta = false end

    autofind.playerId = id
    autofind.playerNick = nick
    autofind.process = true
    sampAddChatMessage(tag.."Слежка за игроком "..autofind.playerNick.."["..autofind.playerId.."] "..green_color.."начата",-1)
end

function cmd_org(arg)
    local id = arg:match('(.+)')
    local nick = ''

    id = arg:match('(.+)')
    if id then nick = checkPlayerOnline(id) end

    if not id then          sampAddChatMessage(tag.."Вы не указали ID!",-1)
    elseif not nick then    sampAddChatMessage(tag.."Игрок с ID: "..id.." не в сети!",-1)
    else
        org_checker.playerId = id
        org_checker.playerNick = nick
        org_checker.color = getColor(id)

        sampAddChatMessage(tag.."Начался поиск игрока "..blue_color..org_checker.playerNick.."["..org_checker.playerId.."]"..white_color..", это займёт некоторое время.",-1)
        sampAddChatMessage(tag.."Не закрывайте телефон, пока идёт поиск!",-1)
        generateOrganizations()
        
        sampSendChat('/phone')
        org_checker.phone = true
    end
end

--==========================================================================================================--

--      ** ** ** ** **       **          **      **          **      ** ** ** ** **      ** ** ** ** **     --
--      ** ** ** ** **       **          **      **          **      ** ** ** ** **      ** ** ** ** **     --
--      **                   **          **      **          **      **                  **                 --
--      **                   **          **      ** **       **      **                  **                 --
--      **                   **          **      **  **      **      **                  **                 --
--      **                   **          **      ** ** **    **      **                  **                 --
--      ** ** ** ** **       **          **      **    ** ** **      **                  ** ** ** ** **     --
--      ** ** ** ** **       **          **      **       ** **      **                              **     --
--      **                   **          **      **          **      **                              **     --
--      **                   **          **      **          **      **                              **     --
--      **                   ** ** ** ** **      **          **      ** ** ** ** **      ** ** ** ** **     --
--      **                      ** ** **         **          **      ** ** ** ** **      ** ** ** ** **     --
                                                              
--==========================================================================================================--

function checkSampLoaded()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    repeat 
        wait(0) 
     until sampIsLocalPlayerSpawned()
end

function sampRegisterChatCommands()
    sampRegisterChatCommand('afind', cmd_afind)
    sampRegisterChatCommand("org", cmd_org)
end

function generateOrganizations()
    table.insert(org_checker.find_organizations, {name = "ТРБ", index = 32})
    for _, org in ipairs(org_checker.all_organizations) do
        if org.color == org_checker.color and org.color ~= 'CFAF46' then
            table.insert(org_checker.find_organizations, {name = org.name, index = org.index})
        end
    end
    if #org_checker.find_organizations == 1 then 
        table.remove(org_checker.find_organizations, 1)
        for _, org in ipairs(org_checker.all_organizations) do
            table.insert(org_checker.find_organizations, {name = org.name, index = org.index})
        end
    end
end

function getColor(id)
	return ("%06X"):format(bit.band(sampGetPlayerColor(id), 0xFFFFFF))
end

function checkPlayerOnline(id)
    if sampIsPlayerConnected(id) then return sampGetPlayerNickname(id)
    else return false end
end

function openPhoneApp(appId)
    local str = ('launchedApp|%s'):format(appId)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)
    raknetBitStreamWriteInt16(bs, #str)
    raknetBitStreamWriteString(bs, str)
    raknetBitStreamWriteInt32(bs, 0)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function afindDefaultParams()
    autofind.playerId = -1
    autofind.playerNick = ''
    autofind.inta = false
    autofind.process = false
end

function org_checkerDefaultParams()
    org_checker.playerId = -1
    org_checker.playerNick = ''
    org_checker.index = 1
    org_checker.color = ''
    org_checker.name = ''
    org_checker.phone = false
    org_checker.process = false
    org_checker.find_organizations = {}
end

function stopFind(dialogId)
    sampSendDialogResponse(dialogId, -1, nil, false)
    sampSendChat("/phone")
    sampSendChat('/stats')
end

function getRangNumber(rang)
    for _, org in ipairs(org_checker.rangs_number) do
        if org.name == org_checker.name then
            for i, r in ipairs(org.rangs) do
                if string.find(rang, r) then
                    return i
                end
            end
        end
    end
    return 0
end

--============================================= SAMP EVENTS =================================================--

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    -- sampev Org Checker
    if title:find("Основная") and org_checker.process then 
        org_checkerDefaultParams()
        sampSendDialogResponse(dialogId, 0, nil, false)
        return false
    end
    
    if dialogId == 8744 and org_checker.process then
        if #org_checker.find_organizations == 0 then
            sampAddChatMessage(tag.."Игрок "..org_checker.playerNick.."["..org_checker.playerId.."] не найден в списке организаций.",-1)
            stopFind(dialogId)
            return false
        end

        local org = org_checker.find_organizations[1]
        if org then
            org_checker.name = org.name
            sampSendDialogResponse(dialogId, 1, org.index, false)
            table.remove(org_checker.find_organizations, 1)
            return false
        end
    end

    if title:find("Сотрудники онлайн") and org_checker.process then
        local next = 25
        local players = {}

        for line in string.gmatch(text, "[^\n]+") do
            table.insert(players, line)
        end

        for _, player in ipairs(players) do
            if player:find(org_checker.playerNick) then
                local rang, nick, id = string.match(player, "%[%d+%] (.+) (%w+_%w+)%((%d+)%)")
                local rang_number = getRangNumber(rang)
                if rang_number > 0 then rang = rang.." ["..rang_number.."]" end
                sampAddChatMessage(tag.."Игрок {"..org_checker.color.."}"..nick.."["..id.."] "..white_color.."найден: "..org_checker.name.." | "..rang..".",-1)
                stopFind(dialogId)
                return false
            end
            
            if player:find("Предыдущая") then next = 26 end

            if player:find("Следующая") then
                sampSendDialogResponse(dialogId, 1, next, false)
                return false
            end
        end
        sampSendDialogResponse(dialogId, -1, nil, false)
        org_checker.process = false
        return false
    end
end

function sampev.onServerMessage(color, text)
    -- sampev AutoFind
    if string.find(text, "Местоположение (%w+_%w+)%[(%d+)%] отмечено на карте") then
        local id = text:match("%[(%d+)%]")
        local nick = text:match("(%w+_%w+)")

        if nick ~= autofind.playerNick then
            sampAddChatMessage(tag.."Игрок "..autofind.playerNick.."["..autofind.playerId.."] вышел из игры!",-1)
            sampAddChatMessage(tag.."Слежка за игроком "..autofind.playerNick.."["..autofind.playerId.."] "..red_color.."остановлена",-1)
            afindDefaultParams()
        end

        if autofind.inta then
            sampAddChatMessage(tag.."Игрок "..autofind.playerNick.."["..autofind.playerId.."] вышел из интерьера!",-1)
            autofind.inta = false
        end
        return false
    end

    if string.find(text, "Игрок находится в") then
        if not autofind.inta then 
            sampAddChatMessage(tag.."Игрок "..autofind.playerNick.."["..autofind.playerId.."] зашел в интерьер!",-1)
            autofind.inta = true
        end
        return false
    end
end

--============================================= AUTO UPDATE =================================================--

function autoupdate(json_url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function()
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((tag..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((tag..'Обновление завершено!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((tag..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, tag
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление.')
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end