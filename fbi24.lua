---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local, different-requires, undefined-field, duplicate-set-field

script_name("FBI Helper")
script_author("Joe Davidson")
script_version("0.1.1")
script_description('Multifunctional FBI helper for Arizona Wednesday')

-- Основные подключения
require 'lib.moonloader'
require 'lib.sampfuncs'
local sampev = require 'lib.samp.events'

-- Доп. подключения
local imgui = require("mimgui")
local ffi = require('ffi')
local json = require("cjson")
local faicons = require('fAwesome6')
local wm = require('windows.message')

-- Основные глобальные переменные
local new = imgui.new
local str = ffi.string
local sizeof = ffi.sizeof

-- Переменные для PageButton
local AI_PAGE = {}
local ToU32 = imgui.ColorConvertFloat4ToU32
local page = 1


-- Кодировка
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
cp1251 = encoding.CP1251

--============================================== Чат =======================================--

local blue_color = "{5A90CE}"
local white_color = "{FFFFFF}"
local red_color = "{F34336}"
local green_color = "{66FF4D}"

local tag = blue_color.."[ FBI Helper | "..red_color.."Joe Davidson "..blue_color.."]: "..white_color

--=================================== Состояия =============================================================--

local pre_start = true

--=================================== Переменные для скриптов ===============================================--


local pathes = {
    config = {
        config_dir = 'moonloader/FBIHelperSettings/',
        settings = 'moonloader/FBIHelperSettings/settings.json',
        notepad = 'moonloader/FBIHelperSettings/notepad.txt',
        resouces = 'moonloader/FBIHelperSettings/resources/',
    },
    update = {
        json_url = 'https://raw.githubusercontent.com/Normalnuy/fbi24/refs/heads/main/update.json'
    }
}

local resources = {
    images = {
        logo = {
            path = pathes.config.resouces .. 'logo.png',
            url = 'https://raw.githubusercontent.com/Normalnuy/fbi24/refs/heads/main/resources/images/logo.png'
        }
    }
}

local settings = {}
local default_settings = {
    player = {
        nickname = '',
        rang = '',
        rang_number = 0,
    },
    asu = {
        articles = {},
    },
    dm = {
        status = 0,         -- 0 - нет доступа, 1 - dismiss/gwarns, 2 - demote
        articles = {},
    },
    dep = {}
}

local asu = {
    playerId = -1,
    playerNick = '',
}

