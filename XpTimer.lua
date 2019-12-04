XpTimer = LibStub("AceAddon-3.0"):NewAddon("XpTimer","AceConsole-3.0","AceComm-3.0", "AceTimer-3.0")

local XpTimer = _G.XpTimer
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local CreateFrame = CreateFrame


XpTimer.events = CreateFrame("Frame")

XpTimer.events:SetScript("OnEvent", function(self, event, ...)
	if not XpTimer[event] then
		return
	end

	XpTimer[event](XpTimer, ...)
end)


XpTimer.consoleOptions = {
	name = "XpTimer",
	type = 'group',
	args = {
		["show"] = {
			order = 12,
			name = "Show",
			desc = "Shows the main window",
			type = 'execute',
			func = function()
				XpTimer.MainWindow:Show()
			end,
			dialogHidden = true
		},
        ["pp"] = {
			order = 13,
			name = "pp",
			desc = "Shows the main window",
			type = 'execute',
			func = function()
				--local point, relativeTo, relativePoint, xOfs, yOfs = XpTimer.MainWindow.frame:GetPoint()
                --DEFAULT_CHAT_FRAME:AddMessage(point)  "BOTTOMRIGHT"
                --DEFAULT_CHAT_FRAME:AddMessage(relativeTo:GetName())
                --DEFAULT_CHAT_FRAME:AddMessage(relativePoint)
                --DEFAULT_CHAT_FRAME:AddMessage(xOfs)
                --DEFAULT_CHAT_FRAME:AddMessage(yOfs)
                --XpTimer.MainWindow.frame:SetPoint("BOTTOMRIGHT",-13,24)
			end,
			dialogHidden = true
		}
	}
}


function XpTimer:insert_space(frame)
    --local target_label = AceGUI:Create("Label")
    --target_label:SetText("   ")
    --frame:AddChild(target_label)
end

local SCALE_LENGTH = 6
local LABEL_SIZE = 12

function XpTimer:ChangeFontSize(f,size)
    local Font, Height, Flags = f.label:GetFont()
    f.label:SetFont(Font, size, Flags)
end

local Default_Profile = {
    profile = {
        MainWindow = {
            Position = {
				point = "CENTER",
                x = 0,
                y = 0
			}
        },
        History = {

        }
    }
}

function XpTimer:OnDragStop(frame)
    local point, relativeTo, relativePoint, xOfs, yOfs = XpTimer.MainWindow.frame:GetPoint()
    XpTimer.db.profile.MainWindow.Position.point = point
    XpTimer.db.profile.MainWindow.Position.x = xOfs
    XpTimer.db.profile.MainWindow.Position.y = yOfs
end

function XpTimer:OnHisShow()
    XpTimer:CreateHistoryWindow()

    XpTimer:HistoryShow(XpTimer.db.profile.History)

    XpTimer.HistoryWindow:Show()
end

