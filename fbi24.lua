---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local, different-requires, undefined-field, duplicate-set-field

script_name("FBI Helper")
script_author("Joe Davidson")
script_version("0.1.1")
script_description('Multifunctional FBI helper for Arizona Wednesday')

-- �������� �����������
require 'lib.moonloader'
require 'lib.sampfuncs'
local sampev = require 'lib.samp.events'

-- ���. �����������
local imgui = require("mimgui")
local ffi = require('ffi')
local json = require("cjson")
local faicons = require('fAwesome6')
local wm = require('windows.message')

-- �������� ���������� ����������
local new = imgui.new
local str = ffi.string
local sizeof = ffi.sizeof

-- ���������� ��� PageButton
local AI_PAGE = {}
local ToU32 = imgui.ColorConvertFloat4ToU32
local page = 1


-- ���������
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
cp1251 = encoding.CP1251

--============================================== ��� =======================================--

local blue_color = "{5A90CE}"
local white_color = "{FFFFFF}"
local red_color = "{F34336}"
local green_color = "{66FF4D}"

local tag = blue_color.."[ FBI Helper | "..red_color.."Joe Davidson "..blue_color.."]: "..white_color

--=================================== �������� =============================================================--

local pre_start = true

--=================================== ���������� ��� �������� ===============================================--


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
        status = 0,         -- 0 - ��� �������, 1 - dismiss/gwarns, 2 - demote
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
        {name = "���",            index = 32,       color = 'CFAF46'},
        {name = "LSPD",           index = 1,        color = '0049FF'},
        {name = "RCSD",           index = 2,        color = '0049FF'},
        {name = "SFPD",           index = 3,        color = '004EFF'},
        {name = "LSMC",           index = 4,        color = 'FF7E7E'},
        {name = "LVMC",           index = 5,        color = 'FF7E7E'},
        {name = "���-��",         index = 6,        color = 'CCFF00'},
        {name = "���",            index = 7,        color = 'BDBDBD'},
        {name = "SFMC",           index = 8,        color = 'FF7E7E'},
        {name = "���������",      index = 9,        color = 'FF6633'},
        {name = "��� ��",         index = 10,       color = 'FF8000'},
        {name = "����� ��",       index = 11,       color = '996633'},
        {name = "LVMPD",          index = 12,       color = '0049FF'},
        {name = "��� ��",         index = 13,       color = 'FF8000'},
        {name = "��� ��",         index = 14,       color = 'FF8000'},
        {name = "����� ��",       index = 15,       color = '996633'},
        {name = "����",           index = 16,       color = '009327'},
        {name = "�����",          index = 17,       color = 'D1DB1C'},
        {name = "������",         index = 18,       color = 'CC00CC'},
        {name = "�����",          index = 19,       color = '00FFE2'},
        {name = "����",           index = 20,       color = '6666FF'},
        {name = "��",             index = 21,       color = '336699'},
        {name = "������",         index = 22,       color = '960202'},
        {name = "���",            index = 23,       color = '993366'},
        {name = "������",         index = 24,       color = 'BA541D'},
        {name = "������ �����",   index = 25,       color = 'A87878'},
        {name = "���",            index = 31,       color = '084F6B'},
        {name = "Jefferson MC",   index = 33,       color = 'FF7E7E'},
        {name = "�������� ���.",  index = 34,       color = 'FF4500'},
    },
    rangs_number = {
        {name = 'LSPD',             rangs = {'����� �������', '������ ������� I', '������ ������� II', '������ ������� II', '������ ������� III', '�������', '���������', '�������', '��������', '����������� ���� ������������', '��� ������������'}},
        {name = 'RCSD',             rangs = {'����� ������', '������� ���������� �����', '���������� �����', '������� ���������� �����', '�������', '���������', '�������', '��������', '����������� ������ ������������', '����� ������������'}},
        {name = 'SFPD',             rangs = {'������� SWAT','�������� SWAT', '����� SWAT', '������� ������� SWAT', '�������� SWAT', '����������� SWAT', '��������� SWAT', '���������� SWAT', '����������� ��������� SWAT', '�������� SWAT'}},
        {name = 'LVMPD',            rangs = {'����� ����� I','�������� ������ II', '�������� ������ III', '�������� ������ IV', '�������', '���������', '�������', '��������', '����������� ������ ������������', '����� ������������'}},
        {name = 'LSMC',             rangs = {'�������', '��������', '�����������', '���������� ����', '��������', '�������', '������', '���������� ����������', '���.����.�����', '����.����'}},
        {name = 'LVMC',             rangs = {'������', '���������� ����', '��������', '��������', '�������', '������', '��������', '���������� ����������', '���.����.�����', '����.����'}},
        {name = '�������� ���.',    rangs = {'������', '��������', '������� ��������', '���������', '�����������', '�������', '���. ���������', '��������', '���. ���� ������������', '��� ��������� ������������'}},
        {name = '���-��',           rangs = {'������ �����', '�����', '������ �������', '��������������� �������', '���������� -', '���������', '������', '��������������� ��������', '����-����������', '���������� �����'}},
        {name = "���",              rangs = {'��������', '�����������', '������� �����������', '��������', '���������', '��������� ���������', '����������� ���. �����', '��������� �����', '���. ���������� ������', '��������� ������'}},
        {name = "���������",        rangs = {'����������', '�����������', '���������� I ���������', '���������� II ���������', '���������� III ���������', '��������� ���������', '��������', '������� ������', '���.���������', '��������'}},
        {name = '��� ��',           rangs = {'�����', '�������������', '��������', '���������', '���-���������', '�������', '���-��������', 'SMM-��������', '���. ���������', '��������'}},
        {name = '����� ��',         rangs = {'�������', '������', '�������', '������-�������', '���������', '�������', '�����', '������������', '���������', '�������'}},
        {name = '����� ��',         rangs = {'������', '������� ������', '������', '������� ������', '���������', '�������-���������', '������� 1-��� �����', '�����-�������', '����-�������', '�������'}},
    }
}