local dm = {
    playerId = -1,
    playerNick = '',
    use_dismiss = false,
    reason = '',
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

--====================================== mimgui параменты ===================================================--

local sw, sh = getScreenResolution()

local buff = {
    window = {
        main = new.bool(),
        asu = new.bool(),
        dm = new.bool(),
        gwarns_dm = new.bool(),
        update = new.bool(),
    },
    text = {
        find_asu = new.char[10000](),
        find_dm = new.char[10000](),
        notepad = new.char[10000](),
        add_asu = new.char[10000](),
        add_asu_name = new.char[10000](),
        edit_asu = new.char[10000](),
        add_dm = new.char[10000](),
        add_dm_name = new.char[10000](),
        edit_dm = new.char[10000](),
    },
    int = {
        add_asu = new.int(1),
        edit_asu = new.int(),
    },
    combo = {
        add_asu = new.int(),
        add_dm = new.int(),

    },
    radioInt = {
        form_dm = new.int(),
    }
}

--=================================== ПРОГРАММА =============================================================--
function main()
    checkSampLoaded()
    autoupdate(pathes.update.json_url)
    
    checkConfig()
    sampRegisterChatCommands()
    sampAddChatMessage(tag.."Скрипт запущен! v"..thisScript().version,-1)
    sampAddChatMessage(tag.."Активация меню: "..blue_color.."/fbi",-1)

    checkCloseWindowEsc()
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

function cmd_fbi()
    buff.window.main[0] = not buff.window.main[0]
end

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

function cmd_asu(arg)
    local id = arg:match('(.+)')
    local nick = ''

    id = arg:match('(.+)')
    if id then nick = checkPlayerOnline(id) end

    if not id then          sampAddChatMessage(tag.."Вы не указали ID!",-1)
    elseif not nick then    sampAddChatMessage(tag.."Игрок с ID: "..id.." не в сети!",-1)
    else
        asu.playerId = id
        asu.playerNick = nick
        buff.window.asu[0] = not buff.window.asu[0]
    end
end

function cmd_dm(arg)
    local id = arg:match('(.+)')
    local nick = ''

    id = arg:match('(.+)')
    if id then nick = checkPlayerOnline(id) end

    if not id then          sampAddChatMessage(tag.."Вы не указали ID!",-1)
    elseif not nick then    sampAddChatMessage(tag.."Игрок с ID: "..id.." не в сети!",-1)
    else
        dm.playerId = id
        dm.playerNick = nick
        buff.window.dm[0] = not buff.window.dm[0]
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
    sampRegisterChatCommand('fbi', cmd_fbi)
    sampRegisterChatCommand('afind', cmd_afind)
    sampRegisterChatCommand("org", cmd_org)
    sampRegisterChatCommand("asu", cmd_asu)
    sampRegisterChatCommand("dm", cmd_dm)

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

function checkCloseWindowEsc()
    addEventHandler('onWindowMessage', function(msg, wparam, lparam)
        if wparam == 27 then
            if buff.window.asu[0] then             -- aw
                if msg == wm.WM_KEYDOWN then consumeWindowMessage(true, false) end
                if msg == wm.WM_KEYUP then buff.window.asu[0] = false end 
            elseif buff.window.dm[0] then          -- dw
                if msg == wm.WM_KEYDOWN then consumeWindowMessage(true, false) end
                if msg == wm.WM_KEYUP then buff.window.dm[0] = false end 
            elseif buff.window.gwarns_dm[0] then   -- gwarns_dm
                if msg == wm.WM_KEYDOWN then consumeWindowMessage(true, false) end
            elseif buff.window.main[0] then        -- main
                if msg == wm.WM_KEYDOWN then consumeWindowMessage(true, false) end
                if msg == wm.WM_KEYUP then buff.window.main[0] = false end 
            end
        end
    end)
end

function saveNote(text)
    f = io.open(pathes.config.notepad, "w")
    f:write(u8:decode(str(text)))
    f:flush()
    f:close()
end

function readNote()
    local f = io.open(pathes.config.notepad, "r+")
    local text = f:read("*a")
    f:close()
    return text
end

function checkConfig()
    if not doesDirectoryExist(pathes.config.config_dir) then createDirectory(pathes.config.config_dir) end
    if not doesFileExist(pathes.config.notepad) then saveNote(' ') end
    buff.text.notepad = new.char[10000](readNote())

    downloadResources()
    load_settings()
    updatePlayerStats()
end

function updatePlayerStats()
    if pre_start then
        sampSendChat('/stats')
    end
end

function load_settings()
    if not doesFileExist(pathes.config.settings) then
        settings = default_settings
        local file = io.open(pathes.config.settings, 'w')
        file:write(encodeJson(settings)) file:close()
		sampAddChatMessage(tag..'Файл с настройками не найден. Скрипт использует стандартные!',-1)
    else
        local file = io.open(pathes.config.settings, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
        		sampAddChatMessage(tag..'Не удалось открыть файл с настройками. Скрипт использует стандартные!',-1)
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					settings = loaded
            		sampAddChatMessage(tag..'Настройки успешно загружены!',-1)
				else
            		sampAddChatMessage(tag..'Не удалось открыть файл с настройками. Скрипт использует стандартные!',-1)
				end
			end
        else
            settings = default_settings
            sampAddChatMessage(tag..'Не удалось открыть файл с настройками. Скрипт использует стандартные!',-1)
        end
    end
end
function save_settings(status)
    local file, errstr = io.open(pathes.config.settings, 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
        if status then sampAddChatMessage(tag..'Настройки успешно сохранены!', -1) end
        return result
    else
        if status then sampAddChatMessage(tag..'Не удалось сохранить настройки хелпера, ошибка: '..errstr, -1) end
        return false
    end
end

function downloadResources()
    print("Проверка наличия ресурсов...")
    createDirectory(pathes.config.resources)
    for _type, object in pairs(resources) do
        print("Проверяем: ".._type)
        for name, res in pairs(object) do
            if not doesFileExist(res.path) then
                local ok, err = pcall(function()
                    downloadUrlToFile(res.url, res.path, function(success) end)
                end)
                if ok then print(name.." успешно загружено!")
                else print("Ошибка при загрузке "..name..": "..err) end
            end
        end
    end
    print("Проверка наличия ресурсов: Успешно загружено!")
end

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function addAsu(name, text, star)
    for i, article in ipairs(settings.asu.articles) do
        if article.name == name then
            table.insert(settings.asu.articles[i].chapters, {text = text, star = star})
            save_settings(true)
            return true
        end
    end
    table.insert(settings.asu.articles, {name = name, chapters = {{text = text, star = star}}})
    save_settings(true)
    return true
end

function addDm(name, text, form)
    for i, article in ipairs(settings.dm.articles) do
        if article.name == name then
            table.insert(settings.dm.articles[i].chapters, {text = text, form = form})
            save_settings(true)
            return true
        end
    end
    table.insert(settings.dm.articles, {name = name, chapters = {{text = text, form = form}}})
    save_settings(true)
    return true
end

function editAsu(name, old_text, old_star, text, star)
    for i, article in ipairs(settings.asu.articles) do
        if article.name == name then
            for j, chapter in ipairs(article.chapters) do
                if chapter.text == old_text and chapter.star == old_star then
                    settings.asu.articles[i].chapters[j].text = text
                    settings.asu.articles[i].chapters[j].star = tonumber(star)
                    save_settings(true)
                    return true
                end
            end
        end
    end
end

function editDm(name, old_text, old_form, text, form)
    for i, article in ipairs(settings.dm.articles) do
        if article.name == name then
            for j, chapter in ipairs(article.chapters) do
                if chapter.text == old_text and chapter.form == old_form then
                    settings.dm.articles[i].chapters[j].text = text
                    settings.dm.articles[i].chapters[j].form = form
                    save_settings(true)
                    return true
                end
            end
        end
    end
end

function deleteAsu(name, text, star)
    for i, article in ipairs(settings.asu.articles) do
        if article.name == name then
            for j, chapter in ipairs(article.chapters) do
                if chapter.text == text and chapter.star == star then
                    table.remove(article.chapters, j)
                    if #article.chapters == 0 then
                        table.remove(settings.asu.articles, i)
                    end
                    save_settings(true)
                    return true
                end
            end
        end
    end
end

function deleteDm(name, text, form)
    for i, article in ipairs(settings.dm.articles) do
        if article.name == name then
            for j, chapter in ipairs(article.chapters) do
                if chapter.text == text and chapter.form == form then
                    table.remove(article.chapters, j)
                    if #article.chapters == 0 then
                        table.remove(settings.dm.articles, i)
                    end
                    save_settings(true)
                    return true
                end
            end
        end
    end
end

function popOpen(params)
    local modalname = params.modalname
    local flag = params.flag
    local name = params.name or ""
    local text = params.text or ""
    local star = params.star or 0
    local form = params.form or 0

    imgui.OnFrame(function() return flag and not isPauseMenuActive() and not sampIsScoreboardOpen() end, function()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        
        if modalname == 'asu_add' then
            imgui.SetNextWindowSize(imgui.ImVec2(sw/3, sh/2.5 - 10), imgui.Cond.Always)

            local title = u8'Добавление статьи'
            imgui.OpenPopup(title)
            if imgui.BeginPopupModal(title, nil, imgui.WindowFlags.NoResize) then
                local chapter_list = {}
                for _, article in ipairs(settings.asu.articles) do
                    table.insert(chapter_list, article.name)
                end
                table.insert(chapter_list, u8'Новый раздел')
                local chapters = imgui.new['const char*'][#chapter_list](chapter_list)
                
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Раздел').x / 2)
                imgui.Text(u8'Раздел')
                imgui.PushItemWidth(-1)
                imgui.Combo(u8'##chapters', buff.combo.add_asu, chapters, #chapter_list)
                imgui.PopItemWidth()

                if buff.combo.add_asu[0] == #chapter_list-1 then
                    imgui.PushItemWidth(-1)
                    imgui.InputTextWithHint('##add_asu_name', u8'Название нового раздела.', buff.text.add_asu_name, sizeof(buff.text.add_asu_name), imgui.InputTextFlags.AutoSelectAll)
                    imgui.PopItemWidth()
                end
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Текст статьи:').x / 2)
                imgui.Text(u8'Текст статьи:')
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint('##add_asu_text', u8'Текст статьи при выдаче розыска.', buff.text.add_asu, sizeof(buff.text.add_asu), imgui.InputTextFlags.AutoSelectAll)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Уровень розыска:').x / 2)
                imgui.Text(u8'Уровень розыска:')
                imgui.PushItemWidth(-1)
                imgui.SliderInt('##', buff.int.add_asu, 1, 6)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - 140)  
                if imgui.Button(u8'Сохранить', imgui.ImVec2(140, 24)) then
                    local add_name = ''
                    local add_text = str(buff.text.add_asu)
                    local add_star = buff.int.add_asu[0]

                    if buff.combo.add_asu[0] == #chapter_list-1 then    add_name = str(buff.text.add_asu_name)
                    else                                                add_name = chapter_list[buff.combo.add_asu[0]+1] end
                    addAsu(add_name, add_text, add_star)
                    imgui.CloseCurrentPopup()
                    flag = false
                end
                imgui.SameLine()
                if imgui.Button(u8'Закрыть', imgui.ImVec2(140, 24)) then
                    imgui.CloseCurrentPopup()
                    flag = false
                end
            end
        end
        if modalname == 'asu' then
            imgui.SetNextWindowSize(imgui.ImVec2(sw/3, sh/3 - 20), imgui.Cond.Always)

            local title = u8'Редактирование статьи ##asu'
            imgui.OpenPopup(title)
            if imgui.BeginPopupModal(title, nil, imgui.WindowFlags.NoResize) then
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8"Раздел: "..'"'..name..'"').x / 2)
                imgui.Text(u8"Раздел: "..'"'..name..'"')
                imgui.Separator()
                
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Текст статьи:').x / 2)
                imgui.Text(u8'Текст статьи:')
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint('##edit_asu_text', u8'Текст статьи при выдаче розыска.', buff.text.edit_asu, sizeof(buff.text.edit_asu), imgui.InputTextFlags.AutoSelectAll)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Уровень розыска:').x / 2)
                imgui.Text(u8'Уровень розыска:')
                imgui.PushItemWidth(-1)
                imgui.SliderInt('##', buff.int.edit_asu, 1, 6)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - 140)  
                if imgui.Button(u8'Сохранить', imgui.ImVec2(140, 24)) then
                    editAsu(name, text, star, str(buff.text.edit_asu), buff.int.edit_asu[0])
                    imgui.CloseCurrentPopup()
                    flag = false
                end
                imgui.SameLine()
                if imgui.Button(u8'Закрыть', imgui.ImVec2(140, 24)) then
                    imgui.CloseCurrentPopup()
                    flag = false
                end
            end
            imgui.EndPopup()
        end
        if modalname == 'dm' then
            imgui.SetNextWindowSize(imgui.ImVec2(sw/3, sh/3 - 20), imgui.Cond.Always)

            local title = u8'Редактирование статьи ##dm'
            imgui.OpenPopup(title)
            if imgui.BeginPopupModal(title, nil, imgui.WindowFlags.NoResize) then
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8"Раздел: "..'"'..name..'"').x / 2)
                imgui.Text(u8"Раздел: "..'"'..name..'"')
                imgui.Separator()
                
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Текст статьи:').x / 2)
                imgui.Text(u8'Текст статьи:')
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint('##edit_dm_text', u8'Текст статьи при выдаче выговора или увольнения.', buff.text.edit_dm, sizeof(buff.text.edit_dm), imgui.InputTextFlags.AutoSelectAll)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Форма наказания:').x / 2)
                imgui.Text(u8'Форма наказания:')
                imgui.RadioButtonIntPtr(u8'Спец. выговор', buff.radioInt.form_dm, 0)
                imgui.SameLine()
                imgui.Text('                        |                    ')
                imgui.SameLine()
                imgui.RadioButtonIntPtr(u8'Увольнение', buff.radioInt.form_dm, 1)
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - 140)  
                if imgui.Button(u8'Сохранить', imgui.ImVec2(140, 24)) then
                    editDm(name, text, form, str(buff.text.edit_dm), buff.radioInt.form_dm[0])
                    imgui.CloseCurrentPopup()
                    flag = false
                end
                imgui.SameLine()
                if imgui.Button(u8'Закрыть', imgui.ImVec2(140, 24)) then
                    imgui.CloseCurrentPopup()
                    flag = false
                end
            end
            imgui.EndPopup()
        end
        if modalname == 'dm_add' then
            imgui.SetNextWindowSize(imgui.ImVec2(sw/3, sh/2.5 - 10), imgui.Cond.Always)

            local title = u8'Добавление статьи'
            imgui.OpenPopup(title)
            if imgui.BeginPopupModal(title, nil, imgui.WindowFlags.NoResize) then
                local chapter_list = {}
                for _, article in ipairs(settings.dm.articles) do
                    table.insert(chapter_list, article.name)
                end
                table.insert(chapter_list, u8'Новый раздел')
                local chapters = imgui.new['const char*'][#chapter_list](chapter_list)
                
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Раздел').x / 2)
                imgui.Text(u8'Раздел')
                imgui.PushItemWidth(-1)
                imgui.Combo(u8'##chapters', buff.combo.add_dm, chapters, #chapter_list)
                imgui.PopItemWidth()

                if buff.combo.add_dm[0] == #chapter_list-1 then
                    imgui.PushItemWidth(-1)
                    imgui.InputTextWithHint('##add_dm_name', u8'Название нового раздела.', buff.text.add_dm_name, sizeof(buff.text.add_dm_name), imgui.InputTextFlags.AutoSelectAll)
                    imgui.PopItemWidth()
                end
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Текст статьи:').x / 2)
                imgui.Text(u8'Текст статьи:')
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint('##add_dm_text', u8'Текст статьи при увольнении или выговоре.', buff.text.add_dm, sizeof(buff.text.add_dm), imgui.InputTextFlags.AutoSelectAll)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'Форма наказания:').x / 2)
                imgui.Text(u8'Форма наказания:')
                imgui.RadioButtonIntPtr(u8'Спец. выговор', buff.radioInt.form_dm, 0)
                imgui.SameLine()
                imgui.Text('                        |                    ')
                imgui.SameLine()
                imgui.RadioButtonIntPtr(u8'Увольнение', buff.radioInt.form_dm, 1)
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - 140)  
                if imgui.Button(u8'Сохранить', imgui.ImVec2(140, 24)) then
                    local add_name = ''
                    local add_text = str(buff.text.add_dm)
                    local add_form = buff.radioInt.form_dm[0]

                    if buff.combo.add_dm[0] == #chapter_list-1 then    add_name = str(buff.text.add_dm_name)
                    else                                                add_name = chapter_list[buff.combo.add_dm[0]+1] end
                    addDm(add_name, add_text, add_form)
                    imgui.CloseCurrentPopup()
                    flag = false
                end
                imgui.SameLine()
                if imgui.Button(u8'Закрыть', imgui.ImVec2(140, 24)) then
                    imgui.CloseCurrentPopup()
                    flag = false
                end
            end
        end
    end)