function XpTimer:CreateMainWindow()

    local frame = AceGUI:Create("Frame2")
    frame:SetTitle("经验统计")
    frame:SetStatusText("停止")
    frame:SetLayout("List")
    frame:SetWidth(42*SCALE_LENGTH)
    frame:SetHeight(floor(32*SCALE_LENGTH))
    frame.frame:SetResizable(false)
    frame.frame["MoveFinished"] = XpTimer.OnDragStop
    frame.frame["OnHisButton"] = XpTimer.OnHisShow

    -- control group

    local ctl_btn_group = AceGUI:Create("SimpleGroup")
    ctl_btn_group:SetLayout("Flow")
    ctl_btn_group:SetWidth(floor(38*SCALE_LENGTH))
    frame:AddChild(ctl_btn_group)
    XpTimer.ctl_btn_group = ctl_btn_group

    XpTimer.btn_start = AceGUI:Create("Button")
    XpTimer.btn_start:SetText("开始")
    XpTimer.btn_start:SetWidth(floor(17*SCALE_LENGTH))
    XpTimer.btn_start:SetCallback("OnClick", XpTimer.OnStartBtn)
    ctl_btn_group:AddChild(XpTimer.btn_start)

    XpTimer.btn_stop = AceGUI:Create("Button")
    XpTimer.btn_stop:SetText("结束")
    XpTimer.btn_stop:SetWidth(floor(17*SCALE_LENGTH))
    XpTimer.btn_stop:SetCallback("OnClick", XpTimer.OnStopBtn)
    XpTimer.btn_stop:SetDisabled(true)
    ctl_btn_group:AddChild(XpTimer.btn_stop)



    XpTimer:insert_space(frame)


    local target_time_group = AceGUI:Create("SimpleGroup")
    target_time_group:SetLayout("Flow")
    target_time_group:SetWidth(floor(38*SCALE_LENGTH))
    frame:AddChild(target_time_group)
    XpTimer.target_time_group = target_time_group


    XpTimer.time_label = AceGUI:Create("Label")
    XpTimer.time_label:SetText("累计时间:0分0秒")
    XpTimer.time_label:SetWidth(36*SCALE_LENGTH)
    self:ChangeFontSize(XpTimer.time_label,LABEL_SIZE)
    target_time_group:AddChild(XpTimer.time_label)

    XpTimer:insert_space(frame)

    XpTimer.accumulate_label = AceGUI:Create("Label")
    XpTimer.accumulate_label:SetText("累计经验:0 击杀数量:0")
    XpTimer.accumulate_label:SetWidth(36*SCALE_LENGTH)
    self:ChangeFontSize(XpTimer.accumulate_label,LABEL_SIZE)
    frame:AddChild(XpTimer.accumulate_label)

    XpTimer:insert_space(frame)

    XpTimer.update_level_label = AceGUI:Create("Label")
    XpTimer.update_level_label:SetText("升级时间:0分 剩余经验:0")
    XpTimer.update_level_label:SetWidth(36*SCALE_LENGTH)
    self:ChangeFontSize(XpTimer.update_level_label,LABEL_SIZE)
    frame:AddChild(XpTimer.update_level_label)

    XpTimer:insert_space(frame)

    XpTimer.averge_label = AceGUI:Create("Label")
    XpTimer.averge_label:SetText("每怪经验:0 剩余怪数:0")
    XpTimer.averge_label:SetWidth(36*SCALE_LENGTH)
    self:ChangeFontSize(XpTimer.averge_label,LABEL_SIZE)
    frame:AddChild(XpTimer.averge_label)

    XpTimer:insert_space(frame)

    XpTimer.speed_icon = AceGUI:Create("Icon")
    XpTimer.speed_icon:SetImage("Interface\\AddOns\\XpTimer\\textures\\gray")
    XpTimer.speed_icon.image:SetPoint("BOTTOMLEFT", 0, 0)
    XpTimer.speed_icon:SetLabel("速度:0/小时")
    XpTimer.speed_icon:SetImageSize(36*SCALE_LENGTH,3*SCALE_LENGTH)
    XpTimer.speed_icon:SetWidth(36*SCALE_LENGTH)
    XpTimer.speed_icon:SetHeight(24)
    self:ChangeFontSize(XpTimer.speed_icon,12)
    frame:AddChild(XpTimer.speed_icon)


    XpTimer.MainWindow = frame
end

function XpTimer:OnStartBtn()


    XpTimer.init_data()
    XpTimer.current_state = 2 -- 1:停止 2：运行中
    XpTimer.btn_start:SetDisabled(true)
    XpTimer.btn_stop:SetDisabled(false)
    XpTimer.MainWindow:SetStatusText("运行中")

end


function XpTimer:OnStopBtn()
    XpTimer.current_state = 1
    XpTimer.btn_start:SetDisabled(false)
    XpTimer.btn_stop:SetDisabled(true)
    XpTimer.MainWindow:SetStatusText("停止")

    XpTimer:SaveCurrentData()
end



function XpTimer:OnUpdate()
    if(XpTimer.current_state ~= 2)then
        return
    end


    local current_time = GetTime()

    if((current_time - XpTimer.last_update_time) < 2 ) then
        return
    end

    XpTimer:Frame_update()

    XpTimer.last_update_time = current_time
end

function XpTimer:OnInitialize()

    local acedb = LibStub("AceDB-3.0")

    XpTimer.db = acedb:New("XpTimerDB",Default_Profile)

    --message(self.db.profile.MainWindow.Position.x)
    --self.db.profile.MainWindow.Position.x = 101
    --self.db.profile.MainWindow.Position.y = 9999


    LibStub("AceConfig-3.0"):RegisterOptionsTable("XpTimer Blizz", XpTimer.consoleOptions,"XpTimer")
    XpTimer:CreateMainWindow()
    XpTimer.MainWindow.frame:SetPoint(self.db.profile.MainWindow.Position.point,
            self.db.profile.MainWindow.Position.x,
            self.db.profile.MainWindow.Position.y)
    XpTimer.MainWindow:Show()
    XpTimer.current_state = 1
    XpTimer.events:SetScript("OnUpdate",XpTimer.OnUpdate)
end

function XpTimer:OnEnable()
    XpTimer.events:RegisterEvent("PLAYER_ENTERING_WORLD")
    XpTimer.events:RegisterEvent("PLAYER_XP_UPDATE")
    XpTimer.events:RegisterEvent("PLAYER_LEVEL_UP")
    XpTimer.events:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
    XpTimer.events:RegisterEvent("PLAYER_LOGOUT")

end

function XpTimer:OnDisable()

end

function XpTimer:PLAYER_ENTERING_WORLD()
    --local current_xp = UnitXP("player")
    --message("hello "..current_xp)

    --XpTimer:init_data()
    --
    --message(XpTimer.start_time)
end

function XpTimer:PLAYER_LOGOUT()
    if(XpTimer.current_state == 2)then
        XpTimer:OnStopBtn()
    end
end