--====================================== mimgui ��������� ===================================================--

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

--=================================== ��������� =============================================================--
function main()
    checkSampLoaded()
    autoupdate(pathes.update.json_url)
    
    checkConfig()
    sampRegisterChatCommands()
    sampAddChatMessage(tag.."������ �������! v"..thisScript().version,-1)
    sampAddChatMessage(tag.."��������� ����: "..blue_color.."/fbi",-1)

    checkCloseWindowEsc()
    while true do wait(0)
        afindUpdate()      -- autofind
        findUpdate()       -- org_checker
    end
end

--===================================== ������� ������������ ����� ==========================================--

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

--===================================== ������������������ ������� ==========================================--

function cmd_fbi()
    buff.window.main[0] = not buff.window.main[0]
end

function cmd_afind(arg)
    local id = arg:match('(.+)')
    local nick = ''
    if id then nick = checkPlayerOnline(id) end

    if (not id and autofind.process) or (id == autofind.playerId and autofind.process) then 
        sampAddChatMessage(tag.."������ �� ������� "..autofind.playerNick.."["..autofind.playerId.."] "..red_color.."�����������",-1)
        afindDefaultParams()
        return 
    end


    if     not id   then    sampAddChatMessage(tag.."�� �� ������� ID!",-1); return
    elseif not nick then    sampAddChatMessage(tag..'����� � ID: \"'..id..'\" �� � ����!',-1); return
    elseif id ~= autofind.playerId and autofind.process then autofind.inta = false end

    autofind.playerId = id
    autofind.playerNick = nick
    autofind.process = true
    sampAddChatMessage(tag.."������ �� ������� "..autofind.playerNick.."["..autofind.playerId.."] "..green_color.."������",-1)
end