end

--======================================== Инициализация mimgui =============================================--

imgui.OnInitialize(function()
    -- Иконки
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 16, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone


    -- Images
    fbi_logo = imgui.CreateTextureFromFile(resources.images.logo.path)


    -- Шрифты
    -- local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    -- impact26 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\impact.ttf', 26, _, glyph_ranges)
    -- impact16 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\impact.ttf', 16, _, glyph_ranges)
    -- calibri58 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\calibri.ttf', 56, _, glyph_ranges)

    -- Стиль
    style()
end)


--===================================== mimgui окна =========================================================--

-- Главное меню
local mw = imgui.OnFrame(function() return buff.window.main[0] end, function(player)
    player.HideCursor = false

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.6, sh*0.7), imgui.Cond.Always)

    imgui.Begin(u8'FBI Helper', buff.window.main, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

        imgui.BeginChild('tabs', imgui.ImVec2(200, -1), true)
            if imgui.PageButton(page == 1, faicons('HOUSE'),              u8'Главное меню') then            page = 1 end
            if imgui.PageButton(page == 2, faicons('STAR'),               u8'Умный розыск [/asu]') then     page = 2 end
            if imgui.PageButton(page == 3, faicons('USER_XMARK'),         u8'Умный demoute [/dm]') then     page = 3 end
            if imgui.PageButton(page == 4, faicons('NOTE_STICKY'),        u8'Заметки') then                 page = 4 end 
            if imgui.PageButton(page == 5, faicons('WALKIE_TALKIE'),      u8'Департамент [/dep]') then      page = 5 end
            if imgui.PageButton(page == 6, faicons('TERMINAL'),           u8'Чат команды') then             page = 6 end
            if imgui.PageButton(page == 99, faicons('LIST'),              u8'История обновлений') then      page = 99 end
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild('workspace', imgui.ImVec2(-1, -1), true, imgui.WindowFlags.NoScrollbar)
            local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()    
            if     page == 1 then
                local logo_size = { x = 325, y = 325 }
                imgui.SetCursorPos(imgui.ImVec2(x/2-logo_size.x/2, y/20))
                imgui.Image(fbi_logo, imgui.ImVec2(logo_size.x, logo_size.y))

                local info_text = u8"Версия: "..thisScript().version.." | "..u8"Автор: "..u8"Joe Davidson"
                imgui.SetCursorPos(imgui.ImVec2(imgui.CalcTextSize(info_text).x*0.05, y-imgui.CalcTextSize(info_text).y*1.5))
                imgui.Text(info_text)

                local btn_text = u8"Сообщить об ошибке"
                imgui.SetCursorPos(imgui.ImVec2(x-imgui.CalcTextSize(btn_text.."._.").x, y-imgui.CalcTextSize(btn_text).y*2.1))
                if imgui.Button(btn_text) then
                    -- todo
                end
                imgui.TextHovered(u8"Функционал в разработке.")

            elseif page == 2 then       -- | ASU
                imgui.SetCursorPosX(x/5)
                imgui.InputTextWithHint('##asu', faicons('MAGNIFYING_GLASS')..u8' Поиск', buff.text.find_asu, sizeof(buff.text.find_asu), imgui.InputTextFlags.AutoSelectAll)
                imgui.Separator()
                if not settings.asu.articles then settings.asu.articles = {} save_settings(false) end
                if imgui.Button(faicons('PLUS'), imgui.ImVec2(-1, 0)) then
                    popOpen{modalname='asu_add', flag=true}
                end
                imgui.Separator()

                local generate_buttons = {}
                for _, article in ipairs(settings.asu.articles) do
                    for _, chapter in ipairs(article.chapters) do
                        if #str(buff.text.find_asu) > 0 then
                            if string.find(string.rlower(u8:decode(chapter.text)), string.rlower(u8:decode(str(buff.text.find_asu)))) then    
                                if not generate_buttons[article.name] then generate_buttons[article.name] = {} end
                                table.insert(generate_buttons[article.name], {text = chapter.text, star = chapter.star})
                            end
                        else
                            if not generate_buttons[article.name] then generate_buttons[article.name] = {} end
                            table.insert(generate_buttons[article.name], {text = chapter.text, star = chapter.star})
                        end
                    end
                end
                
                for name, data in pairs(generate_buttons) do
                    if imgui.CollapsingHeader(name) then
                        for i, chapter in ipairs(data) do
                            imgui.Button(chapter.text, imgui.ImVec2(imgui.GetWindowHeight() - 15, 25))
                            imgui.TextHovered(u8("Санкция: "..chapter.star.." уровень розыска"))
                            imgui.SameLine()
                            if imgui.Button(faicons('PEN').."##"..i, imgui.ImVec2(30, 25)) then
                                buff.text.edit_asu = new.char[10000](chapter.text)
                                buff.int.edit_asu = new.int(chapter.star)
                                popOpen{modalname='asu', flag=true, name=name, text=chapter.text, star=chapter.star}
                            end
                            
                            imgui.SameLine()

                            if imgui.Button(faicons('TRASH').."##"..i, imgui.ImVec2(30, 25)) then
                                deleteAsu(name, chapter.text, chapter.star)
                            end
                            imgui.TextHovered(u8"Для удаления записи необходимо\nскрыть остальные вкладки.")
                        end
                    end
                end
            elseif page == 3 then       -- | DM
                if settings.dm.status == 0 then
                    local text1 = u8'У вас нет доступа к данному функционалу!'
                    local text2 = u8'Необоходимо получить 6+ ранг. [У Вас: '..settings.player.rang_number..']'
                    local text3 = u8"Перезагрузите скрипт, если считаете, что это ошибка."

                    imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text1).x/2, y/2-20))
                    imgui.Text(text1) 
                    
                    imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text2).x/2, y/2))
                    imgui.Text(text2) 
                    
                    imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text3).x/2, y/2+20))
                    imgui.Text(text3)
                    return
                end

                imgui.SetCursorPosX(x/5)
                imgui.InputTextWithHint('##dm', faicons('MAGNIFYING_GLASS')..u8' Поиск', buff.text.find_dm, sizeof(buff.text.find_dm), imgui.InputTextFlags.AutoSelectAll)
                imgui.Separator()
                if not settings.dm.articles then settings.dm.articles = {} save_settings(false) end
                if imgui.Button(faicons('PLUS'), imgui.ImVec2(-1, 0)) then
                    popOpen{modalname='dm_add', flag=true}
                end
                imgui.Separator()

                local generate_buttons = {}
                for _, article in ipairs(settings.dm.articles) do
                    for _, chapter in ipairs(article.chapters) do
                        if #str(buff.text.find_dm) > 0 then
                            if string.find(string.rlower(u8:decode(chapter.text)), string.rlower(u8:decode(str(buff.text.find_dm)))) then    
                                if not generate_buttons[article.name] then generate_buttons[article.name] = {} end
                                table.insert(generate_buttons[article.name], {text = chapter.text, form = chapter.form})
                            end
                        else
                            if not generate_buttons[article.name] then generate_buttons[article.name] = {} end
                            table.insert(generate_buttons[article.name], {text = chapter.text, form = chapter.form})
                        end
                    end
                end
                
                for name, data in pairs(generate_buttons) do
                    if imgui.CollapsingHeader(name) then
                        for i, chapter in ipairs(data) do
                            imgui.Button(chapter.text, imgui.ImVec2(imgui.GetWindowHeight() - 15, 25))
                            local sanctions = {[0] = u8'спец. выговор', [1] = u8'увольнение'}
                            imgui.TextHovered(u8"Санкция: "..sanctions[chapter.form])
                            imgui.SameLine()
                            if imgui.Button(faicons('PEN').."##"..i, imgui.ImVec2(30, 25)) then
                                buff.text.edit_dm = new.char[10000](chapter.text)
                                buff.radioInt.form_dm = new.int(chapter.form)
                                popOpen{modalname='dm', flag=true, name=name, text=chapter.text, form=chapter.form}
                            end
                            
                            imgui.SameLine()

                            if imgui.Button(faicons('TRASH').."##"..i, imgui.ImVec2(30, 25)) then
                                deleteDm(name, chapter.text)
                            end
                            imgui.TextHovered(u8"Для удаления записи необходимо\nскрыть остальные вкладки.")
                        end
                    end
                end
            elseif page == 4 then       -- | NotePad
                if imgui.InputTextMultiline('##notepadText', buff.text.notepad, sizeof(buff.text.notepad), imgui.ImVec2(-1, -1)) then -- EROR: (declaration specifier expected near '<eof>') imgui.InputTextMultiline("##MyMultilineInput", TextMultiLine, 256)
                    saveNote(u8(str(buff.text.notepad)))
                end     
            elseif page == 5 then
                imgui.Text(u8'В разработке!')
            elseif page == 6 then       -- | Chat Commands
                local text =  
