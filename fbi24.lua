---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local, different-requires, undefined-field

script_name("FBI Helper")
script_author("Joe Davidson")
script_version("0.1.0")
script_description('Multifunctional FBI helper for Arizona Wednesday')

-- �������� �����������
require 'lib.moonloader'
require 'lib.sampfuncs'
local sampev = require 'lib.samp.events'

-- ���������
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

--============================================== ��� =======================================--

local blue_color = "{5A90CE}"
local white_color = "{FFFFFF}"
local red_color = "{F34336}"
local green_color = "{66FF4D}"

local tag = blue_color.."[ FBI Helper | "..red_color.."Joe Davidson "..blue_color.."]: "..white_color

--=================================== ���������� ��� �������� ===============================================--

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

--=================================== ��������� =============================================================--

function main()
    checkSampLoaded()
    autoupdate(updateScript.json_url)

    sampRegisterChatCommands()
    sampAddChatMessage(tag.."������ �������!",-1)

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

--============================================= SAMP EVENTS =================================================--

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
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
                sampAddChatMessage((tag..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('��������� %d �� %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('�������� ���������� ���������.')
                      sampAddChatMessage((tag..'���������� ���������!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((tag..'���������� ������ ��������. �������� ���������� ������..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, tag
              )
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