function cmd_org(arg)
    local id = arg:match('(.+)')
    local nick = ''

    id = arg:match('(.+)')
    if id then nick = checkPlayerOnline(id) end

    if not id then          sampAddChatMessage(tag.."�� �� ������� ID!",-1)
    elseif not nick then    sampAddChatMessage(tag.."����� � ID: "..id.." �� � ����!",-1)
    else
        org_checker.playerId = id
        org_checker.playerNick = nick
        org_checker.color = getColor(id)

        sampAddChatMessage(tag.."������� ����� ������ "..blue_color..org_checker.playerNick.."["..org_checker.playerId.."]"..white_color..", ��� ����� ��������� �����.",-1)
        sampAddChatMessage(tag.."�� ���������� �������, ���� ��� �����!",-1)
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

    if not id then          sampAddChatMessage(tag.."�� �� ������� ID!",-1)
    elseif not nick then    sampAddChatMessage(tag.."����� � ID: "..id.." �� � ����!",-1)
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

    if not id then          sampAddChatMessage(tag.."�� �� ������� ID!",-1)
    elseif not nick then    sampAddChatMessage(tag.."����� � ID: "..id.." �� � ����!",-1)
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
    table.insert(org_checker.find_organizations, {name = "���", index = 32})
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
		sampAddChatMessage(tag..'���� � ����������� �� ������. ������ ���������� �����������!',-1)
    else
        local file = io.open(pathes.config.settings, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
        		sampAddChatMessage(tag..'�� ������� ������� ���� � �����������. ������ ���������� �����������!',-1)
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					settings = loaded
            		sampAddChatMessage(tag..'��������� ������� ���������!',-1)
				else
            		sampAddChatMessage(tag..'�� ������� ������� ���� � �����������. ������ ���������� �����������!',-1)
				end
			end
        else
            settings = default_settings
            sampAddChatMessage(tag..'�� ������� ������� ���� � �����������. ������ ���������� �����������!',-1)
        end
    end
end
function save_settings(status)
    local file, errstr = io.open(pathes.config.settings, 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
        if status then sampAddChatMessage(tag..'��������� ������� ���������!', -1) end
        return result
    else
        if status then sampAddChatMessage(tag..'�� ������� ��������� ��������� �������, ������: '..errstr, -1) end
        return false
    end
end

function downloadResources()
    print("�������� ������� ��������...")
    createDirectory(pathes.config.resources)
    for _type, object in pairs(resources) do
        print("���������: ".._type)
        for name, res in pairs(object) do
            if not doesFileExist(res.path) then
                local ok, err = pcall(function()
                    downloadUrlToFile(res.url, res.path, function(success) end)
                end)
                if ok then print(name.." ������� ���������!")
                else print("������ ��� �������� "..name..": "..err) end
            end
        end
    end
    print("�������� ������� ��������: ������� ���������!")
end

local russian_characters = {
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
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
        elseif ch == 168 then -- �
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
        elseif ch == 184 then -- �
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

            local title = u8'���������� ������'
            imgui.OpenPopup(title)
            if imgui.BeginPopupModal(title, nil, imgui.WindowFlags.NoResize) then
                local chapter_list = {}
                for _, article in ipairs(settings.asu.articles) do
                    table.insert(chapter_list, article.name)
                end
                table.insert(chapter_list, u8'����� ������')
                local chapters = imgui.new['const char*'][#chapter_list](chapter_list)
                
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'������').x / 2)
                imgui.Text(u8'������')
                imgui.PushItemWidth(-1)
                imgui.Combo(u8'##chapters', buff.combo.add_asu, chapters, #chapter_list)
                imgui.PopItemWidth()

                if buff.combo.add_asu[0] == #chapter_list-1 then
                    imgui.PushItemWidth(-1)
                    imgui.InputTextWithHint('##add_asu_name', u8'�������� ������ �������.', buff.text.add_asu_name, sizeof(buff.text.add_asu_name), imgui.InputTextFlags.AutoSelectAll)
                    imgui.PopItemWidth()
                end
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'����� ������:').x / 2)
                imgui.Text(u8'����� ������:')
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint('##add_asu_text', u8'����� ������ ��� ������ �������.', buff.text.add_asu, sizeof(buff.text.add_asu), imgui.InputTextFlags.AutoSelectAll)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'������� �������:').x / 2)
                imgui.Text(u8'������� �������:')
                imgui.PushItemWidth(-1)
                imgui.SliderInt('##', buff.int.add_asu, 1, 6)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - 140)  
                if imgui.Button(u8'���������', imgui.ImVec2(140, 24)) then
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
                if imgui.Button(u8'�������', imgui.ImVec2(140, 24)) then
                    imgui.CloseCurrentPopup()
                    flag = false
                end
            end
        end
        if modalname == 'asu' then
            imgui.SetNextWindowSize(imgui.ImVec2(sw/3, sh/3 - 20), imgui.Cond.Always)

            local title = u8'�������������� ������ ##asu'
            imgui.OpenPopup(title)
            if imgui.BeginPopupModal(title, nil, imgui.WindowFlags.NoResize) then
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8"������: "..'"'..name..'"').x / 2)
                imgui.Text(u8"������: "..'"'..name..'"')
                imgui.Separator()
                
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'����� ������:').x / 2)
                imgui.Text(u8'����� ������:')
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint('##edit_asu_text', u8'����� ������ ��� ������ �������.', buff.text.edit_asu, sizeof(buff.text.edit_asu), imgui.InputTextFlags.AutoSelectAll)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'������� �������:').x / 2)
                imgui.Text(u8'������� �������:')
                imgui.PushItemWidth(-1)
                imgui.SliderInt('##', buff.int.edit_asu, 1, 6)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - 140)  
                if imgui.Button(u8'���������', imgui.ImVec2(140, 24)) then
                    editAsu(name, text, star, str(buff.text.edit_asu), buff.int.edit_asu[0])
                    imgui.CloseCurrentPopup()
                    flag = false
                end
                imgui.SameLine()
                if imgui.Button(u8'�������', imgui.ImVec2(140, 24)) then
                    imgui.CloseCurrentPopup()
                    flag = false
                end
            end
            imgui.EndPopup()
        end
        if modalname == 'dm' then
            imgui.SetNextWindowSize(imgui.ImVec2(sw/3, sh/3 - 20), imgui.Cond.Always)

            local title = u8'�������������� ������ ##dm'
            imgui.OpenPopup(title)
            if imgui.BeginPopupModal(title, nil, imgui.WindowFlags.NoResize) then
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8"������: "..'"'..name..'"').x / 2)
                imgui.Text(u8"������: "..'"'..name..'"')
                imgui.Separator()
                
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'����� ������:').x / 2)
                imgui.Text(u8'����� ������:')
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint('##edit_dm_text', u8'����� ������ ��� ������ �������� ��� ����������.', buff.text.edit_dm, sizeof(buff.text.edit_dm), imgui.InputTextFlags.AutoSelectAll)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'����� ���������:').x / 2)
                imgui.Text(u8'����� ���������:')
                imgui.RadioButtonIntPtr(u8'����. �������', buff.radioInt.form_dm, 0)
                imgui.SameLine()
                imgui.Text('                        |                    ')
                imgui.SameLine()
                imgui.RadioButtonIntPtr(u8'����������', buff.radioInt.form_dm, 1)
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - 140)  
                if imgui.Button(u8'���������', imgui.ImVec2(140, 24)) then
                    editDm(name, text, form, str(buff.text.edit_dm), buff.radioInt.form_dm[0])
                    imgui.CloseCurrentPopup()
                    flag = false
                end
                imgui.SameLine()
                if imgui.Button(u8'�������', imgui.ImVec2(140, 24)) then
                    imgui.CloseCurrentPopup()
                    flag = false
                end
            end
            imgui.EndPopup()
        end
        if modalname == 'dm_add' then
            imgui.SetNextWindowSize(imgui.ImVec2(sw/3, sh/2.5 - 10), imgui.Cond.Always)

            local title = u8'���������� ������'
            imgui.OpenPopup(title)
            if imgui.BeginPopupModal(title, nil, imgui.WindowFlags.NoResize) then
                local chapter_list = {}
                for _, article in ipairs(settings.dm.articles) do
                    table.insert(chapter_list, article.name)
                end
                table.insert(chapter_list, u8'����� ������')
                local chapters = imgui.new['const char*'][#chapter_list](chapter_list)
                
                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'������').x / 2)
                imgui.Text(u8'������')
                imgui.PushItemWidth(-1)
                imgui.Combo(u8'##chapters', buff.combo.add_dm, chapters, #chapter_list)
                imgui.PopItemWidth()

                if buff.combo.add_dm[0] == #chapter_list-1 then
                    imgui.PushItemWidth(-1)
                    imgui.InputTextWithHint('##add_dm_name', u8'�������� ������ �������.', buff.text.add_dm_name, sizeof(buff.text.add_dm_name), imgui.InputTextFlags.AutoSelectAll)
                    imgui.PopItemWidth()
                end
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'����� ������:').x / 2)
                imgui.Text(u8'����� ������:')
                imgui.PushItemWidth(-1)
                imgui.InputTextWithHint('##add_dm_text', u8'����� ������ ��� ���������� ��� ��������.', buff.text.add_dm, sizeof(buff.text.add_dm), imgui.InputTextFlags.AutoSelectAll)
                imgui.PopItemWidth()
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - imgui.CalcTextSize(u8'����� ���������:').x / 2)
                imgui.Text(u8'����� ���������:')
                imgui.RadioButtonIntPtr(u8'����. �������', buff.radioInt.form_dm, 0)
                imgui.SameLine()
                imgui.Text('                        |                    ')
                imgui.SameLine()
                imgui.RadioButtonIntPtr(u8'����������', buff.radioInt.form_dm, 1)
                imgui.Separator()

                imgui.SetCursorPosX(imgui.GetWindowWidth()/2 - 140)  
                if imgui.Button(u8'���������', imgui.ImVec2(140, 24)) then
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
                if imgui.Button(u8'�������', imgui.ImVec2(140, 24)) then
                    imgui.CloseCurrentPopup()
                    flag = false
                end
            end
        end
    end)