[[
Авто-поиск игрока:
Включение: /afind [id]
Выключение: /afind | /afind [last_id]

Пробив организации игрока:
Включение: /org [id]

Умная выдача розыска:
Включение: /asu [id]

Умный demoute | dismiss | gwarn:
Включение: /dm [id]
]]

                imgui.Text(u8(text))
            elseif page == 99 then      -- | Update history
                local versions = updateinfo.versions
                for _, version in ipairs(versions) do
                    imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"Версия: "..version.num).x/2)
                    imgui.Text(u8"Версия: "..version.num)
                    imgui.Separator()
                    for _, line in ipairs(version.info) do
                        imgui.TextWrapped(line..'\n')
                    end
                    imgui.Separator()
                end
            end
        imgui.EndChild()
    imgui.End()
end)

--===================================== Вспомогательные mimgui окна ===========================================--

-- Умный розыск
local aw = imgui.OnFrame(function() return buff.window.asu[0] end, function(player)
    player.HideCursor = false

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.3, sh*0.7), imgui.Cond.Always)

    imgui.Begin(u8'FBI Helper ##asu', buff.window.asu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()

        imgui.SetCursorPosX(x/5)
        imgui.InputTextWithHint('##asu', faicons('MAGNIFYING_GLASS')..u8' Поиск', buff.text.find_asu, sizeof(buff.text.find_asu), imgui.InputTextFlags.AutoSelectAll)
        imgui.Separator()
        if not settings.asu.articles then settings.asu.articles = {} save_settings(false) end

        local generate_buttons = {}
        for _, article in ipairs(settings.asu.articles) do
            for _, chapter in ipairs(article.chapters) do
                if #str(buff.text.find_asu) > 0 then
                    if string.find(string.rlower(u8:decode(chapter.text)), string.rlower(u8:decode(str(buff.text.find_asu)))) then    
                        if not generate_buttons[article.name] then generate_buttons[article.name] = {} end
                        table.insert(generate_buttons[article.name], {text = chapter.text, star = chapter.star})
                    end
                else
                    if not generate_buttons[article.name] then generate_buttons[article.name] = {} end
                    table.insert(generate_buttons[article.name], {text = chapter.text, star = chapter.star})
                end
            end
        end
        
        for name, data in pairs(generate_buttons) do
            if imgui.CollapsingHeader(name) then
                for i, chapter in ipairs(data) do
                    if imgui.Button(chapter.text, imgui.ImVec2(-1, 25)) then
                        sampSendChat(string.format('/su %d %d %s', asu.playerId, chapter.star, u8:decode(chapter.text)))
                        buff.window.asu[0] = not buff.window.asu[0]
                    end
                    imgui.TextHovered(u8("Санкция: "..chapter.star.." уровень розыска"))
                end
            end
        end
    imgui.End()
end)

