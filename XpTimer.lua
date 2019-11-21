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
				message("hello world")
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

function XpTimer:CreateMainWindow()

    local frame = AceGUI:Create("Frame2")
    frame:SetTitle("经验统计")
    --frame:SetStatusText("停止")

    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("List")
    frame:SetWidth(42*SCALE_LENGTH)
    frame:SetHeight(floor(33*SCALE_LENGTH))
    frame.frame:SetResizable(false)


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

    --XpTimer.btn_pause = AceGUI:Create("Button")
    --XpTimer.btn_pause:SetText("暂停")
    --XpTimer.btn_pause:SetWidth(115)
    --XpTimer.btn_pause:SetCallback("OnClick", XpTimer.OnPauseBtn)
    --XpTimer.btn_pause:SetDisabled(true)
    --ctl_btn_group:AddChild(XpTimer.btn_pause)

    XpTimer.btn_stop = AceGUI:Create("Button")
    XpTimer.btn_stop:SetText("结束")
    XpTimer.btn_stop:SetWidth(floor(17*SCALE_LENGTH))
    XpTimer.btn_stop:SetCallback("OnClick", XpTimer.OnStopBtn)
    XpTimer.btn_stop:SetDisabled(true)
    ctl_btn_group:AddChild(XpTimer.btn_stop)


    XpTimer:insert_space(frame)

    -- target set group
    local target_set_group = AceGUI:Create("SimpleGroup")
    target_set_group:SetLayout("Flow")
    target_set_group:SetWidth(floor(38*SCALE_LENGTH))
    frame:AddChild(target_set_group)
    XpTimer.target_set_group = target_set_group

    local tgt_set_label = AceGUI:Create("Label")
    tgt_set_label:SetText("目标设置(经验/小时)")
    tgt_set_label:SetWidth(20*SCALE_LENGTH)
    self:ChangeFontSize(tgt_set_label,LABEL_SIZE)
    target_set_group:AddChild(tgt_set_label)
    XpTimer.tgt_set_label = tgt_set_label

    --local tgt_edt_group = AceGUI:Create("SimpleGroup")
    --tgt_edt_group:SetWidth(360)
    --tgt_edt_group:SetLayout("Flow")
    --target_set_group:AddChild(tgt_edt_group)

    XpTimer.tgt_set_editbox = AceGUI:Create("EditBox")
    XpTimer.tgt_set_editbox:SetWidth(16*SCALE_LENGTH)
    XpTimer.tgt_set_editbox:SetCallback("OnEnterPressed", XpTimer.OnSetTargetBtn)
    target_set_group:AddChild(XpTimer.tgt_set_editbox)

    --local tgt_ensure_btn = AceGUI:Create("Button")
    --tgt_ensure_btn:SetText("确定")
    --tgt_ensure_btn:SetCallback("OnClick", XpTimer.OnSetTargetBtn)
    --tgt_ensure_btn:SetWidth(80)
    --tgt_edt_group:AddChild(tgt_ensure_btn)


    XpTimer:insert_space(frame)


    local target_time_group = AceGUI:Create("SimpleGroup")
    target_time_group:SetLayout("Flow")
    target_time_group:SetWidth(floor(38*SCALE_LENGTH))
    frame:AddChild(target_time_group)
    XpTimer.target_time_group = target_time_group

    -- information label
    XpTimer.target_label = AceGUI:Create("Label")
    XpTimer.target_label:SetText("目标:0")
    XpTimer.target_label:SetWidth(18*SCALE_LENGTH)
    self:ChangeFontSize(XpTimer.target_label,LABEL_SIZE)
    target_time_group:AddChild(XpTimer.target_label)

    XpTimer.time_label = AceGUI:Create("Label")
    XpTimer.time_label:SetText("时间:0分0秒")
    XpTimer.time_label:SetWidth(18*SCALE_LENGTH)
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
    XpTimer.update_level_label:SetText("升级剩余时间:0分 剩余经验:0")
    XpTimer.update_level_label:SetWidth(36*SCALE_LENGTH)
    self:ChangeFontSize(XpTimer.update_level_label,LABEL_SIZE)
    frame:AddChild(XpTimer.update_level_label)

    XpTimer:insert_space(frame)

    XpTimer.averge_label = AceGUI:Create("Label")
    XpTimer.averge_label:SetText("平均经验/击杀:0 剩余击杀数量:0")
    XpTimer.averge_label:SetWidth(36*SCALE_LENGTH)
    self:ChangeFontSize(XpTimer.averge_label,LABEL_SIZE)
    frame:AddChild(XpTimer.averge_label)

    XpTimer:insert_space(frame)

    XpTimer.speed_icon = AceGUI:Create("Icon")
    XpTimer.speed_icon:SetImage("Interface\\AddOns\\XpTimer\\textures\\gray")
    XpTimer.speed_icon.image:SetPoint("BOTTOMLEFT", 0, 0)
    XpTimer.speed_icon:SetLabel("速度:0/小时(%0)")
    XpTimer.speed_icon:SetImageSize(36*SCALE_LENGTH,3*SCALE_LENGTH)
    XpTimer.speed_icon:SetWidth(36*SCALE_LENGTH)
    XpTimer.speed_icon:SetHeight(26)
    self:ChangeFontSize(XpTimer.speed_icon,12)
    frame:AddChild(XpTimer.speed_icon)

    frame.closebutton:Hide()
    --frame:Show()
    XpTimer.MainWindow = frame