function XpTimer:init_data()
    XpTimer.start_time = GetTime()
    XpTimer.start_time_t = date("%y/%m/%d %H:%M")
    XpTimer.start_exp = UnitXP("player")
    XpTimer.max_exp = UnitXPMax("player")
    XpTimer.current_level = UnitLevel("player")
    XpTimer.all_exp = 0
    XpTimer.kill_num = 0
    XpTimer.last_update_time = GetTime()
end

function XpTimer:SaveCurrentData()

    local current_data = {}
    local current_time = GetTime()
    current_data["time"] = XpTimer.start_time_t
    current_data["place"] = GetZoneText()
    current_data["time_long"] = floor(current_time - XpTimer.start_time)
    current_data["level"] = XpTimer.current_level
    current_data["exp"] = XpTimer.all_exp
    current_data["kill_num"] = XpTimer.kill_num


    local seconds = current_time - XpTimer.start_time
    local speed_exp_second = (XpTimer.all_exp/seconds)
    speed_exp_second = speed_exp_second * 100
    speed_exp_second = floor(speed_exp_second + 0.5)
    speed_exp_second = speed_exp_second/100
    local speed_exp_hour = speed_exp_second*3600

    current_data["exp_speed"] = speed_exp_hour

    table.insert(XpTimer.db.profile.History,1,current_data)
end

function XpTimer:Frame_update()



    local current_level = UnitLevel("player")

    -- time
    local current_time = GetTime()
    local seconds = current_time - XpTimer.start_time
    local ret_minutes = (floor(seconds / 60))
    local ret_seconds = (floor(seconds % 60))


    -- xp
    local current_exp = UnitXP("player")
    local exp_up = 0
    if(current_level == XpTimer.current_level) then
        exp_up = current_exp - XpTimer.start_exp
        XpTimer.start_exp = current_exp
    else
        exp_up = current_exp + ( XpTimer.max_exp -  XpTimer.start_exp)
        XpTimer.start_exp = current_exp
        XpTimer.current_level = current_level
        XpTimer.max_exp = UnitXPMax("player")
    end

    XpTimer.all_exp = XpTimer.all_exp + exp_up

    local speed_exp_second = (XpTimer.all_exp/seconds)
    speed_exp_second = speed_exp_second * 100
    speed_exp_second = floor(speed_exp_second + 0.5)
    speed_exp_second = speed_exp_second/100
    local speed_exp_hour = speed_exp_second*3600

    -- level up time
    local time_to_up_second = 0
    if(speed_exp_second >= 1)then
        time_to_up_second = (XpTimer.max_exp - current_exp)/speed_exp_second
    end
    local time_to_up_min = floor(time_to_up_second/60)

    -- kill_num
    local averge_exp = 0
    local require_num = 0
    if(XpTimer.kill_num >= 1)then
        averge_exp = floor(XpTimer.all_exp/XpTimer.kill_num)
        require_num = (XpTimer.max_exp - current_exp)/averge_exp
    end


    -- update frame
    XpTimer.time_label:SetText(string.format("累计时间:%d分%d秒",ret_minutes,ret_seconds))
    XpTimer.accumulate_label:SetText(string.format("累计经验:%d 击杀数量:%d",XpTimer.all_exp,XpTimer.kill_num))
    XpTimer.update_level_label:SetText(string.format("升级时间:%d分 剩余经验:%d",time_to_up_min,(XpTimer.max_exp - current_exp)))
    XpTimer.averge_label:SetText(string.format("每怪经验:%d 剩余怪数:%d",averge_exp,require_num))


    local icon_img = ""

    if(speed_exp_hour <= 10000) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\gray"
    elseif(speed_exp_hour >10000 and speed_exp_hour <= 17000) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\green"
    elseif(speed_exp_hour >17000 and speed_exp_hour <= 24000) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\yellow"
    elseif(speed_exp_hour >24000 and speed_exp_hour <= 30000) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\blue"
    elseif(speed_exp_hour >30000 and speed_exp_hour <= 50000) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\red"
    elseif(speed_exp_hour >50000) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\purple"
    end

    XpTimer.speed_icon:SetImage(icon_img)
    local icon_len = 36*SCALE_LENGTH

    XpTimer.speed_icon:SetLabel(string.format("速度:%d/小时",speed_exp_hour,per))
    XpTimer.speed_icon:SetImageSize(icon_len,3*SCALE_LENGTH)
    XpTimer.speed_icon:SetWidth(36*SCALE_LENGTH)
    XpTimer.speed_icon:SetHeight(24)

end

function XpTimer:PLAYER_XP_UPDATE()

    if (XpTimer.current_state ~= 2) then
        return
    end

    XpTimer:Frame_update()
end


function XpTimer:PLAYER_LEVEL_UP()
    if (XpTimer.current_state ~= 2) then
        return
    end

    XpTimer:Frame_update()
end

function XpTimer:CHAT_MSG_COMBAT_XP_GAIN()
    if (XpTimer.current_state ~= 2) then
        return
    end
    XpTimer.kill_num = XpTimer.kill_num + 1
    XpTimer:Frame_update()
end