-- Умный demoute
local dw = imgui.OnFrame(function() return buff.window.dm[0] end, function(player)
    player.HideCursor = false

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.3, sh*0.7), imgui.Cond.Always)

    imgui.Begin(u8'FBI Helper ##dm', buff.window.dm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()

        if settings.dm.status == 0 then
            local text1 = u8'У вас нет доступа к данному функционалу!'
            local text2 = u8'Необоходимо получить 6+ ранг. [У Вас: '..settings.player.rang_number..']'
            local text3 = u8"Перезагрузите скрипт, если считаете, что это ошибка."

            imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text1).x/2, y/2-20))
            imgui.Text(text1) 
            
            imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text2).x/2, y/2))
            imgui.Text(text2) 
            
            imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text3).x/2, y/2+20))
            imgui.Text(text3)
            return
        end

        imgui.SetCursorPosX(x/5)
        imgui.InputTextWithHint('##dm', faicons('MAGNIFYING_GLASS')..u8' Поиск', buff.text.find_dm, sizeof(buff.text.find_dm), imgui.InputTextFlags.AutoSelectAll)
        imgui.Separator()
        if not settings.dm.articles then settings.dm.articles = {} save_settings(false) end

        local generate_buttons = {}
        for _, article in ipairs(settings.dm.articles) do
            for _, chapter in ipairs(article.chapters) do
                if #str(buff.text.find_dm) > 0 then
                    if string.find(string.rlower(u8:decode(chapter.text)), string.rlower(u8:decode(str(buff.text.find_dm)))) then    
                        if not generate_buttons[article.name] then generate_buttons[article.name] = {} end
                        table.insert(generate_buttons[article.name], {text = chapter.text, form = chapter.form})
                    end
                else
                    if not generate_buttons[article.name] then generate_buttons[article.name] = {} end
                    table.insert(generate_buttons[article.name], {text = chapter.text, form = chapter.form})
                end
            end
        end
        
        for name, data in pairs(generate_buttons) do
            if imgui.CollapsingHeader(name) then
                for i, chapter in ipairs(data) do
                    if imgui.Button(chapter.text, imgui.ImVec2(-1, 25)) then
                        dm.reason = chapter.text
                        local commands = {
                            [0] = 'gwarn',
                            [1] = {'dismiss', 'demoute'}
                        }
                        local use_command = commands[chapter.form]

                        if use_command == 'gwarn' then sampSendChat(string.format('/%s %d %s', use_command, dm.playerId, chapter.text))
                        else
                            if settings.dm.status == 1 then dm.use_dismiss = true end
                            sampSendChat(string.format('/%s %d %s', use_command[settings.dm.status], dm.playerId, chapter.text)) end
                            buff.window.dm[0] = not buff.window.dm[0]
                    end
                    local sanctions = {[0] = u8'спец. выговор', [1] = u8'увольнение'}
                    imgui.TextHovered(u8"Санкция: "..sanctions[chapter.form])
                end
            end
        end
    imgui.End()