end

--======================================== ������������� mimgui =============================================--

imgui.OnInitialize(function()
    -- ������
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 16, config, iconRanges) -- solid - ��� ������, ��� �� ���� thin, regular, light � duotone


    -- Images
    fbi_logo = imgui.CreateTextureFromFile(resources.images.logo.path)


    -- ������
    -- local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    -- impact26 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\impact.ttf', 26, _, glyph_ranges)
    -- impact16 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\impact.ttf', 16, _, glyph_ranges)
    -- calibri58 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\calibri.ttf', 56, _, glyph_ranges)

    -- �����
    style()
end)


--===================================== mimgui ���� =========================================================--

-- ������� ����
local mw = imgui.OnFrame(function() return buff.window.main[0] end, function(player)
    player.HideCursor = false

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.6, sh*0.7), imgui.Cond.Always)

    imgui.Begin(u8'FBI Helper', buff.window.main, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

        imgui.BeginChild('tabs', imgui.ImVec2(200, -1), true)
            if imgui.PageButton(page == 1, faicons('HOUSE'),              u8'������� ����') then            page = 1 end
            if imgui.PageButton(page == 2, faicons('STAR'),               u8'����� ������ [/asu]') then     page = 2 end
            if imgui.PageButton(page == 3, faicons('USER_XMARK'),         u8'����� demoute [/dm]') then     page = 3 end
            if imgui.PageButton(page == 4, faicons('NOTE_STICKY'),        u8'�������') then                 page = 4 end 
            if imgui.PageButton(page == 5, faicons('WALKIE_TALKIE'),      u8'����������� [/dep]') then      page = 5 end
            if imgui.PageButton(page == 6, faicons('TERMINAL'),           u8'��� �������') then             page = 6 end
            if imgui.PageButton(page == 99, faicons('LIST'),              u8'������� ����������') then      page = 99 end
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild('workspace', imgui.ImVec2(-1, -1), true, imgui.WindowFlags.NoScrollbar)
            local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()    
            if     page == 1 then
                local logo_size = { x = 325, y = 325 }
                imgui.SetCursorPos(imgui.ImVec2(x/2-logo_size.x/2, y/20))
                imgui.Image(fbi_logo, imgui.ImVec2(logo_size.x, logo_size.y))

                local info_text = u8"������: "..thisScript().version.." | "..u8"�����: "..u8"Joe Davidson"
                imgui.SetCursorPos(imgui.ImVec2(imgui.CalcTextSize(info_text).x*0.05, y-imgui.CalcTextSize(info_text).y*1.5))
                imgui.Text(info_text)

                local btn_text = u8"�������� �� ������"
                imgui.SetCursorPos(imgui.ImVec2(x-imgui.CalcTextSize(btn_text.."._.").x, y-imgui.CalcTextSize(btn_text).y*2.1))
                if imgui.Button(btn_text) then
                    -- todo
                end
                imgui.TextHovered(u8"���������� � ����������.")

            elseif page == 2 then       -- | ASU
                imgui.SetCursorPosX(x/5)
                imgui.InputTextWithHint('##asu', faicons('MAGNIFYING_GLASS')..u8' �����', buff.text.find_asu, sizeof(buff.text.find_asu), imgui.InputTextFlags.AutoSelectAll)
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
                            imgui.TextHovered(u8("�������: "..chapter.star.." ������� �������"))
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
                            imgui.TextHovered(u8"��� �������� ������ ����������\n������ ��������� �������.")
                        end
                    end
                end
            elseif page == 3 then       -- | DM
                if settings.dm.status == 0 then
                    local text1 = u8'� ��� ��� ������� � ������� �����������!'
                    local text2 = u8'����������� �������� 6+ ����. [� ���: '..settings.player.rang_number..']'
                    local text3 = u8"������������� ������, ���� ��������, ��� ��� ������."

                    imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text1).x/2, y/2-20))
                    imgui.Text(text1) 
                    
                    imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text2).x/2, y/2))
                    imgui.Text(text2) 
                    
                    imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text3).x/2, y/2+20))
                    imgui.Text(text3)
                    return
                end

                imgui.SetCursorPosX(x/5)
                imgui.InputTextWithHint('##dm', faicons('MAGNIFYING_GLASS')..u8' �����', buff.text.find_dm, sizeof(buff.text.find_dm), imgui.InputTextFlags.AutoSelectAll)
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
                            local sanctions = {[0] = u8'����. �������', [1] = u8'����������'}
                            imgui.TextHovered(u8"�������: "..sanctions[chapter.form])
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
                            imgui.TextHovered(u8"��� �������� ������ ����������\n������ ��������� �������.")
                        end
                    end
                end
            elseif page == 4 then       -- | NotePad
                if imgui.InputTextMultiline('##notepadText', buff.text.notepad, sizeof(buff.text.notepad), imgui.ImVec2(-1, -1)) then -- EROR: (declaration specifier expected near '<eof>') imgui.InputTextMultiline("##MyMultilineInput", TextMultiLine, 256)
                    saveNote(u8(str(buff.text.notepad)))
                end     
            elseif page == 5 then
                imgui.Text(u8'� ����������!')
            elseif page == 6 then       -- | Chat Commands
                local text =  