end

function XpTimer:OnStartBtn()

    XpTimer.init_data()
    XpTimer.current_state = 2 -- 1:停止 2：运行中
    XpTimer.btn_start:SetDisabled(true)
    XpTimer.btn_stop:SetDisabled(false)
    C_Timer.After(3, XpTimer.TimerFeedback)
    --XpTimer.MainWindow:SetStatusText("运行中")

end

--function XpTimer:OnPauseBtn()
--    XpTimer.current_state = 2
--    XpTimer.btn_pause:SetText("继续")
--end

function XpTimer:OnStopBtn()
    XpTimer.current_state = 1
    XpTimer.btn_start:SetDisabled(false)
    XpTimer.btn_stop:SetDisabled(true)
    --XpTimer.MainWindow:SetStatusText("停止")
end

function XpTimer:OnSetTargetBtn()
    local target = XpTimer.tgt_set_editbox:GetText()
    XpTimer.target_exp = tonumber(target)
    XpTimer.target_label:SetText(string.format("目标:%d",XpTimer.target_exp))
end

function XpTimer:TimerFeedback()

    if(XpTimer.current_state == 1)then
        return
    end
    

    XpTimer:Frame_update()


    if(XpTimer.current_state == 2)then
        C_Timer.After(3, XpTimer.TimerFeedback)
    end
end


function XpTimer:OnInitialize()

    LibStub("AceConfig-3.0"):RegisterOptionsTable("XpTimer Blizz", XpTimer.consoleOptions,"XpTimer")
    XpTimer:CreateMainWindow()

    XpTimer.MainWindow:Show()
    XpTimer.current_state = 1
end

function XpTimer:OnEnable()
    XpTimer.events:RegisterEvent("PLAYER_ENTERING_WORLD")
    XpTimer.events:RegisterEvent("PLAYER_XP_UPDATE")
    XpTimer.events:RegisterEvent("PLAYER_LEVEL_UP")
    XpTimer.events:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

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

function XpTimer:init_data()
    XpTimer.start_time = GetTime()
    XpTimer.start_exp = UnitXP("player")
    XpTimer.max_exp = UnitXPMax("player")
    XpTimer.current_level = UnitLevel("player")
    XpTimer.all_exp = 0
    XpTimer.kill_num = 0

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
    --XpTimer.kill_num = XpTimer.kill_num + 1
    local averge_exp = 0
    local require_num = 0
    if(XpTimer.kill_num >= 1)then
        averge_exp = floor(XpTimer.all_exp/XpTimer.kill_num)
        require_num = (XpTimer.max_exp - current_exp)/averge_exp
    end


    -- update frame
    XpTimer.time_label:SetText(string.format("时间:%d分%d秒",ret_minutes,ret_seconds))
    XpTimer.accumulate_label:SetText(string.format("累计经验:%d 击杀数量:%d",XpTimer.all_exp,XpTimer.kill_num))
    XpTimer.update_level_label:SetText(string.format("升级剩余时间:%d分 剩余经验:%d",time_to_up_min,(XpTimer.max_exp - current_exp)))
    XpTimer.averge_label:SetText(string.format("平均经验/击杀:%d 剩余击杀数量:%d",averge_exp,require_num))


    local icon_img = ""
    local per = floor(speed_exp_hour*100/XpTimer.target_exp)

    if(per <= 50) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\gray"
    elseif(per >50 and per <= 60) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\green"
    elseif(per >60 and per <= 75) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\yellow"
    elseif(per >75 and per <= 90) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\blue"
    elseif(per >90 and per <= 100) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\red"
    elseif(per >100) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\purple"
    end

    XpTimer.speed_icon:SetImage(icon_img)
    local icon_len = 0
    if(per >= 100)then
        icon_len = 36*SCALE_LENGTH
    else
        icon_len = floor(36*SCALE_LENGTH*per/100)
    end
    XpTimer.speed_icon:SetLabel(string.format("速度:%d/小时(%d%%)",speed_exp_hour,per))
    XpTimer.speed_icon:SetImageSize(icon_len,3*SCALE_LENGTH)
    XpTimer.speed_icon:SetWidth(36*SCALE_LENGTH)
    XpTimer.speed_icon:SetHeight(26)

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


--Sandbox = { }
--
--function Sandbox:HelloWorld()
--    message("Hello World!")
--end
--
--function Sandbox:HideGryphons()
--    MainMenuBarLeftEndCap:Hide()
--    MainMenuBarRightEndCap:Hide()
--end
--
--Sandbox:HelloWorld()