end)

local gwarns_dw = imgui.OnFrame(function() return buff.window.gwarns_dm[0] end, function(player)
    player.HideCursor = false

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.25, sh*0.16), imgui.Cond.Always)

    imgui.Begin(u8'! ПРЕДУПРЕЖДЕНИЕ ! ##gwarns_dm', buff.window.gwarns_dm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
        local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()
    
        imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"Сотрудник выше 4-го ранга!").x/2)
        imgui.Text(u8"Сотрудник выше 4-го ранга!")
        imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"Выдать 3 спец. выговора?").x/2)
        imgui.Text(u8"Выдать 3 спец. выговора?")
        imgui.Separator()

        imgui.SetCursorPosX(x/2 - 110)
        if imgui.Button(u8'Да', imgui.ImVec2(110, 25)) or isKeyJustPressed(VK_RETURN) then
            buff.window.gwarns_dm[0] = false
            for i = 1, 3 do
                
                sampSendChat(string.format('/gwarn %d %s', dm.playerId, dm.reason))
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'Нет', imgui.ImVec2(110, 25)) or isKeyJustPressed(VK_ESCAPE) then buff.window.gwarns_dm[0] = false end

    imgui.End()
end)

local uw = imgui.OnFrame(function() return buff.window.update[0] end, function(player)
    player.HideCursor = false
    local max_y = sh*0.7

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.3, -1), imgui.Cond.Always)
    
    imgui.Begin(u8'! ОБНОВЛЕНИЕ ! ##updates', buff.window.update, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()
        local last_version = updateinfo.versions[#updateinfo.versions]

        imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"Версия: "..last_version.num).x/2)
        imgui.Text(u8"Версия: "..last_version.num)
        imgui.Separator()
        for _, line in ipairs(last_version.info) do
            imgui.TextWrapped(line..'\n')
        end
        imgui.Separator()

        imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"Отмена  "..u8"  Установить!").x/2)
        if imgui.Button(u8"Установить!") then
            downloadUrlToFile(updatelink, thisScript().path,
            function(id3, status1, p13, p23)
                if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                    print(string.format('Загружено %d из %d.', p13, p23))
                elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                    print('Загрузка обновления завершена.')
                    sampAddChatMessage((tag..'Обновление завершено!'),-1)
                    goupdatestatus = true
                    lua_thread.create(function() wait(500) thisScript():reload() end)
                end
                if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                    if goupdatestatus == nil then
                        sampAddChatMessage((tag..'Обновление прошло неудачно. Запускаю устаревшую версию..'),-1)
                        update = false
                    end
                end
            end)
        end
        imgui.SameLine()
        if imgui.Button(u8"Отмена") then 
            update = false 
            buff.window.update[0] = not buff.window.update[0]
            end
    imgui.End()