[[
����-����� ������:
���������: /afind [id]
����������: /afind | /afind [last_id]

������ ����������� ������:
���������: /org [id]

����� ������ �������:
���������: /asu [id]

����� demoute | dismiss | gwarn:
���������: /dm [id]
]]

                imgui.Text(u8(text))
            elseif page == 99 then      -- | Update history
                local versions = updateinfo.versions
                for _, version in ipairs(versions) do
                    imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"������: "..version.num).x/2)
                    imgui.Text(u8"������: "..version.num)
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

--===================================== ��������������� mimgui ���� ===========================================--

-- ����� ������
local aw = imgui.OnFrame(function() return buff.window.asu[0] end, function(player)
    player.HideCursor = false

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.3, sh*0.7), imgui.Cond.Always)

    imgui.Begin(u8'FBI Helper ##asu', buff.window.asu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()

        imgui.SetCursorPosX(x/5)
        imgui.InputTextWithHint('##asu', faicons('MAGNIFYING_GLASS')..u8' �����', buff.text.find_asu, sizeof(buff.text.find_asu), imgui.InputTextFlags.AutoSelectAll)
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
                    imgui.TextHovered(u8("�������: "..chapter.star.." ������� �������"))
                end
            end
        end
    imgui.End()
end)

-- ����� demoute
local dw = imgui.OnFrame(function() return buff.window.dm[0] end, function(player)
    player.HideCursor = false

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.3, sh*0.7), imgui.Cond.Always)

    imgui.Begin(u8'FBI Helper ##dm', buff.window.dm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()

        if settings.dm.status == 0 then
            local text1 = u8'� ��� ��� ������� � ������� �����������!'
            local text2 = u8'����������� �������� 6+ ����. [� ���: '..settings.player.rang_number..']'
            local text3 = u8"������������� ������, ���� ��������, ��� ��� ������."

            imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text1).x/2, y/2-20))
            imgui.Text(text1) 
            
            imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text2).x/2, y/2))
            imgui.Text(text2) 
            
            imgui.SetCursorPos(imgui.ImVec2(x/2 - imgui.CalcTextSize(text3).x/2, y/2+20))
            imgui.Text(text3)
            return
        end

        imgui.SetCursorPosX(x/5)
        imgui.InputTextWithHint('##dm', faicons('MAGNIFYING_GLASS')..u8' �����', buff.text.find_dm, sizeof(buff.text.find_dm), imgui.InputTextFlags.AutoSelectAll)
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
                    local sanctions = {[0] = u8'����. �������', [1] = u8'����������'}
                    imgui.TextHovered(u8"�������: "..sanctions[chapter.form])
                end
            end
        end
    imgui.End()
end)

local gwarns_dw = imgui.OnFrame(function() return buff.window.gwarns_dm[0] end, function(player)
    player.HideCursor = false

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.25, sh*0.16), imgui.Cond.Always)

    imgui.Begin(u8'! �������������� ! ##gwarns_dm', buff.window.gwarns_dm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
        local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()
    
        imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"��������� ���� 4-�� �����!").x/2)
        imgui.Text(u8"��������� ���� 4-�� �����!")
        imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"������ 3 ����. ��������?").x/2)
        imgui.Text(u8"������ 3 ����. ��������?")
        imgui.Separator()

        imgui.SetCursorPosX(x/2 - 110)
        if imgui.Button(u8'��', imgui.ImVec2(110, 25)) or isKeyJustPressed(VK_RETURN) then
            buff.window.gwarns_dm[0] = false
            for i = 1, 3 do
                
                sampSendChat(string.format('/gwarn %d %s', dm.playerId, dm.reason))
            end
        end
        imgui.SameLine()
        if imgui.Button(u8'���', imgui.ImVec2(110, 25)) or isKeyJustPressed(VK_ESCAPE) then buff.window.gwarns_dm[0] = false end

    imgui.End()
end)

local uw = imgui.OnFrame(function() return buff.window.update[0] end, function(player)
    player.HideCursor = false
    local max_y = sh*0.7

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(sw*0.3, -1), imgui.Cond.Always)
    
    imgui.Begin(u8'! ���������� ! ##updates', buff.window.update, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        local x, y = imgui.GetWindowWidth(), imgui.GetWindowHeight()
        local last_version = updateinfo.versions[#updateinfo.versions]

        imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"������: "..last_version.num).x/2)
        imgui.Text(u8"������: "..last_version.num)
        imgui.Separator()
        for _, line in ipairs(last_version.info) do
            imgui.TextWrapped(line..'\n')
        end
        imgui.Separator()

        imgui.SetCursorPosX(x/2 - imgui.CalcTextSize(u8"������  "..u8"  ����������!").x/2)
        if imgui.Button(u8"����������!") then
            downloadUrlToFile(updatelink, thisScript().path,
            function(id3, status1, p13, p23)
                if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                    print(string.format('��������� %d �� %d.', p13, p23))
                elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                    print('�������� ���������� ���������.')
                    sampAddChatMessage((tag..'���������� ���������!'),-1)
                    goupdatestatus = true
                    lua_thread.create(function() wait(500) thisScript():reload() end)
                end
                if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                    if goupdatestatus == nil then
                        sampAddChatMessage((tag..'���������� ������ ��������. �������� ���������� ������..'),-1)
                        update = false
                    end
                end
            end)
        end
        imgui.SameLine()
        if imgui.Button(u8"������") then 
            update = false 
            buff.window.update[0] = not buff.window.update[0]
            end
    imgui.End()