end)

--======================================== Упрощенные mimgui функции ========================================--

imgui.TextHovered = function (text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.TextUnformatted(text)
        imgui.EndTooltip()
    end
end

imgui.PageButton = function(bool, icon, name, but_wide)
    but_wide = but_wide or 190
    local duration = 0.25
    local DL = imgui.GetWindowDrawList()
    local p1 = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local col = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
        
    if not AI_PAGE[name] then
        AI_PAGE[name] = { clock = nil }
    end
    local pool = AI_PAGE[name]

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    local result = imgui.InvisibleButton(name, imgui.ImVec2(but_wide, 35))
    if result and not bool then
        pool.clock = os.clock()
    end
    local pressed = imgui.IsItemActive()
    imgui.PopStyleColor(3)
    if bool then
        if pool.clock and (os.clock() - pool.clock) < duration then
            local wide = (os.clock() - pool.clock) * (but_wide / duration)
            DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2((p1.x + 190) - wide, p1.y + 35), 0x10FFFFFF, 15, 10)
               DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 5, p1.y + 35), ToU32(col))
            DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 15, 10)
        else
            DL:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y + 3 or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 32 or p1.y + 35)), ToU32(col))
            DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 15, 10)
        end
    else
        if imgui.IsItemHovered() then
            DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), 0x10FFFFFF, 15, 10)
        end
    end
    imgui.SameLine(10); imgui.SetCursorPosY(p2.y + 8)
    if bool then
        imgui.Text((' '):rep(3) .. icon)
        imgui.SameLine(45)
        imgui.Text(name)
    else
        imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), (' '):rep(3) .. icon)
        imgui.SameLine(50)
        imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), name)
    end
    imgui.SetCursorPosY(p2.y + 40)
    return result