end)

--======================================== ���������� mimgui ������� ========================================--

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
    if title:find("��������") and pre_start then pre_start = false
        if text:find("{FFFFFF}���: {B83434}%[(.-)]") then
            settings.player.nickname = text:match("{FFFFFF}���: {B83434}%[(.-)]")
        end
        if text:find("{FFFFFF}���������: {B83434}(.+)%((%d+)%)") then
            local rang, rang_number = text:match("{FFFFFF}���������: {B83434}(.+)%((%d+)%)(.+)������� �������")
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
    if title:find("��������") and org_checker.process then 
        org_checkerDefaultParams()
        sampSendDialogResponse(dialogId, 0, nil, false)
        return false
    end
    
    if dialogId == 8744 and org_checker.process then
        if #org_checker.find_organizations == 0 then
            sampAddChatMessage(tag.."����� "..org_checker.playerNick.."["..org_checker.playerId.."] �� ������ � ������ �����������.",-1)
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

    if title:find("���������� ������") and org_checker.process then
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
                sampAddChatMessage(tag.."����� {"..org_checker.color.."}"..nick.."["..id.."] "..white_color.."������: "..org_checker.name.." | "..rang..".",-1)
                stopFind(dialogId)
                return false
            end
            
            if player:find("����������") then next = 26 end

            if player:find("���������") then
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

    -- sampev ����� demoute
    if string.find(text, '�� ������') and dm.use_dismiss then dm.use_dismiss = false
        buff.window.gwarns_dm[0] = not buff.window.gwarns_dm[0]
        return false
    end

    -- sampev AutoFind
    if string.find(text, "�������������� (%w+_%w+)%[(%d+)%] �������� �� �����") then
        local id = text:match("%[(%d+)%]")
        local nick = text:match("(%w+_%w+)")

        if nick ~= autofind.playerNick then
            sampAddChatMessage(tag.."����� "..autofind.playerNick.."["..autofind.playerId.."] ����� �� ����!",-1)
            sampAddChatMessage(tag.."������ �� ������� "..autofind.playerNick.."["..autofind.playerId.."] "..red_color.."�����������",-1)
            afindDefaultParams()
        end

        if autofind.inta then
            sampAddChatMessage(tag.."����� "..autofind.playerNick.."["..autofind.playerId.."] ����� �� ���������!",-1)
            autofind.inta = false
        end
        return false
    end

    if string.find(text, "����� ��������� �") then
        if not autofind.inta then 
            sampAddChatMessage(tag.."����� "..autofind.playerNick.."["..autofind.playerId.."] ����� � ��������!",-1)
            autofind.inta = true
        end
        return false
    end
end

--============================================== ���������� ����� ������� =====================================--

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
              print('v'..thisScript().version..': ���������� �� ���������.')
            end
          end
        else
          print('v'..thisScript().version..': �� ���� ��������� ����������.')
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end