end

--============================================= SAMP EVENTS =================================================--

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)

    -- sampev Pre Start
    if title:find("Основная") and pre_start then pre_start = false
        if text:find("{FFFFFF}Имя: {B83434}%[(.-)]") then
            settings.player.nickname = text:match("{FFFFFF}Имя: {B83434}%[(.-)]")
        end
        if text:find("{FFFFFF}Должность: {B83434}(.+)%((%d+)%)") then
            local rang, rang_number = text:match("{FFFFFF}Должность: {B83434}(.+)%((%d+)%)(.+)Уровень розыска")
            settings.player.rang = u8(rang)
            settings.player.rang_number = tonumber(rang_number)
        end
        if settings.player.rang_number >= 9 then       settings.dm.status = 2
        elseif settings.player.rang_number >= 6 then   settings.dm.status = 1
        else settings.dm.status = 0 end
        save_settings(false)
        sampSendDialogResponse(dialogId, 0, nil, false)
        return false
    end

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

    -- sampev Умный demoute
    if string.find(text, 'Вы можете') and dm.use_dismiss then dm.use_dismiss = false
        buff.window.gwarns_dm[0] = not buff.window.gwarns_dm[0]
        return false
    end

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

--============================================== Визуальный стиль скрипта =====================================--

function style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
     style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
     style.WindowPadding = ImVec2(15, 15)
     style.WindowRounding = 15.0
     style.FramePadding = ImVec2(5, 5)
     style.ItemSpacing = ImVec2(12, 8)
     style.ItemInnerSpacing = ImVec2(8, 6)
     style.IndentSpacing = 25.0
     style.ScrollbarSize = 15.0
     style.ScrollbarRounding = 15.0
     style.GrabMinSize = 15.0
     style.GrabRounding = 7.0
    --  style.ChildWindowRounding = 8.0
     style.FrameRounding = 6.0
   
 
       colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
       colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
       colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
    --    colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
       colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
       colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
       colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
       colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
       colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
       colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
       colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
       colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
       colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
       colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
    --    colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
       colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
       colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
       colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
       colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
       colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
       colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
       colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    --    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    --    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    --    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
       colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
       colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
       colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
       colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
       colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    --    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
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
            updateinfo = decodeJson(f:read('*a'))
            updatelink = updateinfo.updateurl
            updateversion = updateinfo.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
                buff.window.update[0] = not buff.window.update[0]
                return
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